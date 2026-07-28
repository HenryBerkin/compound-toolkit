# IGC App Store submission review

Status: Accepted planning baseline under IGC-D016 — not a submission readiness
certification
Task: IGC-008 (iOS / Shared)
Checked: 2026-07-28
Scope: Native iOS 1.0 only; no App Store Connect record, native binary, or store action exists.

## Classification and review position

| Item | Classification | Review position / required action |
| --- | --- | --- |
| Product is an offline educational investment-growth projection calculator, not advice, a forecast, brokerage, bank, trading service, account aggregator, or live-data service. | **App-specific fact** | Preserve this boundary in the binary, metadata, screenshots, support material, and review notes. |
| Values are hypothetical, user-controlled assumptions; no outcome is guaranteed. | **App-specific fact** | Make assumptions and limitations legible near input/result flows; do not market assumed rates or presets as recommendations or likely outcomes. |
| Apple requires accurate, current metadata, screenshots, previews, and privacy information. | **Confirmed current requirement** | Verify each against the release candidate; Guideline 2.3 requires customers to know what they get. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (checked 2026-07-28). |
| Apple can scrutinise apps in highly regulated fields and sensitive-information services; its review guidance calls out banking and financial services. | **Confirmed current requirement** | IGC should plainly establish that it provides neither a regulated financial service nor sensitive-account access. If its final content moves closer to a regulated service, provider/entity and evidence must be reassessed. [App Review overview](https://developer.apple.com/app-store/review/) (checked 2026-07-28). |
| A concise “educational, not financial advice” statement removes all App Review or legal risk. | **Not a valid conclusion** | It helps accurate positioning but does not itself determine regulatory status or prevent a misleading-claims rejection. |
| UK legal treatment of the calculator, names such as “APR”, presets, claims, territories, and marketing needs specialist advice before public launch. | **Legal/regulatory review recommended** | FCA guidance distinguishes factual information from a personal recommendation, but scope depends on final facts. Avoid any buy/sell/hold prompt, suitability language, personalised product selection, performance promise, or FCA-regulated implication pending advice. [FCA: investment decision support](https://www.fca.org.uk/firms/helping-firms-provide-more-support-customers-making-investment-decisions), [FCA: financial promotions](https://www.fca.org.uk/firms/financial-promotions-adverts) (checked 2026-07-28). |

### Recommended reviewer explanation

**Product Manager recommendation:** put a short plain-language disclaimer in the calculator/results/education journey, with a more complete limitations page. It should say the app is an educational projection using user-entered assumptions; it does not give personal advice, guarantee returns, connect to accounts, execute transactions, or use live market data. Legal/PM must approve final wording. Do not imply the PWA’s existing wording is adequate for native review.

**App-specific PWA evidence inspected:** the web `AssumptionsPanel` says results are deterministic examples rather than a market-path forecast and lists excluded factors; `index.html`/the generated manifest describe it as working offline. Its manifest and icon files are PWA-only evidence, not native App Store assets or proof that native disclosures, accessibility, data handling, or metadata are compliant.

In App Review notes, explain that no account or reviewer login is needed; calculations and scenarios work offline; scenario data stays on-device; and the app has local delete-one/reset-all behaviour. Include how to reach those controls in the release candidate.

## Owner-controlled identity and record setup

| Input | Classification | Decision / consequence |
| --- | --- | --- |
| Public name: `Investment Growth Calculator` | **App-specific fact** | It is 28 characters, within Apple’s 2–30-character name limit, but availability/acceptance remains a release-time check. Do not create or reserve a record in this task. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) |
| Display/icon shorthand: `IGC` | **App-specific fact** | Use only as supporting identity; it must not make the app look like an investment firm or product. |
| Bundle identifier and reverse-DNS namespace | **App-specific fact — confirmed** | IGC-D018 fixes `uk.co.mochadesigns.igc`. The explicit App ID and application target must match it. Bundle ID cannot be changed after upload. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) |
| Apple Developer Team, signing ownership, Account Holder access | **Partly confirmed / open owner input** | Team ID `2FKVFS8X67` is owner-confirmed. Confirm the exact Team Name, legal/operational owner, signing responsibility, and Account Holder access before project creation. Do not share individual credentials, use a Personal Team, or invent a team name. |
| App Store SKU | **Open owner input** | Select immediately before the App Store Connect record; it is internal, immutable after creation, and may use letters/numbers/hyphens/periods/underscores (not a leading punctuation mark). [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/) |
| Provider/legal entity and copyright | **Open owner input** | The version metadata requires a copyright owner/year; decide whether the publisher is an individual or legal entity after the regulated-content review. |
| Privacy-policy and support URLs | **Open owner input** | A public privacy-policy URL is required for iOS; support URL is required version information and must provide usable contact details. No URL is invented here. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/), [platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information) |
| Primary category | **Open owner input** | Choose the category that best describes the final binary. **PM recommendation:** Finance is intuitive but raises financial-service expectations; Utilities or Productivity may fit a standalone calculator. Select only after legal/marketing review; an optional secondary category must not misrepresent scope. |
| App Groups, iCloud/CloudKit, associated domains, StoreKit, payment | **Release-time verification** | Scope excludes all of these in 1.0. Archive entitlements and capability settings must prove their absence; associated domains are also unnecessary unless a future support/web feature specifically needs them. |

