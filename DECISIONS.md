# IGC decisions

## IGC-D001 — Build a native SwiftUI application

- Date: 2026-07-28
- Status: Accepted
- Context: the working product is a React PWA, but the intended destination is the
  Apple App Store.
- Decision: rebuild the approved 1.0 experience in SwiftUI. Do not ship a web-view
  wrapper unless a later decision formally supersedes this one.
- Rationale: native interaction, accessibility, maintainability, and platform fit.
- Alternatives: web-view wrapper; continued PWA-only development.
- Consequences: calculation and behavioural parity must be specified and tested.

## IGC-D002 — Preserve the PWA as an isolated reference

- Date: 2026-07-28
- Status: Accepted
- Context: the PWA currently occupies the repository root.
- Decision: retain its tracked source and historical documentation under `igc-pwa/`;
  keep project-wide coordination at the root.
- Rationale: makes the native rebuild explicit while retaining a recoverable oracle.
- Alternatives: leave mixed root layout; delete or archive the PWA externally.
- Consequences: PWA commands run from `igc-pwa/`; relocation must not change behaviour.
  IGC-D006 extends its role from recoverable reference to a supported
  product surface without reversing the repository placement.

## IGC-D003 — Keep the initial product local-first

- Date: 2026-07-28
- Status: Accepted
- Context: the PWA performs all calculations locally and stores only preferences and
  scenarios in browser storage; future cross-platform premium access could introduce
  pressure for accounts and a backend.
- Decision: the initial iOS release and maintained free PWA should require no account,
  backend, analytics, advertising, subscription, cloud sync, or sensitive permission.
- Rationale: matches proven behaviour and reduces privacy, policy, and delivery risk.
- Alternatives: accounts/iCloud sync; telemetry; unified entitlements; monetisation in
  the first release.
- Consequences: local persistence and clear reset/delete behaviour are required.
  Scenario identifiers and schemas should remain versionable and portable enough not to
  obstruct a later, separately approved synchronisation design.

## IGC-D004 — Preserve the verified calculation model before improving it

- Date: 2026-07-28
- Status: Accepted
- Context: the PWA has 58 passing calculation tests and non-obvious timing conventions.
- Decision: port the documented model and fixture outputs first. Any mathematical or
  terminology improvement requires a separate decision and parity impact assessment.
- Rationale: avoids accidental product change during a platform rebuild.
- Alternatives: redesign the model while porting.
- Consequences: Swift tests must cover monthly simulation, frequency conversion, fees,
  inflation, contribution timing, partial years, and boundaries.

## IGC-D005 — Use GBP and UK English in 1.0

- Date: 2026-07-28
- Status: Accepted
- Context: all current formatting, examples, and defaults use GBP and `en-GB`.
- Decision: keep UK English and GBP-only presentation in 1.0; defer multi-currency
  support. Versioned scenario data must explicitly identify `GBP` so the schema is
  currency-ready without exposing currency selection or conversion.
- Rationale: limits scope and preserves a coherent existing product.
- Alternatives: locale-driven display; currency picker.
- Consequences: App Store metadata and screenshots must make the intended market clear.

## IGC-D006 — Treat iOS and PWA as coherent supported product surfaces

- Date: 2026-07-28
- Status: Accepted
- Context: recovery initially described the PWA mainly as a frozen behavioural
  reference, but the product may continue on the web alongside native iOS.
- Decision: IGC has a responsive maintained PWA and will have a native SwiftUI
  application.
  iOS remains the immediate release priority. Shared product behaviour must be explicit,
  while each client keeps platform-appropriate interface and lifecycle behaviour.
- Rationale: preserves the useful web product, broadens access, and avoids making the
  native rebuild the only maintained surface.
- Alternatives: freeze the PWA; replace it with iOS; force identical interfaces.
- Consequences: requirements, tasks, QA, and release notes must identify Shared, iOS, or
  Web scope. PWA maintenance cannot silently expand iOS 1.0.

## IGC-D007 — Use a shared specification and fixtures, not shared runtime code

- Date: 2026-07-28
- Status: Accepted
- Context: Swift and TypeScript implementations must produce consistent financial
  outputs without introducing a web view or cross-language runtime dependency.
- Decision: define a language-neutral calculation/validation specification and portable
  fixtures consumed by both clients. Maintain native Swift and TypeScript engines.
- Rationale: makes parity testable while preserving native architecture and simple web
  delivery.
- Alternatives: duplicate undocumented behaviour; embed JavaScript in iOS; build a
  cross-platform calculation service.
- Consequences: fixture/schema versioning and change control become required; intentional
  model changes must update both clients and shared evidence.

## IGC-D008 — Stage premium access and defer unified entitlements

- Date: 2026-07-28
- Status: Accepted
- Context: cross-platform premium access could require StoreKit, web payments, accounts,
  verification, backend entitlements, privacy disclosures, and ongoing support.
- Decision: ship no premium implementation in the initial scope. Preserve a replaceable
  feature-entitlement boundary in architecture. If early monetisation becomes required,
  prefer a simple iOS StoreKit entitlement before considering unified accounts.
- Rationale: avoids backend and identity complexity before product demand and premium
  value are proven.
