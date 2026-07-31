# IGC project status

Updated: 2026-07-30
Owner: Product Manager and Technical Lead

## Current state

- Phase: IGC-007, IGC-012, and IGC-013 are accepted and integrated. The IGC-007
  foundation was development-signed, installed, and manually validated on a physical
  iPhone; the integrated native app now also includes the accepted local scenario
  lifecycle, secondary content, app preferences, and verified global local-data reset.
- Release preparation: the accepted release-candidate branch
  `codex/igc-release-candidate` was created from exact accepted branding head
  `0c3155493b4ce6c2650da0745bd0890d5fd3f2ae`. On Xcode 26.6 / iOS 26.5 SDK,
  56/56 unit tests, 23/23 iPhone UI tests, and the focused adaptive-iPad route test
  pass. A signed `1.0 (1)` archive builds with zero Xcode warnings/errors and passes
  the identity, signature, orientation, icon, privacy-manifest and binary inspections
  recorded canonically in `docs/RELEASE_CHECKLIST.md`. Candidate commit
  `36eff61d12f7cf0c0a6afcc8cebd3dc33c8a9109` was integrated by merge commit
  `fe1231e0007d0485afa72c7b4cd0127452b8a46a`.
- App Store setup: the explicit App ID `uk.co.mochadesigns.igc` was registered under
  Team `2FKVFS8X67`, then the owner-authorised App Store Connect record was created
  2026-07-30 with iOS, **Investment Growth Calculator**, English (U.K.), immutable SKU
  `IGC-IOS-001`, and Full Access. Apple assigned app ID `6796327865`; version `1.0`
  is **Prepare for Submission**.
- Internal TestFlight: the owner-authorised Xcode 26.6 / iOS 26.5 SDK archive
  `1.0 (1)` was uploaded on 2026-07-30 and Apple validated it as bundle
  `uk.co.mochadesigns.igc`, arm64, iOS 17+, iPhone+iPad, with Team
  `2FKVFS8X67`, no non-exempt encryption, no hidden app icon, no extension and no
  unintended entitlement. App Store Connect Support and Privacy Policy URLs are live
  and saved. Internal group **IGC Internal** has automatic distribution enabled,
  contains build 1, and invited `henryberkin@gmail.com`; beta description, feedback
  email, Privacy/Marketing URLs, and build-specific test focus are saved. Nothing has
  been submitted for external TestFlight review or App Review.
- Working branch: `project/ios-migration-audit`.
- Verified public source: `main` at
  `428fb46432fedab770ae90934b537587a32d70f6`.
- Recovery point: annotated tag `recovered-pwa-baseline-2026-07-28`.
- Verified structural migration commit: `78f2415`.
- Native implementation: IGC-007 Calculator-to-Projection vertical slice, IGC-012
  scenario lifecycle, and IGC-013 secondary content/preferences are integrated into
  `project/ios-migration-audit`. IGC-007 passed its physical-device gate under
  IGC-D019.
- PWA status: supported IGC web edition and behavioural reference, published at
  `https://igc.mochadesigns.co.uk/` on Cloudflare Pages from production branch
  `project/ios-migration-audit`. Release commit
  `f6d514169ab1ca2824d8da931b75eb2fbab4522f` passed the Pages production build
  `6ca2abea-4875-4aaa-86f0-9efb2d12b353`;
  the owner-controlled custom domain is Active with SSL enabled. Public Privacy and
  Support destinations are `https://igc.mochadesigns.co.uk/privacy` and
  `https://igc.mochadesigns.co.uk/support`; no analytics, tracking, Function, database
  or paid service was enabled.
- Public product/App Store name: **Investment Growth Calculator**.
- Shorthand/icon identity: **IGC**; long-form marketing:
  **IGC — Investment Growth Calculator**.
- Native application bundle identifier: `uk.co.mochadesigns.igc` (IGC-D018).
- Apple Developer Team ID: `2FKVFS8X67` (owner-confirmed).
- Apple Developer Team Name: `Henry Berkin` (owner-confirmed).
- Historical repository/package names still include `compound-toolkit` and
  `compound-growth-toolkit`.

## Verified checks at the original PWA root

| Check | Result |
| --- | --- |
| `npm install` | Passed; exposed lockfile-version drift and branded-icon overwrite |
| `npm run lint` | Passed |
| `npm test` | Passed: 58/58 tests |
| `npm run build` | Passed |
| `npm run dev -- --host 127.0.0.1` | Passed after local port permission |
| Mobile and desktop browser audit | Passed with findings in `docs/PWA_AUDIT.md` |
| `npm audit --audit-level=low` | 15 transitive findings: 1 low, 5 moderate, 8 high, 1 critical |

No audit fix or dependency upgrade has been applied.

