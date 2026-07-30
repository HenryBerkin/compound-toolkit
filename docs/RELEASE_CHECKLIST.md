# IGC iOS release checklist and risk register

Status: Accepted checklist under IGC-D016 — completed evidence is recorded below;
uncompleted release rows remain open
Task: IGC-008 (iOS / Shared)
Checked: 2026-07-30 for the signed local release candidate and current Apple rules

Classifications: **Confirmed current requirement**, **App-specific fact**, **Product Manager recommendation**, **Release-time verification**, **Open owner input**, and **Legal/regulatory review recommended**. Apple rules cited here were checked on the date above and must be rechecked before TestFlight and submission.

## Phase-gated checklist

| Gate / owner | Item | Classification | Evidence / status |
| --- | --- | --- | --- |
| Before Xcode project — Product Owner | Confirm Apple Developer Team/account ownership and reverse-DNS bundle identifier; retain provider/legal entity and final signing responsibility for the release record. | **Project identity confirmed / open release input** | IGC-D018 confirms `uk.co.mochadesigns.igc`, Team Name `Henry Berkin`, and Team ID `2FKVFS8X67`. The native project identity gate is complete. Provider/legal entity and final signing responsibility remain open for release operations; no different team is authorised. |
| Before App Store Connect record — Product Owner / PM | Approve the immutable SKU and user access; confirm the latest agreement, explicit Bundle ID eligibility and name availability. Do not create the record without separate approval. | **Passed 2026-07-30** | Owner-approved values were used. Explicit App ID `uk.co.mochadesigns.igc` was registered under Team `2FKVFS8X67`; Apple accepted **Investment Growth Calculator** and created iOS app ID `6796327865` with English (U.K.), SKU `IGC-IOS-001` and Full Access. Version `1.0` is **Prepare for Submission**. |
| Before external beta/public copy — PM / Legal | Approve positioning and disclaimer strategy; assess UK/territory financial-promotion, advice, terminology/preset and trader-status risks. | **Legal/regulatory review recommended** | Counsel/owner disposition; approved copy boundaries. **Open**. |
| Project foundation / before distribution — iOS Engineer | Recheck current Apple upload SDK requirement; plan iOS 17 deployment target separately; identify iPhone-primary/adaptive iPad device support. | **Release-time verification** | **Passed 2026-07-30:** Apple currently requires Xcode 26+ and iOS 26+ SDK; the candidate uses stable Xcode 26.6 (17F113), iOS 26.5 SDK, iOS 17 deployment, and explicit iPhone/iPad orientation metadata. Recheck only if upload is delayed or the rule changes. |
| Project foundation — iOS Engineer | Create only approved target(s); set bundle ID/team/version/build; add no App Groups, iCloud/CloudKit, associated domains, StoreKit, push, accounts, payment, analytics or third-party SDKs. | **Release-time verification** | **Passed for the signed candidate:** app/unit/UI targets, `uk.co.mochadesigns.igc`, Team `2FKVFS8X67`, version `1.0 (1)`, iPhone+iPad family, and absence of unapproved capabilities/entitlements verified. |
| Project foundation — iOS Engineer | Establish dependency register and privacy-review approval for every package/SDK; retain first-party-only policy for 1.0. | **Product Manager recommendation** | **Passed for the signed candidate:** no package, embedded framework or third-party SDK; system-framework boundary unchanged. |
| Physical-device foundation — Product Owner / PM | Development-sign, install, launch, and smoke-test the integrated vertical slice on an iPhone; classify unsupported toolchain/device combinations honestly. | **Release-time verification** | **Passed under IGC-D019:** Xcode 26.2 signed/installed on iOS 27.0; direct Home Screen launch and all requested smoke items passed. Debugger-attached execution skipped because Apple lists Xcode 26.2 device support through iOS 26.2. |
| Project foundation — iOS Engineer / QA | Design storage in Application Support with data protection, atomic writes, recovery copy, safe unknown-schema handling, delete-one/reset-all. | **Release-time verification** | **Product Manager-accepted implementation pass through IGC-013:** the accepted IGC-012 store remains unchanged for ordinary CRUD/recovery; IGC-013 adds separately confirmed complete scenario-directory/recovery erasure, owned-preference reset, authoritative re-reads, no-false-success partial failure and relaunch/retry evidence. Final supported-device/data-protection and release-archive recheck remains open. No atomic cross-store or absolute encryption claim. |
| Feature-complete — PM / Designer | Ensure calculator/results/education communicate assumptions, hypothetical nature and limitations; remove personal recommendation, guarantee, regulated-service, account/live-data/payment implications. | **Legal/regulatory review recommended** | **Product Manager-accepted implementation pass for restrained development/internal-beta content:** bundled hierarchy, methodology, exclusions, glossary, exact authorised disclaimer and contextual routes are implemented and covered. Final external-beta/public copy approval and UI screenshots remain **Open**. |
| Feature-complete — iOS Engineer | Verify offline calculation/scenario lifecycle; no network calls, accounts, permissions, tracking, analytics, support diagnostics or exports/sharing. | **Release-time verification** | **Passed through the signed candidate:** accepted unreachable-proxy evidence remains applicable; archive inventory contains no embedded framework, extension or added service/capability. No network or excluded product surface was introduced. |
| Feature-complete — QA / Designer | Validate Dynamic Type, VoiceOver, contrast, dark mode, Reduce Motion, keyboard/focus, legible validation, text alternative for chart, iPhone and adaptive iPad layouts. | **Release-time verification** | **Partial implementation pass:** IGC-007 evidence remains accepted; IGC-013 adds automated accessibility hierarchy/focus, accessibility-size Dark Mode compact-iPhone content, adaptive iPad routes and full iPhone regressions. Manual spoken VoiceOver order/focus, Increase Contrast measurement, Bold Text, supported physical-device and release-candidate matrix remain open. |
| Feature-complete — iOS Engineer / App Store Reviewer | Inventory all APIs and dependencies; author/validate actual privacy manifest only when justified; generate privacy report and match it to questionnaire answers. | **Release-time verification** | **Archive inspection passed:** signed app-root manifest parses and declares only `NSPrivacyAccessedAPICategoryUserDefaults` / `CA92.1`; no collected-data/tracking declaration, dependency, endpoint, added capability or entitlement was found. The optional human-readable Xcode Organizer privacy report and final App Privacy answers remain release operations. |
| Before TestFlight — QA | Run unit/fixture/persistence/accessibility/device/offline/reset/recovery tests; record passed, failed and skipped tests. | **Release-time verification** | **Automated gate passed 2026-07-30 on iOS 26.5:** 56/56 unit/fixture/store/content/preference/reset/privacy tests; 23/23 iPhone UI tests including landscape, accessibility sizing, GBP locale, persistence/recovery/reset; focused iPad route 1/1. Zero failures or skips. Earlier supported offline-proxy evidence remains applicable. Manual spoken VoiceOver/contrast/Bold Text on a supported physical pairing remains advisable before external beta, not an internal-upload blocker. Result bundles: `/private/tmp/igc-rc-unit-ios265.xcresult`, `/private/tmp/igc-rc-ui-ios265.xcresult`, `/private/tmp/igc-rc-ipad-ios265.xcresult`. |
| Before TestFlight — Product Owner / App Store Reviewer | Verify release archive built with currently required Xcode/SDK; inspect architectures, target/platforms, signed entitlements, capabilities, icon asset processing and binary contents. | **Release-time verification** | **Passed locally 2026-07-30:** `/private/tmp/IGC-1.0-rc.xcarchive` built with Xcode 26.6 / iOS 26.5 SDK; Xcode result has 0 errors, warnings and analyzer warnings. Archive is arm64 iOS, iOS 17+, iPhone+iPad, validly development-signed by Team `2FKVFS8X67`, and contains no extension/framework. App icon processing contains opaque sRGB 1024×1024 `AppIcon` renditions for phone and pad. iPhone supports portrait and both landscapes; iPad supports all four orientations. This local development archive is not an uploaded or App Store-distribution-signed build. |
| Before TestFlight — App Store Reviewer | Prepare beta description, test focus and feedback email; answer export-compliance questions from actual cryptography evidence. | **Release-time verification** | App Store Connect TestFlight fields and export response. **Open**. |
| Before TestFlight — PM / QA | Make a privacy policy/support page live, verify URLs/contact details and policy/UI alignment; complete provisional App Privacy decision review. | **Release-time verification** | **Public URL gate passed 2026-07-30:** `https://igc.mochadesigns.co.uk/privacy` and `https://igc.mochadesigns.co.uk/support` are owner-controlled Cloudflare Pages routes; clean URLs redirect to the approved static pages, the custom domain is Active with SSL, and Support identifies `support@mochadesigns.co.uk`. No analytics, tracking, Function, database or paid service is enabled. Final App Privacy questionnaire entry remains a later App Store Connect operation. |
| Release candidate — Designer / QA | Capture truthful screenshots: iPhone 6.9-inch and iPad 13-inch because native iPad support is intended; 1–10 non-transparent JPEG/JPG/PNG images per device class. | **Release-time verification** | Validated upload-ready assets; no future/native-excluded features. [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) |
| Release candidate — PM / App Store Reviewer | Finalise name/subtitle, description, keywords, category, age-rating questionnaire, copyright, primary language, support/privacy URLs, reviewer contact and notes. | **Open owner input** | Metadata sheet and owner approval. **Open**. |
| Record setup / before submission — Product Owner | Create the App Store Connect record after immutable SKU/bundle approval; choose territories and answer EU trader-status prompts as applicable before distribution. | **Record passed / distribution inputs open** | Record `6796327865` was created as approved. Territory, pricing/availability and applicable EU DSA trader declarations remain later owner operations. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) |
| Submission — App Store Reviewer | Select processed release build, supply complete accurate metadata/privacy information, export compliance, age rating, screenshots and reviewer instructions. | **Confirmed current requirement** | Submission record. **Open**. |
| After upload / pre-review — QA / App Store Reviewer | Recheck processed build warnings, App Privacy label, entitlement/privacy manifest output, screenshot rendering, support/privacy URLs, reviewer access, and release setting. | **Release-time verification** | Dated pre-review sign-off. **Open**. |
| Post-release — Product Owner / Support | Monitor support contact, privacy-policy accuracy, deletion/recovery reports and App Review changes; re-review before any data/SDK/network/monetisation scope change. | **Product Manager recommendation** | Change log and periodic owner review. **Open**. |

