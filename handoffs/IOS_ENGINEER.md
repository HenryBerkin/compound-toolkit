# iOS Engineer handoff

## IGC-007 native vertical slice completed

Status: **Done — accepted and integrated**.

The native vertical slice is implemented on
`codex/igc-007-native-vertical-slice` in
`/private/tmp/igc-007-native-vertical-slice`, created from exact base
`dc521186d9d0f30add2f45c06cb02d6d98d35195`. The exact implementation commit before
the first reporting-only handoff update is
`ab45c935853fc4edab0fce2d25291d74255b49d1`
(`feat(ios): build native calculator vertical slice`).

Product Manager review returned **Changes requested**. All seven scoped findings were
corrected in
`76b1e39db01830642b4de7481ea7efc85ae568f1`
(`fix(ios): address IGC-007 review findings`), and the task is returned to **Ready for
review**:

- Currency input now applies a strict en-GB grammar before locale-aware Decimal
  conversion. It accepts ungrouped digits, correctly grouped commas or UK grouping
  spaces, one decimal point, and an optional leading pasted `£`. It rejects malformed
  grouping, signs, exponents, non-finite names/overflow, non-ASCII digits, mixed
  grouping, typed percent signs, and embedded/repeated currency characters without
  stripping or coercion.
- Preset reconciliation parses only APR, inflation, annual fee, and compounding.
  Invalid or edited principal, contribution, contribution frequency, duration, timing,
  or target no longer clears a deliberately selected matching preset.
- Next validates the current field before advancing; Done validates before keyboard
  dismissal; focus loss validates; and correction of a focused invalid field clears
  the resolved error without a success announcement. View projection still performs
  whole-form validation.
- Whole-form submission expands a collapsed target disclosure before scrolling to and
  focusing an invalid target.
- Remove target now presents a destructive confirmation alert. Cancel retains the
  draft; confirmation clears and collapses it. Its VoiceOver hint includes the current
  target value.
- Contribution timing uses the segmented picker only when its labels fit at standard
  Dynamic Type. `ViewThatFits` falls back to an accessible menu at narrow widths, and
  accessibility Dynamic Type selects the menu directly.
- The chart symbol scale explicitly maps after-fee points to circles and real-value
  points to diamonds, matching the visible and spoken descriptions.

The correction remained within Calculator/Projection and test scope. Persistence,
comparison, export, networking, premium, StoreKit, App Store, and all other deferred
work remain unchanged.

Product Manager re-review accepted all seven corrections after an independent 27/27
test run and Release simulator build. The specialist history is integrated into
`project/ios-migration-audit` by merge commit
`c26d25a13a65d47f487fc55cebaeb216b7a8eb62`. Nothing was pushed, archived, uploaded,
or submitted to App Store Connect.

### Delivered scope

- `igc-ios/InvestmentGrowthCalculator.xcodeproj` contains shared application,
  unit-test, and UI-test targets. The application minimum is iOS 17 and the device
  family is iPhone plus iPad.
- Application identity is `uk.co.mochadesigns.igc`, version `1.0` build `1`.
  Automatic signing is configured only for Team Name `Henry Berkin` / Team ID
  `2FKVFS8X67`; no Personal Team, capability, App Group, iCloud container, or
  entitlement was added.
- The application uses one first-party SwiftUI module with Foundation, Charts,
  SwiftUI, and UIKit only. There are no packages or third-party dependencies.
- Four stable tabs each own a `NavigationStack`. Calculator routes carry the validated
  immutable `ProjectionSnapshot` directly, preventing result-state races and retaining
  Calculator navigation state while switching tabs.
- Calculator launches with the explicit Custom baseline: £10,000 principal, £250
  monthly contribution, 7% APR, 3% inflation, 0.20% annual fee, monthly compounding,
  15 years, start-of-period timing, and no target.
- The visible slice validates on **View projection**, keeps invalid input on Calculator,
  focuses the first error, and routes only a valid snapshot to Projection.
- Projection prioritises after-fee balance, today’s-money context, optional raw target
  status, composition, fee impact, assumptions, and a two-series Charts view. Series
  differ by colour, solid/dashed line, and circle/diamond symbols. A factual text
  summary and annual-detail route provide non-chart alternatives.
- Annual detail exposes before-fee, after-fee, and real-value modes using truthful
  aggregate rows, including partial final years. Native monthly detail, persistence,
  save/CRUD, comparison, export, premium, StoreKit, sync, accounts, networking,
  analytics, remote configuration, backend, and App Store work remain deferred.
- Saved is an honest empty state; Education and Settings remain minimal. No unavailable
  Save, Compare, Export, or monthly-detail affordance is shown.

### Calculation and shared-contract implementation

