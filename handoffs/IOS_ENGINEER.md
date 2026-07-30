# iOS Engineer handoff

## Native 1.0 local release candidate accepted and integrated

Status: **Accepted and integrated**. This is a local release-preparation gate, not a
new feature task. Candidate commit
`36eff61d12f7cf0c0a6afcc8cebd3dc33c8a9109` was integrated into
`project/ios-migration-audit` by merge commit
`fe1231e0007d0485afa72c7b4cd0127452b8a46a`. After owner approval, explicit App ID
`uk.co.mochadesigns.igc` was registered and App Store Connect record `6796327865`
was created on 2026-07-30. Version `1.0` is **Prepare for Submission**. No build has
been uploaded and no TestFlight or submission action has been made.

- Candidate branch: `codex/igc-release-candidate`
- Exact accepted base: `0c3155493b4ce6c2650da0745bd0890d5fd3f2ae`
- Toolchain: Xcode 26.6 (17F113), iOS 26.5 SDK, macOS 26.5
- Product change: explicit supported orientations in the app target’s Debug and
  Release settings—portrait and both landscapes on iPhone; all four orientations on
  iPad. This resolves the signed-device/store-validation warning without requiring
  full-screen mode or changing adaptive iPad scope.
- Automated evidence: 56/56 unit tests, 23/23 iPhone UI tests, and focused adaptive
  iPad route 1/1 passed with no failures or skips.
- Archive: `/private/tmp/IGC-1.0-rc.xcarchive`, version `1.0 (1)`, bundle
  `uk.co.mochadesigns.igc`, Team `2FKVFS8X67`; archive action succeeded with zero
  errors, warnings or analyzer warnings.
- Inspection: valid development signature; arm64 iOS app; iOS 17 minimum;
  iPhone+iPad; correct processed opaque 1024×1024 IGC icon; valid app-root
  UserDefaults/`CA92.1` privacy manifest; no embedded framework, extension, package,
  third-party SDK or added entitlement/capability.
- Apple rules rechecked 2026-07-30: Xcode 26+/iOS 26+ SDK is currently required for
  upload, so Xcode 26.6/iOS 26.5 meets the current upload-toolchain floor. Xcode 26.6
  supports physical devices only through iOS 26.5; the owner’s iOS 27 device still
  requires Xcode 27 for attached debugging under IGC-D019.

`docs/RELEASE_CHECKLIST.md` is the canonical detailed evidence and open-gate record.
The local archive is development-signed; App Store distribution signing occurs during
an authorised export/upload. Remaining owner/release operations—URLs, metadata,
export/App Privacy answers, distribution upload and submission—must not be inferred
from this gate.

## IGC-013 native secondary content and preferences ready for review

Status: **Ready for review**. IGC-013 is not Done, accepted, integrated, merged or
pushed. Stop here; do not begin another milestone.

### Task control, base and commits

- Task: IGC-013 — Complete native secondary content and preferences (iOS).
- Authority: IGC-D022; this remained the only active engineering milestone.
- Repository: `/Users/henryberkin/Projects/IGC`.
- Base branch: `project/ios-migration-audit`.
- Exact accepted base:
  `22c24a12488139b9f9c6c33a7ac5a0d579986349`.
- Task branch: `codex/igc-013-native-secondary-content`.
- Required isolated worktree:
  `/private/tmp/igc-013-native-secondary-content`.
- Exact implementation/source/test commit:
  `7803db18471a06b61973e9d848f922a2d8d3cf81`
  (`feat(ios): complete secondary content and preferences`).
- The documentation/handoff commit is the immediate successor at task-branch tip. Its
  immutable hash is recorded in the final specialist response because a commit cannot
  contain its own hash.
- Complete review range:
  `22c24a12488139b9f9c6c33a7ac5a0d579986349..codex/igc-013-native-secondary-content`.
  Review it with:

  ```sh
  git log --oneline \
    22c24a12488139b9f9c6c33a7ac5a0d579986349..codex/igc-013-native-secondary-content
  git diff \
    22c24a12488139b9f9c6c33a7ac5a0d579986349..codex/igc-013-native-secondary-content
  ```

Preflight confirmed that the integration checkout was clean on
`project/ios-migration-audit`, resolved exactly to the accepted base, and had no task
branch or worktree. The branch/worktree was created directly from the exact commit.
Every edit, build, test and commit was made in the required isolated worktree. Nothing
was rebased, merged, pulled, pushed, uploaded, archived or submitted; no toolchain,
signing, bundle, capability or entitlement setting was changed.

### Delivered feature architecture

IGC-013 extends the accepted IGC-007/IGC-012 implementation without changing shared
calculation, validation, fixtures, terminology, schema, scenario meaning, ordinary
delete-one semantics, or corrupt/unsupported preservation:

- Education is a static Swift hierarchy bundled in the app. Its root routes are
  **Understanding your projection**, **How calculations work**, **Glossary**,
  **What this projection excludes**, and **Projection disclaimer**.
- Glossary rows remain in the accepted order: **Annual growth rate (APR)**,
  **Compounding**, **Inflation**, **Annual fee**, **After fees**,
  **Today’s money / purchasing power**, **Contribution frequency**,
  **Contribution timing**, **Preset and Custom**, and **Target**. Each opens a
  separately titled bundled definition.
- Calculator exposes **How calculations work** in Rates and assumptions and
  **Projection disclaimer** beside its projection action. Projection exposes
  **How calculations work** in Assumptions and **Projection disclaimer** beside its
  headline disclaimer. All four are typed Calculator-stack routes; they never select
  the Education tab and preserve the other three tab stacks and scroll state.
- The non-modal Calculator coach appears before the normal form on a first launch. It
  never blocks Calculator. **Choose a preset** dismisses it and moves keyboard and
  accessibility focus to the Preset picker without choosing one. **Dismiss** only
  dismisses. Neither action changes the Custom 7% APR / 3% inflation / 0.20% fee
  baseline. A failed write dismisses for the session, shows a non-blocking explanation
  and allows the coach to return on relaunch.
- Settings now has **Appearance**, **Data on this device**, and **About and help**.
  It provides System/Light/Dark, the separately confirmed destructive reset, About
  IGC, bundled Privacy, and Projection disclaimer. No Support or public Privacy row,
  fabricated URL, contact, web view or remote content was added.
- About displays **Investment Growth Calculator**, **IGC**, and actual bundle
  `CFBundleShortVersionString` / `CFBundleVersion` (`1.0 (1)` in verified builds).
