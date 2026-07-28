# IGC behavioural QA inventory

Status: Accepted under IGC-D015; implementation evidence updated through IGC-D019
Task: IGC-006 — Shared / iOS / Web
Scope: behavioural inventory plus explicitly recorded implementation evidence; planned
rows remain planned unless a dated task/gate says otherwise.

## 1. Strategy, language, and evidence

IGC releases must be correct before polished. Financial calculation, validation, raw
scenario values, and target meaning are shared contractual behaviour. iOS and Web must
prove their deliberately different capabilities without treating a browser quirk as a
native requirement. Principal risks are a silent formula/order change, JavaScript/Swift
binary64 drift, loss or misleading reporting of local scenarios, inaccessible results or
charts, an accidental online/premium dependency, and reporting planned iOS capability
as delivered.

| Ownership | Must prove |
| --- | --- |
| Shared | V1 contract/schema/fixture structure; canonical validation, presets, calculation, rows, target semantics, GBP and raw-value rules. |
| iOS | Independent Swift consumer, iOS 17+ offline native flow, annual-only presentation, V1 Codable store/recovery, SwiftUI navigation/accessibility/adaptation. |
| Web | Supported PWA calculation/regression, browser parsing/persistence/comparison/CSV, responsive and service-worker lifecycle/accessibility. |

### Labels

- **Approved behaviour** — accepted specification/decision and a release requirement.
- **Observed behaviour** — evidence from the current PWA; preserve only where it is supported Web scope and does not conflict with an accepted decision.
- **Known defect** — observed behaviour that conflicts with an approved requirement or documented risk; never a desired iOS behaviour.
- **Recommendation** — proposed coverage/environment/policy pending Product Manager approval; not a product commitment.
- **Deferred feature** — intentionally outside the release; test that it is absent or correctly represented, not as missing parity.

Test IDs are stable and do not encode implementation detail:

| Prefix | Area | Example |
| --- | --- | --- |
| `SH-CT-###` | shared contract/fixture | `SH-CT-001` |
| `SH-CAL-###`, `SH-VAL-###`, `SH-INV-###` | calculation, validation, invariant | `SH-CAL-014` |
| `SH-PRE-###`, `SH-SCN-###` | presets, portable scenario | `SH-PRE-004` |
| `IOS-...` | iOS planned cases | `IOS-STORE-012` |
| `WEB-...` | PWA regression | `WEB-PWA-009` |
| `REL-...` | release/manual evidence | `REL-A11Y-003` |

Test levels are contract, unit, invariant/metamorphic, integration, UI, accessibility,
exploratory, compatibility, and privacy/release review. A case can have more than one
level, but its primary owner and observable pass condition are recorded once.

| Result | Minimum evidence |
| --- | --- |
| Pass | ID, build/fixture version, environment, steps or automated run, observed raw/UI result, and artefact/log/screenshot where meaningful. |
| Fail | ID, expected versus actual, reproduction inputs, environment/build, severity, owner, and raw fixture values where applicable. |
| Blocked | ID, dependency/permission/environment preventing execution, attempts made, owner, and next action; not inferred pass. |
| Skipped | ID, explicit authorised reason and planned execution point. |
| Not applicable | ID plus accepted platform/version boundary, for example native 1.0 CSV. |

## 2. Requirements traceability and gates

The matrix is the minimum release trace. IGC-005 is accepted under IGC-D017; its rows
identify planned evidence and do not claim that an unbuilt interface passes.

