# IGC native iOS architecture proposal

Status: Proposed for Product Manager review
Task: IGC-004 — iOS / Shared
Date: 2026-07-28
Scope: Architecture only. No iOS project, Swift source, dependency, or generated artifact is created by this proposal.

## 1. Executive recommendation

Build Investment Growth Calculator as a single SwiftUI application target with an internal domain core, first-party frameworks only, and a local Codable scenario store. The calculation engine is a pure Double (IEEE 754 binary64) component with no UI, persistence, formatting, or feature-availability dependency. Its tests consume the repository's authoritative calculation fixture directly.

This is proportionate to an offline, iPhone-primary calculator with a small local record set. It preserves the expensive boundaries that matter: independent Swift fixture parity, portable version-1 scenarios, serialised persistence, and a tiny feature-availability seam. It deliberately excludes packages, third-party SDKs, accounts, networking, CloudKit, StoreKit, analytics, remote flags, and a backend.

The accepted iOS 17 minimum, local-first privacy model, UK English/GBP presentation, annual-only native detail, retained internal monthly rows, future multiple-scenario comparison, and maintained PWA drive this recommendation. The PWA is evidence only; React and browser localStorage are not native architecture.

## 2. Platform and toolchain assumptions

| Topic | Proposal | Authority or rationale |
| --- | --- | --- |
| Deployment | iOS 17 minimum; iPhone-primary and adaptive iPad compatibility. | Accepted IGC-D013. This runtime choice is separate from the App Store upload SDK. |
| Upload toolchain | Use Xcode required at submission. At this proposal date Apple requires Xcode 26 or later with iOS 26 SDK or later for App Store Connect uploads. | Apple requirement: [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/). Recheck before implementation/release. |
| Swift mode | Use the newest language mode supported by that release Xcode; recommend Swift 6 mode and concurrency diagnostics from project creation. | Recommendation: establishes explicit ownership early; does not raise deployment target. |
| UI | SwiftUI with system controls/navigation. | Accepted direction. Common controls receive baseline semantics; custom views still need labels/values: [Accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals). |
| Data and tests | Foundation, Observation/SwiftUI, Swift Testing, XCTest/XCUI. | Apple supports modern unit/integration and UI-test combinations: [Adding tests](https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project). |
| Dependencies | No third-party runtime/build dependency in 1.0. | No demonstrated gap; avoids supply-chain, privacy, licence, and migration cost. |

