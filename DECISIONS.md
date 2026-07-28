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

## IGC-D003 — Keep native 1.0 local-first

- Date: 2026-07-28
- Status: Proposed
- Context: the PWA performs all calculations locally and stores only preferences and
  scenarios in browser storage.
- Decision: native 1.0 should require no account, backend, analytics, advertising,
  subscription, cloud sync, or sensitive permission.
- Rationale: matches proven behaviour and reduces privacy, policy, and delivery risk.
- Alternatives: accounts/iCloud sync; telemetry; monetisation in the first release.
- Consequences: local persistence and clear reset/delete behaviour are required.

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
