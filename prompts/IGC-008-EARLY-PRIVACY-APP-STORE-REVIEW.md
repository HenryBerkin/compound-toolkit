# Standalone specialist prompt — IGC-008 early privacy and App Store review

You are the App Store and Privacy Reviewer for **Investment Growth Calculator** (IGC).
Complete **IGC-008 — Early privacy and App Store risk review** as a documentation-only,
evidence-backed review. Do not submit an app, create store records, or begin native
implementation.

## Thread and work isolation

- Exact thread name: `IGC-008 — Early Privacy & App Store Review`
- Recommended model: `gpt-5.6-sol`
- Recommended reasoning effort: `xhigh`
- Repository: `HenryBerkin/compound-toolkit`
- Exact accepted base commit:
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`
- Worktree: required
- Worktree path: `/private/tmp/igc-008-app-store-privacy-review`
- Branch: `codex/igc-008-app-store-privacy-review`

Create an isolated worktree and the named branch from the exact base commit. Do not
work on or merge into `project/ios-migration-audit`. IGC-005 and IGC-006 may run in
parallel from the same base, so do not edit or assume their unaccepted deliverables.

## Read before reviewing

Read these files completely:

- `AGENTS.md`
- `PROJECT_STATUS.md`
- `TASKS.md`
- `DECISIONS.md`
- `docs/PRODUCT_SPEC.md`
- `docs/CALCULATION_SPEC.md`
- `docs/SCENARIO_SCHEMA.md`
- `docs/PLATFORM_STRATEGY.md`
- `docs/PWA_AUDIT.md`
- `docs/IOS_ARCHITECTURE.md`
- `handoffs/APP_STORE_REVIEWER.md`
- `handoffs/IOS_ENGINEER.md`
- `handoffs/PRODUCT_MANAGER.md`
- `shared/schemas/scenario-v1.schema.json`
- `shared/examples/scenario-v1.example.json`

Inspect PWA user-facing disclaimers, assumptions, privacy-relevant behavior, manifest,
icons, and metadata as evidence. Do not assume the web copy is sufficient for native
submission.

## Source and classification rules

This review is time-sensitive and high stakes:

- browse current official Apple primary sources;
- use direct Apple Developer/App Store Connect links near each current requirement;
- prefer App Review Guidelines, Apple Developer documentation, App Store Connect Help,
  and current Apple requirement pages;
- use official UK government/FCA sources only when a UK regulatory risk needs to be
  flagged;
- do not rely on blogs, search-result snippets, forum speculation, or remembered rules;
- state the date each volatile requirement was checked;
- keep quotations short and otherwise paraphrase.

Classify every material item as one of:

- **Confirmed current requirement**
- **App-specific fact**
- **Product Manager recommendation**
- **Release-time verification**
- **Open owner input**
- **Legal/regulatory review recommended**

Do not present recommendations or assumptions as Apple requirements. Do not give a
definitive legal opinion.

## Accepted product and architecture facts

- Native SwiftUI app, minimum iOS 17, iPhone-primary/adaptive iPad.
- Public/intended App Store name: `Investment Growth Calculator`.
- Shorthand/icon identity: `IGC`.
- UK English and GBP-only in 1.0.
- Educational investment-growth projection, not advice, forecast, brokerage, bank,
  trading platform, portfolio connection, or live market-data service.
- Local calculation and local actor-backed Codable scenario storage.
- Scenario data includes balances, contributions, rates, optional target, user name for
  a scenario, preset ID, and timestamps.
- No account, sign-in, backend, sync, CloudKit, App Group, analytics, advertising,
  tracking, contacts, financial-account connection, sensitive permission, payment,
  StoreKit, subscription, premium UI, or remote configuration.
- No export or sharing in native 1.0.
- Delete/reset behavior is required; system device backups may have their own lifecycle.
- All 1.0 functionality is free and works offline.
- Native comparison is deferred to iOS 1.1.
- Exact bundle identifier and Apple Developer Team are owner inputs before project
  creation; App Store SKU is an owner input before creating the App Store Connect
  record.
- No Xcode project or native implementation exists, so code-dependent declarations
  must be framed as release-time checks.

## Objective and deliverables

Produce:

- `docs/APP_STORE_SUBMISSION.md`
- `docs/PRIVACY.md`
- `docs/RELEASE_CHECKLIST.md`

These documents must identify current policy/privacy risks and turn them into an
actionable pre-project, implementation, TestFlight, and submission checklist without
claiming an unbuilt app is compliant.

## Required coverage — App Store submission

### 1. Product classification and review positioning

Assess how to describe IGC accurately:

- educational projection calculator;
- no personalised recommendations or guaranteed results;
- no transactions, custody, brokerage, banking, account aggregation, or market data;
- assumptions and limitations visible;
- potential financial-services/regulated-content ambiguity to avoid.

Identify any current App Review Guidelines relevant to financial content, misleading
claims, data handling, minimum functionality, metadata, or review access. Separate
Apple review risk from UK legal/regulatory risk.

### 2. App identity and owner-controlled setup

Define pre-project/store-record inputs:

- public name and App Store name length/availability check;
- bundle identifier/reverse-DNS namespace;
- Apple Developer Team/signing ownership;
- App Store SKU timing;
- primary category and realistic alternatives;
- copyright/provider name;
- support and privacy-policy ownership;
- version/build numbering recommendation;
- absence of App Groups, iCloud, associated domains, and StoreKit capabilities.

Do not invent final identifiers, legal entity names, URLs, category, SKU, or signing
team. Provide decision-ready options and consequences where owner input is required.

### 3. Toolchain and technical submission requirements

Verify current official requirements for:

- Xcode and iOS SDK used for upload;
- distinction between upload SDK and iOS 17 deployment target;
- supported architectures and device family at a checklist level;
- privacy manifests and required-reason APIs, while acknowledging no code exists;
- app icons/asset requirements at a checklist level;
- export-compliance questions;
- entitlements/capabilities;
- current age-rating questionnaire;
- TestFlight and App Review information.

Do not prescribe code or create project files.

### 4. Metadata and store presence

Inventory:

- name, subtitle, promotional text, description, keywords, category;
- privacy-policy URL, support URL, marketing URL if used;
- copyright;
- age rating;
- screenshots and optional previews;
- localization/UK-English positioning;
- review notes and contact information;
- disclaimer/assumptions positioning;
- accessibility and offline/local-first claims that require implementation evidence.

Verify current field requirements and limits from App Store Connect Help. Do not write
final marketing copy unless clearly labelled draft/recommendation.

### 5. Screenshot and device obligations

Verify current screenshot requirements and define a release-time plan for:

- iPhone;
- adaptive iPad support;
- representative states without fabricated functionality;
- accessibility/legibility;
- no comparison, monthly native detail, CSV, premium, account, or sync implication.

IGC-005 may be in parallel; record design dependencies rather than inventing its
screens.

### 6. Review notes and financial-content risk

Recommend evidence/review notes explaining:

- all calculations are local;
- assumptions are user-controlled;
- outputs are hypothetical educational projections;
- no advice, guarantee, live data, account access, payment, or transaction;
- no reviewer account is needed;
- saved scenarios are local;
- delete/reset behavior;
- offline operation.

Identify wording requiring Product Manager or legal review. Do not claim a disclaimer
alone eliminates regulatory or App Review risk.

### 7. Monetisation deferral

Record that 1.0 has no StoreKit, premium access, subscription, payment, or cross-platform
entitlement. Summarise—not redesign—the future review trigger: any paid digital feature
requires a new current-policy review. Do not add purchase metadata or product IDs.

## Required coverage — privacy

### 8. Data inventory and flow

Map each data category:

- calculator inputs;
- scenario names;
- optional target;
- rates/preset;
- timestamps and stable IDs;
- appearance/onboarding preferences;
- local error/recovery data;
- potential logs/crash diagnostics, currently excluded.

For each, state source, purpose, storage, transmission, retention/deletion, backup
consideration, and whether the developer currently collects it under Apple's current
definitions. Distinguish local device processing from developer collection.

### 9. App Privacy answers

Using current official definitions:

- provide a decision table for likely App Privacy questionnaire answers under accepted
  1.0 facts;
- clearly mark answers that cannot be final until the binary, dependencies, logging,
  support tooling, and network behavior are verified;
- cover tracking, linked-to-user, not-linked, diagnostics, identifiers, financial
  information, user content, and purchases where relevant;
- do not infer “no privacy issue” merely because data is local.

Do not submit answers or create an App Store Connect record.

### 10. Privacy policy and in-app disclosure

Define required/recommended policy sections:

- product purpose;
- local processing;
- local scenarios and optional target;
- no account/backend/analytics/tracking/advertising;
- offline behavior;
- device backup caveat;
- deletion/reset scope;
- retention and corrupt recovery copy;
- support contact;
- changes/future features;
- children's/age positioning only if current requirements make it relevant.

Verify current Apple requirements for privacy-policy availability. Do not invent a URL
or final legal text.

### 11. Data protection and lifecycle

Review architecture assumptions for:

- Application Support storage;
- iOS sandbox/system data protection;
- no absolute encryption claim;
- backup behavior;
- atomic writes;
- corruption preservation;
- delete one/reset all;
- app uninstall;
- logs and screenshots;
- unsupported schema;
- support diagnostics without scenario disclosure.

Identify copy and QA evidence needed before release.

### 12. Privacy manifest and required-reason APIs

Explain:

- what can be decided before code exists;
- what must be inventoried after project/dependency creation;
- first-party-only policy implications;
- release-time archive inspection;
- why a privacy manifest should not be fabricated now.

Use current Apple sources.

## Required coverage — release checklist

### 13. Phase-gated checklist

Create an owner/status/evidence checklist covering:

- before Xcode project creation;
- during project foundation;
- before feature-complete;
- before TestFlight;
- before release candidate;
- before App Store Connect record/submission;
- after upload/pre-review;
- post-release/support.

Include Product Owner, iOS Engineer, Designer, QA, App Store Reviewer, and legal review
where applicable.

### 14. Submission blockers versus recommendations

Provide separate lists for:

- confirmed blockers;
- likely blockers dependent on implementation;
- owner inputs;
- PM recommendations;
- deferred future-feature triggers;
- release-time official-rule rechecks.

Do not mark unexecuted items complete.

### 15. Open decisions and risk register

At minimum cover:

- bundle identifier/team/SKU;
- support and privacy URLs;
- provider/legal entity/copyright;
- category;
- age rating answers;
- screenshot set;
- disclaimer/legal review;
- device backup policy/copy;
- diagnostics remaining excluded or later added;
- distribution territories and UK/EU trader-status implications;
- encryption/export questions;
- accessibility evidence;
- future monetisation review trigger.

For each risk, give owner, timing, impact, mitigation, and evidence needed.

## Files you may edit

Only:

- `docs/APP_STORE_SUBMISSION.md`
- `docs/PRIVACY.md`
- `docs/RELEASE_CHECKLIST.md`
- `handoffs/APP_STORE_REVIEWER.md`
- `TASKS.md` — IGC-008 status and verification fields only
- `PROJECT_STATUS.md` — IGC-008 review-state update only
- `CHANGELOG.md` — one concise IGC-008 entry only

Do not edit:

- `DECISIONS.md`;
- any other handoff;
- accepted product, calculation, scenario, platform, architecture, design, or QA docs;
- `shared/`;
- `igc-pwa/`;
- `igc-ios/` or any native project/source/configuration;
- prompts for other tasks.

If current official guidance conflicts with accepted scope, document the exact rule,
source, date checked, consequence, and decision needed. Do not silently change the
product or architecture.

## Explicit non-goals

Do not:

- create an Xcode project, code, entitlements, privacy manifest, metadata file, signing
  asset, App Store Connect record, TestFlight build, submission, or legal document;
- contact Apple, the FCA, a lawyer, or external parties;
- implement analytics, consent, network, account, payment, or privacy tooling;
- add StoreKit/premium scope;
- certify compliance or provide definitive legal advice;
- start IGC-005, IGC-006, or IGC-007;
- dispatch another specialist or merge branches.

## Required completion handoff

When work begins, set only IGC-008 to `In progress`. Mark it `Ready for review` only
after all three deliverables and checks are complete.

Before completion:

1. verify every volatile requirement against current official primary sources;
2. verify citations resolve and appear near supported claims;
3. verify requirement/recommendation/fact/open-input classifications are consistent;
4. verify the three documents agree on data handling, owner inputs, and blockers;
5. run `git diff --check` before committing;
6. confirm contracts, PWA, native implementation, and other specialist deliverables are
   unchanged;
7. commit the documentation-only result with a focused message;
8. run `git diff --check
   c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a..HEAD`;
9. confirm the working tree is clean.

Return:

- status: `Ready for review`;
- thread name;
- branch and worktree path;
- base commit;
- final commit SHA;
- files changed;
- executive privacy/App Store assessment;
- confirmed current submission blockers;
- owner inputs and Product Manager decisions required;
- legal-review flags without legal conclusions;
- official sources used and date checked;
- checks run, passed, failed, skipped, or not applicable;
- explicit confirmation that no App Store action, native implementation, or IGC-007
  work began.
