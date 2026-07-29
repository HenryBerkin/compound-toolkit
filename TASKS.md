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
- Unresolved questions: IGC-D018 has since confirmed the application bundle identifier,
  Team Name `Henry Berkin`, and Team ID `2FKVFS8X67`. App Store SKU remains required
  before its App Store Connect record. These owner-controlled values did not block
  architecture acceptance.
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
- Status: Done
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
- Verification:
  - Xcode 26.2 (17C52), Swift 6.2.3, and the iOS 26.2 SDK built the iOS 17 project
    in Debug and Release simulator configurations.
  - After Product Manager corrections, the canonical iPhone 17 result bundle passed
    27/27 tests: 18 unit/fixture tests and 9 UI tests. Focused regressions cover strict
    en-GB input parsing, preset reconciliation with invalid unrelated drafts, the
    Next/Done/focus-loss/correction lifecycle, collapsed invalid target focus, confirmed
    target removal, and adaptive contribution-timing presentation. The fixture suite
    consumed the root calculation fixture and both
    root schemas directly and covered all 7 calculation cases, 8 monthly checkpoints,
    8 annual checkpoints, and 19 validation expectations.
  - Calculator-to-Projection and annual-detail smoke flows passed on iPhone 16e,
    iPhone 17, iPhone 17 Pro Max, and iPad Pro 13-inch simulators. Dark appearance,
    AX XXXL text, Reduce Motion, VoiceOver-enabled semantics, landscape, and a French
    system locale retaining explicit GBP formatting also passed focused checks.
  - Source and Release-binary inventory found only first-party Foundation, Charts,
    SwiftUI, and UIKit application linkage; no networking, persistence, analytics,
    third-party SDK, entitlement, collected-data, tracking, or required-reason API
    surface was added. No privacy manifest is required for this implemented slice.
  - Physical-device and StoreKit/manual purchase checks were skipped because this
    local-only free slice has no StoreKit path and no authorised device run was made.
- Signing inputs: Apple Developer Team Name `Henry Berkin` and Team ID `2FKVFS8X67`
  are owner-confirmed. Do not use a Personal Team, placeholder, different Team ID, or
  different signing identity.
- Branch/worktree: `codex/igc-007-native-vertical-slice` in an isolated worktree from
  exact base `dc521186d9d0f30add2f45c06cb02d6d98d35195`; initial implementation commit
  `ab45c935853fc4edab0fce2d25291d74255b49d1` and Product Manager correction commit
  `76b1e39db01830642b4de7481ea7efc85ae568f1`; accepted and integrated into
  `project/ios-migration-audit` by merge commit
  `c26d25a13a65d47f487fc55cebaeb216b7a8eb62`.
- Standalone prompt: `prompts/IGC-007-NATIVE-VERTICAL-SLICE.md`.

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
- Unresolved questions: SKU, publisher, URLs, category, territories and trader status;
  legal review of final positioning;
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

## IGC-012 — Implement native scenario lifecycle and persistence

- Owner: iOS Engineer
- Status: Done
- Priority: P1
- Platform: iOS
- Dependencies: IGC-003, IGC-004, IGC-005, IGC-006, IGC-007, IGC-008, IGC-009;
  physical-device gate accepted in IGC-D019
- Affected: `igc-ios/`, `docs/PRIVACY.md`, `handoffs/IOS_ENGINEER.md`, task/status
  records
- Objective: add the accepted native V1 scenario model and actor-backed Codable
  Application Support store, then deliver save, load, rename, duplicate, delete,
  relaunch persistence, and truthful storage-recovery behaviour without changing the
  accepted calculation contract.
- Acceptance criteria:
  - Native records map exactly to `shared/schemas/scenario-v1.schema.json`, including
    V1, opaque UUID identity, explicit GBP, canonical inputs, truthful `presetId`,
    optional target, and UTC timestamps.
  - A narrow `ScenarioStore` protocol and actor-backed Codable implementation serialise
    reads/mutations in private Application Support, use temporary-write/atomic
    replacement, retain the last readable document, apply appropriate data protection,
    and distinguish empty, unavailable/protected, corrupt, and unsupported states.
  - Projection supports **Save** and loaded scenarios support **Save as new**; neither
    overwrites. Saved supports deterministic updated/created/id ordering, load, rename,
    duplicate, and confirmed delete with accurate success/failure feedback.
  - Loading validates before changing Calculator, never changes timestamps, and treats
    an otherwise-valid preset mismatch as Custom without mutating the record.
  - Corrupt/unsupported source is preserved under the accepted recovery policy; no
    error presents false success, false empty state, partial decode, or partial load.
  - Store/unit/integration/UI coverage implements the applicable `IOS-STORE-001–016`
    inventory, relaunch persistence, failure injection, accessibility, offline
    behaviour, and unchanged 27/27 calculation-fixture parity.
  - Actual API/dependency/privacy-manifest impact is inventoried and documented; the
    implementation remains first-party, local-only, and free.