The pure binary64 engine implements the accepted version-1 operation order without
intermediate rounding. It includes canonical domain models and enums, all accepted
presets, explicit validation boundaries, effective contribution/rate calculations,
monthly before-fee and after-fee paths, annual aggregation, nominal and real balances,
nominal fees, and raw target analysis. GBP and percentage presentation is fixed to the
accepted en-GB contract and rounds half away from zero only at display time.

Unit tests load these repository-root resources directly through Xcode resource paths;
they are not copied, regenerated, or hand-transcribed:

- `shared/fixtures/calculation-v1.json`
- `shared/schemas/calculation-fixture-v1.schema.json`
- `shared/schemas/scenario-v1.schema.json`

Direct fixture evidence covers contract version 1, GBP, 7 calculation cases, 8 monthly
checkpoints, 8 annual checkpoints, and 19 validation expectations. Additional tests
cover 1/12/13/720-period aggregation, zero rates, every contribution-frequency /
compounding / timing combination, no intermediate rounding, non-finite rejection,
deliberate preset transitions, sub-penny raw target classification, target independence,
fixed GBP formatting, and the local-free feature-availability seam.

### Toolchain and Apple requirement check

Executed toolchain:

- macOS 26.5 (25F5042g)
- Xcode 26.2 (17C52)
- Apple Swift 6.2.3 (`swiftlang-6.2.3.3.21`, `clang-1700.6.3.2`)
- iOS Simulator SDK 26.2

Apple’s current official upload requirement was checked at
`https://developer.apple.com/news/?id=ueeok6yw`: from 28 April 2026, uploads must be
built with Xcode 26 or later and an iOS 26 SDK or later. The executed toolchain meets
that requirement. No upload was attempted.

### Canonical verification

Debug simulator build passed:

```sh
xcodebuild -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/igc-007-derived \
  CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS=arm64 build
```

The corrected final combined test run passed **27/27**, with zero failures, skips, or
expected failures: 18 unit/fixture tests and 9 UI tests on iPhone 17 / iOS 26.2.
Canonical result bundle: `/private/tmp/igc-007-review-final.xcresult`.

```sh
xcodebuild -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination \
  'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
  -derivedDataPath /private/tmp/igc-007-review-derived \
  -resultBundlePath /private/tmp/igc-007-review-final.xcresult \
  CODE_SIGNING_ALLOWED=NO test
```

`xcrun xcresulttool get test-results summary` confirms `totalTestCount: 27`,
`passedTests: 27`, `failedTests: 0`, and `skippedTests: 0`.

New focused evidence consists of 4 parser/preset unit tests and 4 UI tests covering
validation lifecycle, collapsed-target expansion/focus, removal confirmation/Cancel,
and the accessibility-size timing menu. The first focused UI attempt passed 2/4 and
failed 2/4: one test reused an obscured stale field snapshot, while
`confirmationDialog` did not expose Cancel consistently. The confirmation was changed
to an alert, interactions were made unobscured, and the focused rerun passed 2/2 before
the complete 27/27 run.

Release simulator build passed store-bundle validation:

```sh
xcodebuild -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/igc-007-review-release-derived \
  CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS=arm64 build
```

### Device, appearance, accessibility, locale, and offline evidence

- Small iPhone: iPhone 16e / iOS 26.2 — Calculator → Projection → annual detail passed.
- Standard iPhone: iPhone 17 / iOS 26.2 — full 19-test canonical run passed.
- Large iPhone: iPhone 17 Pro Max / iOS 26.2 — target status and tab-state flow passed.
- iPad: iPad Pro 13-inch (M5) / iOS 26.2 — Calculator → Projection → annual detail
  passed.
- Light/default text: covered by the canonical suite.
- Dark appearance + accessibility-extra-extra-extra-large text + Reduce Motion:
  Calculator → Projection → annual detail passed. The first automation attempt exposed
  a partially obscured large-text tap; the final test helper requires controls to be
  wholly above the tab bar and the rerun passed.
- VoiceOver preferences enabled: target field, combined below-target status text,
  chart alternative, tab controls, and retained Calculator navigation were exposed
  through the accessibility hierarchy; the focused target/tab test passed. Preferences
  were restored afterwards.
- French system language/locale: explicit GBP output remained `£`; portrait Projection
  rotated into supported landscape and retained Calculator and Settings tab access.
- Offline/local-only: the complete Calculator → Projection → annual-detail flow uses
  only in-process inputs and bundled resources. Source and optimized Release-binary
  inventory found no app networking API, network framework/symbol, endpoint, remote
  configuration, or web view. Simulator radio isolation is not exposed by supported
  `simctl`; this evidence establishes that the implemented flow has no network
  dependency without claiming an unavailable airplane-mode run.

An early UI run exposed a real route-state race that could show “Projection
unavailable.” The production fix makes typed Calculator routes own their immutable
validated snapshot; the complete suite and device matrix passed after the fix.

### Privacy and release-binary inventory