- Alternatives: independent platform purchases immediately; unified accounts and
  entitlements immediately.
- Consequences: commercial parity may arrive later; migrations must be designed before
  any paid web or iOS entitlement is sold.

## IGC-D009 — Defer native scenario comparison to iOS 1.1

- Date: 2026-07-28
- Status: Accepted
- Context: the PWA supports comparing two saved scenarios, but this workflow adds
  navigation, visualisation, accessibility, and QA scope to the first native release.
- Decision: retain two-scenario comparison in the supported PWA and defer it from native
  iOS 1.0 to iOS 1.1. Native 1.0 still supports multiple saved scenarios and a model
  capable of later comparison.
- Rationale: keeps the first native release focused without deleting a supported web
  capability or creating a single-scenario persistence dead end.
- Alternatives: ship comparison in native 1.0; remove comparison from both clients.
- Consequences: comparison is an explicit temporary platform difference and must not be
  presented as iOS 1.0 parity.

## IGC-D010 — Keep native 1.0 detail annual and without export

- Date: 2026-07-28
- Status: Accepted
- Context: the PWA exposes monthly and annual detail plus CSV download, while native
  file-sharing and dense monthly presentation would expand first-release scope.
- Decision: native iOS 1.0 presents annual detail only and has no CSV export. The shared
  engine continues to calculate monthly rows. The PWA retains monthly detail and CSV.
- Rationale: annual detail answers the primary planning question while preserving the
  calculation granularity and a straightforward later native enhancement path.
- Alternatives: native monthly detail without export; full monthly/export parity.
- Consequences: monthly correctness remains a shared test requirement even though the
  native 1.0 UI does not expose monthly rows.

## IGC-D011 — Make the accepted baseline explicitly Custom

- Date: 2026-07-28
- Status: Accepted
- Context: the PWA initially displays the Global Index preset while its default 0.20%
  fee does not match that preset's 0.40% fee.
- Decision: the initial state is Custom with £10,000 principal, £250 monthly
  contribution, 7% APR, 3% inflation, 0.20% annual fee, monthly compounding, 15 years,
  and start-of-period contributions. The Global Index preset and its 0.40% fee apply
  only after deliberate selection.
- Rationale: preserves the verified baseline result and makes preset state truthful.
- Alternatives: apply Global Index by default; define a new default preset.
- Consequences: both clients need an explicit Custom state. Editing a preset-controlled
  assumption returns the state to Custom. Correcting the existing PWA selector is a
  separately verified Web change.

## IGC-D012 — Use Investment Growth Calculator as the public name

- Date: 2026-07-28
- Status: Accepted
- Context: repository and historical package names differ from the visible IGC brand,
  and App Store metadata needs one clear naming hierarchy.
- Decision: the public product and intended App Store name is
  `Investment Growth Calculator`; shorthand and icon identity use `IGC`; long-form
  marketing may use `IGC — Investment Growth Calculator`.
- Rationale: the public name explains the utility while IGC remains a compact,
  recognisable identity.
- Alternatives: `IGC` alone; a combined short App Store name.
- Consequences: final App Store availability and metadata still require release-time
  verification. Historical package, storage, and repository identifiers need not be
  destructively renamed.

## IGC-D013 — Target iOS 17 with adaptive iPad compatibility

- Date: 2026-07-28
- Status: Accepted
- Context: the native architecture needs a deployment target and initial device-family
  boundary before framework and navigation choices are proposed.
- Decision: native 1.0 has a minimum deployment target of iOS 17. It is iPhone-primary
  and adaptively iPad-compatible, without requiring a bespoke iPad experience.
- Rationale: provides a modern SwiftUI baseline while retaining meaningful device
  coverage and avoiding an unnecessary iPad-specific design track.
- Alternatives: iOS 16, iOS 18, or current-major-only; iPhone-only; bespoke universal
  layouts in 1.0.
- Consequences: architecture and QA must cover supported iPhone sizes, Dynamic Type,
  rotation where supported, and sensible adaptive iPad layouts. App Store uploads use
  the then-required current Xcode and SDK independently of this deployment target.

## IGC-D014 — Adopt the proportionate native iOS architecture

- Date: 2026-07-28
- Status: Accepted
- Context: IGC-004 evaluated native structure, persistence, shared-fixture parity,
  feature availability, accessibility, privacy, testing, and delivery sequencing for
  the accepted local-first iOS 1.0.
- Decision: use one SwiftUI app module with feature folders and feature-local state,
  first-party frameworks only, a pure binary64 calculation core, direct consumption of
  the root shared fixtures by native tests, an actor-backed Codable Application Support
  scenario store, and a minimal local-free feature-availability seam. Defer SwiftData,
  packages, third-party dependencies, StoreKit, accounts, networking, sync, analytics,
  remote configuration, and backend services until an accepted requirement justifies
  them.
- Rationale: fits the small offline product, preserves calculation and scenario
  boundaries that are expensive to recover later, and avoids speculative infrastructure.
- Alternatives: SwiftData persistence; multiple Swift packages; third-party routing,
  dependency-injection, persistence, or entitlement frameworks; no availability seam.
