# IGC roadmap

## Phase 0 — Recovery and source of truth

- Preserve the public PWA baseline.
- Audit behaviour, formulas, storage, accessibility, and risks.
- Move the reference implementation into `igc-pwa/` without behavioural refactoring.
- Establish concise project, task, decision, and handoff records.

## Phase 1 — Shared product definition

- Accept a coherent two-client direction: native iOS and maintained PWA/web.
- Resolve the six product decisions and accept a deliberately limited iOS 1.0 scope.
- Define shared calculation, validation, rounding, terminology, scenario-schema, and
  fixture contracts.
- Classify requirements and release notes as Shared, iOS, or Web.

## Phase 2 — Native definition

- Approve the SwiftUI architecture and persistence approach.
- Produce a lightweight native design system and behavioural QA inventory.

## Phase 3 — Native build

- Implement and test the calculation engine first.
- Build a small end-to-end calculator and results vertical slice.
- Add saved scenarios, target analysis, comparison, education, accessibility, and
  appearance support only in the approved sequence.

## Phase 4 — iOS release readiness

- Complete regression and accessibility testing.
- Confirm privacy declarations and current App Store requirements.
- Prepare metadata, support information, screenshots, release notes, and submission
  checks.

## Maintained web track

- Keep the currently verified calculator, target analysis, scenarios, comparison,
  breakdown, CSV export, education, theme, responsiveness, and offline behaviour
  supported.
- Allow security, dependency, accessibility, compatibility, and correctness maintenance
  while iOS remains the release priority.
- Defer non-critical PWA redesign, feature expansion, account work, payment work, and
  broad dependency modernisation until after the first iOS release unless a release
  blocker emerges.

## Later candidates

Currency selection, richer exports, iCloud sync, widgets, variable-return modelling,
tax wrappers, withdrawals, market data, accounts, analytics, cross-platform
entitlements, and premium expansion are not part of the proposed iOS 1.0 scope.