- Privacy distinguishes in-app calculation, Application Support scenarios, app
  preferences, no IGC account/app-operated sync, normal backup lifecycle, delete-one,
  recovery and global deletion, and absent analytics/advertising/tracking/remote
  configuration/account connection/payment/live data/support diagnostics.
- A successful global reset returns Calculator to
  `CalculatorDraft.customBaseline`, clears loaded-scenario context, clears all four
  navigation paths, selects Calculator, restores System/coach defaults, and displays
  **All app data deleted**. Calculator draft restoration after an ordinary termination
  remains excluded and was not added.

### Exact preference contract

The injectable `AppPreferencesStore` is the only preference persistence boundary.
Views observe `AppPreferencesModel`; there is no `@AppStorage` and no direct
UserDefaults access in a view.

| Preference | Stable key | Stable values | Default |
| --- | --- | --- | --- |
| Appearance | `igc.appearance.v1` | `system`, `light`, `dark` | `system` |
| Coach dismissal | `igc.coach.dismissed.v1` | Boolean | `false` |

Production uses the standard app-only UserDefaults domain. UI automation uses an
argument-selected, app-owned suite isolated by the same identifier as its temporary
scenario store; this does not change normal production semantics. An absent or unknown
appearance value reads as System. Unknown raw values are not rewritten, silently
migrated or promoted to a theme. No earlier preference schema exists, so there is no
migration. Reset removes and verifies only the two owned keys, preserving unrelated
defaults.

Deterministic injection can fail appearance writes, coach writes, reset before any
mutation, or reset once after appearance removal. Production injects none. UI flags
are `-uiAppearanceWriteFailure`, `-uiCoachWriteFailure`,
`-uiPreferenceResetFailsOnce`, and `-uiScenarioEraseFailsOnce`. Tests prove session
usability, no false persistence, authoritative relaunch state and retry.

No scenario name, principal/balance, contribution, target, APR/rate, inflation, fee,
duration, timing, identifier, timestamp or other financial/scenario value is written
to UserDefaults. Unit tests compare the complete persistent domain with exactly the
two owned keys.

### Exact development/internal-beta copy boundary

The implemented disclaimer is exactly:

> IGC creates an illustrative projection from the assumptions you enter. It is not
> financial advice, a forecast, or a recommendation. Rates and contributions are held
> constant. The calculation does not model taxes, market volatility or the order of
> returns, changing inflation, contribution limits, platform or transaction charges
> beyond the annual fee you enter, pension or ISA rules, withdrawals, or investment
> losses along a market path. Actual outcomes may be higher or lower.

This is the IGC-D022-authorised development/internal-beta string. It is **not final
legal, regulatory, external-beta or public-release approval**.

The coach copy is exactly:

- Heading: **Start with the example**
- Body: **The visible values are a Custom illustrative example. You can use them as
  they are, edit any value, or choose a preset.**
- Actions: **Choose a preset** and **Dismiss**

The global confirmation is exactly:

- Title: **Delete all app data?**
- Body: **This deletes saved scenarios and resets appearance, onboarding, and
  calculator state on this device. This can’t be undone. Device backups have their own
  lifecycle.**
- Actions: **Delete all app data** (destructive) and **Cancel**

The methodology says, verbatim across its visible paragraphs:

- **The calculation proceeds month by month for the duration you select. Annual detail
  groups those internal monthly periods, including a final partial year.**
- **The annual growth rate (APR) is converted to an effective monthly rate according
  to the selected daily, monthly, quarterly or annual compounding frequency.**
- **Weekly contributions are converted using the amount × 52 ÷ 12. Annual
  contributions are converted using the amount ÷ 12. Monthly contributions use the
  amount entered.**
- **With start-of-period timing, the monthly-equivalent contribution is added before
  that period’s growth and fee. With end-of-period timing, growth and the asset-based
  fee are applied before the contribution is added.**
- **In each monthly period, growth occurs before the asset-based fee deduction. The
  fee is applied to the post-growth balance; it is not subtracted from APR.**
- **Today’s-money values divide the relevant future amount by the effect of your
  inflation assumption over the elapsed time.**
- **Rates and contributions remain constant throughout this deterministic projection.
  The calculation does not create a variable market path or probability range.**

The exact Understanding, exclusion, glossary-definition, About and Privacy paragraphs
are the static constants/views in
`igc-ios/InvestmentGrowthCalculator/Features/Education/EducationView.swift` and
`igc-ios/InvestmentGrowthCalculator/Features/Settings/SettingsView.swift`; there is no
remote fallback or loading state. Tests enforce the complete route hierarchy,
glossary order, required methodology phrases, absence of “expected return”, exact
disclaimer, truthful About bundle metadata, and all Privacy section headings.

### Delete all app data sequencing and failure semantics

`ScenarioStore` gains only `eraseAllData()`. `CodableScenarioStore` performs it under
actor isolation and explicit global-reset authority:

1. Refuse an injected/unavailable or pre-mutation failure without claiming mutation.
2. Resolve the app-owned
   `Application Support/InvestmentGrowthCalculator/SavedScenarios` directory without
   treating a corrupt/unsupported document as an ordinary empty store.
3. Remove that complete directory, deliberately covering
   `scenarios-v1.store.json`, `Recovery/**`, and app-owned temporary material.
4. Verify the directory is absent, re-read through the authoritative store, verify an
   empty readable snapshot, then verify the recreated store directory has no remaining
   item.
5. Return success only after those checks.

The main-actor coordinator conservatively sequences scenario erasure and removal of
the two owned preference keys. It then refreshes/re-reads both observable stores.
**All app data deleted** is possible only when both mutations returned success, the
scenario snapshot re-read empty, and preferences re-read exactly at defaults.
In-memory draft, loaded context, tab and paths are reset only after that result.

There is deliberately no atomic-transaction claim across filesystem, UserDefaults and
in-memory navigation. Any mutation error, partial result or unverified re-read returns
**Deletion did not complete**, identifies readable scenarios, unreadable/unsupported
state, unknown recovery-material erasure, or remaining preference where possible,
keeps Settings usable, focuses the failure banner and retains **Try again**. It never
shows success. Representative injected failure after document removal leaves recovery
material, reports it as unverified, and succeeds only on retry. Unit coverage creates
fresh store/model instances after a partial result to prove relaunch/retry semantics.