- Consequences: the native engine and validator must pass the version 1 shared fixture
  gate before feature expansion. The Product Owner must confirm the reverse-DNS bundle
  identifier and Apple Developer Team before Xcode project creation. App Store SKU is
  confirmed before creating the App Store Connect record. App Groups and iCloud remain
  absent from 1.0 unless a later accepted decision introduces them.

## IGC-D015 — Adopt the cross-platform behavioural QA inventory

- Date: 2026-07-28
- Status: Accepted
- Context: IGC-006 translated the accepted Shared, iOS, and Web behavior into traceable
  test identifiers, evidence requirements, platform-specific matrices, defect handling,
  and staged release gates.
- Decision: adopt `docs/QA_PLAN.md` as the version 1 behavioural QA inventory. Require
  independent Swift and TypeScript consumers of the root shared fixtures, exact
  platform-difference testing, explicit planned-versus-executed evidence, and the
  documented calculation, persistence, accessibility, Web regression, and release
  gates.
- Rationale: prevents fixture drift, makes intentional Web/iOS differences testable,
  and stops observed PWA defects or unexecuted native plans from being reported as
  accepted or passing behavior.
- Alternatives: separate untraced platform checklists; fixture-only parity; treating
  PWA behavior as the complete native oracle.
- Consequences: the IGC-005 design assertions accepted in IGC-D017 are traced into the
  marked native QA suites; IGC-008 privacy/App Store requirements accepted in IGC-D016
  receive their detailed trace during release-test implementation. Browser-support
  policy and known Web-defect prioritisation remain separate Product Manager decisions;
  this inventory does not claim that future native or release tests have executed.

## IGC-D016 — Adopt the early privacy and App Store release-risk baseline

- Date: 2026-07-28
- Status: Accepted
- Context: IGC-008 reviewed the accepted local-first iOS 1.0 architecture against
  current Apple submission, privacy, metadata, TestFlight, screenshot, and release
  requirements before native implementation exists.
- Decision: adopt `docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`, and
  `docs/RELEASE_CHECKLIST.md` as the planning and release-evidence baseline. Treat “no
  developer data collection” as provisional until the release binary, dependencies,
  manifests, logs, support path, and network behaviour verify the local-only design.
  Keep owner-controlled identifiers, URLs, publisher/category/territory choices, and
  final legal positioning unresolved until their documented gates.
- Rationale: establishes accurate early constraints without claiming compliance for an
  unbuilt app or inventing owner/legal decisions.
- Alternatives: defer all review until a release candidate; treat local-only intent as
  sufficient evidence; create App Store records or declarations before owner inputs.
- Consequences: every volatile Apple rule is rechecked before TestFlight and
  submission; the actual archive controls privacy-manifest, export-compliance, and App
  Privacy answers. Final financial-content claims and territory choices require
  Product Manager/owner approval and legal review where documented. No App Store
  submission, record creation, native implementation, or compliance certification is
  authorised by this decision.

## IGC-D017 — Adopt the native design and interaction system

- Date: 2026-07-28
- Status: Accepted
- Context: IGC-005 translated the accepted native scope and architecture into an
  implementation-ready screen hierarchy, form behaviour, result presentation,
  scenario lifecycle, semantic visual foundation, accessibility intent, adaptive
  layout, and state matrix.
- Decision: adopt `docs/DESIGN_SYSTEM.md` for native iOS 1.0 and accept DS-01 through
  DS-07: one optional non-blocking coach card; an explicit validated **View
  projection** action; **Projection** as the result title; load into Calculator and
  save loaded scenarios only as new records; updated-first deterministic scenario
  sorting; System appearance by default with Light/Dark overrides; and a two-series
  after-fee chart for future pounds and today’s money. Target state follows the
  unrounded raw gap with truthful sub-penny copy. Completed scenario names must pass
  the portable schema, and an otherwise-valid preset mismatch loads as Custom without
  mutating the saved record or entering recovery.
- Rationale: provides a calm, native, accessible projection workflow without copying
  the PWA layout or inventing comparison, export, sync, premium, or network states.
- Alternatives: blocking onboarding; live/debounced routed results; a Results title;
  overwrite-on-load; manual ordering; app-specific appearance default; a dense
  four-series chart.
- Consequences: IGC-007 must implement the accepted compact hierarchy and state
  semantics from the start, while IGC-006 evidence remains planned until implementation
  exists. Final legal/privacy/support copy and URLs, measured custom colours, optional
  chart exploration, and release screenshots remain gated by IGC-D016 and later QA.
  This decision does not create an Xcode project or authorise native implementation
  before the owner-controlled bundle identifier and Apple Developer Team are confirmed.

## IGC-D018 — Fix the native application bundle identifier

- Date: 2026-07-28
- Status: Accepted
- Context: project creation requires an owner-controlled reverse-DNS identifier and
  Apple Developer Team. The Product Owner has completed Apple Developer Program
  enrolment, but activation and the resulting Team Name and Team ID are still pending.
- Decision: use `uk.co.mochadesigns.igc` as the native application bundle identifier.
  Record the Apple Developer Team Name and Apple-assigned 10-character Team ID only
  after programme activation; do not substitute a Personal Team, placeholder, or
  inferred value.
