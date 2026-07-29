# IGC iOS release checklist and risk register

Status: Accepted checklist under IGC-D016 — completed evidence is recorded below;
uncompleted release rows remain open
Task: IGC-008 (iOS / Shared)
Checked: 2026-07-29 for IGC-013 implementation evidence; Apple-rule baseline
2026-07-28

Classifications: **Confirmed current requirement**, **App-specific fact**, **Product Manager recommendation**, **Release-time verification**, **Open owner input**, and **Legal/regulatory review recommended**. Apple rules cited here were checked on the date above and must be rechecked before TestFlight and submission.

## Phase-gated checklist

| Gate / owner | Item | Classification | Evidence / status |
| --- | --- | --- | --- |
| Before Xcode project — Product Owner | Confirm Apple Developer Team/account ownership and reverse-DNS bundle identifier; retain provider/legal entity and final signing responsibility for the release record. | **Project identity confirmed / open release input** | IGC-D018 confirms `uk.co.mochadesigns.igc`, Team Name `Henry Berkin`, and Team ID `2FKVFS8X67`. The native project identity gate is complete. Provider/legal entity and final signing responsibility remain open for release operations; no different team is authorised. |
| Before App Store Connect record — Product Owner / PM | Decide App Store SKU convention (do not create record yet), category options, copyright owner/year, territories, support and privacy-policy owner/URLs. | **Open owner input** | Decision log/approved URLs. **Open**. |
| Before external beta/public copy — PM / Legal | Approve positioning and disclaimer strategy; assess UK/territory financial-promotion, advice, terminology/preset and trader-status risks. | **Legal/regulatory review recommended** | Counsel/owner disposition; approved copy boundaries. **Open**. |
| Project foundation / before distribution — iOS Engineer | Recheck current Apple upload SDK requirement; plan iOS 17 deployment target separately; identify iPhone-primary/adaptive iPad device support. | **Release-time verification** | **Foundation passed 2026-07-28:** iOS 17 target and adaptive iPhone/iPad settings verified with current Apple sources. Recheck before TestFlight/submission. |
| Project foundation — iOS Engineer | Create only approved target(s); set bundle ID/team/version/build; add no App Groups, iCloud/CloudKit, associated domains, StoreKit, push, accounts, payment, analytics or third-party SDKs. | **Release-time verification** | **Passed for IGC-007:** approved app/unit/UI targets, bundle/team/version/device families, and absence of unapproved capabilities/entitlements verified. Recheck after each feature task. |
| Project foundation — iOS Engineer | Establish dependency register and privacy-review approval for every package/SDK; retain first-party-only policy for 1.0. | **Product Manager recommendation** | **Passed for IGC-007:** Foundation, Charts, SwiftUI, and UIKit only; no package/third-party SDK. Recheck after each feature task. |
| Physical-device foundation — Product Owner / PM | Development-sign, install, launch, and smoke-test the integrated vertical slice on an iPhone; classify unsupported toolchain/device combinations honestly. | **Release-time verification** | **Passed under IGC-D019:** Xcode 26.2 signed/installed on iOS 27.0; direct Home Screen launch and all requested smoke items passed. Debugger-attached execution skipped because Apple lists Xcode 26.2 device support through iOS 26.2. |
| Project foundation — iOS Engineer / QA | Design storage in Application Support with data protection, atomic writes, recovery copy, safe unknown-schema handling, delete-one/reset-all. | **Release-time verification** | **Implementation pass through IGC-013, review pending:** the accepted IGC-012 store remains unchanged for ordinary CRUD/recovery; IGC-013 adds separately confirmed complete scenario-directory/recovery erasure, owned-preference reset, authoritative re-reads, no-false-success partial failure and relaunch/retry evidence. Final supported-device/data-protection and release-archive recheck remains open. No atomic cross-store or absolute encryption claim. |
| Feature-complete — PM / Designer | Ensure calculator/results/education communicate assumptions, hypothetical nature and limitations; remove personal recommendation, guarantee, regulated-service, account/live-data/payment implications. | **Legal/regulatory review recommended** | **Implementation pass for restrained development/internal-beta content, review pending:** bundled hierarchy, methodology, exclusions, glossary, exact authorised disclaimer and contextual routes are implemented and covered. Final external-beta/public copy approval and UI screenshots remain **Open**. |
| Feature-complete — iOS Engineer | Verify offline calculation/scenario lifecycle; no network calls, accounts, permissions, tracking, analytics, support diagnostics or exports/sharing. | **Release-time verification** | **Implementation pass through IGC-013, review pending:** complete suites, unreachable-proxy Education/context routes and static source/project/optimized-bundle inventories pass; no runtime endpoint, embedded SDK or listed excluded surface was found. Release-candidate network/privacy report/archive and supported-device recheck remain open. |
| Feature-complete — QA / Designer | Validate Dynamic Type, VoiceOver, contrast, dark mode, Reduce Motion, keyboard/focus, legible validation, text alternative for chart, iPhone and adaptive iPad layouts. | **Release-time verification** | **Partial implementation pass:** IGC-007 evidence remains accepted; IGC-013 adds automated accessibility hierarchy/focus, accessibility-size Dark Mode compact-iPhone content, adaptive iPad routes and full iPhone regressions. Manual spoken VoiceOver order/focus, Increase Contrast measurement, Bold Text, supported physical-device and release-candidate matrix remain open. |
| Feature-complete — iOS Engineer / App Store Reviewer | Inventory all APIs and dependencies; author/validate actual privacy manifest only when justified; generate privacy report and match it to questionnaire answers. | **Release-time verification** | **Implementation pass for simulator bundle, review pending:** app-only UserDefaults is isolated to two stable keys; source and Debug/Release manifests parse; optimized Release app-root manifest declares only `NSPrivacyAccessedAPICategoryUserDefaults` / `CA92.1`; no collected-data/tracking entry, third-party dependency, endpoint, capability or entitlement addition was found. Signed archive placement and generated Xcode privacy report remain **Open**. |
| Before TestFlight — QA | Run unit/fixture/persistence/accessibility/device/offline/reset/recovery tests; record passed, failed and skipped tests. | **Release-time verification** | CI/device results. **Open**. |
| Before TestFlight — Product Owner / App Store Reviewer | Verify release archive built with currently required Xcode/SDK; inspect architectures, target/platforms, signed entitlements, capabilities, icon asset processing and binary contents. | **Release-time verification** | Archive report and dated SDK-rule check. **Open**. |
| Before TestFlight — App Store Reviewer | Prepare beta description, test focus and feedback email; answer export-compliance questions from actual cryptography evidence. | **Release-time verification** | App Store Connect TestFlight fields and export response. **Open**. |
| Before TestFlight — PM / QA | Make a privacy policy/support page live, verify URLs/contact details and policy/UI alignment; complete provisional App Privacy decision review. | **Release-time verification** | Public URL test and questionnaire evidence. **Open**. |
| Release candidate — Designer / QA | Capture truthful screenshots: iPhone 6.9-inch and iPad 13-inch because native iPad support is intended; 1–10 non-transparent JPEG/JPG/PNG images per device class. | **Release-time verification** | Validated upload-ready assets; no future/native-excluded features. [Screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) |
| Release candidate — PM / App Store Reviewer | Finalise name/subtitle, description, keywords, category, age-rating questionnaire, copyright, primary language, support/privacy URLs, reviewer contact and notes. | **Open owner input** | Metadata sheet and owner approval. **Open**. |
| Before record/submission — Product Owner | Create App Store Connect record only after immutable SKU/bundle/provider decisions; choose territories and answer EU trader-status prompt as applicable. | **Open owner input** | Record settings checked by Account Holder. Apple requires an EU DSA trader declaration when distributing in the EU. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) |
| Submission — App Store Reviewer | Select processed release build, supply complete accurate metadata/privacy information, export compliance, age rating, screenshots and reviewer instructions. | **Confirmed current requirement** | Submission record. **Open**. |
| After upload / pre-review — QA / App Store Reviewer | Recheck processed build warnings, App Privacy label, entitlement/privacy manifest output, screenshot rendering, support/privacy URLs, reviewer access, and release setting. | **Release-time verification** | Dated pre-review sign-off. **Open**. |
| Post-release — Product Owner / Support | Monitor support contact, privacy-policy accuracy, deletion/recovery reports and App Review changes; re-review before any data/SDK/network/monetisation scope change. | **Product Manager recommendation** | Change log and periodic owner review. **Open**. |