- PM-approved save-name suggestion: use `<N>-year projection` for an exact whole-year
  duration and `<N>-month projection` otherwise; it remains editable and schema
  validated.
- Explicit exclusions: Settings-wide **Delete all app data**, appearance/onboarding
  persistence, complete secondary content, native comparison, monthly UI, CSV/import/
  export/share, PWA migration, multi-currency, accounts, sync, networking, analytics,
  premium, StoreKit, TestFlight, App Store records, upload, and submission.
- Verification result (specialist, 2026-07-28/29):
  - implementation commit
    `802ff473b9b6a091103591eefd87b79745116f4f` was created from exact accepted base
    `9b5f17b41d768bf72af12c215b096d2e101962e0`; after Product Manager review of
    `be572a2825c4988b67049f21bdf8ea56c151c5c6`, focused correction commit
    `5d6c757871d82709fab27b20f41c6b50f001c360` made recovery evidence correspond
    byte-for-byte to the current source and gated Projection Save from the live store
    state;
  - 40/40 Swift unit/fixture/store tests and 16/16 UI tests passed on iPhone 17 /
    iOS 26.2, retaining all 27 accepted IGC-007 tests and all normal IGC-012 lifecycle
    paths;
  - deterministic correction coverage proves changed corrupt sources and a second
    corruption episode receive distinct evidence, while later-source preservation
    failure blocks reset and leaves that source unchanged;
  - unavailable, corrupt, and unsupported Projection states expose accessible reasons,
    keep review/annual detail usable, and cannot enter the Save flow; normal Save and
    Save as new remain enabled and passing for an available store;
  - focused iPad Pro 13-inch (M5) adaptive navigation/Saved-root UI smoke passed;
  - Debug and Release simulator builds, clean-install launch, relaunch persistence,
    unavailable/corrupt/unsupported/failure-injection coverage, and unreachable-proxy
    offline-dependency smoke passed;
  - source/project inventory found no network, analytics, logging, StoreKit, CloudKit,
    App Group, third-party dependency, collected-data, tracking, or used
    required-reason API surface, so no privacy manifest was added;
  - shared contracts/fixtures, PWA, signing, capabilities, and entitlements remain
    unchanged. Physical-device execution and release archive/privacy-report inspection
    were skipped as out of specialist scope or unavailable under the accepted
    Xcode 26.2 / iOS 27 pairing.
- Product Manager acceptance and integration (2026-07-29):
  - accepted the corrected exact specialist head
    `20af11c905a2c2bf16fe46af132725d97a1cf7f9` with no remaining findings;
  - independently repeated 40/40 unit/fixture/store tests, 16/16 UI tests, and the
    Release simulator build with no failures or skips;
  - confirmed `git diff --check`, protected-contract/PWA/project scope, privacy and
    dependency boundaries, and clean specialist/integration worktrees;
  - integrated the accepted head into `project/ios-migration-audit` with merge commit
    `853555794173814a9299d257d6ff12786c7b26dc`;
  - accepted physical-device execution as skipped under IGC-D019’s documented
    Xcode 26.2/iOS 27 compatibility boundary, without a project workaround.
- Required completion handoff: update `handoffs/IOS_ENGINEER.md` with exact base,
  branch/head commits, store/envelope/mapping and recovery behaviour, files changed,
  every check and environment, privacy/dependency findings, skips/limitations, review
  instructions, rollback guidance, and clean-worktree confirmation; stop at
  **Ready for review** without push or merge.
- Specialist: iOS Engineer using `gpt-5.6-sol` at `xhigh` reasoning.
- Branch/worktree: `codex/igc-012-native-scenario-lifecycle` in required isolated
  worktree `/private/tmp/igc-012-native-scenario-lifecycle`.
- Historical dispatch control: the earlier prompt based on
  `212cf6056bd37ca22d5aff9db542f9aab4acdd19` is withdrawn. The Product Manager’s
  reissued standalone prompt supplies the exact accepted management-update base; if
  the integration head differs, stop for reissue rather than rebasing or guessing.

## IGC-013 — Complete native secondary content and preferences

- Owner: iOS Engineer
- Status: Ready for review
- Priority: P1
- Platform: iOS
- Dependencies: IGC-003, IGC-004, IGC-005, IGC-006, IGC-007, IGC-008, IGC-009,
  IGC-012; accepted IGC-D021 integration and IGC-D022 authorisation
- Affected: native app composition and routes, Calculator/Projection contextual
  education, Education, Settings/About, local preferences, Settings-wide local-data
  reset, native unit/UI tests, privacy/release evidence, and iOS Engineer handoff