- Rationale: the identifier is owner-provided, matches the intended Mocha Designs
  namespace, and is costly to change after distribution. Keeping the signing identity
  as an explicit unresolved input prevents the project from being created under the
  wrong team.
- Alternatives: retain an invented placeholder; use the historical
  `compound-toolkit` identity; or create the project under a Personal Team and migrate
  it later.
- Consequences: IGC-007 may be fully briefed against the fixed bundle identifier but
  remains blocked from dispatch and Xcode-project creation until the Product Owner
  provides both the activated Team Name and Team ID. Test target identifiers may be
  derived under the same namespace during implementation. The App Store SKU remains a
  later gate before App Store Connect record creation.
- Owner update, 2026-07-28: Apple Developer Team Name `Henry Berkin` and Team ID
  `2FKVFS8X67` are confirmed. The owner-controlled project signing identity is
  complete, so the Product Manager may issue IGC-007 from an exact base containing
  this update.

## IGC-D019 — Accept the IGC-007 physical-device gate with a supported-debugger limitation

- Date: 2026-07-28
- Status: Accepted
- Context: the owner used Xcode 26.2 to development-sign and install the integrated
  IGC-007 build on an iPhone running iOS 27.0. Xcode-attached launch produced debugger
  and logging failures, while direct launch from the installed Home Screen icon
  succeeded and every requested manual smoke item passed. Apple’s current Xcode
  compatibility table lists Xcode 26.2 device support through iOS 26.2 and Xcode 27
  device support for iOS 27.
- Decision: pass the IGC-007 physical-device gate for signing, installation, direct
  launch, and manual app behaviour. Classify debugger-attached execution as skipped
  because the Xcode 26.2/iOS 27 pairing is outside Apple’s documented device-support
  range, not as an established IGC defect. Do not introduce `IDEPreferLogStreaming`,
  signing, capability, entitlement, or other project workarounds without separate
  evidence.
- Future-debugging rule: use a maintained Xcode version whose documented device-support
  range includes the target OS—currently Xcode 27 for iOS 27 on a compatible Mac—or
  use a physical device supported by the maintained project toolchain. Do not install
  or switch toolchains merely to close this completed gate.
- Additional observation: returning to Calculator after another tab preserves the
  Calculator stack and scroll position. This is accepted behaviour under the separate
  tab-root design, not shared cross-tab scroll state or a defect.
- Evidence: unchanged bundle/team identity; successful development signing and install;
  direct Home Screen launch; complete requested physical smoke pass; expected
  non-persistent relaunch; Apple compatibility table rechecked 2026-07-28 at
  `https://developer.apple.com/xcode/system-requirements`.
- Consequences: IGC-012 may proceed from a new exact Product Manager base. A future
  release candidate still requires debugger/device evidence on a supported pairing,
  broader release QA, and archive/privacy/submission gates.

## IGC-D020 — Authorise native scenario lifecycle as the next engineering milestone

- Date: 2026-07-28
- Status: Accepted
- Context: IGC-007 is accepted, integrated, and has passed its physical-device gate.
  The next dependency in IGC-D014’s delivery order is native scenario lifecycle; the
  current Saved tab remains an intentional placeholder and the app does not yet retain
  user scenarios.
- Decision: make IGC-012 **Ready** for an iOS Engineer to implement the exact V1
  actor-backed Codable Application Support store and save/load/rename/duplicate/delete/
  recovery lifecycle defined in `TASKS.md`. Use the deterministic editable suggestion
  `<N>-year projection` for whole-year durations and `<N>-month projection` otherwise.
- Sequencing: store-level deliberate recovery/reset support belongs in IGC-012. The
  Settings-wide **Delete all app data** flow remains in the later secondary-content
  milestone so it can reset scenarios, appearance, onboarding, calculator, and
  navigation together rather than pretending that not-yet-implemented stores exist.
- Alternatives: implement all secondary content and preferences in the persistence
  task; omit recovery until later; begin TestFlight work from the non-persistent
  vertical slice.
- Consequences: IGC-012 must not add comparison, export, networking, accounts, premium,
  App Store operations, or change shared calculation/schema meaning. It uses an
  isolated worktree and stops at Ready for review. The earlier prompt based on
  `212cf6056bd37ca22d5aff9db542f9aab4acdd19` is withdrawn and must not be dispatched.

## IGC-D021 — Accept and integrate the corrected native scenario lifecycle

- Date: 2026-07-29
- Status: Accepted
- Context: IGC-012 implemented the native V1 scenario mapping, private actor-backed
  Codable Application Support store, save/Save-as-new, load, rename, duplicate,
  confirmed delete, relaunch persistence, and recovery states. Initial Product Manager
  review found stale recovery evidence and an active Projection save affordance for
  unusable stores. Correction commit
  `5d6c757871d82709fab27b20f41c6b50f001c360` made recovery evidence correspond to the
  exact current source and added accessible store-state save gating.
- Decision: accept exact corrected specialist head
  `20af11c905a2c2bf16fe46af132725d97a1cf7f9` and integrate it into
  `project/ios-migration-audit` through merge commit
  `853555794173814a9299d257d6ff12786c7b26dc`. Mark IGC-012 Done.
