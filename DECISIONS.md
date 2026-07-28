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
  IGC-D006 extends its role from recoverable reference to a potentially maintained
  product surface without reversing the repository placement.

## IGC-D003 — Keep the initial product local-first

- Date: 2026-07-28
- Status: Proposed
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

## IGC-D005 — Use GBP and UK English for proposed 1.0

- Date: 2026-07-28
- Status: Proposed
- Context: all current formatting, examples, and defaults use GBP and `en-GB`.
- Decision: keep GBP and UK English in 1.0; defer multi-currency support.
- Rationale: limits scope and preserves a coherent existing product.
- Alternatives: locale-driven display; currency picker.
- Consequences: App Store metadata and screenshots must make the intended market clear.

## IGC-D006 — Treat iOS and PWA as coherent supported product surfaces

- Date: 2026-07-28
- Status: Accepted
- Context: recovery initially described the PWA mainly as a frozen behavioural
  reference, but the product may continue on the web alongside native iOS.
- Decision: IGC may have a native SwiftUI application and a responsive maintained PWA.
  iOS remains the immediate release priority. Shared product behaviour must be explicit,
  while each client keeps platform-appropriate interface and lifecycle behaviour.
- Rationale: preserves the useful web product, broadens access, and avoids making the
  native rebuild the only maintained surface.
- Alternatives: freeze the PWA; replace it with iOS; force identical interfaces.
- Consequences: requirements, tasks, QA, and release notes must identify Shared, iOS, or
  Web scope. PWA maintenance cannot silently expand iOS 1.0.

## IGC-D007 — Use a shared specification and fixtures, not shared runtime code

- Date: 2026-07-28
- Status: Proposed
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
- Status: Proposed
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