The same install, lint/type-check, 58-test suite, build, development server, mobile
default-result check, saved-scenario persistence check, desktop load, and fresh browser
console check passed after relocation into `igc-pwa/`. Installation left the branded
icon hashes unchanged.

IGC-009 added a direct shared-fixture consumer: 27 cross-platform contract tests pass
alongside the original 58 tests (85 total), and lint/type-check plus production build
pass.

## Current gates and next action

The six product decisions, dual-client direction, staged premium deferral, calculation
contract, fixture schema, representative outputs, validation cases, and portable
scenario schema are accepted and complete. IGC-003 and IGC-009 are Done.

IGC-004 is Done and its architecture is accepted in IGC-D014. The corrected specialist
head is `1940e3f95427f5fc0b3ca2dab07801e887650821`; the proposal was integrated into
`project/ios-migration-audit` by merge commit `856f156`.

IGC-008 is Done and its early App Store/privacy planning baseline is accepted in
IGC-D016. The specialist head
`1bc787858ae991a706d009214b14bc3867f36baf` is integrated into
`project/ios-migration-audit` by merge commit `7dc3e08`. The review records current
Apple submission gates, provisional local-only App Privacy answers, owner inputs,
financial-content/legal review flags, and phase-gated release evidence; it makes no
submission or native-compliance claim.

IGC-005 is Done and its corrected native design system is accepted in IGC-D017. The
specialist head `3f176284a0badeb342bf48bfa737a0c6fd52543b` is integrated into
`project/ios-migration-audit` by merge commit `004af38`. It fixes the four-tab
hierarchy, explicit Calculator-to-Projection flow, scenario interaction/recovery,
results and annual detail, accessibility intent, adaptive behaviour, and semantic
visual foundations without adding native implementation.

The IGC-007 native implementation was completed in its required specialist worktree
from exact base `dc521186d9d0f30add2f45c06cb02d6d98d35195`. It uses bundle identifier
`uk.co.mochadesigns.igc`, Apple Developer Team Name `Henry Berkin`, and Team ID
`2FKVFS8X67`. Initial implementation commit
`ab45c935853fc4edab0fce2d25291d74255b49d1` and correction commit
`76b1e39db01830642b4de7481ea7efc85ae568f1` are integrated by merge commit
`c26d25a13a65d47f487fc55cebaeb216b7a8eb62`.

IGC-006 is Done and its behavioural inventory is accepted in IGC-D015. The specialist
head `7e4f462ef6ec78fa22dea81dbda772e9032af2f9` is integrated into
`project/ios-migration-audit` by merge commit `c895476`.

IGC-007 is Done. Product Manager review accepted its corrected SwiftUI
Calculator-to-Projection slice, pure calculation core, direct root-fixture parity
tests, annual detail, adaptive tab navigation, and accessibility alternatives. The
independent review gate passed 27/27 tests with no failures or skips, plus the Release
simulator build and store-bundle validation. Focused simulator evidence covers
representative small, standard, large, and iPad devices plus Dark Mode, AX XXXL,
Reduce Motion, VoiceOver-enabled semantics, supported landscape, and a non-UK locale
retaining GBP. Release inspection found no third-party SDK, network, persistence,
analytics, entitlement, collected-data, tracking, or required-reason API surface, so
no privacy manifest is required for this slice.

The owner then used Xcode 26.2 to sign and install the unchanged integrated application
on an iPhone running iOS 27.0. Direct launch from the installed Home Screen icon and
every requested manual smoke item passed, including calculations, validation, chart,
navigation, accessibility, offline operation, and expected non-persistent relaunch.
Calculator scroll position remained local to its tab as specified. Debugger-attached
launch was skipped because Apple documents Xcode 26.2 device support only through iOS
26.2; the initial debugger failures are not an established IGC defect. IGC-D019 records
the accepted gate and future compatible-toolchain/device rule.

IGC-012 is **Done — accepted and integrated** under IGC-D020 and IGC-D021. The
specialist implementation was created on `codex/igc-012-native-scenario-lifecycle`
from exact base
`9b5f17b41d768bf72af12c215b096d2e101962e0`; implementation commit
`802ff473b9b6a091103591eefd87b79745116f4f` adds the exact native V1 mapping,
actor-backed Codable Application Support store, save/Save-as-new, deterministic Saved
root, load, rename, duplicate, confirmed delete, recovery states, and persistence
coverage. Product Manager review requested corrections at
`be572a2825c4988b67049f21bdf8ea56c151c5c6`; correction commit
`5d6c757871d82709fab27b20f41c6b50f001c360` now requires exact current-source
recovery evidence before reset and disables Projection Save with an accessible,
state-specific reason while storage is loading, unavailable, corrupt, or unsupported.
Final correction evidence is 40/40 unit/fixture/store tests and 16/16 iPhone UI tests,
plus passing Debug and Release simulator builds. The normal Save/relaunch/load/Save
as new/rename/duplicate/delete paths, all 27 accepted IGC-007 tests, and focused
recovery/Projection regressions pass. The prior focused iPad, clean-install, relaunch,
and offline-dependency evidence remains recorded in the specialist handoff. The
first-party privacy/dependency/API inventory is unchanged. Product Manager review
independently repeated 40/40 unit/fixture/store tests, 16/16 UI tests, and the Release
simulator build before accepting exact specialist head
 `20af11c905a2c2bf16fe46af132725d97a1cf7f9`, integrated by merge commit
 `853555794173814a9299d257d6ff12786c7b26dc`. Physical-device execution was skipped
 under the accepted Xcode 26.2/iOS 27 compatibility boundary. Global Settings reset,