- Evidence: independent Product Manager reruns passed 40/40 unit/fixture/store tests,
  16/16 UI tests, and the Release simulator build. `git diff --check`, protected
  contract/PWA/project scope, privacy/dependency inventory, and clean worktrees passed.
  Specialist evidence additionally records focused iPad, clean-install, relaunch, and
  unreachable-proxy offline checks.
- Scope boundary: shared calculation/scenario meaning, PWA, signing, capabilities,
  entitlements, Settings-wide reset, appearance/onboarding persistence, comparison,
  export, networking, analytics, premium, TestFlight, upload, and App Store services
  remain unchanged or deferred.
- Consequences: the native app now has accepted local scenario persistence. Future
  physical persistence/recovery evidence must use a supported Xcode/device pairing
  under IGC-D019. No subsequent engineering milestone is authorised by this decision;
  Product Manager roadmap review must select and brief it from the new integration
  head.

## IGC-D022 — Authorise native secondary content and preferences

- Date: 2026-07-29
- Status: Accepted
- Context: IGC-012 completed the architecture’s scenario-lifecycle step. The remaining
  native-build sequence places secondary content before release evidence. Education
  and Settings are still provisional, appearance and first-launch coach choices do not
  persist, and the accepted Settings-wide Delete all app data control does not exist.
  These concerns share the app-level navigation and preference boundary and the global
  reset must coordinate with the now-accepted scenario store.
- Decision: authorise IGC-013 as the next and only active engineering milestone. It
  completes bundled Education/methodology/glossary/exclusions/disclaimer content,
  contextual education routes, the accepted non-blocking first-launch coach,
  System/Light/Dark appearance preferences, Settings/About/Privacy information, and
  the confirmed global local-data reset. Keep them in one task so app-level state,
  preference persistence, navigation reset, and reset failure semantics are designed
  and tested together.
- Preference/privacy decision: store only appearance and coach dismissal in the
  standard app-only `UserDefaults` domain behind an injectable app-preference
  boundary. Under Apple’s current required-reason API rules, IGC-013 must add and
  validate an app-target privacy manifest declaring
  `NSPrivacyAccessedAPICategoryUserDefaults` for app-only reason `CA92.1`. This is an
  API-use declaration, not a collected-data, tracking, security, or compliance claim.
  Scenario financial data and names remain in the accepted protected Application
  Support store and must never move to UserDefaults.
- Reset decision: one explicit confirmation authorises erasure of app-local scenario
  records and recovery material plus app preferences. A cross-store transaction is not
  claimed. The coordinator must sequence changes conservatively, re-read authoritative
  stores, show success only for a verified empty/default result, and report a partial
  or unknown result without false success. Calculator, loaded-scenario context,
  selected tab, and navigation reset only after verified persistent success.
- Content/release boundary: restrained copy may be implemented for development and
  internal-beta validation under the accepted product/design terminology. This does
  not approve final legal wording or external distribution. Legal/regulatory review,
  final disclaimer/investment-risk wording, live owner-controlled Privacy and Support
  destinations, support contact, metadata, TestFlight, archive/upload, and App Store
  actions remain later gates.
- Consequences: IGC-013 must start from the exact Product Manager management-update
  commit supplied in its standalone prompt and use its isolated worktree. IGC-010
  remains proposed Web work; IGC-011 remains deferred; no other feature or release
  implementation is authorised.

## IGC-D023 — Accept and integrate native secondary content and preferences

- Date: 2026-07-29
- Status: Accepted
- Context: IGC-013 implemented the authorised bundled Education, contextual help,
  first-launch coach, System/Light/Dark preferences, Settings/About/Privacy, deliberate
  scenario/recovery erasure, and verified cross-store Delete all app data flow. It
  also introduced the narrow app-only UserDefaults boundary and corresponding
  `CA92.1` required-reason privacy manifest entry.
- Decision: accept exact specialist head
  `425af8e302269e52a0971815fdb70241854404d2` and integrate it into
  `project/ios-migration-audit` through merge commit
  `a6a1e5fac3c66ea5c42bd71d8d93df93516e8ef6`. Mark IGC-013 Done.
- Evidence: independent Product Manager reruns passed 56/56
  unit/fixture/store/content/preference/reset/privacy tests, 23/23 UI tests, and the
  Release simulator build. Source and packaged privacy manifests parse and contain
  only `NSPrivacyAccessedAPICategoryUserDefaults` / `CA92.1`. `git diff --check`,
  protected contract/PWA/project scope, dependency/network/capability/entitlement
  boundaries, and clean worktrees passed. Specialist evidence additionally records
  focused adaptive-iPad routes, compact accessibility-size Dark Mode content, and
  unreachable-proxy offline checks.
- Scope boundary: the accepted copy remains development/internal-beta content, not
  final legal or external-distribution approval. Public Privacy/Support destinations,
  support contact, signed archive/privacy report, physical-device/manual accessibility
  sign-off, TestFlight, metadata, upload and submission remain open. App Store Connect
  record `6796327865` was subsequently created with the approved identity values.
  Shared calculation/scenario meaning, PWA behaviour, signing, capabilities,
  entitlements, comparison, export, networking, analytics and premium remain unchanged.