Ordinary delete-one, atomic write, exact-source corrupt/unsupported recovery evidence,
and recovery reset behaviour are unchanged. Dedicated regression tests still prove
corrupt/unsupported distinction and preservation outside global-reset authority.

### Privacy manifest and static inventory

The synchronized app source group automatically includes
`igc-ios/InvestmentGrowthCalculator/PrivacyInfo.xcprivacy`; no project-file edit was
needed. Source, Debug and Release built manifests parse as plists. The optimized
Release app contains it at:

`/private/tmp/igc-013-release-final/Build/Products/Release-iphonesimulator/InvestmentGrowthCalculator.app/PrivacyInfo.xcprivacy`

Its complete semantic content is one `NSPrivacyAccessedAPITypes` item:

- `NSPrivacyAccessedAPIType` =
  `NSPrivacyAccessedAPICategoryUserDefaults`
- `NSPrivacyAccessedAPITypeReasons` = `["CA92.1"]`

There is no other top-level key, reason, required-reason category, collected-data type,
tracking flag/domain or SDK declaration. A hosted unit test parses the built app
manifest and enforces those exact keys/counts.

Inventory evidence:

- No `Package.resolved`, `XCRemoteSwiftPackageReference`,
  `XCSwiftPackageProductDependency`, XCFramework, CocoaPods artifact, third-party SDK,
  or embedded framework.
- Optimized Release linkage is first-party/system Foundation, Charts, Combine,
  CoreFoundation, SwiftUI, UIKit, Swift runtime, Objective-C and libSystem only.
- Required-reason source scan finds only the declared UserDefaults access.
- App source has no `Logger`, `os_log`, `NSLog` or `print` call. The optimized binary
  has SwiftUI system runtime-issue logging symbols, but no app logging implementation
  or scenario logging.
- No runtime HTTP/HTTPS/WebSocket endpoint string; no URLSession/URLRequest/
  NWConnection/WebKit, StoreKit, CloudKit, analytics, Crashlytics, advertising,
  tracking/ATT/AdSupport/SKAdNetwork, remote configuration or support-diagnostics
  source/project/linkage match.
- No `.entitlements` file, `CODE_SIGN_ENTITLEMENTS`, App Group, iCloud/CloudKit, push
  or `SystemCapabilities` setting. The unsigned simulator Release app reports no
  entitlements. Bundle ID/team/deployment target remain
  `uk.co.mochadesigns.igc` / `2FKVFS8X67` / iOS 17.
- Release bundle metadata is version `1.0` build `1`, en-GB, iPhone+iPad, SDK 26.2,
  and contains only the executable, Info.plist, PkgInfo and PrivacyInfo at app-root
  depth; no embedded SDK/framework.

This remains simulator-build evidence. A signed Release archive, Xcode privacy report,
App Privacy questionnaire and final archive inspection remain mandatory later gates.

### Files changed

Implementation/source/tests in
`7803db18471a06b61973e9d848f922a2d8d3cf81`:

- `igc-ios/InvestmentGrowthCalculator/App/AppDataReset.swift`
- `igc-ios/InvestmentGrowthCalculator/App/AppPreferences.swift`
- `igc-ios/InvestmentGrowthCalculator/App/AppRoutes.swift`
- `igc-ios/InvestmentGrowthCalculator/App/InvestmentGrowthCalculatorApp.swift`
- `igc-ios/InvestmentGrowthCalculator/App/RootTabView.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/CodableScenarioStore.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/ScenarioStore.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Calculator/CalculatorView.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Education/EducationView.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Results/ProjectionView.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/SavedScenarios/ScenarioLibraryModel.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Settings/SettingsView.swift`
- `igc-ios/InvestmentGrowthCalculator/PrivacyInfo.xcprivacy`
- `igc-ios/InvestmentGrowthCalculator/SharedUI/ScenarioNameEntryView.swift`
- `igc-ios/InvestmentGrowthCalculatorTests/AppPreferencesAndContentTests.swift`
- `igc-ios/InvestmentGrowthCalculatorTests/CodableScenarioStoreTests.swift`
- `igc-ios/InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests.swift`

Permitted documentation/handoff closeout:

- `TASKS.md`
- `PROJECT_STATUS.md`
- `CHANGELOG.md`
- `docs/PRIVACY.md`
- `docs/QA_PLAN.md`
- `docs/RELEASE_CHECKLIST.md`
- `handoffs/IOS_ENGINEER.md`

No `project.pbxproj`, shared contract/fixture/schema, PWA file, protected specification,
decision, roadmap, signing, version policy, capability or entitlement changed.

### Final environment

- macOS 26.5 (25F5042g)
- Xcode 26.2 (17C52); no switch or install
- Apple Swift 6.2.3 (`swiftlang-6.2.3.3.21`,
  `clang-1700.6.3.2`)
- iOS Simulator SDK 26.2 (23C53)
- iPhone 17, iOS 26.2 (23C54),
  `B8C76566-0A54-4ECF-BC13-A9CAEBF4307B`
- iPhone 16e, iOS 26.2 (23C54),
  `2DD9CF3B-E780-4786-A19A-C381A5F68A71`
- iPad Pro 13-inch (M5), iOS 26.2 (23C54),
  `95A18A80-BDFE-47BF-A8EE-264947EAB159`

### Canonical final verification

Complete unit/fixture/store/content/preference/reset/privacy suite: **56/56 passed**,
zero failures, skips or expected failures. It includes all accepted calculation,
validation and scenario regressions plus IGC-013 defaults/stable values/unknown
fallback/writes/relaunch/injected failures, coach state, content/glossary/copy,
actual bundle metadata, built manifest, all-data erasure/recovery, partial failure,
retry and relaunch-after-partial coverage.

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator \
  -destination \
  'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
  -resultBundlePath /private/tmp/igc-013-unit-final-2.xcresult \
  -only-testing:InvestmentGrowthCalculatorTests
```

Complete UI suite: **23/23 passed** in 660.424 seconds, zero failures, skips or
expected failures. It includes all accepted Calculator/Projection/annual-detail/
scenario lifecycle/recovery regressions and seven IGC-013 UI cases for coach actions,
focus/no selection/persistence/failure, every Education/Settings/contextual
destination, glossary entries, all appearances/relaunch, actual About metadata,
Privacy, destructive confirmation/Cancel/success/relaunch, loaded context/four paths,
partial failure/no false success/retry, accessibility-size and Dark Mode.

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator \
  -destination \
  'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
  -resultBundlePath /private/tmp/igc-013-ui-final-2.xcresult \
  -only-testing:InvestmentGrowthCalculatorUITests
```

