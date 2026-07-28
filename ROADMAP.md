# IGC roadmap

## Phase 0 — Recovery and source of truth

- Preserve the public PWA baseline.
- Audit behaviour, formulas, storage, accessibility, and risks.
- Move the reference implementation into `igc-pwa/` without behavioural refactoring.
- Establish concise project, task, decision, and handoff records.

## Phase 1 — Shared product definition

- Accepted a coherent two-client direction: native iOS and maintained PWA/web.
- Resolved the six product decisions and accepted a deliberately limited iOS 1.0 scope.
- Defined version 1 calculation, validation, rounding, terminology, scenario-schema,
  and portable fixture contracts.
- Classify requirements and release notes as Shared, iOS, or Web.

## Phase 2 — Native definition

- Approved the SwiftUI architecture, Codable persistence, fixture gate, dependency
  policy, and local-free availability boundary.
- Accepted the cross-platform behavioural QA inventory and release-gate model.
- Accepted the early App Store/privacy risk baseline and phase-gated evidence
  checklist without claiming submission readiness.
- Produce and accept the lightweight native design system.

## Phase 3 — Native build

- Implement and test the calculation engine first.
- Build a small end-to-end calculator and results vertical slice.
- Add saved scenarios, target analysis, education, accessibility, and appearance
  support only in the approved sequence.
- Add native two-scenario comparison in iOS 1.1, not 1.0.

## Phase 4 — iOS release readiness

- Complete regression and accessibility testing.
- Recheck and complete privacy declarations and current App Store requirements against
  the release archive.
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