- Consequences: the native feature implementation now covers the architecture’s
  Calculator/Projection, local scenario lifecycle, and secondary-content milestones.
  No subsequent engineering milestone is authorised by this decision; Product Manager
  roadmap review must select and brief the next release-oriented task from the new
  integration head.

## IGC-D024 — Stop presenting the growth assumption as an APR

- Date: 2026-07-30
- Status: Accepted
- Platform: Shared
- Context: a pre-public-release accuracy review of the native app found that both
  clients label the growth assumption "APR". In the United Kingdom, APR is a defined
  measure of the cost of credit, not of investment growth; the corresponding
  investment conventions are an annualised return or, for savings, AER. The PWA
  additionally labelled the same field "Annual Interest Rate", giving three terms for
  one assumption. The app is on internal TestFlight only, so no public expectation has
  formed around the current wording.
- Decision: present the field as **annual growth rate** in both clients and describe it
  explicitly as a nominal rate. Retain `apr` as the contract identifier in
  `docs/CALCULATION_SPEC.md`, `docs/SCENARIO_SCHEMA.md`, `shared/`, and persisted
  scenarios. Record the user-facing terminology in the shared calculation contract so
  the identifier and the presented term cannot drift apart again. State in both
  glossaries why APR is not used.
- Rationale: the term was factually wrong for a UK-English financial calculator and is
  the kind of inaccuracy an App Store reviewer or an informed user would reasonably
  challenge. Correcting copy without touching identifiers avoids any schema, fixture,
  or migration impact.
- Alternatives: keep "APR" with a clarifying note, as the PWA glossary previously did;
  correct iOS only and accept deliberate cross-platform drift.
- Consequences: copy-only change in both clients. No calculation, schema, fixture, or
  persisted-data change. Saved scenarios are unaffected. Two iOS content tests and the
  PWA glossary/preset strings were updated to match.

## IGC-D025 — Align the Savings account preset with the UK AER convention

- Date: 2026-07-30
- Status: Accepted
- Platform: Shared
- Context: the `savings-account` preset shipped 4% with monthly compounding. Under the
  accepted nominal-rate model that produces 4.0742% effective annual growth, whereas a
  UK savings account advertising "4% AER" returns exactly 4%. On £10,000 over 15 years
  the preset overstated the outcome by £193.58. The other three presets model
  investments, where a nominal rate with monthly compounding is a defensible
  convention; a savings account is the one preset whose real-world analogue is quoted
  as an effective rate.
- Decision: change `savings-account` to annual compounding in both clients and in the
  preset table in `docs/CALCULATION_SPEC.md`, so the entered 4% is the effective rate.
  Rename the PWA preset label to "4% AER". Leave the engine, the rate-conversion
  formulae, the other three presets, and all fixtures unchanged.
- Rationale: the preset is a curated example of a real product type and should not
  misrepresent how that product's headline rate behaves. The correction is a preset
  default, not a model change, so no fixture expectation moves.
- Alternatives: keep monthly compounding and explain in copy that the rate is nominal;
  leave the preset unchanged.
- Consequences: no engine, contract-version, or fixture change; `calculation-v1.json`
  covers explicit inputs rather than preset defaults and needed no update. Existing
  saved scenarios are untouched because each scenario persists its own
  `compoundFrequency`. A scenario saved against the previous preset now displays as
  Custom, which is the existing truthful-selection behaviour working as designed and
  affects only internal TestFlight data. A new iOS invariant test asserts the preset's
  entered rate equals its effective annual rate.

## IGC-D026 — Correct native results presentation so breakdowns add up and labels are honest

- Date: 2026-07-30
- Status: Accepted
- Platform: iOS
- Context: the same review found three presentation defects in the native results,
  none of them in the engine, which reproduces the shared fixtures exactly.
  Annual detail discounted a row's opening balance at the row's start date while
  discounting every other amount in the row at the row's end date, so today's-money
  rows did not sum to their own closing balance — £291.26 out in year 1 and £1,886.92
  out in year 15 of the default scenario. In after-fee modes the "Growth" figure was
  already net of fees while "Fees paid in this year" was listed beneath it, so
  subtracting the fee gave the wrong closing balance. On Projection, the Breakdown list
  placed the "Balance before fees" total among three amounts that add to a different
  total.
- Decision: apply one row-end divisor to every amount in an annual row, so both paths
  add up exactly in nominal and today's-money modes; label after-fee growth "Growth
  after fees" and the fee line "Fees deducted this year", with a per-row note stating
  that growth is already net of the fee shown; move "Balance before fees" into the Fee
  impact section and close the Breakdown list with its actual total. Record the
  row-end-divisor rule in the shared calculation contract.
- Rationale: each defect made a correct calculation read as an incorrect one. The
  row-end divisor is already the contract's own convention for a row's closing balance,
  so adopting it throughout the row preserves parity while restoring additivity.
- Alternatives: preserve continuity between rows instead of additivity within a row;
  remove the additive breakdown from today's-money modes entirely. Horizon discounting
  cannot provide both properties, and the row is the unit users actually read.
- Consequences: presentation-only change. Closing balances still equal the contract's
  `realEndingBalance` and `realEndingBalanceAfterFees`, so fixture parity is unaffected.
  Because divisors differ per row, an opening balance in today's money is not the
  previous row's closing balance; the interface and the contract both now say so. A new
  iOS invariant test asserts additivity on both paths in both bases.

