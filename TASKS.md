# IGC tasks

Statuses use: Proposed, Ready, In progress, Blocked, Ready for review, Ready for QA,
Changes requested, Ready for acceptance, Done, Deferred.

Each new task must identify its platform as `Shared`, `iOS`, or `Web`. A task may list
more than one only when its acceptance criteria genuinely span those surfaces.

## IGC-001 — Recover and audit the PWA

- Owner: Product Manager and Technical Lead
- Status: Done
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
- Relevant commit: `78f2415`

## IGC-002 — Reorganise the repository

- Owner: Product Manager and Technical Lead
- Status: Done
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
- Relevant commit: `78f2415`

## IGC-003 — Accept cross-platform direction and native iOS 1.0 scope

- Owner: Product Manager and Technical Lead
- Status: Done
- Priority: P0
- Platform: Shared / iOS / Web
- Dependencies: IGC-001
- Affected: `docs/PRODUCT_SPEC.md`, `DECISIONS.md`
- Objective: agree a coherent two-client product direction and a small, complete native
  release before architecture or feature work.
- Acceptance criteria:
  - User resolves or explicitly defers all six product questions.
  - Shared and platform-specific behaviour boundaries are accepted.
  - Maintained-PWA scope and iOS release priority are accepted.
  - Premium implementation remains excluded or a separate approved scope replaces that
    exclusion.
- Verification: accepted decisions recorded in `DECISIONS.md`.
- Unresolved questions: None for architecture; later commercial and release questions
  remain separately scoped.
- Branch: `project/ios-migration-audit`

## IGC-004 — Propose native iOS architecture

- Owner: iOS Engineer
- Status: Ready
- Priority: P0
- Platform: iOS / Shared
- Dependencies: IGC-003, IGC-009
- Affected: `docs/IOS_ARCHITECTURE.md`, `handoffs/IOS_ENGINEER.md`
- Objective: propose a proportionate SwiftUI architecture and test strategy without
  implementing product features.
- Acceptance criteria:
  - Supported iOS/Xcode assumptions, app structure, calculation-engine porting,
    persistence, navigation, dependency policy, accessibility, and test layers covered.
  - Expensive-to-reverse choices and alternatives identified.
  - Dual-client maintenance, shared fixture consumption, versioned scenario schema,
    replaceable entitlement boundaries, and future synchronisation constraints covered.
  - No backend, account, payment, analytics, or third-party dependency is implemented or
    assumed for iOS 1.0.
- Verification: document review by Product Manager; no build required unless a minimal
  feasibility spike is explicitly approved.
- Unresolved questions: architecture alternatives to be evaluated by the iOS Engineer;
  no unresolved product input blocks the proposal.
- Branch/worktree: `codex/igc-004-ios-architecture` in an isolated worktree from
  `3bf1e517636d543e368b610b8a006cafd271e836`.
- Standalone prompt: `prompts/IGC-004-IOS-ARCHITECTURE.md`.

## IGC-005 — Define native design system

- Owner: Designer
- Status: Proposed
- Priority: P1
- Platform: iOS
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
- Platform: Shared / iOS / Web
- Dependencies: IGC-003, IGC-009
- Affected: `docs/QA_PLAN.md`, `handoffs/QA_ENGINEER.md`
- Objective: turn approved shared requirements and platform-specific behaviour into
  reproducible cross-platform tests.
- Acceptance criteria: canonical fixtures, input boundaries, persistence, comparison,
  accessibility, platform-difference, and regression cases defined.
- Verification: Product Manager and iOS Engineer review.

## IGC-007 — Implement native vertical slice

- Owner: iOS Engineer
- Status: Proposed
- Priority: P1
- Platform: iOS
- Dependencies: IGC-003, IGC-004, relevant portions of IGC-005 and IGC-006
- Affected: `igc-ios/`
- Objective: native input-to-result flow with tested calculation parity.
- Acceptance criteria and verification: to be defined after architecture acceptance.

## IGC-008 — Early privacy and App Store risk review

- Owner: App Store Reviewer
- Status: Proposed
- Priority: P1
- Platform: iOS / Shared
- Dependencies: IGC-003, IGC-004
- Affected: `docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`,
  `docs/RELEASE_CHECKLIST.md`
- Objective: identify current policy, privacy, metadata, support, and screenshot needs.
- Acceptance criteria: confirmed requirements separated from recommendations and open
  questions, with official Apple sources where requirements are time-sensitive.
- Verification: Product Manager review.

## IGC-009 — Define shared calculation contract and fixture plan

- Owner: Product Manager and Technical Lead
- Status: Done
- Priority: P0
- Platform: Shared
- Dependencies: IGC-003
- Affected: `docs/CALCULATION_SPEC.md`, `docs/SCENARIO_SCHEMA.md`, `shared/`,
  `docs/PRODUCT_SPEC.md`, `handoffs/QA_ENGINEER.md`, `handoffs/IOS_ENGINEER.md`
- Objective: make calculation, validation, rounding, terminology, presets, and example
  outputs a language-neutral product contract consumed by Swift and TypeScript.
- Acceptance criteria:
  - Canonical input/output fields, units, enum values, validation bounds, formulas,
    operation order, rounding rules, and versioning defined.
  - Portable fixture format and numerical tolerances defined without coupling either
    client to the other's implementation.
  - TypeScript and future Swift test responsibilities identified.
  - Change-control process distinguishes intentional model changes from regressions.
- Verification: shared JSON is consumed directly by the TypeScript suite; 27 contract
  tests and the original 58 tests pass, followed by a successful production build.
- Unresolved questions: None for contract version 1. Any mathematical or terminology
  change uses the documented change-control process.
- Branch: `project/ios-migration-audit`

## IGC-010 — Plan maintained PWA releases and refinement backlog

- Owner: Product Manager and Technical Lead
- Status: Proposed
- Priority: P1
- Platform: Web / Shared
- Dependencies: IGC-003, IGC-009
- Affected: `igc-pwa/`, root and web changelogs, web deployment planning
- Objective: keep the PWA supported without distracting from the first iOS release.
- Acceptance criteria:
  - Supported capabilities and compatibility baseline recorded.
  - Security, accessibility, dependency, correctness, and deployment work prioritised.
  - Non-critical redesign and expansion explicitly deferred.
  - Correct the visible initial preset state to explicit Custom without changing the
    verified 7% / 3% / 0.20% baseline or losing legacy browser scenarios.
  - Release-note ownership distinguishes Shared and Web changes.
- Verification: approved backlog and repeatable web regression checks.

## IGC-011 — Select premium model and entitlement boundary

- Owner: Product Manager and Technical Lead
- Status: Deferred
- Priority: P2
- Platform: Shared / iOS / Web
- Dependencies: evidence of premium demand; IGC-008 before implementation
- Affected: `docs/PLATFORM_STRATEGY.md`, future product and architecture decisions
- Objective: choose independent, unified, or staged premium access only when commercial
  requirements justify the operational cost.
- Acceptance criteria:
  - Premium value, purchase type, platform availability, account need, entitlement
    source of truth, pricing, migration, support, privacy, and current store compliance
    accepted.
  - App Store Reviewer verifies then-current official Apple requirements.
- Verification: formal accepted decision and separately scoped implementation tasks.
- Unresolved questions: premium feature set, pricing, one-time purchase versus
  subscription, web commercial model, and account strategy.