| Authority / requirement | Suites | Gate / evidence |
| --- | --- | --- |
| Calculation V1, raw fixture, binary64, no intermediate rounding | `SH-CT-001–009`, `SH-CAL-001–018`, `IOS-CT-001–009`, `WEB-CT-001–009` | calculation-core parity |
| Bounds and exact canonical error fields | `SH-VAL-001–024`, client parser cases | calculation-core parity; vertical slice |
| Custom baseline and curated presets | `SH-PRE-001–008`, `IOS-PRE-001–008`, `WEB-PRE-001–008` | vertical slice / Web regression |
| Optional today-value target | `SH-TGT-001–006`, `IOS-RES-004`, `WEB-RES-004` | vertical slice |
| Native design and interaction system (IGC-D017) | `IOS-NAV-001–006`, `IOS-UI-001–006`, `IOS-RES-001–005`, `IOS-STORE-001–018`, `IOS-A11Y-001–016` | vertical slice / scenario lifecycle / accessibility readiness |
| Monthly calculation; iOS annual-only / Web monthly+CSV | `SH-CAL-015`, `IOS-RES-005`, `WEB-BRK-001–008` | core parity; platform capability gate |
| Web comparison; iOS comparison deferred to 1.1 | `WEB-CMP-001–008`, `IOS-DEF-001` | Web regression / iOS scope gate |
| Scenario V1 meaning and platform persistence | `SH-SCN-001–012`, `IOS-STORE-001–018`, `WEB-STORE-001–012` | scenario lifecycle |
| Local-first/offline/no network or entitlement | `IOS-OFF-001–004`, `WEB-PWA-001–006`, `REL-PRIV-001–006` | release candidate |
| Accessibility/adaptive iOS and Web | `IOS-A11Y-001–016`, `WEB-A11Y-001–012`, `REL-A11Y-001–006` | accessibility readiness |
| Delete/reset, storage/backup wording and privacy boundary | `IOS-STORE-014–018`, `WEB-STORE-010–012`, `REL-PRIV-001–006` | scenario/release gate |
| Deferred premium boundary, no locked state | `IOS-DEF-002–004`, `REL-SCOPE-001–004` | architecture/vertical-slice/release gate |

IGC-D017 fixes the approved component hierarchy, explicit View projection flow,
Projection title, load/Save-as-new semantics, deterministic scenario sorting, System
appearance default, two-series chart, raw target status, schema-valid scenario names,
and safe preset-mismatch presentation. Map these to the listed native suites and visual
review without promoting optional deferred details into requirements. IGC-008 is
accepted under IGC-D016; perform its detailed release trace when release tests are
implemented, retaining every binary-dependent item as planned rather than passed
evidence.

## 3. Shared fixture parity

TypeScript and future Swift test targets consume `shared/fixtures/calculation-v1.json` directly. `shared/schemas/calculation-fixture-v1.schema.json` and `shared/schemas/scenario-v1.schema.json` are structural inputs. No client transcribes or regenerates expected values. The loader requires `contractVersion: 1` and `currency: "GBP"`, validates fixture shape, rejects missing/malformed/unsupported resources clearly, and records asset hash/version in test output.

| ID | Contract consumer assertion |
| --- | --- |
| `SH-CT-001` | Verify fixture/schema identifiers, V1, and GBP before calculation assertions. |
| `SH-CT-002` | Parameterise `custom-baseline`, `zero-growth-weekly-partial`, `monthly-end-one-month`, `daily-start-fee-partial`, `quarterly-end-annual-contribution`, `annual-start-principal-only`, and `maximum-duration`. |
| `SH-CT-003` | Compare every scalar, monthly rate/contribution, counts, and supplied monthly/yearly checkpoint. |
| `SH-CT-004` | Compare all nineteen validation cases, validity and exact canonical `errorFields`. |
| `SH-CT-005` | Match counts, enums, IDs, validity, and error fields exactly; do not use numeric tolerance for them. |
| `SH-CT-006` | Compare raw binary64 values before GBP/rate/chart formatting. |
| `SH-CT-007` | Confirm no test derives expectations from either engine or rewrites source fixtures. |
| `SH-CT-008` | Check scenario example/schema V1 separately from private storage format. |
| `SH-CT-009` | Fail with actionable unsupported-version/schema error and preserve source assets. |

For normal numbers use exactly `abs(actual - expected) <= max(0.000001, 1e-12 * max(1, abs(expected)))`.

Effective monthly rates use absolute tolerance `1e-14`; monthly contributions and all other normal raw fields use the general rule. A display-penny comparison is not parity evidence.