## IGC-D027 — Release iOS 1.0 to the United Kingdom and Ireland only

- Date: 2026-07-31
- Status: Accepted
- Platform: iOS
- Context: iOS 1.0 is GBP-only with UK-English terminology, and IGC-D024/IGC-D025
  deepened that commitment by adopting UK conventions the app must be judged against
  (annual growth rate rather than APR; AER for the savings preset). The App Store is
  global by default, so a worldwide listing would surface a GBP-only calculator to
  users it cannot serve, risking early one-star reviews on a listing with no rating
  history to absorb them.
- Decision: restrict App Store availability to the United Kingdom and Ireland for 1.0,
  and state "UK English · GBP" in the listing so intent is visible before download.
  Treat multi-currency and location-specific configuration as a later update rather
  than a launch requirement.
- Rationale: precise terminology requires committing to a jurisdiction, and the value
  of this product is precision. Territory availability can be widened at any time
  without a new binary; early reviews cannot be withdrawn.
- Alternatives: worldwide availability with a clear description; delaying release until
  multi-currency exists.
- Consequences: no code change. `currency: GBP` is already explicit in the scenario
  schema and the engine is currency-agnostic, so adding currencies later is
  presentation work plus a schema value rather than a data migration. A future
  multi-currency decision must also decide whether terminology becomes locale-specific,
  which is the harder half of that work.
- Narrowed by IGC-D029, which drops Ireland and releases to the United Kingdom only.
  The reasoning about committing to a jurisdiction is unchanged; only the territory
  list is narrower.

## IGC-D028 — Keep the tax-wrapper product shape deliberately open

- Date: 2026-07-31
- Status: Accepted (as a deferral, not a design)
- Platform: Shared
- Context: ISA-versus-pension modelling, including tax relief on contributions and tax
  on drawdown, is the highest-value UK feature the product could offer and is already
  listed as a later candidate in `ROADMAP.md`. Two questions arose together: how to
  build it safely, and whether it belongs inside IGC at all.
- Decision: defer both. Do not build tax-wrapper modelling in iOS 1.0 or 1.1, and do not
  yet commit to whether it ships as an IGC feature or as a separate application.
  Record the following constraints so a later decision starts from them rather than
  rediscovering them.
- Constraints that any future implementation must respect:
  - The user supplies the tax assumptions — relief rate, expected drawdown rate,
    tax-free portion — exactly as they already supply the growth rate. The app must not
    infer them from income. This avoids collecting income data, keeps the tool an
    arithmetic calculator rather than a personal recommendation, and means there is no
    tax table to go stale.
  - Consequently no remote configuration is required. Shipping maintained tax tables
    would force either an App Store release every Budget or a network fetch, and a
    network fetch would invalidate the App Privacy answer, the Settings and Privacy copy,
    and the reviewer notes, all of which currently state that the app makes no network
    request.
  - Present both wrappers side by side and never state which is better, matching the
    existing target feature, which reports above/below without judging suitability.
  - Current-year allowances may be offered as editable defaults labelled with their tax
    year, but the app must not assert authority over figures it cannot keep current.
  - Obtain a professional legal or compliance opinion before implementation.
    `docs/RELEASE_CHECKLIST.md` already carries an open financial-content review flag,
    and wrapper comparison is materially closer to the advice boundary than a general
    growth projection.
- Product shape, unresolved: a separate application would let IGC remain free, which
  suits its positioning and its existing About copy, and would resolve the finding that
  almost nothing in IGC can be honourably paywalled; it would also rank for search
  intent that a feature inside IGC never could, and would isolate the advice-adjacent
  surface and the Budget maintenance cycle. Against that, a second application doubles
  listings, privacy declarations, review cycles, screenshots and support, and IGC has
  no users yet from whom to learn whether the demand is real.
- Rationale: the deciding evidence does not exist yet. Both paths remain cheap provided
  the calculation core is extractable, which is the subject of IGC-015.
- Consequences: `ISA` and `pension` stay out of App Store keywords and the description
  while the app does not model them. Revisit after iOS 1.0 has real usage.

## IGC-D029 — Narrow iOS 1.0 availability to the United Kingdom only

- Date: 2026-07-31
- Status: Accepted
- Platform: iOS
- Supersedes: the territory selection in IGC-D027, whose reasoning otherwise stands
- Context: IGC-D027 selected the United Kingdom and Ireland. Ireland is an EU
  storefront, which places the app under Digital Services Act trader requirements:
  App Store Connect requires a trader declaration whose name, address, telephone number
  and email address are published on the public listing. The Apple Developer account is
  an individual one, so the address would be the owner's home address, and the owner's
  name is already public as the seller.
- Decision: release iOS 1.0 to the **United Kingdom only**. The United Kingdom is not
  an EU storefront, so the trader publication requirement does not apply.
- Rationale: publishing a home address is a disproportionate cost for a marginal
  territory, and it sits badly with a product whose privacy position is that it
  collects nothing and sends nothing. Ireland was also a weak product fit
  independently of that: the app is GBP-only with UK-specific terminology, and the ISA
  wrapper referenced in the copy and keywords does not exist in Ireland, so an Irish
  user would receive a calculator denominated in the wrong currency using terms for
  products they cannot hold.