appearance/onboarding persistence, comparison, export, networking, premium,
TestFlight, archive/upload, and App Store work were excluded from IGC-012.

IGC-013 is **Done — accepted and integrated** under IGC-D022 and IGC-D023. Exact-base
implementation commit
`7803db18471a06b61973e9d848f922a2d8d3cf81` adds bundled
Education/methodology/glossary/exclusions/disclaimer content; feature-local Calculator
and Projection education routes; the non-blocking first-launch coach; injectable
app-only System/Light/Dark and coach preferences; Settings/About/Privacy; deliberate
scenario/recovery-material erasure; verified cross-store Delete all app data
coordination; and an app-target UserDefaults `CA92.1` privacy manifest. Shared
calculation, validation, schema, fixtures, scenario semantics, and ordinary
corrupt/unsupported recovery remain unchanged.

Implementation evidence is 56/56 complete unit/fixture/store/content/preference/reset/
privacy tests and 23/23 complete iPhone UI tests, with zero failures or skips in the
final runs. Focused iPad routes, compact-iPhone accessibility-size Dark Mode content,
and unreachable-proxy offline routes each pass 1/1. Debug and Release simulator builds
pass with zero build warnings/errors; both app bundles contain a valid manifest and
the optimized Release bundle contains no embedded framework, endpoint, capability or
entitlement addition. Product Manager review independently repeated 56/56 unit tests,
23/23 UI tests, the Release simulator build, manifest parsing and packaging, scope
checks, and clean-worktree checks before accepting exact specialist head
`425af8e302269e52a0971815fdb70241854404d2`, integrated by merge commit
`a6a1e5fac3c66ea5c42bd71d8d93df93516e8ef6`. Physical execution remains skipped
under IGC-D019. Final legal copy, public Privacy/Support destinations, supported-device
manual accessibility sign-off, TestFlight, distribution upload, processed-build
review, metadata completion and submission remain later release gates. No subsequent
engineering milestone is authorised until Product Manager roadmap review.

Release-candidate preparation is **Accepted and integrated**. The candidate adds
explicit supported-orientation metadata required for the adaptive iPhone/iPad target;
it does not change product behaviour, calculation, persistence, signing identity,
capability or entitlement scope. `docs/RELEASE_CHECKLIST.md` is the single canonical
evidence record; the iOS handoff links to it rather than duplicating the full command
transcript.

The internal TestFlight release gate is **Passed**. Fresh archive
`/private/tmp/IGC-1.0-1-TestFlight.xcarchive` passed identity, bundle metadata,
signature, privacy-manifest and binary-content inspection before Xcode upload.
App Store Connect processed build UUID `4c40e517-4b71-4af1-b6cb-2864607c7794`,
reports Binary State **Validated**, and distributes it to the one-member
**IGC Internal** group. The App Store Connect record thumbnail still showed its
generic wireframe after processing, but archive and processed-build evidence both say
the IGC icon is present and not hidden. The TestFlight-installed Home Screen icon is
the decisive owner check; do not create a replacement build unless that installation
reproduces the wireframe.

## IGC-014 pre-public-release accuracy corrections

IGC-014 is Done and accepted in IGC-D024, IGC-D025 and IGC-D026. An independent review
of the native app, run against the shared contract and fixtures before any public
release, found the calculation engine correct: an independent reimplementation
reproduced `shared/fixtures/calculation-v1.json` exactly. Every defect it found was in
terminology or presentation, and all are now corrected in both clients:

- the growth assumption is no longer called an APR, a UK term for the cost of credit,
  and is described as the nominal rate it is, with the implied effective yearly growth
  stated rather than inferred;
- the `savings-account` preset now treats its 4% as an effective annual rate, matching
  how UK savings accounts advertise AER;
- annual-detail rows apply one row-end inflation divisor throughout, so both paths add
  up to their own closing balance, and after-fee growth and already-deducted fees are
  labelled honestly;
- the Projection breakdown separates its addends from its totals.