Triage first confirms fixture/schema identity and reproduces untouched inputs. If both consumers fail, stop expectation changes, log a potential **Shared** contract issue, and seek an accepted change decision. Swift-only is iOS parity; TypeScript-only is Web parity. Formatter/UI-only is platform-specific unless it changes shared canonical data. An accepted model change needs the Shared task, compatibility/version assessment, spec/schema/fixture update, both consumers, and changelog evidence.

Additional `SH-INV` tests complement, never replace, fixtures:

- `SH-INV-001–004`: zero APR/fee/inflation identities; zero-fee paths equal; zero APR with zero fee has balance = principal + effective contribution × periods.
- `SH-INV-005–007`: every contribution/compounding conversion; start timing is not below end timing for non-negative contribution/growth under like inputs.
- `SH-INV-008–010`: 1, 12, 13, and 720 period indexing/annual aggregation; period/year/month/cumulative values are continuous.
- `SH-INV-011–013`: fee/inflation ordering under positive scenarios; no-fee balance is at least after-fee; real equals nominal at zero inflation.
- `SH-INV-014–016`: deterministic repeat calculation, finite raw values at accepted extremes, and no row/scalar rounding before display.
- `SH-INV-017–019`: metamorphic equivalents: a monthly contribution equals the same converted canonical monthly value; contiguous period simulation preserves final path; target cannot alter engine rows/results.

## 4. Shared calculation, validation, parsing, and target inventory

`SH-VAL` validates canonical numeric candidates; `IOS-INPUT` and `WEB-INPUT` validate platform text parsing and accessible error presentation. Neither client may silently clamp/coerce, calculate non-finite input, or turn formatted display text into stored canonical values.

| IDs | Cases and expected semantic result |
| --- | --- |
| `SH-VAL-001–006` | Principal/contribution: 0, 0.01, £1bn max, negative, over-max, and both zero (only `principal` error). |
| `SH-VAL-007–012` | APR 0/9.99 valid; negative/over invalid; inflation 0/0.20 valid, negative/over invalid; fee 0/0.10 valid, negative/over invalid. |
| `SH-VAL-013–019` | Years non-negative integer; fractional/negative invalid; months integer 0–11; 0 total months invalid (`duration`); 1 and 720 valid; 721 invalid. |
| `SH-VAL-020–024` | Every `weekly`/`monthly`/`annual`, every `daily`/`monthly`/`quarterly`/`annual`, and both `start`/`end` are accepted only as canonical enums. |
| `SH-CAL-001–006` | Zero optional values, every frequency, fee formula/order, inflation divisor, contribution conversion, and start/end operations match the specification. |
| `SH-CAL-007–010` | One-month end formula; partial years; raw monthly rows/partial final annual row; annual aggregation derives from monthly rows. |
| `SH-CAL-011–014` | Daily/monthly/quarterly/annual rate and fee conversion; rates exactly zero for zero annual rate; fee is post-growth drag, never APR subtraction. |
| `SH-CAL-015–018` | Internal monthly rows for every valid duration, finite/complete 720 boundary, annual real row-end divisor, and no intermediate rounding. |

`IOS-INPUT-001–008` and `WEB-INPUT-001–010` cover empty/invalid/non-finite text (`NaN`, `Infinity`, exponent/overflow where platform permits), UK-English GBP entry, commas/spaces accepted by current Web currency parsing, decimal percent entry, whole-number duration, optional blank inflation/fee as canonical zero, and display rounding only at output. UK-English display is GBP two decimals and rates two decimals; exact halfway monetary values round away from zero. Web's permissive currency parsing is observed Web behaviour, not a portable model rule.

`SH-TGT-001–006`: absent target produces no analysis; `0` differs from absent and compares with `finalBalanceAfterFeesReal`; equal, above, and below are expressed correctly; future context is `targetToday × (1 + inflationRate)^(totalMonths / 12)`; target cannot mutate engine inputs/results. `WEB-INPUT-010` records current invalid target text silently removing analysis as a known Web defect/risk, not an approved rule.