**Product Manager recommendation:** start `1.0.0` with monotonically increasing build strings (for example `1`, then `2`); use semantic-looking public versions only if release policy adopts them. Apple identifies a build by bundle ID, version number, and build string. [Upload builds](https://developer.apple.com/help/app-store-connect/manage-builds/upload-builds/)

## Technical upload and binary checks

| Topic | Classification | Release-time evidence |
| --- | --- | --- |
| Upload toolchain | **Confirmed current requirement** | Since 2026-04-28, App Store Connect uploads require Xcode 26 or later and an iOS 26 (or later) SDK. This is separate from the accepted iOS 17 deployment target. Recheck immediately before archive/upload. [Upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) (checked 2026-07-28). |
| Supported devices/architectures | **Release-time verification** | Confirm supported iPhone/iPad device family, iOS 17 minimum, valid App Store archive architectures, launch on physical iPhone and adaptive iPad, and no unintended platforms/extensions. No project exists to inspect. |
| Privacy manifest / required-reason APIs | **Release-time verification** | Apple privacy manifests describe collected data and required-reason API use; invalid bundled manifests cause submission rejection. Do not fabricate one before source/dependencies/API inventory exists. Inspect the archive and every dependency after project creation. [Privacy manifest files](https://developer.apple.com/documentation/bundleresources/privacy-manifest-files), [adding a privacy manifest](https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk) |
| Icons and launch assets | **Release-time verification** | Create an Asset Catalog and validate Xcode/App Store processing. The PWA PNG/SVG assets are visual reference only, not proof of native asset conformance. |
| Entitlements/capabilities | **Release-time verification** | Record the signed entitlement report and capability list; expected 1.0 result is no iCloud, App Group, associated-domain, push, Sign in with Apple, Health, contacts, payments, or StoreKit capability. |
| Encryption/export compliance | **Release-time verification** | Each TestFlight build must answer export-compliance questions or supply approved documentation; determine actual cryptography use from the archive and Apple’s current questionnaire. System transport/storage protections must not be assumed to settle the answer. [TestFlight export compliance](https://developer.apple.com/help/app-store-connect/test-a-beta-version/provide-export-compliance-information-for-beta-builds) |
| Age rating | **Open owner input** | Age rating is required; Apple’s updated questionnaire applies and must be answered from the final binary/content, not guessed as “4+”. [App information](https://developer.apple.com/help/app-store-connect/reference/app-information/app-information/), [upcoming requirements](https://developer.apple.com/news/upcoming-requirements/) |
| TestFlight | **Confirmed current requirement** | Provide beta description, test focus and feedback email. External testing can require beta App Review; builds expire after 90 days. [TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview) |

## Metadata inventory

| Field | Classification | Requirement / planned treatment |
| --- | --- | --- |
| Name / subtitle | **Release-time verification** | Name: 2–30 characters; subtitle: max 30. Validate final localised fields and availability. |
| Promotional text / description / keywords | **Product Manager recommendation** | Promotional text max 170 characters; description max 4,000; keywords max 100 bytes, each over two characters. Draft only after PM/legal review; describe actual local calculation, GBP/UK-English scope and limitations, without unsupported accessibility/offline claims. [Platform version information](https://developer.apple.com/help/app-store-connect/reference/app-information/platform-version-information) |
| Category, copyright, age rating, primary language | **Open owner input** | Complete from approved owner inputs; primary language should be English (UK) only if the final localisation is actually en-GB. |
| Privacy/support/marketing URLs | **Open owner input** | Privacy and support URLs are required; marketing URL is optional. URLs must be live and owner-controlled at submission. |
| Review notes/contact | **Release-time verification** | Provide reviewer contact and clear offline/no-login navigation instructions. Apple asks for full review access and explanations of non-obvious functionality. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) |
| Disclaimers and assumptions | **Legal/regulatory review recommended** | Align words, screenshots, UI and review notes. Do not hide limitations in a support URL or claim regulator approval. |

No final marketing copy is approved by this review.

## Screenshots, previews, and accessibility evidence

Apple accepts 1–10 JPEG/JPG/PNG screenshots per required device size without alpha/transparency. An iPhone app requires a 6.9-inch set or, if absent, a 6.5-inch set; an app running on iPad requires 13-inch iPad screenshots. Current pixel alternatives are maintained in Apple’s [screenshot specifications](https://developer.apple.com/help/app-store-connect/reference/app-information/screenshot-specifications/) (checked 2026-07-28).

**Release-time plan:** capture only completed iOS 1.0 states on a current supported 6.9-inch iPhone and 13-inch iPad simulator/device: calculator assumptions; projected result with limitation context; annual detail/text alternative; saved scenarios and delete/reset location; and education/assumptions. Add an optional preview only if it represents the finished app. Verify large text/legibility and do not crop in a way that hides warnings.

**Design dependencies:** IGC-005 is accepted under IGC-D017 and supplies the intended
native hierarchy and visual rules; IGC-006 supplies the reproducible
accessibility/device evidence once implementation exists. Do not show comparison,
monthly native detail, CSV/export, premium, account, sync, portfolio connection, live
prices, payment, or fabricated feature states.

## Monetisation boundary

**App-specific fact:** 1.0 is free, offline, and has no StoreKit, premium UI, subscription, payment, or cross-platform entitlement.

**Confirmed current requirement:** if a later iOS release unlocks digital features/functionality, Guideline 3.1.1 requires In-App Purchase, subject to current storefront-specific rules. That change needs a new privacy, StoreKit, metadata, age-rating, export-compliance, and App Review review before implementation. [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) (checked 2026-07-28).

## Submission risk summary

### Confirmed current blockers

- No compliant archive exists; upload cannot occur until it is built with the currently required Xcode/SDK.
- No public privacy-policy or support URL has been selected/provided.
- No App Privacy answers, required age-rating responses, screenshots, final metadata, reviewer contact/notes, or export-compliance response exist.

### Likely implementation-dependent blockers

- Archive cannot demonstrate accurate privacy manifest/required-reason API/dependency declarations, entitlements, icon assets, architecture/device support, or actual no-network/no-analytics behaviour yet.
- Metadata and screenshots cannot accurately represent an unbuilt app.

### Release-time official-rule rechecks

Re-open every linked Apple page before TestFlight and before submission. Apple describes the Review Guidelines as living rules; category, age-rating, screenshot, SDK, App Privacy, export, territory/trader, and payment rules can change.
