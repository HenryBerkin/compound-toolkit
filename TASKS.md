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
- Status: Done
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
- Verification: Product Manager review accepted the corrected proposal and its five
  decision areas in IGC-D014. Specialist range
  `3bf1e517636d543e368b610b8a006cafd271e836..1940e3f95427f5fc0b3ca2dab07801e887650821`
  passes `git diff --check`; no native build was applicable.
- Unresolved questions: IGC-D018 has since confirmed the application bundle identifier;
  activated Apple Developer Team Name and Team ID remain required before project
  creation, and App Store SKU remains required before its App Store Connect record.
  These owner-controlled values did not block architecture acceptance.
- Branch/worktree: `codex/igc-004-ios-architecture` in an isolated worktree from
  `3bf1e517636d543e368b610b8a006cafd271e836`.
- Standalone prompt: `prompts/IGC-004-IOS-ARCHITECTURE.md`.

## IGC-005 — Define native design system

- Owner: Designer
- Status: Done
- Priority: P1
- Platform: iOS
- Dependencies: IGC-003, IGC-004
- Affected: `docs/DESIGN_SYSTEM.md`, design assets, `handoffs/DESIGNER.md`
- Objective: translate useful IGC identity and workflows into native iOS patterns.
- Acceptance criteria: implementation-ready hierarchy, components, Dynamic Type,
  VoiceOver, contrast, dark mode, and touch guidance.
- Verification: Product Manager/Technical Lead review accepted the corrected design
  system and DS-01 through DS-07 under IGC-D017. Specialist range
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a..3f176284a0badeb342bf48bfa737a0c6fd52543b`
  passes `git diff --check`; only permitted documentation/handoff files changed and no
  native implementation or asset catalogue was added.
- Unresolved questions: final legal/privacy/support copy and URLs; measured accent and
  chart colours; optional chart scrubbing/Years rotor; regular-width annual-table
  enhancement; and unsaved draft restoration after termination. None changes the
  accepted compact vertical-slice behaviour.
- Branch/worktree: `codex/igc-005-native-design-system` in an isolated worktree from
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`.
- Standalone prompt: `prompts/IGC-005-NATIVE-DESIGN-SYSTEM.md`.

## IGC-006 — Create behavioural QA inventory

- Owner: QA Engineer
- Status: Done
- Priority: P1
- Platform: Shared / iOS / Web
- Dependencies: IGC-003, IGC-004, IGC-009
- Affected: `docs/QA_PLAN.md`, `handoffs/QA_ENGINEER.md`
- Objective: turn approved shared requirements and platform-specific behaviour into
  reproducible cross-platform tests.
- Acceptance criteria: canonical fixtures, input boundaries, persistence, comparison,
  accessibility, platform-difference, and regression cases defined.
- Verification: Product Manager/Technical Lead review accepted the inventory under
  IGC-D015. Specialist range
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a..7e4f462ef6ec78fa22dea81dbda772e9032af2f9`
  passes `git diff --check`; protected contracts, PWA, and native paths are unchanged.
- Unresolved questions: implement and evidence the accepted IGC-005/IGC-008 traces;
  approve a browser-support policy and prioritise known Web defects separately.
- Branch/worktree: `codex/igc-006-behavioural-qa-inventory` in an isolated worktree from
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`.
- Standalone prompt: `prompts/IGC-006-BEHAVIOURAL-QA-INVENTORY.md`.

## IGC-007 — Implement native vertical slice

- Owner: iOS Engineer
- Status: Blocked
- Priority: P1
- Platform: iOS
- Dependencies: IGC-003, IGC-004, IGC-005, IGC-006, IGC-008
- Affected: `igc-ios/`, `handoffs/IOS_ENGINEER.md`
- Objective: create the native project foundation, port the pure shared calculation
  contract, and deliver an accessible Calculator-to-Projection vertical slice with
  tested fixture parity.
- Acceptance criteria:
  - SwiftUI application, unit-test, and UI-test targets use iOS 17, support iPhone and
    iPad, and identify the application as `uk.co.mochadesigns.igc`.
  - The project follows IGC-D014: one application module, first-party frameworks only,
    pure binary64 core, direct root-fixture test consumption, and a local-free feature
    availability seam.
  - The Swift engine covers canonical types, presets, validation, monthly/annual
    calculation rows, target analysis, and every version-1 calculation and validation
    fixture without copying or regenerating expected values.
  - The visible slice follows IGC-D017: explicit Custom baseline, validated **View
    projection** action, **Projection** results hierarchy, accessible two-series chart
    with text/annual alternatives, truthful target status, Dynamic Type, VoiceOver,
    dark mode, and adaptive iPad behaviour.
  - Scenario persistence/CRUD, comparison, monthly native detail, CSV export, sync,
    accounts, payments, premium, analytics, networking, remote configuration, backend,
    and App Store record/submission work remain out of scope.
  - Build, unit, fixture, UI smoke, simulator, accessibility, and offline evidence is
    reported as executed, failed, skipped, or untested; no unexecuted plan is called
    passing.
- Verification: exact commands and destinations are specified in the standalone brief;
  implementation has not started.
- Blocker: Product Owner must provide the activated Apple Developer Team Name and
  Apple-assigned Team ID. Do not use a Personal Team, placeholder, or inferred signing
  identity and do not create the Xcode project before the brief is explicitly
  unblocked.
- Branch/worktree when unblocked: `codex/igc-007-native-vertical-slice` in an isolated
  worktree from the exact base named in the standalone prompt.
- Standalone prompt: `prompts/IGC-007-NATIVE-VERTICAL-SLICE.md` (prepared separately;
  do not dispatch while blocked).

## IGC-008 — Early privacy and App Store risk review

- Owner: App Store Reviewer
- Status: Done
- Priority: P1
- Platform: iOS / Shared
- Dependencies: IGC-003, IGC-004
- Affected: `docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`,
  `docs/RELEASE_CHECKLIST.md`
- Objective: identify current policy, privacy, metadata, support, and screenshot needs.
- Acceptance criteria: confirmed requirements separated from recommendations and open
  questions, with official Apple sources where requirements are time-sensitive.
- Verification: Product Manager/Technical Lead review accepted the planning baseline
  under IGC-D016. Specialist range
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a..1bc787858ae991a706d009214b14bc3867f36baf`
  passes `git diff --check`; current Apple primary sources were independently
  rechecked 2026-07-28.
- Unresolved questions: owner-controlled Team Name and Team ID, SKU, publisher, URLs,
  category, territories and trader status; legal review of final positioning;
  binary-dependent privacy, manifest, export, accessibility, metadata and submission
  evidence.
- Branch/worktree: `codex/igc-008-app-store-privacy-review` in an isolated worktree from
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`.
- Standalone prompt: `prompts/IGC-008-EARLY-PRIVACY-APP-STORE-REVIEW.md`.

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