## 5. Presets and Custom

| IDs | Required case |
| --- | --- |
| `SH-PRE-001` | Initial state is Custom, `presetId: null`, with £10,000 / £250 monthly / 7% / 3% / 0.20% / monthly / 15y0m / start and V1 baseline raw result. |
| `SH-PRE-002–005` | Deliberately select each stable ID and apply exact APR/inflation/fee/monthly compounding. Global Index applies 0.40%, not 0.20%. |
| `SH-PRE-006` | Edit any preset-controlled value and state becomes Custom; uncontrolled values do not fabricate a mismatch. |
| `SH-PRE-007` | Save/load/duplicate retain `presetId`/Custom truthfully; names are derived display copy, not identity. |
| `SH-PRE-008` | Unknown/mismatching preset ID is rejected/recovery-handled, never displayed as falsely active. |

`WEB-PRE-008` records the current selector mismatch (visual Global Index with 0.20% Custom inputs) as a **known Web defect**. Native implements `SH-PRE-001`, not this bug. A Web correction must preserve the baseline and browser data.

## 6. Scenario persistence and recovery

All scenario tests assert schema V1 meaning: opaque stable ID (new native UUID), trimmed non-empty name up to 120 portable characters, `currency: GBP`, decimal rates, optional non-negative `targetToday` with absence distinct from zero, stable `presetId` or null, and UTC ISO 8601 timestamps. Private file/localStorage keys and display copy are not contract identity. No cross-platform import, sync, account, or automatic legacy conversion is approved.

| iOS planned IDs | Required evidence |
| --- | --- |
| `IOS-STORE-001–005` | Save valid scenario; trim/reject name limits; load without mutation; rename changes only `updatedAt`; duplicate uses unique UUID/timestamps and legal Copy name. |
| `IOS-STORE-006–009` | Delete needs confirmation; reset-all needs distinct destructive confirmation; list supports multiple scenarios without comparison UI; IDs stay unique/stable. |
| `IOS-STORE-010–013` | Codable V1 round trip preserves raw fields; unknown version refuses without partial V1 decode; corrupt data is preserved for recovery; user chooses retry/retain/reset. |
| `IOS-STORE-014–016` | Temp-write/atomic replacement preserves last readable document on injected failure/interruption; protected/unavailable Application Support gives recovery UI; success only after durable mutation/reload. |
| `IOS-STORE-017–018` | Relaunch loads latest durable snapshot; reset failure cannot claim deletion. Settings says on-device/no app-operated sync while normal device backup may apply and is not iCloud sync. |

| Web IDs | Required evidence / current boundary |
| --- | --- |
| `WEB-STORE-001–006` | Current `cgt-scenarios` save/load/duplicate/delete/selection, generated IDs/timestamps, name/target/preset display, and no loss in supported UI. |
| `WEB-STORE-007–009` | Unavailable/quota/throwing localStorage and malformed JSON do not crash; visible state and subsequent mutation are truthful. |
| `WEB-STORE-010–012` | Legacy `presetName` records lacking schemaVersion/currency/presetId are explicitly legacy, not silently V1. Future migration needs separate read/fallback/rollback tests. |

## 7. Deliberate capability matrix

| Capability | Shared | iOS 1.0 | Supported PWA | Deferred |
| --- | --- | --- | --- | --- |
| Calculation/validation/target | V1 parity | Yes | Yes | — |
| Monthly calculation rows | Required | Internal only | Shown to 120 months | iOS display later |
| Annual detail | Required aggregation | Shown | Shown | — |
| Two-scenario comparison | Semantics remain shared | Not exposed | Supported | iOS 1.1 |
| CSV/share/export | No shared output format | No CSV/share | CSV, six decimals/current `compound-toolkit_` filename | native later |
| Persistence | V1 meanings | Codable Application Support | browser localStorage (legacy today) | migration/import/sync |
| Offline lifecycle | Local-first | native offline/relaunch | service-worker cache/update/install | deployment policy |
| Navigation/layout | Semantic outcomes | tabs/stacks/adaptive iPad | responsive single-page | bespoke iPad optional |
| Accessibility | Required outcomes | SwiftUI/VoiceOver/Dynamic Type | browser semantics/keyboard/zoom | IGC-005 refinements |
| Premium/availability | Free boundary | all local-free, no locks | free | premium/StoreKit/accounts |