Focused adaptive iPad Education/glossary/all-contextual-route smoke: **1/1 passed**:

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator \
  -destination \
  'platform=iOS Simulator,id=95A18A80-BDFE-47BF-A8EE-264947EAB159' \
  -resultBundlePath /private/tmp/igc-013-ui-ipad-routes-final.xcresult \
  -only-testing:InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests/testEducationHierarchyGlossaryAndContextualRoutesStayFeatureLocal
```

Focused compact iPhone 16e, accessibility-size, Dark Mode Education/Privacy smoke:
**1/1 passed**:

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator \
  -destination \
  'platform=iOS Simulator,id=2DD9CF3B-E780-4786-A19A-C381A5F68A71' \
  -resultBundlePath /private/tmp/igc-013-ui-compact-ax-dark-final.xcresult \
  -only-testing:InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests/testAccessibilitySizeDarkEducationAndPrivacyRemainReadable
```

Unreachable-proxy offline smoke: simulator launchd `HTTP_PROXY` and `HTTPS_PROXY` were
temporarily set to `http://127.0.0.1:9`; the complete Education/glossary/all-contextual
route test passed **1/1**, and both variables were successfully removed afterwards.
Result bundle:
`/private/tmp/igc-013-ui-offline-proxy-final.xcresult`.

Final Debug and optimized Release generic-simulator builds both passed with zero
reported build/analyzer warnings or errors:

```sh
xcodebuild build \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/igc-013-debug-final \
  -resultBundlePath /private/tmp/igc-013-debug-build-final.xcresult \
  CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS=arm64

xcodebuild build \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/igc-013-release-final \
  -resultBundlePath /private/tmp/igc-013-release-build-final.xcresult \
  CODE_SIGNING_ALLOWED=NO ONLY_ACTIVE_ARCH=YES ARCHS=arm64
```

`plutil -lint` passes for source, Debug and Release manifests. Built Release `plutil`
inspection, app-root placement, `otool -L`, `file`, `codesign` entitlement output,
embedded-bundle search, `nm`/endpoint scans, project package/capability/entitlement
search, required-reason/API/network/logging/service scans, `git diff --check`, staged
diff check and final diff check pass as described above. Checks without XCTest/Xcode
actions have no result bundle.

### Failed, interrupted and superseded evidence

All failures were retained and were resolved before the canonical runs:

| Bundle / check | Result | Finding and resolution |
| --- | --- | --- |
| `/private/tmp/igc-013-unit-initial.xcresult` | 55/55 passed | Initial full unit suite before final relaunch-partial test. |
| `/private/tmp/igc-013-unit-final.xcresult` | 55/55 passed | Full unit repeat before the 56th test was added. |
| `/private/tmp/igc-013-ui-focused-initial.xcresult` | 0/7 passed | Coach Section identifier was inherited by child buttons; identifier placement and scroll-aware interaction corrected. |
| `/private/tmp/igc-013-ui-focused-second.xcresult` | 2/7 passed | Obscured-field, overlong identifier query and contextual presentation automation findings; tests/route presentation corrected. |
| `/private/tmp/igc-013-ui-focused-third.xcresult` | 1/5 passed | Exact display assertion and scroll/status routing findings; assertions and typed local routes corrected. |
| `/private/tmp/igc-013-ui-focused-fourth.xcresult` | 1/4 passed | Direct destination links were not path-owned and reset status was offscreen; typed paths and status focus/scroll corrected. |
| `/private/tmp/igc-013-ui-focused-fifth.xcresult` | 1/3 passed | Remaining reset-retry status and contextual-route automation findings; corrected. |
| `/private/tmp/igc-013-ui-focused-sixth.xcresult` | 2/2 passed | Final targeted reset-retry and contextual-route correction evidence. |
| `/private/tmp/igc-013-ui-final.xcresult` | 22/23 passed | New coach changed the starting geometry of a legacy keyboard/scroll test. Production behaviour was unchanged; that legacy test now dismisses the separately tested coach before its original lifecycle. |
| `/private/tmp/igc-013-ui-focus-regression.xcresult` | 0/1, interrupted | A trial with a larger swipe cap was manually cancelled when it proved non-deterministic. |
| `/private/tmp/igc-013-ui-focus-regression-2.xcresult` | 1/1 passed | Isolated corrected legacy lifecycle before the final 23/23 suite. |
| First sandboxed offline-proxy setup | failed before mutation | CoreSimulator access was denied by the sandbox. The authorised retry reached the simulator. |
| First authorised proxy setup | failed before mutation | iPhone 16e was not booted. It was booted, both proxy variables were set, the route smoke passed, and both variables were removed. |

Preparatory generic Debug `build` and `build-for-testing` also passed before the final
bundled commands; no result bundle was requested for those preparatory checks. They are
superseded by the final Debug/Release build bundles and complete test actions.

XCTest result bundles record non-failing SwiftUI
**Invalid frame dimension (negative or non-finite)** runtime warnings in several
legacy UI transitions, and the iPad automation log records transient remote
accessibility-hierarchy warnings. Assertions and final suites pass; no new app logging
or crash occurs. Product Manager may decide whether to create a separate diagnostic
task, but IGC-013 did not broaden scope to unrelated chart/layout remediation.

### Accessibility, adaptation and offline evidence boundary

- New article/privacy/glossary views use visible semantic headings and fixed-size
  multiline text inside scrolling, bounded 720-point reading measures.
- Coach and reset UI have visible text, minimum 44-point actions, descriptive labels/
  hints, no colour-only state, keyboard and accessibility focus changes, and failure/
  Cancel restoration. Failure banners receive accessibility focus; successful reset
  scrolls to and focuses the visible status.
- System/Light/Dark use semantic SwiftUI colours only; no custom theme/token or
  contrast-dependent state was added.
- Full iPhone tests cover portrait and supported landscape. Focused iPhone 16e covers
  compact width plus accessibility-size Dark Mode; iPad Pro 13-inch covers regular
  width and the same native tab/stack architecture, with no bespoke window/sidebar.
- UI automation queries the accessibility hierarchy, labels/values/identifiers,
  heading visibility, keyboard focus, coach preset focus, loaded/reset status focus and
  destructive failure focus. IGC-007’s accepted VoiceOver-enabled Calculator/results
  evidence remains unchanged.