Apple currently requires a public privacy-policy URL for iOS, accurate metadata, an age rating, and platform version fields including required support URL; it requires Xcode 26+/iOS 26 SDK+ for uploads since 2026-04-28. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/), [platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [upcoming requirements](https://developer.apple.com/news/upcoming-requirements/). TestFlight’s beta-information, external-review and 90-day rules are documented in [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview).

## Submission blockers and decisions

### Confirmed current submission blockers

- Final App Privacy, age-rating, metadata, screenshots, reviewer contact/notes,
  export-compliance and territory/trader responses remain open.
- The current archive is local and development-signed. Distribution export/upload and
  processed-build validation require explicit owner approval and App Store Connect.

### Engineering position

No known native engineering defect blocks an internal TestFlight upload. The signed
candidate, complete automated suites, archive contents, manifest, icon and orientation
metadata pass. Remaining work is owner/release operation or advisable manual quality
evidence unless a processed build or beta test reveals a defect.

### Owner inputs

- Provider/legal entity and final signing ownership. Bundle identifier
  `uk.co.mochadesigns.igc`, Team Name `Henry Berkin`, and Team ID `2FKVFS8X67` are
  confirmed in IGC-D018.
- App Store record `6796327865`, SKU `IGC-IOS-001` and Full Access are fixed.
  Provider/legal entity, copyright, category, territories and EU trader status remain
  later inputs.
- Support, privacy-policy and optional marketing URLs plus support contact.
- Final age-rating questionnaire responses and release mode.
- Device-backup policy/copy and whether diagnostics remain excluded.

### Product Manager recommendations

- Select Finance vs Utilities/Productivity only after reviewing final positioning; preserve “educational projection, not advice” across all channels.
- Use a simple `1.0.0` public version and monotonically increase build strings.
- Capture only actual iOS 1.0 states; use visible limitation context without burying copy.
- Keep first-party-only dependencies and no diagnostics/network scope through 1.0 unless separately approved.

### Deferred future-feature triggers

- Any StoreKit, premium feature, subscription, payment, entitlement, web checkout or cross-platform purchase: current payments/policy review, new metadata/privacy/export/support review. Apple’s current guideline requires In-App Purchase for in-app digital feature unlocks. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- Accounts, backend, CloudKit/sync, App Group, export/sharing, support upload, live market data, financial-account connection, analytics/crash reporting, advertising/tracking, permissions, new territories/currencies, comparison, or new data types: privacy/data-lifecycle/App Privacy/reviewer-note reevaluation.

### Official-rule rechecks

Before TestFlight upload and final submission recheck Apple’s App Review Guidelines,
upload SDK, App Privacy definitions, screenshot specifications, app information/version
fields, privacy manifests, age-rating questions, export compliance, TestFlight and
territorial/trader requirements. The upload SDK and Xcode compatibility sources were
rechecked 2026-07-30; other source checks retain their recorded dates.

## Open risk register

| Risk / decision | Owner / timing | Impact | Mitigation and evidence needed |
| --- | --- | --- | --- |
| Physical debugger/device OS exceeds maintained Xcode support | iOS Engineer/QA; physical debugging and RC | Debugger/logging failures can be misclassified as app defects | Stable Xcode 26.6 supports devices through iOS 26.5, while the owner device runs iOS 27. Under IGC-D019 use Xcode 27 on a compatible Mac for iOS 27, or a supported device; do not add project workarounds without separate evidence. |
| Provider/legal entity and final signing owner unresolved; project identity confirmed | Product Owner; before App Store record/release | Project work can begin, but distribution ownership/metadata could be wrong if guessed | IGC-D018 records `uk.co.mochadesigns.igc`, `Henry Berkin`, and `2FKVFS8X67`; approve provider/legal entity and release signing responsibility before record/archive distribution. |
| Provider / copyright unresolved | Product Owner; before metadata completion | Publisher metadata could be wrong | Approve the provider/legal entity and copyright line before submission; SKU is already fixed as `IGC-IOS-001`. |
| Finance category/positioning and financial-promotion/advice boundary | PM/Legal; before public copy or territory choice | App Review ambiguity; legal/regulatory exposure | Legal review, final claims/preset/“APR” review; reviewer note; no advice/guarantee/regulated-service implication. |
| Age rating / child positioning undecided | Product Owner/PM; before record submission | Required field wrong; Kids obligations if elected | Complete latest questionnaire from final content; do not mark Made for Kids without separate decision. |
| Screenshot set not yet captured | Designer/QA; public release candidate | Misleading/invalid metadata; iPad screenshot requirement missed | Capture 6.9-inch iPhone and 13-inch iPad states from the accepted build; validate truthful content and legibility. |
| App Privacy “no collection” could be invalidated by binary/dependency/network | iOS Engineer/App Store Reviewer; feature complete and RC | Incorrect App Privacy label/review issue | Dependency/API/privacy report, network trace, manifest/archive inspection; repeat on every scope change. |
| Local data deletion/recovery/backups copy unclear | iOS Engineer/PM/QA; feature complete | User harm, inaccurate privacy claims | Persistence/reset/corruption tests; approved plain language distinguishing app-local delete from backup lifecycle. |
| Diagnostics/logs remain excluded | iOS Engineer/PM; every build | Financial scenarios could leak/require disclosures | Release-log inspection; no raw scenarios in console/breadcrumb/crash/support data; formal change review if added. |
| Accessibility/offline claims not evidenced | Designer/QA; RC | Misleading metadata, usability/review risk | Device/simulator evidence for Dynamic Type, VoiceOver, contrast, motion, chart alternative, iPad and offline flows. |
| Encryption/export response unknown | iOS Engineer/Product Owner; every TestFlight/release upload | Build may be Missing Compliance | Determine real cryptography and complete current questionnaire; retain Apple response evidence. |
| EU/UK territories and trader status unknown | Product Owner/Legal; record creation | Incorrect territory/legal disclosures | Distribution plan and, if EU, App Store Connect trader declaration. Legal review of UK scope. |
| Future monetisation | PM/App Store Reviewer; before feature design | Payments rule, purchase/privacy/support scope change | Separate accepted task and current Apple-policy review before code/metadata/product IDs. |

## Suggested release notes to App Review (draft evidence outline)

**Product Manager recommendation; not final copy:** explain that IGC is a free, offline educational projection calculator. Users enter their own assumptions; results are hypothetical and not personal advice or guarantees. It has no login, account link, transactions, payment, live market data or reviewer credentials. Saved scenarios are held locally; identify the Settings/Saved Scenarios delete/reset controls and the assumption/disclaimer route. Ensure the release candidate proves every statement.