`IOS-DEF-001–004` and `REL-SCOPE-001–004` verify absence/non-promotion of native comparison, monthly UI/CSV, accounts/sync/network/analytics/StoreKit/remote flags, and locked states. These are scope tests, not parity failures. Web service-worker lifecycle, install/update, and responsive navigation are platform behaviours, not native requirements.

## 8. Native feature and navigation inventory

IGC-007 now implements the Calculator-to-Projection, annual-detail, tab-navigation,
fixture, and local-free portions below. IGC-012 owns the still-planned scenario/store
portions; later milestones own secondary content and release evidence:

- `IOS-NAV-001–006`: Calculator, Saved scenarios, Education, Settings/About tabs; typed routes; Calculator → Results → Annual detail; saved-scenario load; tab switching retains feature-local draft state without stale result leakage.
- `IOS-UI-001–006`: draft text separate from canonical values; invalid errors/focus/recovery; validated results snapshot; annual-only detail; save/rename/delete confirmation/recovery; no local-free feature locked.
- `IOS-RES-001–005`: final after-fee KPI, nominal/real/fee context, target outcomes, disclaimer/assumptions, chart text/table alternative, and no monthly screen.
- `IOS-LIFE-001–005`: cold launch/default, background/foreground, relaunch after save, no-network operation, failure/retry/protected-storage state.

## 9. Supported PWA regression inventory

`WEB-CAL-001–006` covers form/debounced validation/results and V1 fixture consumer; `WEB-RES-001–006` covers insights/target and display rounding; `WEB-CHART-001–006` covers nominal/after-fee/real toggles and a truthful non-visual alternative; `WEB-BRK-001–008` covers annual views, nominal monthly view, 120-month limit note, expand/collapse, CSV columns/escaping/six decimals/current date filename prefix; `WEB-SCN-001–008` covers CRUD and exactly-two comparison with comparability cues; and `WEB-CONTENT-001–004` covers glossary/methodology/assumptions.

`WEB-PWA-001–006` verifies responsive 390px/desktop evidence, dark-mode persistence, service-worker precache/offline/available-update refresh-dismiss lifecycle, install manifest behaviour where deployed, and keyboard/browser-storage behaviour. Browser support is a recommendation pending policy: test current stable Safari (including iOS), Chrome/Edge, and Firefox categories rather than claiming an unapproved version matrix.

Known findings remain visible risk records: disabled pinch zoom (`WEB-A11Y-011`), chart inaccessible/no tied data alternative (`WEB-A11Y-012`), invalid target text (`WEB-INPUT-010`), preset selector mismatch (`WEB-PRE-008`), dependency vulnerabilities (`REL-WEB-003`), legacy compound naming/CSV prefix (`WEB-BRK-008`), and unconfigured deployment (`REL-WEB-004`). They need triage/fix/accepted exception; none becomes accepted native/shared behaviour.

## 10. Accessibility and adaptive evidence