Evidence: 58/58 iOS unit tests including two added invariants, 23/23 iOS UI tests, and
Web lint, 85/85 tests and production build. No engine, contract-version, fixture,
schema or persisted-data change was made, so fixture parity is unaffected and saved
scenarios need no migration.

This work is a correctness and wording gate, not a release gate. Final legal copy
review, physical-device sign-off, and App Review submission remain open. A new
TestFlight build is required for these corrections to reach any tester.

## Remaining public-submission gaps

The binary itself carries no known submission blocker. The archive inspection for
`1.0 (2)` matches the `1.0 (1)` baseline, the app icon is a 1024×1024 PNG with no alpha
channel, no placeholder or TODO copy remains in shipping source, and export compliance
is now declared in the Info.plist. What remains is App Store Connect metadata plus two
verification passes:

- Screenshots. The device family is `1,2`, so **iPad screenshots are mandatory**, not
  optional, unless iPad support is dropped.
- Primary category. Still undecided. Note that `LSApplicationCategoryType` is empty in
  the project, but on iOS that key is a macOS artefact and is not read by the App Store;
  the category is chosen only in App Store Connect, so this is a metadata decision and
  not a code gap.
- Final App Privacy questionnaire, age rating, reviewer notes and release mode.
- Landscape on iPhone is enabled in the supported orientations but has no automated
  coverage; the Projection chart is the likely pinch point. The owner's `1.0 (3)`
  device pass found no landscape problem.
- Territory availability must be set to the **United Kingdom only**, per IGC-D029,
  which narrows IGC-D027. Ireland is an EU storefront and would require a Digital
  Services Act trader declaration publishing the owner's address on the listing. The
  listing should state "UK English · GBP".

The owner's physical-device pass on `1.0 (3)` passed, with two findings now fixed in
`1.0 (4)`: money rows wrapped mid-figure at large Dynamic Type, and the projection
chart's accessibility hint promised an audio graph that no code implemented. Both are
addressed and need re-checking on `1.0 (4)`, specifically the Breakdown at the largest
text size and the VoiceOver rotor's Describe Chart / Audio Graph actions on Projection.

Deferred deliberately: `FeatureAvailability` is injected into `RootTabView` and never
read by any view. It is the intended premium seam, so it is harmless but currently
unexercised.

## Known issues and deferred work

- The preset picker initially displays “Global index (DIY)” while the untouched
  defaults use the accepted Custom 0.20% fee. The decision is resolved; the supported
  PWA correction belongs to a separately verified Web task.
- Build history. `1.0 (1)` to `1.0 (4)` are superseded. `1.0 (3)` was uploaded and
  passed the owner's physical-device pass, which raised two accessibility findings.
  `1.0 (4)` addressed Dynamic Type but its `AXChartDescriptor` proved unreachable:
  owner testing on device confirmed VoiceOver could focus only individual chart
  sections, never the chart itself. **`1.0 (5)` is the current build**, archived and
  inspected at `~/Library/Developer/Xcode/Archives/2026-07-31/IGC 1.0 (5).xcarchive`,
  carrying the chart-accessibility restructure and the duplicated-percent-symbol fix.
- The projection chart's audio graph remains **unverified**. The chart is now a single
  focusable element carrying its factual summary, which a UI test asserts, and that is
  a real accessibility improvement on its own. Whether iOS then offers a playable audio
  graph needs VoiceOver audio on hardware. The accessibility hint deliberately no
  longer mentions the rotor, so the app promises nothing that may not materialise.
- `1.0 (5)` **has not been exported or uploaded.** Command-line export fails with
  `No signing certificate "iOS Distribution" found`, alongside
  `DVTDeveloperAccountManager: Invalid credentials in keychain ... missing
  Xcode-Username`. No Apple Distribution certificate is present in the login keychain
  and the stored Xcode account session is invalid, so distribution signing cannot be
  performed non-interactively. Xcode Organizer's **Distribute App** resolves both: it
  authenticates interactively, obtains the distribution certificate, re-signs the
  archive and uploads in one flow. This machine also holds no App Store Connect API key,
  so upload remains an owner operation regardless.
- Committed PWA documentation and package naming lag behind product behaviour.
- The web viewport disables pinch zoom, an accessibility risk not to reproduce natively.
- Dependency vulnerabilities remain in the preserved PWA toolchain.
- Current PWA saved records predate explicit `schemaVersion`, `currency`, and
  `presetId`; a Web migration must be scoped and tested before changing localStorage.
- Debugger-attached physical execution on the owner’s iOS 27.0 device remains
  unavailable with stable Xcode 26.6, whose documented device support ends at iOS
  26.5. Use Xcode 27 on a compatible Mac or a device within the maintained
  Xcode toolchain’s documented device-support range when attached debugging is needed;
  no project workaround is authorised without separate evidence.
- Premium features, pricing, purchase type, entitlement sharing, and account strategy
  remain deliberately deferred and excluded from implementation.