Apple currently requires a public privacy-policy URL for iOS, accurate metadata, an age rating, and platform version fields including required support URL; it requires Xcode 26+/iOS 26 SDK+ for uploads since 2026-04-28. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/), [platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information), [upcoming requirements](https://developer.apple.com/news/upcoming-requirements/). TestFlight’s beta-information, external-review and 90-day rules are documented in [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview).

## Submission blockers and decisions

### Confirmed current submission blockers

- No iOS archive exists and therefore no current-Xcode/current-SDK upload evidence exists.
- Required public privacy-policy and support URLs have no owner-provided values.
- Required App Privacy answers, age-rating answers, version metadata, screenshots, reviewer contact/notes and export-compliance response cannot be completed honestly without a built release candidate.

### Likely blockers dependent on implementation

- Archive inspection must establish actual entitlements/capabilities, icon processing, device family/architecture, dependencies, privacy manifests/required-reason APIs, network behaviour and diagnostic/logging configuration.
- QA must demonstrate offline operation, calculation fixture parity, adaptive iPad/accessibility support, delete/reset/recovery, and that no unapproved local data is disclosed.

### Owner inputs

- Provider/legal entity and final signing ownership. Bundle identifier
  `uk.co.mochadesigns.igc`, Team Name `Henry Berkin`, and Team ID `2FKVFS8X67` are
  confirmed in IGC-D018.
- App Store SKU, provider/legal entity, copyright, category, territories and EU trader status if relevant.
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

Before project creation, TestFlight, and final submission recheck Apple’s App Review Guidelines, upload SDK, App Privacy definitions, screenshot specifications, app information/version fields, privacy manifests, age-rating questions, export compliance, TestFlight and territorial/trader requirements. The above sources are a 2026-07-28 snapshot, not perpetual policy.

## Open risk register

| Risk / decision | Owner / timing | Impact | Mitigation and evidence needed |
| --- | --- | --- | --- |
| Physical debugger/device OS exceeds maintained Xcode support | iOS Engineer/QA; physical debugging and RC | Debugger/logging failures can be misclassified as app defects | Under IGC-D019 use Xcode 27 on a compatible Mac for iOS 27, or a device within the maintained Xcode range; do not add project workarounds without separate evidence. |
| Provider/legal entity and final signing owner unresolved; project identity confirmed | Product Owner; before App Store record/release | Project work can begin, but distribution ownership/metadata could be wrong if guessed | IGC-D018 records `uk.co.mochadesigns.igc`, `Henry Berkin`, and `2FKVFS8X67`; approve provider/legal entity and release signing responsibility before record/archive distribution. |
| SKU / provider / copyright unresolved | Product Owner; before App Store Connect record | Immutable SKU/publisher metadata could be wrong | Approved record inputs before creation. |
| Privacy/support URLs absent | Product Owner/PM; before TestFlight/release | Required metadata blocked; no reliable user contact | Public reachable pages, correct entity/contact, policy/UI/App Privacy consistency. |
| Finance category/positioning and financial-promotion/advice boundary | PM/Legal; before public copy or territory choice | App Review ambiguity; legal/regulatory exposure | Legal review, final claims/preset/“APR” review; reviewer note; no advice/guarantee/regulated-service implication. |
| Age rating / child positioning undecided | Product Owner/PM; before record submission | Required field wrong; Kids obligations if elected | Complete latest questionnaire from final content; do not mark Made for Kids without separate decision. |
| Screenshot set depends on unbuilt design | Designer/QA; release candidate | Misleading/invalid metadata; iPad screenshot requirement missed | 6.9-inch iPhone and 13-inch iPad validation; truthful completed states and legibility checks. |
| App Privacy “no collection” could be invalidated by binary/dependency/network | iOS Engineer/App Store Reviewer; feature complete and RC | Incorrect App Privacy label/review issue | Dependency/API/privacy report, network trace, manifest/archive inspection; repeat on every scope change. |
| Local data deletion/recovery/backups copy unclear | iOS Engineer/PM/QA; feature complete | User harm, inaccurate privacy claims | Persistence/reset/corruption tests; approved plain language distinguishing app-local delete from backup lifecycle. |
| Diagnostics/logs remain excluded | iOS Engineer/PM; every build | Financial scenarios could leak/require disclosures | Release-log inspection; no raw scenarios in console/breadcrumb/crash/support data; formal change review if added. |
| Accessibility/offline claims not evidenced | Designer/QA; RC | Misleading metadata, usability/review risk | Device/simulator evidence for Dynamic Type, VoiceOver, contrast, motion, chart alternative, iPad and offline flows. |
| Encryption/export response unknown | iOS Engineer/Product Owner; every TestFlight/release upload | Build may be Missing Compliance | Determine real cryptography and complete current questionnaire; retain Apple response evidence. |
| EU/UK territories and trader status unknown | Product Owner/Legal; record creation | Incorrect territory/legal disclosures | Distribution plan and, if EU, App Store Connect trader declaration. Legal review of UK scope. |
| Future monetisation | PM/App Store Reviewer; before feature design | Payments rule, purchase/privacy/support scope change | Separate accepted task and current Apple-policy review before code/metadata/product IDs. |

## Suggested release notes to App Review (draft evidence outline)

**Product Manager recommendation; not final copy:** explain that IGC is a free, offline educational projection calculator. Users enter their own assumptions; results are hypothetical and not personal advice or guarantees. It has no login, account link, transactions, payment, live market data or reviewer credentials. Saved scenarios are held locally; identify the Settings/Saved Scenarios delete/reset controls and the assumption/disclaimer route. Ensure the release candidate proves every statement.