| Area | Reproducible checks | Evidence type |
| --- | --- | --- |
| Dynamic Type | Default through accessibility sizes; no clipped core content; reflowed controls/table/chart alternative. | Simulator + physical iPhone/iPad capture. |
| VoiceOver | Labels, values, units/hints, logical swipe order/headings, actions, result/error/update announcements. | Device assistive-tech recording/notes. |
| Chart | Meaning available via summary and annual table without chart; no colour-only difference. | Manual VoiceOver plus UI assertion where possible. |
| Focus/errors/dialogs | Focus reaches actionable validation error; glossary/confirmations trap and restore focus; Escape/keyboard actions on Web. | Automated UI plus manual confirmation. |
| Contrast/appearance | Light/dark semantic contrast; state/error not colour-only; high-contrast audit where available. | Automated candidate + manual visual review. |
| Motion/touch | Reduce Motion removes nonessential motion; controls meet platform touch expectations. | Simulator/device/manual. |
| Keyboard/reflow | iOS hardware/software numeric keyboard and return; Web keyboard order, browser zoom, 200–400% reflow. | Device/browser manual evidence. |
| Adaptation | Compact/large iPhone; supported portrait/landscape; iPad compact/regular and multitasking widths. | Simulator matrix + physical smoke. |

`IOS-A11Y-001–016` and `WEB-A11Y-001–012` record whether evidence is automated, simulator, physical-device, assistive-technology, or manual. IGC-005 can add approved visual/interaction assertions later; until then this plan evaluates outcomes, not an invented visual system.

## 11. Environment and compatibility recommendations

Recheck current Xcode/SDK/App Store upload requirements immediately before native
implementation/release; accepted runtime minimum remains iOS 17. Apple’s compatibility
table separates deployment target from physical device support. The IGC-007 physical
gate signed and installed with Xcode 26.2 on iOS 27.0, but attached debugging was
skipped because Xcode 26.2 documents device support only through iOS 26.2. Future
attached physical debugging requires a maintained Xcode whose range contains the
device OS—currently Xcode 27 for iOS 27 on a compatible Mac—or a device within the
maintained Xcode toolchain’s range. Do not treat an unsupported debugger pairing as an
app failure or add project workarounds without separate evidence.

Use representative small/standard/large iPhone simulator classes and iPad compact/
regular width, not a frozen marketing-device list, plus at least one physical-device
smoke category. Exercise en-GB/GBP and a non-UK system locale without changing the GBP
contract, multiple time zones for UTC timestamp handling, light/dark, clean install,
upgrade/migration, relaunch, offline, unavailable storage, and protected-storage
conditions.

For Web, recommended categories are current stable Safari (including iOS), Chromium (Chrome/Edge), and Firefox at desktop/mobile responsive widths, with clean profile, existing storage, private/restricted storage where feasible, offline/update and browser zoom/keyboard checks. Product Manager must approve the actual browser support policy before it becomes a release rule.

## 12. Automation, cadence, and ownership

| Trigger | Automated / manual work |
| --- | --- |
| Every change | Relevant TypeScript/Vitest units; fixture structural checks when shared resources change; formatting/type/build checks for modified client. |
| Shared-contract change | Both direct JSON consumers, every fixture/checkpoint/validation case, schema checks, invariant suite, change-control review. |
| Web change | Vitest/Web integration regression, supported-browser smoke, localStorage/PWA lifecycle and accessibility cases touched. |
| iOS pull request | Future Swift Testing core/store tests; XCTest/XCUI affected flow; simulator accessibility/adaptive checks. |
| Release candidate | Both parity consumers, full Web regression, iOS simulator/device smoke, offline/relaunch/recovery, manual accessibility, known-issue review. |
| App Store submission | IGC-008-approved privacy/metadata/support evidence, current SDK/toolchain verification, archive/signing/release checklist; this plan does not approve submission. |

TypeScript/Vitest owns current Web contract/unit/invariant coverage. Future Swift Testing owns independent engine/validation/codec/store coverage; XCTest/XCUI owns native flows/accessibility. JSON/schema structural checks remain shared. Exploratory, assistive-technology, physical-device, privacy and release review are manual evidence. IGC-006 creates no CI or test implementation.

## 13. Defects and change control

Severity is impact: **S0** data loss, wrong financial result, privacy/security exposure, or unusable core flow; **S1** material wrong/misleading outcome or major accessibility/platform-blocking defect; **S2** workaround exists but workflow/accessibility/regression impact is important; **S3** cosmetic/copy/minor inconsistency. Priority considers release scope and likelihood separately. A fixture mismatch is an S0/S1 candidate until triaged; an intentional approved contract change is not a defect only after full Shared change-control evidence exists.