- Objective: complete the architecture’s native secondary-content milestone by
  replacing the provisional Education and Settings screens with accessible bundled
  product content, persisting the accepted appearance and first-launch coach choices,
  and implementing one truthful Settings-wide **Delete all app data** flow over the
  accepted scenario store and app preferences.
- Acceptance criteria:
  - Education provides the accepted small offline hierarchy: Understanding your
    projection, How calculations work, the specified glossary terms, exclusions, and
    Projection disclaimer. Copy preserves the shared calculation meaning and avoids
    advice, forecast, guarantee, recommendation, live-data, regulated-service, and
    unsupported storage/security claims.
  - Calculator and Projection expose useful local contextual routes to methodology or
    disclaimer content without secretly switching the selected tab. Missing bundled
    content is treated as a build defect, never a network/loading state.
  - The accepted non-blocking **Start with the example** coach card appears on first
    launch, leaves the Custom 7% / 3% / 0.20% baseline untouched, supports **Choose a
    preset** and **Dismiss**, and persists only dismissal. A persistence failure must
    not block calculation and may dismiss for the current session.
  - Appearance defaults to **System**, offers only System/Light/Dark, applies at the
    app root, persists across relaunch, and remains truthful if preference persistence
    fails. Preferences are hidden behind a small injectable boundary rather than
    scattered direct storage access.
  - Settings uses the accepted Appearance, Data on this device, and About and help
    hierarchy; About reads version/build from the bundle; bundled Privacy and
    Projection disclaimer routes explain the implemented local-only/no-app-operated-
    sync and backup caveat accurately. No broken or invented Privacy/Support URL or
    contact destination is shown.
  - **Delete all app data** uses the exact-scope destructive confirmation and resets
    saved scenarios (including recovery material where the store can authoritatively
    erase it), appearance, coach dismissal, Calculator to the accepted Custom
    baseline, loaded-scenario context, selected tab, and all navigation paths.
    Success appears only after persistent stores are re-read and empty/default; a
    partial or unknown result reports failure and what remains unknown, retains a
    retry path, and never claims transactional atomicity across separate stores.
  - The scenario store gains only the minimum deliberate all-data erasure operation;
    existing delete-one and corrupt/unsupported preservation behaviour remains
    unchanged outside this separately confirmed global reset.
  - Standard app-only `UserDefaults` is used for appearance/coach preferences through
    the approved boundary. The app target includes a valid `PrivacyInfo.xcprivacy`
    declaring only the required-reason API category
    `NSPrivacyAccessedAPICategoryUserDefaults` with reason `CA92.1`; no collected-data
    or tracking declaration is invented.
  - Unit and focused UI tests cover preference defaults/write/relaunch/failure,
    coach-card actions, all appearance choices, Education/Settings routes, bundled
    content availability, global-reset success/Cancel/partial failure/relaunch,
    recovery-material erasure, accessibility identifiers/labels/focus, Dynamic Type,
    dark mode, adaptive iPad, and offline operation. All existing fixture, store, and
    UI regressions still pass.
  - Debug and Release simulator builds pass. The specialist inventories dependencies,
    runtime APIs, privacy manifest placement/content, capabilities, entitlements,
    networking, logging, and scope exclusions, and records every passed, failed,
    skipped, and untested check honestly.
- Content approval boundary: IGC-D022 authorises restrained development/internal-beta
  copy within the accepted design guardrails. Final external-beta/public positioning,
  investment-risk/disclaimer wording, legal/regulatory disposition, public Privacy and
  Support URLs, and support contact remain release gates and are not certified here.
- Explicit exclusions: calculation/schema/fixture changes; scenario import/export or
  migration; native comparison; monthly UI; CSV/share; draft restoration after
  termination; remote content; accounts; sync; CloudKit; App Groups; networking;
  analytics; diagnostics; advertising/tracking; premium; StoreKit; new dependency;
  new capability/entitlement; live Privacy/Support services; TestFlight; archive/
  upload; App Store Connect records; metadata; screenshots; submission.
- Required completion handoff: update `handoffs/IOS_ENGINEER.md` with the exact base,
  branch and commit range; preference keys/version/defaults and migration behaviour;
  every Education/Settings route and final implemented development copy; complete
  reset sequencing, erasure scope, partial-failure/relaunch semantics and recovery
  handling; privacy-manifest/API/dependency inventory; files changed; all test/build/
  accessibility/adaptive/offline evidence and environment; skips/limitations; review
  instructions; rollback guidance; and clean-worktree confirmation. Stop at
  **Ready for review** without push or merge.
- Specialist: iOS Engineer using `gpt-5.6-sol` at `xhigh` reasoning.
- Branch/worktree: `codex/igc-013-native-secondary-content` in required isolated
  worktree `/private/tmp/igc-013-native-secondary-content`.
- Dispatch control: the standalone Product Manager prompt supplies the exact accepted
  management-update base. If the integration head differs, stop and request a reissued
  base rather than rebasing, merging, or guessing.
