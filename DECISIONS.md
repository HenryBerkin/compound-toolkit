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