Each report contains test ID, build/commit, client/device/browser/locale, inputs/storage fixture, exact steps, expected/actual raw and displayed values, suitable logs/screenshot/video, reproducibility, severity/priority, owner, and redaction of planning data. Assign Shared for specification/assets, iOS for Swift/native lifecycle, Web for browser/PWA, and cross-link related reports without duplicate ownership.

Fixture/specification changes require an accepted Shared decision, compatibility/version assessment, schema/spec/fixture update, both clients' consumers and regressions, and a changelog record. Never “fix” by regenerating expectations. Known issues retain owner, impact, workaround/exception, and gate status. Failures block the affected client; a Shared parity/spec issue blocks both release claims. IGC-005 is accepted under IGC-D017 and enters `IOS-NAV`, `IOS-UI`, `IOS-RES`, `IOS-STORE`, and `IOS-A11Y`; IGC-008 updates `REL-PRIV` during release-test implementation.

## 14. Entry, exit, and release gates

| Gate | Objective exit evidence | Current state |
| --- | --- | --- |
| Architecture/design readiness | Accepted architecture; QA inventory reviewed; IGC-005 decisions traced; bundle/team owner inputs before project creation. | Passed: architecture/design/QA accepted; bundle, Team Name, and Team ID implemented and development-signed. |
| Calculation-core parity | Both V1 consumers, every fixture/schema/checkpoint/validation and invariants pass; raw tolerance evidence. | Passed for V1: Web 85-test evidence and native 27/27 accepted fixture/unit/UI evidence. |
| Vertical slice | Native validated draft → raw result → annual accessible alternative; local-free/offline and fixture gate. | Passed under IGC-007/IGC-D019: simulator matrix plus signed physical install/direct launch/manual smoke. Debugger-attached execution skipped on unsupported Xcode 26.2/iOS 27 pairing. |
| Scenario lifecycle | V1 CRUD, atomic/recovery/failure/reset/relaunch evidence and truthful backup wording. | Planned. |
| Accessibility readiness | Automated/simulator/device/VoiceOver/manual evidence; Dynamic Type/adaptive/contrast/motion/keyboard findings resolved or accepted. | Partial: IGC-007 simulator/accessibility suite and requested physical smoke passed; feature-complete and release-candidate evidence remains open. |
| Web regression | Supported PWA passes; known defects/vulnerabilities/deployment risk triaged with owner/exception. | Historical audit/85-test evidence; rerun for change/release. |
| TestFlight/release candidate | iOS parity/regression/device/offline/recovery/privacy evidence, no unresolved release blockers, approved known-issue list. | Planned. |
| App Store/privacy readiness | IGC-008 current official review, approved disclosures/URLs/metadata, current SDK/upload/signing evidence. | Planned; not a compliance claim. |

### Current evidence versus planned evidence

Current evidence includes accepted V1 specs/schemas/fixtures; direct TypeScript fixture
consumer reported as 27 tests alongside 58 existing tests (85); historical PWA
lint/build/browser evidence; and accepted IGC-007 native evidence. Native evidence is
27/27 fixture/unit/UI tests, Debug/Release simulator builds, representative iPhone/iPad
and accessibility/locale runs, plus successful development signing, physical
installation, direct launch, and requested manual smoke on iOS 27.0. The attached
debugger attempt is explicitly skipped under IGC-D019 because Xcode 26.2 supports
devices only through iOS 26.2. Scenario lifecycle, feature-complete accessibility,
privacy/archive, TestFlight, and App Store evidence remain planned.

Product Manager/Technical Lead review accepted this inventory and traceability under
IGC-D015. IGC-D017 assertions are partly evidenced by IGC-007 and remain requirements
for future feature/release gates. Calculator scroll retention after switching tabs is
expected feature-local state under the accepted design, not a defect. IGC-008 remains
the authority for privacy/submission evidence. Known Web defects still require separate
prioritisation.