- No manual spoken VoiceOver order/focus session, Increase Contrast measurement, Bold
  Text matrix or physical-device secondary-content run was performed. These remain
  honest review/release gaps rather than inferred passes.
- Offline route smoke passed with unreachable proxies. Static content has no loading
  state, runtime endpoint, network API/framework or web view. The accepted calculation/
  scenario offline behaviour also remains covered by the complete regressions.

### Skipped work, limitations and remaining gates

- Physical-device execution was skipped under IGC-D019. Henry’s iOS 27 device is not
  an authorised attached-debug target for maintained Xcode 26.2; no workaround or
  toolchain switch was attempted.
- No signed device archive, effective locked-device data-protection check, Xcode
  privacy report, TestFlight build, upload, App Store Connect record, metadata,
  screenshots, questionnaire, export-compliance response or submission was created.
- The exact disclaimer and other content are authorised development/internal-beta
  copy only. Final legal/regulatory/financial-promotion review remains open.
- Public Privacy and Support URLs/contact are owner dependencies. No Support row ships
  in this implementation because no truthful useful destination is approved.
- App Privacy answers/no-collection position, signed archive manifest aggregation and
  backup/uninstall wording require release-candidate revalidation.
- Comparison, monthly native detail, import/export/share, draft restoration, accounts,
  sync, CloudKit/App Groups, networking/live data, analytics/diagnostics, advertising/
  tracking, premium/StoreKit/payment, notification/widget/Shortcut and bespoke iPad
  work remain excluded.

### Review and rollback

Product Manager review should:

1. Confirm the branch range starts at the exact accepted base and contains only the
   implementation commit plus documentation closeout.
2. Review the exact disclaimer/content boundary, preference keys/isolation, manifest,
   complete directory erasure and cross-store no-false-success conditions.
3. Re-run the 56-test unit suite, 23-test UI suite and Release build commands above.
4. Inspect the built Release manifest with `plutil -p` and confirm no protected/shared/
   PWA/project-signing file changed.
5. Treat remaining legal, manual accessibility, physical-device and release gates as
   open; do not mark IGC-013 Done without accepted review evidence.

Rollback is two ordinary reverts on the task/integration branch after Product Manager
direction: revert the documentation closeout commit first, then revert
`7803db18471a06b61973e9d848f922a2d8d3cf81`. Do not rewrite shared history, delete
recovery tags or regenerate fixtures. The final task worktree was checked clean after
the closeout commit.

## IGC-012 native scenario lifecycle correction ready for review

Status: **Ready for review**. Stop here; do not begin another task.

### Task control and commits

- Task: IGC-012 — Native Scenario Lifecycle and Persistence (iOS).
- Decision: formally approved and Ready under IGC-D020.
- Repository: `/Users/henryberkin/Projects/IGC`.
- Required isolated worktree:
  `/private/tmp/igc-012-native-scenario-lifecycle`.
- Base branch: `project/ios-migration-audit`.
- Exact accepted base:
  `9b5f17b41d768bf72af12c215b096d2e101962e0`.
- Task branch: `codex/igc-012-native-scenario-lifecycle`.
- Exact source implementation commit:
  `802ff473b9b6a091103591eefd87b79745116f4f`
  (`feat(ios): implement native scenario lifecycle`).
- Exact originally reviewed documentation head:
  `be572a2825c4988b67049f21bdf8ea56c151c5c6`
  (`docs(ios): hand off IGC-012 for review`).
- Exact Product Manager correction source/test commit:
  `5d6c757871d82709fab27b20f41c6b50f001c360`
  (`fix(ios): correct recovery evidence and save gating`).
- The correction closeout is the subsequent documentation-only branch-tip commit.
  Review the complete task history with
  `git log --oneline 9b5f17b41d768bf72af12c215b096d2e101962e0..codex/igc-012-native-scenario-lifecycle`;
  the final specialist response records its exact hash.
- The correction continued in the existing isolated worktree at the exact reviewed
  head. Nothing was rebased, merged, pulled, or moved to another worktree.
- The worktree was created directly from the exact accepted base after confirming the
  integration checkout was clean at that commit and that neither the proposed worktree
  nor task branch already existed. Nothing was rebased, merged, pulled or guessed.

The withdrawn prompt based on
`212cf6056bd37ca22d5aff9db542f9aab4acdd19` was not used.

### Architecture and integration

IGC-012 extends the accepted IGC-007 vertical slice without changing the calculation
engine, validation contract, shared fixtures, platform terminology, signing,
capabilities or entitlements:

- `ScenarioV1` is a strict native mapping of the portable V1 schema. It rejects unknown
  keys, unknown enum raw values, unsupported versions, non-finite/malformed values and
  semantic invalidity rather than coercing or partially decoding a record.
- New native IDs use opaque `UUID().uuidString` values. Names are trimmed, non-empty
  and limited to 120 Unicode code points while duplicate truncation removes complete
  extended grapheme clusters.
- Currency is fixed to `GBP`; inputs use canonical decimal-rate values and stable raw
  enums; `presetId` is stable or nil; `targetToday` distinguishes absence from zero;
  timestamps encode as UTC ISO-8601 values.
- The accepted `CalculationValidator` enforces all canonical limits, including
  principal/contribution not both zero and duration 1–720 months.
- A narrow `ScenarioStore` protocol returns immutable snapshots. The
  `CodableScenarioStore` actor owns and serialises all filesystem work; SwiftUI views
  only await the main-actor `ScenarioLibraryModel`.
- Calculator draft strings remain separate from canonical values. A loaded record is
  fully validated before any Calculator state changes; its exact canonical input and
  target remain the source for an untouched loaded draft, avoiding text-round-trip
  coercion. A mismatching stored preset is presented as Custom in Calculator and Saved
  without modifying the record.
- Four independent `NavigationStack` roots remain. A successful load selects
  Calculator, pops its stack to root, scrolls to and VoiceOver-focuses the inline
  **Loaded “[name]”** status, and preserves the other feature roots.

### Private store and recovery

- Private production location:
  app sandbox `Application Support/InvestmentGrowthCalculator/SavedScenarios`.
- Private document filename: `scenarios-v1.store.json`.
- Private envelope version: 1, with implementation-only `storeVersion` and `scenarios`
  keys. These names are not part of the portable scenario contract.
- The actor orders snapshots by `updatedAt` descending, then `createdAt` descending,
  then `id` ascending.