- Alternatives: obtain a business or registered-office address usable for publication;
  accept publishing the home address; incorporate. All remain open later.
- Consequences: no code change and no new build; territories are metadata and widen at
  any time without a binary. The EU trader declaration is not required for this
  release. If any EU territory is added later, the declaration and a publishable
  address must be resolved first. The listing copy's "BUILT FOR UK USERS" section and
  the reviewer note remain accurate and need no change beyond removing Ireland.

## IGC-D030 — Launch iOS 1.0 free, and monetise later without an upfront price

- Date: 2026-07-31
- Status: Accepted
- Platform: Shared
- Context: App Store Connect requires a price before a version can be submitted. A
  £0.99 launch price was considered and rejected.
- Decision: publish iOS 1.0 at **no cost**. Any future revenue comes from an in-app
  purchase or a separate paid product, not from putting a price on this listing.
- Rationale: the app tells users it is free. `AboutIGCView` states "IGC is a free,
  local educational calculator", so charging would make the app's own copy wrong on the
  day it ships, in a product whose differentiator is not overstating things. Beyond
  that, the listing has no ratings, the category is crowded with free
  compound-interest calculators, and the qualities that distinguish IGC — fee and
  inflation modelling, and candour about exclusions — are not visible until after
  download, so a price would be asked for a quality the buyer cannot yet perceive.
  Downloads, reviews and feature requests are currently worth more than the revenue a
  £0.99 price would realistically produce, and they are the evidence IGC-D028 needs.
- Alternatives: £0.99 upfront; free with an immediate in-app purchase.
- Consequences: the free positioning in `AboutIGCView`, the Settings and Privacy copy,
  and the App Store description remain accurate and must be revisited together if that
  ever changes. `FeatureAvailability` stays the intended entitlement seam. If a charge
  is introduced later, enrol in the App Store Small Business Program, which reduces
  commission from 30% to 15% below the annual revenue threshold. Adding an in-app
  purchase or shipping a separate paid product disturbs neither this listing nor the
  About copy; putting a price on this listing would disturb both.

## IGC-D031 — Include ISA, but not pension, in App Store keywords

- Date: 2026-08-01
- Status: Accepted
- Platform: iOS
- Supersedes: the keyword consequence recorded in IGC-D028, which stated that both
  `ISA` and `pension` stay out of App Store keywords and the description. The rest of
  IGC-D028 stands.
- Context: IGC-D028 excluded both terms on the grounds that the app models neither
  wrapper. An independent audit found that the submitted listing includes `ISA` while
  IGC-D028 still forbade it, leaving an accepted decision contradicted by shipped
  metadata with no superseding record. That contradiction is the reason for this entry.
- Decision: include `ISA` in keywords. Continue to exclude `pension`.
- Rationale: the two cases are not alike, which IGC-D028 failed to distinguish. An ISA
  is a tax-free wrapper with no tax on growth inside it and none on withdrawal, so the
  projection IGC produces applies to ISA savings directly and correctly; what it does
  not model is the annual subscription limit, which governs how much may be paid in
  rather than how the balance grows. For a pension, relief on contributions and income
  tax on drawdown usually dominate the outcome and IGC models neither, so a projection
  that ignores both would materially mislead someone searching for a pension
  calculator.
- Consequences: keywords are 91 of 100 characters. The description continues to state
  that pension and ISA rules are not modelled, so expectations are set inside the
  listing. Revisit `pension` only if the wrapper modelling contemplated by IGC-D028 is
  built.

## IGC-D032 — Declare the maintained Web edition ready for 1.0

- Date: 2026-08-01
- Status: Accepted
- Platform: Web
- Context: the public PWA still identifies itself as `0.8.2`, although it is a
  supported product surface and has since received the accepted annual-growth-rate
  terminology, savings-preset, reconciled-results, accessibility and update-delivery
  corrections. A live check confirmed that the current origin serves the corrected
  application, while one Safari client remained controlled by the earlier precached
  application shell. Cloudflare served the generated `sw.js` with a four-hour cache
  lifetime.
- Decision: release the maintained Web edition as product version **1.0.0**. Serve the
  generated service-worker entry point with `Cache-Control: no-cache, no-store,
  must-revalidate`, retain the existing user-visible **Update available / Refresh**
  flow, and leave fingerprinted application assets under their normal cache policy.
- Rationale: `0.8.2` no longer communicates the maturity of the supported Web product,
  and prompt discovery should not be delayed by an ordinary static-asset cache
  lifetime. Web `1.0.0` and native iOS `1.0` describe aligned public product maturity;
  their build and patch numbers remain independently managed.
- Alternatives: retain `0.8.2`; wait for native public release; remove offline PWA
  support; force every new worker to activate without user control.
- Consequences: no calculation, validation, terminology, contract, fixture, scenario
  schema, browser-storage key, dependency or product-feature change. Existing local
  scenarios remain compatible. A visitor controlled by the legacy `autoUpdate` worker
  may still need to close every IGC tab or standalone window once so the waiting
  prompt-mode worker can activate; clearing website data is not the default remedy
  because it would also erase local scenarios.