The optimized Release app’s generated `Info.plist` confirms bundle ID
`uk.co.mochadesigns.igc`, version `1.0` / build `1`, iOS 17 minimum, en-GB development
region, and iPhone/iPad device families. `otool -L` reports application linkage only to
Foundation, Charts, SwiftUI, UIKit, Swift runtime libraries, Objective-C, and libSystem.
Source and undefined-symbol searches found no networking, storage, analytics, ad,
tracking, location, photo, contacts, calendar, health, camera, microphone, pasteboard,
StoreKit, CloudKit, Core Data, or SwiftData surface. The app contains no entitlements,
third-party SDKs, or `PrivacyInfo.xcprivacy`.

For this implemented slice the privacy-manifest determination is **not required**:
there is no data collection, tracking, privacy-affecting third-party SDK, or used
required-reason API to declare. Re-run this inventory against a signed Release archive
before any future upload and add a manifest if later storage, persistence, analytics,
SDK, or required-reason API work changes the result.

### Skipped and follow-up

- Physical-device execution: skipped; no authorised physical-device run was made.
- StoreKit purchase/restore manual testing: skipped and not applicable; StoreKit,
  payments, premium, and receipt paths are absent by scope.
- Signed device archive, TestFlight, App Store Connect record, metadata, privacy
  questionnaire, submission, and upload: not run and remain out of scope.
- Product/legal review of financial-content wording remains a release gate from
  IGC-008.
- Before integration, review implementation commit
  `ab45c935853fc4edab0fce2d25291d74255b49d1`, re-run the canonical result command,
  and resolve any integration conflicts without changing shared fixtures or the PWA.

## IGC-004 completed proposal context

No native code exists. The completed proposal followed the revised standalone prompt
in `prompts/IGC-004-IOS-ARCHITECTURE.md`, based at
`3bf1e517636d543e368b610b8a006cafd271e836`; the earlier prompt remains withdrawn.

IGC-004 is Done and accepted in IGC-D014. The documentation-only proposal is
`docs/IOS_ARCHITECTURE.md`; its corrected specialist head is
`1940e3f95427f5fc0b3ca2dab07801e887650821` on
`codex/igc-004-ios-architecture`, based on
`3bf1e517636d543e368b610b8a006cafd271e836`.

The recommendation is a single SwiftUI app module with feature-local state, a pure
Swift binary64 calculation engine, direct test-bundle consumption of the version-1
shared fixture, an actor-backed Codable Application Support scenario store, and a
small local-free feature-availability seam. It defers SwiftData, packages, third-party
dependencies, StoreKit, accounts, networking, sync, analytics, remote configuration,
and backend work.

Native V1 scenarios map exactly to the portable schema: UUID opaque IDs, explicit GBP,
decimal rates, stable preset IDs, optional today-value target, and UTC timestamps.
Unknown future versions must fail safely and be preserved for recovery. PWA legacy
localStorage migration is a separately tested Web concern. Native comparison remains
deferred to 1.1; annual detail is native 1.0 only while monthly rows remain required in
the engine and parity tests.

## Accepted decisions and verification

Product Manager accepted the persistence choice, single-module and first-party
dependency policy, direct shared-resource parity gate, and local-free availability
seam. IGC-D018 fixes the native application bundle identifier as
`uk.co.mochadesigns.igc` and records Apple Developer Team Name `Henry Berkin` and Team
ID `2FKVFS8X67`. Do not use a different Team ID, Team Name, Personal Team, or
placeholder. App Store SKU waits until the App Store Connect record; App Groups and
iCloud remain absent from 1.0.

Verification completed: required project/specification/fixture/PWA evidence read;
official Apple primary sources checked for current upload SDK, data, testing, and
accessibility claims; all architecture sections present; cited Apple links opened;
`git diff --check` passed; no `igc-ios/`, Xcode project, Swift source, dependency, or
generated artifact was added; shared assets, accepted decisions, and PWA files remain
unchanged. No native build was run because native project creation is out of scope.

Before future implementation work, read the accepted behavioural inventory in
`docs/QA_PLAN.md` and preserve its direct-fixture gate and planned-versus-executed
evidence rules. Read the native hierarchy and interaction contract accepted under
IGC-D017 in `docs/DESIGN_SYSTEM.md`; implement no substitute onboarding, live-result,
overwrite, comparison, export, premium, or network semantics. IGC-008 is also accepted
under IGC-D016: read
`docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`, and
`docs/RELEASE_CHECKLIST.md` before project creation. Preserve the first-party-only,
local-only, no-unapproved-capabilities boundary and treat privacy manifest, export,
network, storage-protection, and archive assertions as evidence to establish from the
actual implementation rather than assumed compliance.

IGC-007 is Done, accepted, and integrated. Its current implementation and verification
evidence are recorded at the top of this handoff. Team Name `Henry Berkin`, Team ID
`2FKVFS8X67`, and bundle identifier `uk.co.mochadesigns.igc` remain fixed inputs.
