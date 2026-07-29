# IGC privacy review and release evidence

Status: Accepted planning baseline under IGC-D016 with IGC-012 source and simulator
build evidence — no signed release archive has been inspected
Task: IGC-008 (iOS / Shared), implementation evidence from IGC-012
Checked: 2026-07-28

## Scope and rule of interpretation

The implemented iOS slice is local calculation plus actor-backed Codable scenario
storage in private Application Support. Source, project, simulator-build and dependency
inventory for IGC-012 found no account, backend, sync, CloudKit, App Group, analytics,
advertising, tracking, contacts, financial-account connection, sensitive permission,
payment, StoreKit, remote configuration, export, sharing, or network transport. This
is implementation evidence, not signed-release-archive evidence.

For App Privacy, Apple defines “collect” as transmitting data off device so the developer or third party can access it beyond the time needed to service a real-time request. Data processed only on-device and never sent off-device is not collected for those questionnaire answers. Apple still requires developers to keep answers accurate as practices change. [App Privacy details](https://developer.apple.com/app-store/app-privacy-details/) (confirmed current requirement, checked 2026-07-28).

That definition does not mean local financial-planning information is risk-free or exempt from clear user disclosure, secure handling, deletion controls, or applicable privacy law. It only supports the provisional App Privacy answer below.

## Data inventory and lifecycle

| Data | Source / purpose | Expected storage / transmission | Retention and deletion | App Privacy position |
| --- | --- | --- | --- | --- |
| Starting balance, regular contribution, contribution frequency, APR/growth assumption, inflation, fee, compounding, duration, timing | User input; calculate a hypothetical projection | In-memory calculation; saved only when included in a scenario, in sandboxed Application Support | Draft data until changed/closed; saved data remains until individual deletion or app uninstall; the Settings-wide reset remains deferred, and device backup has its own lifecycle | **Implementation evidence:** financial-planning values remain on device; provisionally not “collected.” |
| Optional today-value target | User input; compare result against user goal | Same as calculation/scenario data | Same as above | **App-specific fact:** no transmission planned. |
| Scenario name | User-created label; scenario management | Codable scenario document; max 120 characters under schema | Individual delete or reset all; recovery copy may remain after corruption until user resolves it | **App-specific fact:** user content remains on device; do not put it in logs/screenshots/support tickets by default. |
| Preset ID and applied rates | Product selection / reproduce scenario | Codable scenario document; `presetId` can be `null` for Custom | With scenario; removed with it | **App-specific fact:** no transmission planned. |
| Stable scenario ID and created/updated timestamps | Local identity, ordering, CRUD/recovery | Codable scenario document | With scenario; fresh values on duplicate | **App-specific fact:** identifier is not an account/device ID; no transmission planned. |
| Appearance, onboarding, app-local selection preferences | User/device choice; present UI | Local app preferences/Application Support or UserDefaults, implementation to decide | Reset scope must be stated; app uninstall removes sandbox data subject to OS backup lifecycle | **App-specific fact:** no transmission planned. |
| Atomic-write/recovery metadata and unreadable document copy | Prevent data loss and enable user-directed recovery | App sandbox only; private `scenarios-v1.store.json` document plus recovery copies under the app’s Application Support area, protected with `FileProtectionType.complete` | Recovery evidence is retained when practical before a deliberate store reset; the unreadable source is not silently treated as empty or overwritten as sole evidence | **IGC-012 implementation evidence:** local recovery material is not diagnostics to the developer. |
| Crash logs, telemetry, performance data, support diagnostics | Excluded from 1.0 | Must not be added or transmitted | N/A | **App-specific fact:** excluded. Adding any service changes App Privacy answers and requires review. |

**Backup caveat — Product Manager recommendation:** say “saved scenarios are stored on this device” only with a qualification that normal system backups may have a separate Apple/device lifecycle. Do not claim end-to-end encryption, no backup, iCloud sync, or irreversible erasure unless archive/device testing and final policy substantiate it.

## Provisional App Privacy questionnaire decision table

These are planning answers, not submitted answers. Re-evaluate against the release archive, dependencies, manifests, network traces, logs, support workflow, and any Apple service configuration.

| Questionnaire topic/data type | Likely 1.0 answer under accepted facts | Classification / why | Mandatory release-time check |
| --- | --- | --- | --- |
| Does the developer collect data from this app? | **No** | **Release-time verification.** Data is intended to be local only. Apple says on-device-only data not sent to a server is not collected for these answers. [App Privacy details](https://developer.apple.com/app-store/app-privacy-details/) | Test offline; inspect network traffic, ATS exceptions, SDKs, app privacy report, crash/reporting configuration, and support links. |
| Other Financial Info (assets/balances/goals/contributions/rates) | **Not declared if the preceding answer remains No** | Apple lists assets/income/debts as Other Financial Info, but local-only values are not collected. If any leave device, classify/re-answer by actual purpose/linkage. | Search binary/source/configuration and test save/load/reset. |
| Other User Content (scenario names) | **Not declared if local only** | Generic scenario name is user-generated content; it must be declared if collected. | Confirm no names in logs, feedback, support prefill, or crash tools. |
| User ID / Device ID | **No** | No account, sign-in, IDFA, device identifier, or remote identifier is in accepted scope. Scenario UUID is local record identity, not a developer-held user ID. | Scan APIs/SDKs and outgoing requests. |
| Purchases / Payment Info | **No** | No StoreKit, subscription, payment, or purchase history. | Confirm no purchase framework/third-party payment code. |
| Diagnostics (crash/performance/other) | **No** | Analytics/crash diagnostics are excluded. Apple classifies crash/performance diagnostic data when collected. | Check Xcode, provider SDKs, TestFlight/production configuration, logs and backend endpoints. |
| Product Interaction / usage data | **No** | No analytics or remote collection. | Confirm no analytics/telemetry/remote config. |
| Linked to user | **No collected data to classify** | If later data is collected, Apple treats personal data as linked unless robust de-identification conditions are met. | Reassess each newly transmitted field and recipient. |
| Tracking | **No** | No collection, third-party data linking, ad measurement, data broker, or tracking domains. Apple says solely on-device linkage is not tracking. | Inspect manifests, domains, SDKs, ATT APIs and privacy report. |

Apple’s data types, purposes, linked-to-user criteria and tracking definition are set out in [App Privacy details](https://developer.apple.com/app-store/app-privacy-details/) (confirmed current requirement, checked 2026-07-28). Do not choose an “optional disclosure” exception as a shortcut: it has cumulative conditions and does not replace the local-only evidence above.

## Privacy policy and in-app disclosure plan

Apple requires a publicly accessible privacy-policy URL for the App Store product page and for iOS app information. [App Privacy details](https://developer.apple.com/app-store/app-privacy-details/), [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) (confirmed current requirement, checked 2026-07-28).

Before the store record is created, the owner must provide a public, owner-controlled policy URL and approve the policy. **Open owner input:** publisher/legal entity, support contact, policy URL, effective-date/change process, territories, and whether a separate privacy-choices URL is needed. This review does not draft legal terms or invent a URL.

**Product Manager recommendation:** the policy and an in-app Privacy/About route should accurately cover:

- educational purpose and that projections use user-controlled assumptions;
- local calculation and local scenarios, including balances/contributions/rates/targets/names;
- no account, backend, analytics, advertising, tracking, financial account connection, sharing, sync, payment, or live-market data in 1.0;
- offline operation and an explicit “no developer collection under the 1.0 design” statement only once verified;
- scenario deletion, reset-all scope, app-uninstall scope, backup caveat, and recovery/corrupt-file behaviour;
- no raw scenario content in normal diagnostic/support requests; a deliberate, consent-led support workflow if that changes;
- how users contact support and how policy/future-feature changes are communicated;
- age/children positioning only after the age-rating/category/territory decision. Do not select Made for Kids unless that is an intentional, separately assessed product choice.

## Data protection and lifecycle QA evidence

IGC-012 implements a private
`Application Support/InvestmentGrowthCalculator/SavedScenarios` directory and
`scenarios-v1.store.json` envelope version 1. The actor serialises reads and mutations,
writes and synchronises a protected temporary document, atomically replaces the
previous document, and re-reads before reporting success. Deterministic tests prove
that injected temporary-write and replacement failures preserve the previous readable
document; corrupt/unsupported input is all-or-recovery and copied before a deliberate
store reset where practical. Simulator filesystems do not always report an effective
protection attribute, so release/device validation of effective lock-state behaviour
remains required even though the implementation requests
`FileProtectionType.complete`.

| Concern | Classification | Required evidence before release |
| --- | --- | --- |
| Application Support and sandbox | **Release-time verification** | Inspect actual storage location and exclude unintended shared containers. Ensure no scenario value is written to UserDefaults, cache, console, analytics, or document-export path contrary to scope. |
| iOS data protection | **Release-time verification** | Record chosen protection class and test protected/unavailable states. Phrase public copy conditionally; device lock/passcode/OS/backup environment affect effective protection. |
| Atomic writes and corruption | **Release-time verification** | Integration tests must prove previous readable content survives failed replacement; corrupt/unsupported records are preserved where practical and recovery/reset is user-directed. |
| Delete one / reset all | **Release-time verification** | Demonstrate confirmation, mutation/reload, persistence across relaunch, truthful success/failure UI, and documented preference scope. |
| Backup and uninstall | **Open owner input** | Test documented behaviour where practical; policy states system backups have their own lifecycle. Do not promise deletion from backups. Confirm user-facing reset does not overclaim. |
| Logs, screenshots, support | **Release-time verification** | Test release configuration. Prohibit raw balances, scenario names, targets, IDs, and recovery files from console logs, breadcrumbs, crash reports, screenshot automation, and unsolicited support attachments. |
| Unknown schema | **Release-time verification** | Test safe refusal/preservation of unsupported versions; no partial decode or destructive migration. |

## Privacy manifests and required-reason APIs

Apple’s current framework requires privacy manifests to report data collection and required-reason APIs used by an app or SDK; all bundled manifests must be valid, and invalid manifest files can reject submission. [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [adding a privacy manifest](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk) (confirmed current requirement, checked 2026-07-28).

What can be decided now:

- **IGC-012 implementation evidence:** the Xcode project has no Swift package product,
  XCFramework, CocoaPods or other third-party dependency. The implemented persistence
  uses Foundation `FileManager`, `FileHandle`, `Data`, `JSONEncoder`/`JSONDecoder`,
  `ISO8601DateFormatter`, `UUID`, `Date`, and `FileProtectionType.complete`.
- **IGC-012 implementation evidence:** source inventory found no used API in Apple’s
  required-reason categories and no collection, tracking, analytics, ad network,
  cloud service, or tracking domain to declare. No `PrivacyInfo.xcprivacy` was added;
  adding an empty or invented manifest/reason code would not be evidence-based.
- **Product Manager recommendation:** retain the first-party-only policy unless a later approved exception includes a privacy/supply-chain review.

What remains release-time work:

- Recheck required-reason categories, collected-data entries, tracking domains,
  dependencies, embedded manifests and archive placement against the eventual signed
  Release archive. Generate Xcode’s privacy report before upload.

Release procedure: inventory project targets, Swift packages/XCFrameworks and APIs; generate Xcode’s privacy report; validate each manifest and required reason; inspect the archived `.app` contents; compare answers with App Privacy questionnaire/network evidence; document every exception. A new dependency, diagnostics provider, network call, app group, CloudKit, support form, web view, export/share flow, account, or payment feature is a privacy-review trigger.

## Legal and regulatory boundary

**Legal/regulatory review recommended:** the accepted intent is educational factual calculation, but investment terminology/presets/assumed returns/marketing can carry financial-promotion or advice risk. The FCA notes generic factual information may not be investment advice, while the actual boundary depends on context; it also states financial promotions must be fair, clear and not misleading. [FCA: investment decision support](https://www.fca.org.uk/firms/helping-firms-provide-more-support-customers-making-investment-decisions), [FCA: financial promotions](https://www.fca.org.uk/firms/financial-promotions-adverts) (checked 2026-07-28). Obtain advice before territory launch; this document offers no legal conclusion.