Use Foundation for JSON, dates, file I/O, and formatting; SwiftUI for UI/navigation; Swift Testing for pure/unit/integration tests; XCTest/XCUI for UI automation. Apple describes ModelContainer as SwiftData storage owner and ModelContext as its fetch/change/save context ([ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer), [ModelContext](https://developer.apple.com/documentation/swiftdata/modelcontext)). Those first-party facilities are evaluated below but not selected for the initial store.

Do not add a package merely for routing, DI, charts, JSON Schema validation, formatting, persistence, or test parameterisation. A later dependency needs a separate decision showing a Foundation/SwiftUI capability gap, maintenance evidence, licence/privacy impact, and removal plan.

## 3. Future app structure and dependency direction

This is a proposed future layout only; IGC-004 does not create it.

~~~
igc-ios/
  InvestmentGrowthCalculatorApp/
    App/                         # composition root / scene assembly
    Core/
      Domain/                    # canonical types, validation, presets
      Calculation/               # pure engine, rows, target analysis
      Persistence/               # ScenarioStore / Codable file implementation
      Presentation/              # formatting / chart projection
      Availability/              # AppFeature / local-free provider
    Features/
      Calculator/ Results/ SavedScenarios/ Education/ Settings/
    SharedUI/                    # small reusable native controls/chart shell
    Resources/                   # app copy and assets only
  InvestmentGrowthCalculatorTests/
    Calculation/ Validation/ Persistence/ FeatureState/
    Resources/                   # references root shared assets
  InvestmentGrowthCalculatorUITests/
    Flows/ Accessibility/ AdaptiveLayouts/
~~~

Keep one app module plus two test bundles initially. Enforce Core/Features boundaries through imports and review rather than creating packages before there is a measured ownership/build problem. If a Calculation package is justified later, extract the already-pure core and its tests.

~~~mermaid
flowchart TB
  App["App composition"] --> Features["SwiftUI feature views and feature state"]
  Features --> Core["Domain + Calculation + Presentation + Availability"]
  Features --> Store["ScenarioStore protocol"]
  Store --> File["Codable Application Support file"]
  Core --> Contract["Shared specs and fixture test resources"]
  UnitTests["Swift Testing / XCTest"] --> Core
  UnitTests --> Store
  UITests["XCTest UI tests"] --> Features
~~~

### Ownership, state, and navigation

- The composition root owns ScenarioStore, local-free FeatureAvailability, formatter configuration, and feature factories. Inject protocols/values, not global singletons.
- A feature owns its screen/editing state. Calculator state owns draft text/canonical input and validation; Results state owns a validated snapshot/result; saved-scenario state owns list loading and mutation feedback. UI observable state is main-actor isolated.
- Domain inputs/results are immutable values. The engine returns a fresh result and never observes a view or writes a store.
- Do not create a global view model. Do not hide simple state behind generic reducers or DI framework.
- Use a root TabView for Calculator, Saved scenarios, Education, and Settings/About. Each tab owns a NavigationStack and typed route enum. Calculator pushes Results; Results pushes Annual detail. Saved scenarios loads a scenario into Calculator and presents save/rename/delete confirmations.
- Reserve a 1.1 comparison route in SavedScenarios but do not expose or implement it in 1.0.
- On iPad keep the same routes/semantics. NavigationSplitView is optional only when width supports it and IGC-005 specifies it; otherwise the iPhone stack remains valid.

### Placement rules

| Concern | Home | Boundary |
| --- | --- | --- |
| Presets / Custom detection | Core/Domain | Stable IDs, decimal assumptions, and match-all-controlled-fields semantics are shared. Display copy is presentation. |
| Validation | Core/Domain | Validate canonical numeric values before engine. Text parsing, focus, announcements are feature concerns. |
| Engine / annual aggregation | Core/Calculation | Binary64-only; no strings, rounding, persistence, or SwiftUI. |
| Target analysis | Core/Calculation beside growth engine | Compare optional today target with final after-fee real result. |
| GBP / rate formatting | Core/Presentation | en_GB/GBP display only; formatted text never feeds engine/persistence. |
| Chart projection | Core/Presentation | Annual rows to display series; chart is never calculation evidence. |
| Scenario mapping | Core/Persistence | Maps portable V1 values without making file keys the contract. |

## 4. Calculation port and parity

### Canonical model

Use Double for raw inputs, intermediate values, results, and rows. Use Int for years, months, periods, and indexes. Use String-backed Codable enums for:

~~~
ContributionFrequency: weekly | monthly | annual
CompoundFrequency: daily | monthly | quarterly | annual
ContributionTiming: start | end
Currency: GBP
PresetID: global-index-diy | balanced-portfolio | equity-heavy-portfolio | savings-account
~~~

CalculationInputV1, MonthlyRow, AnnualRow, and CalculationResult are values. Scenario inputs use canonical GBP amounts and decimal annual rates, so 0.07 means 7%. Form text is separate presentation state. Reject non-finite and semantically invalid candidates before calculation; never silently clamp, coerce, or round them.

### Required behaviour

1. Convert nominal APR and fee to effective monthly rates using selected compounding formulas, with exact zero for zero annual rate. Convert contributions weekly as C times 52 divided by 12, monthly as C, annual as C divided by 12.
2. Simulate exactly years times 12 plus months periods. Maintain no-fee and after-fee paths. For start timing add contribution before growth; for end timing grow and fee before contribution. Fees are post-growth asset drag, never APR subtraction. No intermediate rounding.
3. Emit every monthly row, including partial final years. Aggregate annual rows from those rows, preserving opening balance, sums, row-end balances, fee totals, and partial final row. iOS 1.0 simply does not render monthly rows.
4. Discount final and annual row-end nominal totals by (1 + inflationRate) to elapsed years. Finals use totalMonths/12; annual rows use row-end period/12. This is horizon discounting, not cash-flow-by-cash-flow adjustment.
5. Keep target analysis outside the engine. Compare targetToday with finalBalanceAfterFeesReal and calculate nominal horizon context only for explanation.

Use a dedicated, tested formatter for en_GB/GBP that applies the contract's two-decimal halfway-away-from-zero rule. Persist/fixture-compare raw values before formatting. Formatted strings are never reused as calculation values.

### Shared fixture consumer

The test target references these root resources by Xcode target membership:

- ../../shared/fixtures/calculation-v1.json
- ../../shared/schemas/calculation-fixture-v1.schema.json
- ../../shared/schemas/scenario-v1.schema.json

The fixture stays a single maintained source; its test-bundle copy is build output, not another fixture. Do not transcribe expected values into Swift.

The loader decodes the fixture envelope and requires contractVersion 1 plus GBP; it fails clearly for missing, malformed, unsupported, or incompatible fixture/schema resources. Parameterise every calculation and semantic validation case from JSON. A test-side structural check verifies expected fixture/schema identifiers before parity assertions.

For normal raw numeric fields, pass when:

~~~
abs(actual - expected) <= max(0.000001, 1e-12 * max(1, abs(expected)))
~~~

Effective monthly rates use absolute tolerance 1e-14. Counts, identifiers, enum values, validation validity, and validation error fields match exactly. A fixture failure is a Shared-contract candidate until independently reproduced in TypeScript; never generate new expectations from Swift.

## 5. Scenario model, persistence, and migration

### Options evaluated

| Option | Benefits | Costs / failure modes | Decision |
| --- | --- | --- | --- |
| SwiftData | First-party query/change tracking, migrations, SwiftUI integration. | More modelling than one small document needs; storage evolution coupled to app models; requires deliberate configuration to avoid accidental CloudKit behaviour. | Defer; re-evaluate for relationships, query scale, or approved sync. |
| Codable Application Support file | Direct auditable V1 mapping; small record set; simple recovery/future interchange boundary. | Must explicitly serialise I/O, atomic replacement, corruption handling, and migration dispatch. | **Recommend for 1.0.** |

### Recommended store

Define a narrow ScenarioStore protocol and one actor-backed CodableScenarioStore. It owns a private Application Support directory and versioned private store document, serialises reads/writes, and returns immutable snapshots. Main-actor feature state awaits store operations and turns errors into recovery UI; no view reaches the file system.

The private document contains a store envelope and ScenarioV1 records. Filename, directory, and envelope keys are not interchange format. Mapping to shared/schemas/scenario-v1.schema.json is exact:

| Contract field | Native rule |
| --- | --- |
| schemaVersion | New native V1 scenarios use integer 1; unknown versions are never decoded as V1. |
| id | New record uses UUID().uuidString and remains opaque/stable. |
| name | Trim; require non-empty and at most 120 portable characters. |
| currency | Explicit GBP always; no picker/conversion. |
| inputs | Validated canonical Double values and stable enum raw values. |
| presetId | Stable ID or nil for Custom; presentation name is never contract identity. |
| targetToday | Optional non-negative raw GBP Double; absence differs from zero. |
| timestamps | Generate Date, encode ISO 8601 UTC, preserve when loading. |

Write a temporary document then atomically replace the prior file. Request an appropriate system data-protection class and treat unavailable/protected storage as recoverable failure; do not claim a cryptographic property beyond the device's configured protection and backup environment. Retain the last readable document until replacement completes.

### CRUD, recovery, backup, and future comparison

- **Save:** validate, trim/limit name, generate UUID/timestamps, atomically persist, then report success.
- **Rename:** validate name, update updatedAt only, atomically persist.
- **Load:** decode/validate V1 and copy inputs/target/preset into calculator; loading does not mutate record.
- **Duplicate:** fresh UUID/timestamps; localised Copy name within 120 characters; retain values/preset semantics.
- **Delete:** confirmation removes one ID. **Reset all** uses a separate destructive confirmation and only reports success after mutation/reload.
- **Failure:** offer Try again and non-destructive recovery. For corruption preserve unreadable data under a recovery filename, explain it, and start empty only after the user chooses recovery/reset. Never overwrite sole evidence automatically.
- **Comparison:** retain multiple IDs. Future 1.1 can hold two transient IDs; it is not persisted/exposed in 1.0.

The V1 document should participate in normal device backup unless the later privacy/release review decides otherwise. It must not claim iCloud sync. “On this device” means no app-operated account/sync service, not necessarily that operating-system backup cannot contain the data. Settings/About and IGC-008 need clear copy on this distinction/reset's local effect.

PWA localStorage is browser-origin storage with browser lifecycle/error behaviour, not a native API or migration source. Current PWA records lack schemaVersion, explicit currency, and stable presetId. Browser migration/fallback/rollback remains separately tested **Web** work. Native V1 preserves portable meanings without assuming import, export, or automatic interchange.

## 6. Feature availability and deferred premium

Introduce only:

~~~
AppFeature: calculator, scenarios, annualDetail, education
FeatureAvailability: isAvailable(AppFeature) -> Bool
LocalFreeAvailability: true for the 1.0 feature set
~~~

Views ask an injected availability value. Calculation, persistence, and domain types do not depend on it. There are no locked states in 1.0 and no StoreKit types, product IDs, receipt handling, account model, network interface, backend protocol, remote flag, or premium screen.

Expand only after a separately accepted commercial decision defines paid value, platform availability, purchase type, entitlement source of truth, restore/support/migration policy, privacy impact, and current App Store rules. A later provider must not retrofit payments into calculation or scenario schema.

## 7. Privacy, security, and data lifecycle

Local data includes financial-planning inputs, scenario names, optional targets, timestamps, appearance/onboarding preferences, and app-local selection state. This remains user data even without account, analytics, or network traffic.

- Store only accepted-feature data. Do not log raw scenarios, balances, names, or targets to console, crash breadcrumbs, or diagnostics.
- Use sandboxed Application Support and explicit system data protection. Effective protection depends on device lock, passcode, OS, and backup settings; verify disclosures later rather than claim absolute encryption.
- No network permission, tracking, contacts, account connection, or remote configuration is needed. Offline calculation/scenarios continue without network.
- Delete/reset removes app-local records deterministically and explains that backup has its own lifecycle. A failed reset never leaves UI claiming data was erased.
- Corrupt/unsupported data is recovery, not permission to discard it. Preserve a diagnostic copy where practical and offer retry, retain, or deliberate reset.

IGC-008 must verify current App Privacy answers, support/privacy URLs, protection/backup claims, projection/disclaimer copy, age-rating inputs, and submission rules. This proposal makes no App Store compliance claim.

## 8. Accessibility and adaptive interface architecture

| Concern | Architecture rule | Design / QA follow-through |
| --- | --- | --- |
| Dynamic Type | Semantic styles, wrapping layouts, scrolling content, no fixed-height cards/tables. | IGC-005 hierarchy; IGC-006 accessibility-size testing. |
| VoiceOver | Labelled controls; hierarchy defines reading order; combine value/unit/context when one fact; chart summary. | Design labels/hints; QA swipe order/actions. |
| Validation | Feature owns field errors; predictable focus; announce changes without keystroke noise. | Design wording; QA focus/announcement evidence. |
| Charts | Supplementary only: text summary and annual table. | Design nonvisual treatment; QA validates without sight. |
| Contrast / appearance | Semantic system colours; no colour-only meaning; light/dark. | Design contrast; QA both appearances. |
| Motion | Respect Reduce Motion; no motion-only explanation. | Design alternative; QA toggles setting. |
| Touch / keyboard | System controls, adequate targets, predictable numeric keyboard/return behaviour. | QA keyboard/focus evidence. |
| Adaptive iPad | Same routes/controls; width-aware without truncation or mandatory split view. | QA portrait/landscape/adaptive widths. |

SwiftUI baseline semantics do not remove the need for deliberate modifiers/user testing ([Apple accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)). Do not reproduce the PWA's disabled pinch zoom or chart-without-equivalent-data risks.

## 9. Test strategy

Use many isolated tests, fewer integration tests, and focused UI tests. Apple recommends this combination ([Xcode testing](https://developer.apple.com/documentation/xcode/testing)).

| Layer | Evidence / owner | Environment |
| --- | --- | --- |
| Calculation fixture | Swift Testing loads shared JSON: every scalar/checkpoint/count/conversion/tolerance. | No simulator where target permits; also iOS CI. |
| Invariants | Zero rates, timing, partial years, 720 months, finite outputs, fee/inflation ordering, no intermediate rounding. | No simulator. |
| Validation / presets | Bounds/error fields, Custom default, deliberate selection, edit returns Custom. | No simulator. |
| Target / presentation | Target comparison, annual projection, formatter rounding separate from engine. | No simulator. |
| Codec / store | V1 encoding, IDs/timestamps, unknown-version refusal, corruption, failure injection, CRUD/reset/migrations. | Temp directory/fakes; iOS integration too. |
| Feature state | Calculator/results/save flows, navigation intent, availability fakes. | No simulator. |
| SwiftUI integration | Route transitions, annual-only detail, saved-scenario mutation/load. | Simulator; device smoke test. |
| UI / accessibility | XCUI flows, Dynamic Type, labels/values, keyboard/focus, dark mode, Reduce Motion, chart alternative. | Simulator plus VoiceOver/device checks. |
| Adaptive / release | iPhone/iPad widths, offline lifecycle, reset/recovery, privacy/submission evidence. | Simulator plus device/review checklist. |

Swift Testing suits unit/integration targets while XCTest remains UI automation; both coexist ([Adding tests](https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project)).

If a fixture fails in Swift and TypeScript, it is potential **Shared** specification work: do not change expectations. Swift-only fixture failures are iOS parity defects. Navigation, UI, file protection, VoiceOver, and iPad failures are iOS-only unless their root cause changes shared semantics.

## 10. Delivery sequence after approval

1. **Project foundation (iOS):** confirm owner-controlled bundle/product naming, signing input, current Xcode requirement, test targets, and direct shared-resource references.
2. **Parity core (Shared / iOS):** types, validation, presets, engine, rows, target analysis, full fixture consumer, and independent Swift/TypeScript reporting.
3. **Vertical slice (iOS):** accessible calculator draft, validated calculation, primary after-fee result, annual text/table alternative, local-free availability, simulator/device checkpoint.
4. **Scenario lifecycle (iOS):** Codable store, V1 mapping, save/load/rename/duplicate/delete/reset, recovery UI, integration tests.
5. **Secondary content (iOS):** education, assumptions/disclaimer, settings/about, appearance/onboarding, accessibility/adaptive polish.
6. **Release evidence (iOS / Shared):** both fixture consumers, QA inventory, device checks, privacy/App Store review, release checklist. Do not add comparison, export, sync, or premium incidentally.

IGC-005 defines hierarchy/copy/chart/accessibility presentation before slice polish. IGC-006 turns these layers into reproducible QA evidence. IGC-008 verifies current privacy/App Store requirements before submission. IGC-004 does not start/deliver those tasks.

## 11. Alternatives and expensive-to-reverse choices

| Choice | Recommendation | Alternative / consequence | Reversibility / timing |
| --- | --- | --- | --- |
| Persistence | Actor-backed Codable V1 document. | SwiftData for relationships/query scale/approved sync adds complexity now. | Moderately reversible with importer. Decide before saved beta. |
| Navigation / state | Feature-local observable state and typed stacks under small tabs. | Global view model couples screens; reducer/DI framework lacks evidence. | Local refactor. Decide route map before creation. |
| Modules / packages | One app module/test bundles; logical folders. | Multiple packages add targets/resources/configuration. | Extract pure Core later. Decide start before creation. |
| Dependencies | First-party only. | Router/chart/DI/schema packages add lifecycle/privacy/licence risk. | Costly migration. Policy before creation; exceptions need approval. |
| Scenario migration | Native V1 immediately; preserve/reject unknown; no web migration. | Silent legacy-web interpretation risks semantic drift/loss. | Test every future native migration; web separate. |
| Fixture packaging | Test target references root shared resources. | Copying values causes drift; network fixture violates local scope. | Low-cost if source remains direct. |
| Availability seam | Small local-free FeatureAvailability. | No seam spreads future checks; commerce design now is unused risk. | Cheap now/costly later. Decide before features. |
| Bundle/product naming | Display name Investment Growth Calculator; module convention InvestmentGrowthCalculator; reverse-DNS pattern owned by team. | Historical compound-toolkit exposes tooling identity; inventing identifiers/team/SKU is invalid. | Bundle ID costly after distribution. Owner confirms namespace, exact ID, team, SKU, app-group/iCloud IDs before creation. |

### Proposed decisions for Product Manager acceptance

1. Adopt this single-module, feature-folder SwiftUI structure and first-party-only dependency policy for native 1.0.
2. Adopt the actor-backed Codable Application Support scenario store for native V1; defer SwiftData unless later requirements justify it.
3. Adopt direct root shared test-resource consumption and specified tolerance/version failure behaviour as native parity gate.
4. Adopt local-free FeatureAvailability and defer richer entitlement architecture until a commercial decision.
5. Confirm owner-controlled identifiers/signing inputs before any Xcode project. Exact bundle ID, Developer Team, App Store SKU, app group, and iCloud capability intentionally remain undecided.

## Review checklist and references

No conflict among accepted scope, calculation, and scenario requirements was discovered. Product Manager should confirm the five proposed decisions, especially persistence/backup wording and owner-controlled identifiers. Designer, QA, and App Store Reviewer should review their dependencies in section 10.

Primary Apple references:

- [App Store upload SDK requirements](https://developer.apple.com/news/upcoming-requirements/)
- [SwiftData ModelContainer](https://developer.apple.com/documentation/swiftdata/modelcontainer)
- [SwiftData ModelContext](https://developer.apple.com/documentation/swiftdata/modelcontext)
- [Swift Testing](https://developer.apple.com/documentation/testing)
- [Adding tests to an Xcode project](https://developer.apple.com/documentation/xcode/adding-tests-to-your-xcode-project)
- [Xcode testing strategy](https://developer.apple.com/documentation/xcode/testing)
- [SwiftUI accessibility fundamentals](https://developer.apple.com/documentation/swiftui/accessibility-fundamentals)

Apple requirements are rechecked at implementation/release. All other choices are recommendations pending Product Manager review.
