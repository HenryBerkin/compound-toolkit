# IGC tasks

Statuses use: Proposed, Ready, In progress, Blocked, Ready for review, Ready for QA,
Changes requested, Ready for acceptance, Done, Deferred.

## IGC-001 — Recover and audit the PWA

- Owner: Product Manager and Technical Lead
- Status: Ready for acceptance
- Priority: P0
- Dependencies: None
- Affected: original root PWA, `docs/PWA_AUDIT.md`
- Objective: establish a verified behavioural and technical baseline.
- Acceptance criteria:
  - Git state, branches, tags, remotes, history, configuration, and docs inspected.
  - Install, development server, build, lint/type-check, tests, and browser behaviour
    verified with warnings recorded.
  - Calculations, workflows, storage, dependencies, accessibility, privacy, and risks
    documented without inventing behaviour.
- Verification: results recorded in `PROJECT_STATUS.md` and `docs/PWA_AUDIT.md`.
- Unresolved questions: see `docs/PRODUCT_SPEC.md`.
- Branch: `project/ios-migration-audit`
- Baseline: `428fb46432fedab770ae90934b537587a32d70f6`

## IGC-002 — Reorganise the repository

- Owner: Product Manager and Technical Lead
- Status: In progress
- Priority: P0
- Dependencies: IGC-001
- Affected: root layout, `igc-pwa/`, project documentation
- Objective: preserve the working PWA as an isolated reference implementation.
- Acceptance criteria:
  - Planned tracked files are moved with history retained.
  - Existing README, changelog, licence, and PWA docs are preserved as documented.
  - A clean install no longer overwrites branded IGC icons.
  - Install, lint, tests, build, and development server pass from `igc-pwa/`.
  - Structural work is committed separately from native features.
- Verification: commands in `AGENTS.md`; post-move browser smoke test.
- Unresolved questions: deployment destination is not configured in this repository.
- Branch: `project/ios-migration-audit`

## IGC-003 — Accept native iOS 1.0 scope

- Owner: Product Manager and Technical Lead
- Status: Ready for review
- Priority: P0
- Dependencies: IGC-001
- Affected: `docs/PRODUCT_SPEC.md`, `DECISIONS.md`
- Objective: agree a small, complete native release before architecture or feature work.
- Acceptance criteria: user resolves the open product questions and accepts or amends the
  proposed inclusions and exclusions.
- Verification: accepted decisions recorded in `DECISIONS.md`.
- Unresolved questions: listed in `docs/PRODUCT_SPEC.md`.
- Branch: `project/ios-migration-audit`

## IGC-004 — Propose native iOS architecture

- Owner: iOS Engineer
- Status: Ready
- Priority: P0
- Dependencies: IGC-001, IGC-002; architecture must label IGC-003 scope assumptions
- Affected: `docs/IOS_ARCHITECTURE.md`, `handoffs/IOS_ENGINEER.md`
- Objective: propose a proportionate SwiftUI architecture and test strategy without
  implementing product features.
- Acceptance criteria:
  - Supported iOS/Xcode assumptions, app structure, calculation-engine porting,
    persistence, navigation, dependency policy, accessibility, and test layers covered.
  - Expensive-to-reverse choices and alternatives identified.
  - No backend, account, analytics, or third-party dependency is assumed.
- Verification: document review by Product Manager; no build required unless a minimal
  feasibility spike is explicitly approved.
- Unresolved questions: inherit unresolved scope items from IGC-003.
- Branch/worktree: isolated worktree required; base set in the specialist prompt.

## IGC-005 — Define native design system

- Owner: Designer
- Status: Proposed
- Priority: P1
- Dependencies: IGC-003
- Affected: `docs/DESIGN_SYSTEM.md`, design assets, `handoffs/DESIGNER.md`
- Objective: translate useful IGC identity and workflows into native iOS patterns.
- Acceptance criteria: implementation-ready hierarchy, components, Dynamic Type,
  VoiceOver, contrast, dark mode, and touch guidance.
- Verification: Product Manager review against accepted scope.

## IGC-006 — Create behavioural QA inventory

- Owner: QA Engineer
- Status: Proposed
- Priority: P1
- Dependencies: IGC-003
- Affected: `docs/QA_PLAN.md`, `handoffs/QA_ENGINEER.md`
- Objective: turn approved requirements and verified PWA behaviour into reproducible tests.
- Acceptance criteria: formula fixtures, input boundaries, persistence, comparison,
  accessibility, and regression cases defined.
- Verification: Product Manager and iOS Engineer review.

## IGC-007 — Implement native vertical slice

- Owner: iOS Engineer
- Status: Proposed
- Priority: P1
- Dependencies: IGC-003, IGC-004, relevant portions of IGC-005 and IGC-006
- Affected: `igc-ios/`
- Objective: native input-to-result flow with tested calculation parity.
- Acceptance criteria and verification: to be defined after architecture acceptance.

## IGC-008 — Early privacy and App Store risk review

- Owner: App Store Reviewer
- Status: Proposed
- Priority: P1
- Dependencies: IGC-003, IGC-004
- Affected: `docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`,
  `docs/RELEASE_CHECKLIST.md`
- Objective: identify current policy, privacy, metadata, support, and screenshot needs.
- Acceptance criteria: confirmed requirements separated from recommendations and open
  questions, with official Apple sources where requirements are time-sensitive.
- Verification: Product Manager review.
