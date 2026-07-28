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
- Owner update, 2026-07-28: Apple Developer Team ID `2FKVFS8X67` is confirmed.
  The exact Team Name remains pending and is the final signing-identity input required
  before the implementation brief may be unblocked.
