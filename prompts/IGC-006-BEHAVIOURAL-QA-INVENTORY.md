# Standalone specialist prompt — IGC-006 behavioural QA inventory

You are the QA Engineer for **Investment Growth Calculator** (IGC). Complete
**IGC-006 — Create behavioural QA inventory** as a documentation-only quality-planning
task. Do not implement tests or begin the native app.

## Thread and work isolation

- Exact thread name: `IGC-006 — Behavioural QA Inventory`
- Recommended model: `gpt-5.6-sol`
- Recommended reasoning effort: `high`
- Repository: `HenryBerkin/compound-toolkit`
- Exact accepted base commit:
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`
- Worktree: required
- Worktree path: `/private/tmp/igc-006-behavioural-qa-inventory`
- Branch: `codex/igc-006-behavioural-qa-inventory`

Create an isolated worktree and the named branch from the exact base commit. Do not
work on or merge into `project/ios-migration-audit`. IGC-005 and IGC-008 may run in
parallel from the same base, so do not edit or assume their unaccepted deliverables.

## Read before planning

Read these files completely:

- `AGENTS.md`
- `PROJECT_STATUS.md`
- `TASKS.md`
- `DECISIONS.md`
- `docs/PRODUCT_SPEC.md`
- `docs/CALCULATION_SPEC.md`
- `docs/SCENARIO_SCHEMA.md`
- `docs/PLATFORM_STRATEGY.md`
- `docs/PWA_AUDIT.md`
- `docs/IOS_ARCHITECTURE.md`
- `handoffs/QA_ENGINEER.md`
- `handoffs/IOS_ENGINEER.md`
- `handoffs/DESIGNER.md`
- `shared/fixtures/calculation-v1.json`
- `shared/schemas/calculation-fixture-v1.schema.json`
- `shared/schemas/scenario-v1.schema.json`
- `shared/examples/scenario-v1.example.json`

Inspect relevant PWA source and existing tests, especially:

- `igc-pwa/src/lib/calc.ts`
- `igc-pwa/src/lib/calc.test.ts`
- `igc-pwa/src/lib/sharedContract.test.ts`
- `igc-pwa/src/lib/exportCsv.ts`
- `igc-pwa/src/lib/presets.ts`
- `igc-pwa/src/hooks/useScenarios.ts`
- `igc-pwa/src/App.tsx`
- scenario, comparison, results, chart, and breakdown components.

You may run existing read-only PWA checks to confirm evidence. Do not change tests,
fixtures, product behavior, dependencies, or generated assets.

## Accepted inputs that must not be reopened

- Shared calculation and validation contract version 1 is authoritative.
- Shared scenario schema version 1 is authoritative and explicitly uses GBP.
- TypeScript and future Swift engines are independent consumers of the same JSON
  fixtures.
- Native iOS 1.0 is iOS 17+, iPhone-primary and adaptively iPad-compatible.
- Native 1.0 has annual detail only and no CSV; monthly calculations remain required.
- Native two-scenario comparison is deferred to iOS 1.1; Web comparison remains
  supported.
- Initial state is explicitly Custom at the verified 7% / 3% / 0.20% baseline.
- Global Index applies 0.40% only after deliberate selection.
- Native persistence is an actor-backed Codable Application Support store mapping
  scenario V1; PWA persistence remains browser localStorage and legacy Web records are
  not silently V1.
- All 1.0 features are local/free. No account, backend, sync, analytics, payment,
  StoreKit, advertising, remote configuration, or network dependency.
- No native code or Xcode project exists yet.

## Objective

Create a reproducible, traceable behavioural QA inventory spanning Shared, iOS, and
Web responsibilities. It must be specific enough for later test implementation and
release acceptance without treating current PWA quirks as automatic requirements.

The primary deliverable is:

- `docs/QA_PLAN.md`

## Required QA coverage

### 1. Quality strategy and taxonomy

Define:

- quality objectives and release risks;
- Shared versus iOS versus Web ownership;
- approved behavior, observed behavior, known defect, recommendation, and deferred
  feature labels;
- test levels: contract, unit, invariant, integration, UI, accessibility, exploratory,
  compatibility, privacy/release;
- stable test-case identifier convention, such as Shared/iOS/Web prefixes;
- evidence required for pass, fail, blocked, skipped, and not applicable.

### 2. Requirements traceability

Create a traceability matrix from accepted decisions/specifications to test suites and
release gates. Cover at least:

- calculation contract and fixture version;
- validation bounds and error fields;
- Custom baseline and presets;
- target semantics;
- annual/monthly platform difference;
- comparison platform difference;
- scenario schema and persistence;
- offline/local-first behavior;
- accessibility/adaptive requirements;
- privacy and reset/delete behavior;
- deferred premium boundary.

IGC-005 may be running in parallel. Identify design-dependent assertions without
inventing its outcome; state how its accepted deliverable will later be incorporated.

### 3. Shared calculation parity

Specify how both clients consume `shared/fixtures/calculation-v1.json` directly:

- fixture/schema version handling;
- every calculation case, validation case, checkpoint, count, enum, and tolerance;
- the exact absolute/relative/rate tolerance algorithm;
- no expectation regeneration from either implementation;
- investigation flow for both-clients failure versus Swift-only or TypeScript-only
  failure;
- invariant and metamorphic tests beyond fixture examples;
- raw-value comparison before presentation formatting.

Do not alter or recompute fixture expected values.

### 4. Calculation and validation inventory

Provide cases for:

- principal and contribution minimum/maximum and both-zero rule;
- APR, inflation, and annual-fee bounds;
- whole years, extra months, 1-month minimum, 720-month maximum;
- every contribution frequency;
- every compounding frequency;
- start/end contribution timing;
- zero rates and zero optional values;
- partial years;
- fee and inflation ordering;
- contribution conversion;
- annual aggregation and internal monthly rows;
- non-finite/invalid canonical values;
- UK-English form parsing and display-boundary rounding;
- target absent, zero, met, above, and below.

Separate shared semantic validation from platform-specific text-input parsing.

### 5. Preset and Custom behavior

Cover:

- truthful initial Custom state;
- exact verified default inputs and result;
- deliberate selection of each preset;
- Global Index 0.40% fee;
- editing controlled values returns to Custom;
- saving/loading/duplicating retains preset ID or Custom accurately;
- display copy is not persisted contract identity;
- known current PWA selector mismatch is a Web defect, not desired native behavior.

### 6. Scenario persistence and recovery

Define tests for native and Web separately:

- save, name, trim/limit, load, rename, duplicate, delete, reset all;
- stable/unique identifiers and timestamp rules;
- explicit GBP, decimal rates, optional target, preset ID;
- atomic native writes, failed writes, protected/unavailable storage;
- corrupt data preservation/recovery;
- unknown schema refusal;
- interrupted mutation and UI truthfulness;
- device backup wording versus no app-operated sync;
- multiple scenarios without native comparison;
- PWA localStorage unavailable/malformed data and legacy format;
- no unapproved cross-platform import/sync behavior.

### 7. Platform capability matrix

Create an explicit matrix showing:

- Shared behavior;
- native iOS 1.0 behavior;
- supported PWA behavior;
- deferred iOS 1.1 or later behavior.

Include comparison, monthly detail, CSV, service-worker lifecycle, install/update,
navigation/layout, persistence, sharing/export, accessibility APIs, and offline
operation. Test platform differences intentionally rather than reporting them as
parity defects.

### 8. Native feature and navigation inventory

Based on accepted architecture, specify later tests for:

- tabs and typed navigation;
- calculator draft/validation/results snapshot;
- results and annual detail;
- saved scenarios and loading into Calculator;
- Education and Settings/About;
- error/recovery/confirmation flows;
- feature-local state and tab switching;
- local-free availability with no locked states;
- app lifecycle, background/foreground, relaunch, and offline use.

No native implementation exists; identify these as planned cases and do not claim they
were executed.

### 9. PWA regression inventory

Preserve supported Web behavior:

- calculator/validation/results;
- target analysis and insights;
- chart modes;
- annual/monthly breakdown and 120-month monthly-display limit;
- CSV structure, precision, and current filename behavior;
- scenario CRUD and comparison;
- glossary/methodology;
- responsive layout;
- dark mode;
- service worker/offline/update behavior;
- localStorage persistence;
- keyboard and browser accessibility.

Separate known findings: disabled pinch zoom, inaccessible chart risk, target invalid
text behavior, preset selector mismatch, dependency vulnerabilities, legacy naming,
and unconfigured deployment. Do not silently convert them into accepted behavior.

### 10. Accessibility and adaptive QA

Define reproducible checks for:

- Dynamic Type including accessibility sizes;
- VoiceOver labels, values, hints, order, headings, actions, and announcements;
- chart text/table alternative;
- focus movement after validation and dialogs;
- contrast and non-colour meaning in light/dark;
- Reduce Motion;
- touch targets;
- hardware/software keyboard behavior;
- compact/large iPhones;
- portrait/landscape where supported;
- iPad compact/regular widths and multitasking;
- browser zoom, keyboard order, and responsive reflow on Web.

Clearly distinguish automated, simulator, physical-device, assistive-technology, and
manual evidence.

### 11. Environment and compatibility matrix

Recommend:

- supported iOS versions and current SDK/toolchain recheck;
- representative iPhone/iPad simulator classes without hard-coding transient device
  marketing names as the entire strategy;
- at least one physical-device smoke-test category;
- supported browser categories for Web;
- locale/time-zone and light/dark combinations;
- clean install, upgrade/migration, relaunch, offline, and storage-failure conditions.

Label recommendations rather than inventing an approved browser support policy.

### 12. Automation ownership and execution

Map cases to:

- TypeScript/Vitest;
- future Swift Testing;
- future XCTest/XCUI;
- schema/fixture structural checks;
- manual exploratory/accessibility/device review;
- release checklist.

State which checks run on every change, Shared-contract changes, Web changes, iOS pull
requests, release candidates, and App Store submission. Do not create CI configuration
or test code under IGC-006.

### 13. Defect and change-control process

Define:

- severity/priority guidance;
- regression versus intentional contract change;
- minimum reproduction/evidence;
- platform ownership;
- fixture-change approval;
- known-issue handling;
- when a failure blocks iOS, Web, or both;
- how design/app-review findings enter the plan later.

### 14. Entry/exit and release gates

Provide objective gates for:

- architecture/design readiness;
- calculation-core parity;
- vertical slice;
- scenario lifecycle;
- accessibility readiness;
- Web regression;
- TestFlight/release candidate;
- App Store/privacy readiness.

Do not mark future gates passed. List current evidence separately from planned evidence.

## Files you may edit

Only:

- `docs/QA_PLAN.md`
- `handoffs/QA_ENGINEER.md`
- `TASKS.md` — IGC-006 status and verification fields only
- `PROJECT_STATUS.md` — IGC-006 review-state update only
- `CHANGELOG.md` — one concise IGC-006 entry only

Do not edit:

- `DECISIONS.md`;
- any other handoff;
- accepted product, calculation, scenario, platform, architecture, or design docs;
- `shared/` fixtures or schemas;
- any PWA source, tests, dependencies, or configuration;
- `igc-ios/` or any native project/source/test file;
- prompts for other tasks.

If an accepted requirement conflicts with observed behavior, record the exact conflict
and evidence in `docs/QA_PLAN.md`. Do not resolve scope or regenerate fixtures.

## Explicit non-goals

Do not:

- implement, modify, or execute native tests;
- create an Xcode project or Swift code;
- change PWA code/tests or fix known defects;
- define new product features or design-system outcomes;
- start IGC-005, IGC-007, or IGC-008;
- perform App Store submission or legal/privacy review;
- modify contracts, calculations, fixtures, schema, persistence semantics, or
  architecture;
- dispatch another specialist or merge branches.

## Required completion handoff

When work begins, set only IGC-006 to `In progress`. Mark it `Ready for review` only
after the deliverable and checks are complete.

Before completion:

1. verify every required QA section and traceability area is present;
2. verify local links and references;
3. if existing PWA checks were run, report exact results; do not imply they were
   required if the evidence already sufficed;
4. run `git diff --check` before committing;
5. confirm shared contracts/fixtures, PWA files, native files, and other specialist
   deliverables are unchanged;
6. commit the documentation-only result with a focused message;
7. run `git diff --check
   c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a..HEAD`;
8. confirm the working tree is clean.

Return:

- status: `Ready for review`;
- thread name;
- branch and worktree path;
- base commit;
- final commit SHA;
- files changed;
- concise QA strategy;
- current evidence versus future/unexecuted coverage;
- proposed release gates and Product Manager review decisions;
- dependencies on the later accepted IGC-005/IGC-008 outputs;
- checks run, passed, failed, skipped, or not applicable;
- explicit confirmation that no native implementation, test implementation, or
  IGC-007 work began.