- Writes encode a complete envelope to a uniquely named temporary file, request
  `FileProtectionType.complete`, write through `FileHandle`, synchronise and close it,
  then use atomic replacement (or initial move). The previous readable document is not
  selected for replacement until the temporary document is durable.
- Mutation success is returned only after strict reload. A reload failure reports no
  success; it does not guess whether the durable replacement took effect.
- Empty, unavailable/protected, corrupt and unsupported states are distinct and
  all-or-recovery. Unsupported store/scenario versions are probed before V1 decode.
  Corrupt/unsupported source is copied to a protected private `Recovery` directory
  where practical. The source is not presented as empty and a deliberate store reset
  is refused unless recovery evidence was preserved.
- Recovery evidence is now source-specific: the actor compares the exact current
  document bytes against readable copies in the private Recovery directory and never
  treats a cached URL or an earlier episode as proof for a different source. Reset
  captures the matched bytes and rechecks them before and immediately before atomic
  replacement. A changed source therefore receives its own durable copy; if that copy
  cannot be created, reset fails and the changed source and all earlier copies remain.
- The recovery reset affects only the saved-scenario store. It does not implement the
  excluded Settings-wide Delete all app data flow.

### CRUD and user behaviour

- Projection **Save** and loaded Projection **Save as new** always create a fresh
  UUID and fresh equal creation/update timestamps from an immutable validated
  `ProjectionSnapshot`; neither overwrites.
- Projection observes the current immutable store snapshot. Save remains enabled for
  an available store; loading, unavailable, corrupt, and unsupported states disable
  it, prevent the name sheet from opening or remaining open, and show a visible
  state-specific VoiceOver-labelled explanation beside the projection. Calculation,
  review, annual detail, and navigation remain usable.
- Editable name suggestions are exactly `<N>-year projection` for whole-year duration
  and `<N>-month projection` otherwise. Save/rename sheets retain entered text on
  failure and provide Try again and Cancel.
- Saved exposes count, accepted empty state and Go to Calculator action, truthful local
  Application Support/system-backup caveat, deterministic rows, whole-row Load, and
  reachable Load/Rename/Duplicate/Delete menu actions. It uses centred 840-point list
  and 720-point recovery measures without a sidebar or comparison UI.
- Rows include name, truthful preset/Custom state, principal, contribution/frequency,
  APR, duration and update date. VoiceOver labels/hints/custom actions mirror the
  accepted design; large Dynamic Type recovery state is covered by UI automation.
- Rename re-resolves the ID in the store and changes only name and `updatedAt`.
- Duplicate has no confirmation, preserves values/truthful persisted `presetId`,
  creates a fresh UUID/timestamps and uses ` copy`, ` copy 2`, and so on with
  schema-valid grapheme-safe truncation and collision avoidance.
- Delete uses the exact-name destructive confirmation, re-reads and resolves the exact
  ID at mutation time, removes only that ID, and retains retryable failure UI.
- No success status is shown before persistence and reload complete. Failed load stays
  in Saved and cannot partially change Calculator.

### Files changed

Source and tests in implementation commit
`802ff473b9b6a091103591eefd87b79745116f4f`:

- `igc-ios/InvestmentGrowthCalculator.xcodeproj/project.pbxproj`
- `igc-ios/InvestmentGrowthCalculator/App/AppRoutes.swift`
- `igc-ios/InvestmentGrowthCalculator/App/InvestmentGrowthCalculatorApp.swift`
- `igc-ios/InvestmentGrowthCalculator/App/RootTabView.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Domain/ScenarioModels.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/CodableScenarioStore.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/ScenarioJSONCodec.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/ScenarioStore.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Calculator/CalculatorDraft.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Calculator/CalculatorView.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Results/ProjectionSnapshot.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Results/ProjectionView.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/SavedScenarios/SavedScenariosView.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/SavedScenarios/ScenarioLibraryModel.swift`
- `igc-ios/InvestmentGrowthCalculator/SharedUI/ScenarioNameEntryView.swift`
- `igc-ios/InvestmentGrowthCalculator/SharedUI/ScenarioStatusBanner.swift`
- `igc-ios/InvestmentGrowthCalculatorTests/CodableScenarioStoreTests.swift`
- `igc-ios/InvestmentGrowthCalculatorTests/ScenarioModelTests.swift`
- `igc-ios/InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests.swift`

Source and tests changed in correction commit
`5d6c757871d82709fab27b20f41c6b50f001c360`:

- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/CodableScenarioStore.swift`
- `igc-ios/InvestmentGrowthCalculator/Core/Persistence/ScenarioStore.swift`
- `igc-ios/InvestmentGrowthCalculator/Features/Results/ProjectionView.swift`
- `igc-ios/InvestmentGrowthCalculatorTests/CodableScenarioStoreTests.swift`
- `igc-ios/InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests.swift`

Permitted documentation-only closeout changed in this correction round:

- `TASKS.md`
- `PROJECT_STATUS.md`
- `CHANGELOG.md`
- `handoffs/IOS_ENGINEER.md`

`docs/PRIVACY.md` did not require another edit: the correction adds no runtime
framework, dependency, collected-data flow, logging, or required-reason API.

No `shared/**`, accepted calculation/scenario/architecture/design/QA specification,
`DECISIONS.md`, `igc-pwa/**`, Settings source, signing file, capability or entitlement
was changed.

### Final test and build evidence

Environment:

- macOS 26.5 (25F5042g)
- Xcode 26.2 (17C52)
- Apple Swift 6.2.3 (`swiftlang-6.2.3.3.21`,
  `clang-1700.6.3.2`)
- iOS Simulator SDK 26.2 (23C53)
- iPhone 17 simulator, iOS 26.2 (23C54),
  `B8C76566-0A54-4ECF-BC13-A9CAEBF4307B`
- iPad Pro 13-inch (M5) simulator, iOS 26.2 (23C54),
  `95A18A80-BDFE-47BF-A8EE-264947EAB159`

Complete correction-round unit, direct-fixture and store suite: **40/40 passed**, zero
failures or skips. This includes all 18 accepted IGC-007 unit/fixture tests plus 22
IGC-012 model and store tests. The three new deterministic tests cover changed source
A-to-B evidence, a second corruption after reset and a valid store, and later-source
preservation failure blocking reset without changing source B. Result bundle:
`/private/tmp/igc-012-correction-unit-rerun.xcresult`.

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination \
  'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
  -derivedDataPath /private/tmp/igc-012-correction-unit-dd \
  -resultBundlePath /private/tmp/igc-012-correction-unit-rerun.xcresult \
  -only-testing:InvestmentGrowthCalculatorTests \
  CODE_SIGNING_ALLOWED=NO
```

Complete correction-round UI suite: **16/16 passed**, zero failures or skips in
355.902 seconds. This includes all 9 accepted IGC-007 UI tests plus 7 IGC-012
lifecycle/recovery tests. Save, populated/empty Saved, termination/relaunch
persistence, load and Save as new, rename, duplicate, delete
confirmation/Cancel/success, unavailable large Dynamic Type, corrupt/unsupported
recovery, and unavailable/corrupt/unsupported Projection Save gating are covered.
Result bundle: `/private/tmp/igc-012-correction-ui-complete.xcresult`.

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination \
  'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
  -derivedDataPath /private/tmp/igc-012-correction-ui-focused-dd \
  -resultBundlePath /private/tmp/igc-012-correction-ui-complete.xcresult \
  -only-testing:InvestmentGrowthCalculatorUITests \
  CODE_SIGNING_ALLOWED=NO
```

The new three-state Projection regression also passed alone before the complete run:

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination \
  'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
  -derivedDataPath /private/tmp/igc-012-correction-ui-focused-dd \
  -resultBundlePath /private/tmp/igc-012-correction-ui-focused.xcresult \
  -only-testing:InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests/testProjectionBlocksSaveWithAccessibleReasonForUnusableStores \
  CODE_SIGNING_ALLOWED=NO
```

Prior reviewed-head focused iPad adaptive tab/Saved-root smoke: **1/1 passed**, zero
failures or skips. It was not repeated in the correction round because no tab or
Saved-root source changed.
Result bundle: `/private/tmp/igc-012-ipad-smoke-frozen.xcresult`.

```sh
xcodebuild test \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination \
  'platform=iOS Simulator,id=95A18A80-BDFE-47BF-A8EE-264947EAB159' \
  -derivedDataPath /private/tmp/igc-012-ipad-dd-frozen \
  -resultBundlePath /private/tmp/igc-012-ipad-smoke-frozen.xcresult \
  -only-testing:InvestmentGrowthCalculatorUITests/InvestmentGrowthCalculatorUITests/testCleanLaunchShowsExactCustomBaselineAndStableTabs \
  CODE_SIGNING_ALLOWED=NO
```

Correction-round Debug and Release simulator builds both passed:

```sh
xcodebuild build \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Debug \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/igc-012-correction-debug-build \
  CODE_SIGNING_ALLOWED=NO

xcodebuild build \
  -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
  -scheme InvestmentGrowthCalculator -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath /private/tmp/igc-012-correction-release-build \
  CODE_SIGNING_ALLOWED=NO
```

Prior reviewed-head clean-install smoke passed: the app was explicitly uninstalled
from the iPhone 17 simulator, the reviewed Debug `.app` was installed, `simctl launch`
returned a live PID, and `/private/tmp/igc-012-clean-install-frozen.png` visually
confirms the accepted Custom Calculator baseline. The correction-round complete UI
suite repeatedly installs and launches the corrected app, including relaunch
persistence.

```sh
xcrun simctl uninstall \
  B8C76566-0A54-4ECF-BC13-A9CAEBF4307B uk.co.mochadesigns.igc
xcrun simctl install \
  B8C76566-0A54-4ECF-BC13-A9CAEBF4307B \
  /private/tmp/igc-012-debug-build-frozen/Build/Products/Debug-iphonesimulator/InvestmentGrowthCalculator.app
xcrun simctl launch \
  B8C76566-0A54-4ECF-BC13-A9CAEBF4307B uk.co.mochadesigns.igc
```

Relaunch persistence passed in
`testSavePopulatesSavedRootAndPersistsAcrossRelaunch`, which terminates and launches
the app with the same isolated Application Support test store and verifies the saved
record remains.

Prior reviewed-head offline-dependency smoke passed: the installed app relaunched with
standard HTTP and HTTPS directed to unreachable `127.0.0.1:9`, still presented the
normal Calculator, and `/private/tmp/igc-012-offline-proxy-smoke.png` confirms the
state. Correction-round static source inventory again found no network
transport/framework call or endpoint. `simctl` does not offer supported
radio/airplane-mode isolation, so this does not claim a hardware radio disconnect.

```sh
SIMCTL_CHILD_HTTP_PROXY=http://127.0.0.1:9 \
SIMCTL_CHILD_HTTPS_PROXY=http://127.0.0.1:9 \
xcrun simctl launch --terminate-running-process \
  B8C76566-0A54-4ECF-BC13-A9CAEBF4307B uk.co.mochadesigns.igc
```

Recovery/failure evidence is deterministic in `CodableScenarioStoreTests`: V1 exact
mapping; semantic/structural rejection; names and optional target; save/load/no-load
mutation; multiple/concurrent persistence; rename; duplicate; delete; sorting;
relaunch; store/scenario versions; corrupt preservation/reset; unavailable/protected
state; injected temporary-write, replacement and reload failures; last-readable
preservation; complete data-protection request; whole-document recovery; distinct
recovery evidence after a pre-reset source change; a second actor-lifetime corruption
episode; and a later-source preservation failure that leaves that source unchanged.

Repository checks passed after the documentation update:

```sh
git diff --check
git diff --quiet \
  be572a2825c4988b67049f21bdf8ea56c151c5c6 -- \
  shared igc-pwa docs/CALCULATION_SPEC.md docs/SCENARIO_SCHEMA.md \
  docs/IOS_ARCHITECTURE.md docs/DESIGN_SYSTEM.md docs/QA_PLAN.md DECISIONS.md
git status --short --branch
```

Generated-file inspection found no DerivedData, build, `.build`, `node_modules`,
`.xcresult`, `.xcarchive`, `.app` or `.dSYM` output in the repository. DerivedData,
result bundles, screenshots and simulator products remain under `/private/tmp`.

### Privacy, dependency and API inventory

The app remains first-party, local-only and free:

- no Swift package, XCFramework, CocoaPods, Carthage or third-party SDK;
- no URLSession/network framework, endpoint, account/backend/sync, CloudKit, App
  Group, analytics/crash SDK, remote configuration, StoreKit/payment or entitlement;
- no logging call for balances, contributions, targets, scenario names/IDs or recovery
  contents;
- persistence API surface is Foundation `FileManager`, `FileHandle`, `Data`,
  `JSONEncoder`/`JSONDecoder`, `ISO8601DateFormatter`, `UUID`, `Date`, and
  `FileProtectionType.complete`;
- none of the app’s used APIs is in Apple’s required-reason categories; no data is
  collected or tracked by the implementation.

Accordingly no `PrivacyInfo.xcprivacy` was added and no collected-data entry, tracking
declaration, domain or required-reason code was invented. The correction uses only the
same previously inventoried Foundation APIs, so the accepted `docs/PRIVACY.md`
implementation evidence remains accurate without another edit.

### Failed, retried, skipped and unavailable checks

- The first correction-round complete unit command stopped at compile time before any
  test ran because the matched recovery bytes were bound inside a switch case and used
  after that scope. The binding was moved to the reset function scope; the exact
  complete rerun above then passed 40/40. The failed result bundle is
  `/private/tmp/igc-012-correction-unit.xcresult` and is not counted as passing.

  ```sh
  xcodebuild test \
    -project igc-ios/InvestmentGrowthCalculator.xcodeproj \
    -scheme InvestmentGrowthCalculator -configuration Debug \
    -destination \
    'platform=iOS Simulator,id=B8C76566-0A54-4ECF-BC13-A9CAEBF4307B' \
    -derivedDataPath /private/tmp/igc-012-correction-unit-dd \
    -resultBundlePath /private/tmp/igc-012-correction-unit.xcresult \
    -only-testing:InvestmentGrowthCalculatorTests \
    CODE_SIGNING_ALLOWED=NO
  ```

- Initial sandboxed `xcresulttool` summary extraction lacked permission to create its
  temporary report directory. The same read-only extraction was retried with the
  required host permission and confirmed 40 passed unit tests and 16 passed UI tests,
  zero failures and zero skips. This was tooling-only and did not rerun or change tests.
- An early full UI run was interrupted while lifecycle status queries were being
  corrected; it is not counted as passing. Focused Save/relaunch, load/Save-as-new,
  rename/duplicate and delete tests passed before the originally reviewed complete
  15/15 run.
- The first focused iPad attempt used the phone-only `tabBars.buttons` query and failed
  “Missing stable Calculator tab” even though visual inspection showed the correct
  adaptive floating tab bar. A retry briefly failed to compile because the test loop
  variable shadowed its helper; the next run exposed duplicate accessibility wrappers
  for the adaptive Saved tab. The query was corrected to use `firstMatch`; the
  subsequent and final frozen-source iPad runs passed. No app navigation redesign was
  made.
- One early generic build session result became unavailable after its tool process
  closed. It is not counted. The explicit final Debug and Release builds above passed.
- The simulator may not expose an effective `.protectionKey` attribute. The test
  asserts the implementation’s `.complete` class and verifies the filesystem attribute
  when the simulator reports it; effective lock-state protection remains a
  physical-device/release gate.
- Physical-device testing was skipped by the specialist. The owner’s prior IGC-007
  Xcode 26.2/iOS 27 Home Screen smoke remains accepted; debugger-attached iOS 27
  execution still requires Xcode 27 or a device within the maintained Xcode 26.2
  support range. No workaround, logging, signing, capability or entitlement was added.
- Signed archive, privacy report, TestFlight, App Store Connect, upload, submission,
  StoreKit and external service checks were not run and remain explicitly excluded.

### Known limitations and exclusions

- The pre-existing minimal Settings placeholder still describes saved-scenario storage
  as later work. `Features/Settings/**` was outside the permitted IGC-012 file list and
  the Settings-wide coordinated data reset remains a later secondary-content task.
- Effective backup and data-protection behaviour needs final supported physical-device
  and signed-release review; the app copy deliberately uses the accepted system-backup
  caveat rather than promising no backup or irreversible erasure.
- Complete Education/disclaimer, appearance/onboarding persistence, Settings-wide
  reset, comparison, monthly UI, import/export/share/CSV, PWA migration,
  multi-currency, accounts/backend/sync/networking, analytics, premium/StoreKit,
  TestFlight and App Store work remain excluded.

### Review and rollback

Review:

1. Inspect the task history from the exact base, especially correction commit
   `5d6c757871d82709fab27b20f41c6b50f001c360`; verify only the listed permitted
   files changed and shared assets/fixture expectations are byte-for-byte unchanged.
2. Run the final unit and UI commands above, then the Debug and Release builds.
3. Inspect the exact-byte recovery matching and all three new store sequence tests
   before manual recovery testing.
4. Manually save two scenarios, terminate/relaunch, load one, verify Save as new,
   rename, duplicate and Cancel/confirm deletion, then exercise each recovery launch
   argument in a disposable simulator test store.
5. Reconfirm the privacy/dependency/API inventory before integration. Do not add a
   manifest without actual required evidence.

Rollback of only this correction should use ordinary `git revert` of the
documentation-only correction branch-tip commit and
`5d6c757871d82709fab27b20f41c6b50f001c360` in reverse order after Product Manager
review. Full task rollback additionally reverts the original reviewed documentation
and implementation commits. No migration or shared-contract rollback is needed
because this task has not been integrated or distributed.

At completion the isolated task worktree is clean. Nothing was pushed, merged,
uploaded, archived for distribution, submitted, sent to an external service, or used
to alter Apple Developer/App Store Connect resources.

## IGC-007 native vertical slice completed

Status: **Done — accepted and integrated**.

### Post-integration Product Manager gate

IGC-D019 records the later owner-run physical-device validation of the unchanged
integrated build. Xcode 26.2 successfully development-signed and installed it on an
iOS 27.0 iPhone; direct Home Screen launch and every requested manual smoke item
passed. Debugger-attached execution is explicitly skipped because Apple documents
Xcode 26.2 device support only through iOS 26.2. This is not an established IGC defect,
and no logging, signing, capability, or entitlement workaround is authorised. Future
attached debugging uses Xcode 27 on a compatible Mac for iOS 27, or a device within the
maintained Xcode toolchain’s device-support range. The original specialist “physical
device skipped” statement below remains accurate for the specialist execution phase
but is superseded for the Product Manager gate by IGC-D019.

IGC-D020 makes IGC-012 native scenario lifecycle **Ready** as the next iOS Engineer
task. Use only the reissued Product Manager prompt and its exact management-update
base; the earlier chat prompt based on
`212cf6056bd37ca22d5aff9db542f9aab4acdd19` is withdrawn.

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
