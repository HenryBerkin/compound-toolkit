# Standalone specialist prompt — IGC-004 native iOS architecture

You are the iOS Engineer for **Investment Growth Calculator** (IGC). Complete
**IGC-004 — Propose native iOS architecture** as a documentation-only architecture
task. Do not begin native implementation.

## Repository and work isolation

- Repository: `HenryBerkin/compound-toolkit`
- Exact accepted base commit:
  `3bf1e517636d543e368b610b8a006cafd271e836`
- Create an isolated worktree and branch named
  `codex/igc-004-ios-architecture` from that exact commit.
- Do not work on or merge into `project/ios-migration-audit`.
- Preserve all accepted product, fixture, and schema files.

Before substantive work, read completely:

- `AGENTS.md`
- `PROJECT_STATUS.md`
- `TASKS.md`
- `DECISIONS.md`
- `docs/PRODUCT_SPEC.md`
- `docs/CALCULATION_SPEC.md`
- `docs/SCENARIO_SCHEMA.md`
- `docs/PLATFORM_STRATEGY.md`
- `docs/PWA_AUDIT.md`
- `handoffs/IOS_ENGINEER.md`
- `handoffs/QA_ENGINEER.md`
- `shared/fixtures/calculation-v1.json`
- `shared/schemas/calculation-fixture-v1.schema.json`
- `shared/schemas/scenario-v1.schema.json`
- `shared/examples/scenario-v1.example.json`

Inspect the relevant PWA source and tests where needed to validate your understanding,
especially:

- `igc-pwa/src/lib/calc.ts`
- `igc-pwa/src/lib/calc.test.ts`
- `igc-pwa/src/lib/sharedContract.test.ts`
- `igc-pwa/src/types/index.ts`
- `igc-pwa/src/lib/presets.ts`
- `igc-pwa/src/hooks/useScenarios.ts`

The documents and shared assets are authoritative. The PWA is implementation evidence,
not permission to import web architecture into the native app.

## Accepted product constraints

Treat these as fixed inputs, not questions to reopen:

- Build a native SwiftUI app, not a web-view wrapper.
- Minimum deployment target: iOS 17.
- iPhone-primary, with sensible adaptive iPad compatibility; no bespoke iPad
  experience is required for 1.0.
- Public/App Store name: `Investment Growth Calculator`.
- Shorthand and icon identity: `IGC`.
- Long-form marketing name where useful: `IGC — Investment Growth Calculator`.
- UK English and GBP-only in 1.0.
- Scenario data explicitly stores `currency: "GBP"` so the model is currency-ready.
- The initial calculator state is explicitly Custom and preserves the verified
  7% APR / 3% inflation / 0.20% annual-fee baseline.
- The Global Index preset applies its 0.40% fee only after deliberate selection.
- Native 1.0 saves multiple local scenarios but does not compare two scenarios.
  Native comparison is planned for iOS 1.1, so the model and navigation must not block
  it.
- Native 1.0 displays annual detail only and has no CSV export.
- Monthly calculations and rows remain required internally and in parity tests.
- The supported PWA retains comparison, monthly detail, and CSV export.
- Calculations and saved scenarios work offline and locally.
- No account, backend, sync, analytics, advertising, tracking, remote configuration,
  payment, StoreKit, subscription, premium UI, or third-party SDK is in 1.0 scope.
- Premium staged deferral is accepted. Propose only a proportionate replaceable
  feature-availability/entitlement boundary; do not design a speculative commerce
  system.
- Do not change the accepted mathematical model, fixtures, schema, terminology, or
  platform scope.

## Task objective

Produce a decision-ready, proportionate native architecture for the accepted iOS 1.0.
The proposal must be detailed enough for Product Manager, Designer, QA Engineer, App
Store Reviewer, and a later implementation engineer to evaluate the structure and
sequence without committing the repository to unnecessary abstraction.

The primary deliverable is:

- `docs/IOS_ARCHITECTURE.md`

Also update:

- `handoffs/IOS_ENGINEER.md` with completed proposal context, key recommendations,
  remaining review decisions, verification performed, and the commit SHA;
- `TASKS.md`: set IGC-004 to `In progress` when work begins and `Ready for review` only
  when the deliverable and checks are complete;
- `PROJECT_STATUS.md` with the architecture-review state and an explicit statement that
  native implementation has not started;
- `CHANGELOG.md` under the unreleased preparation section.

Do not edit `DECISIONS.md` to mark architecture choices Accepted. Architecture choices
remain recommendations until Product Manager review. You may include proposed ADRs or
decision candidates in `docs/IOS_ARCHITECTURE.md`.

## Required architecture coverage

### 1. Executive recommendation

Give a concise recommended architecture, why it fits this product, and which accepted
requirements drive it. State what is intentionally absent.

### 2. Platform and toolchain assumptions

- iOS 17 deployment target versus the current App Store build SDK requirement.
- Recommended Swift language mode and Xcode baseline, distinguishing deployment target
  from upload toolchain.
- iPhone and adaptive iPad behavior.
- First-party framework and third-party dependency policy.

Use current official Apple primary sources for time-sensitive Xcode, SDK, SwiftUI,
data, testing, accessibility, and submission claims. Cite direct links near the claims.
Separate Apple requirements from your recommendations. Do not rely on blog summaries.

### 3. App structure and dependency direction

Propose a concrete feature/file or package layout for the future `igc-ios/` directory,
including app composition, domain model, calculation engine, persistence, features,
shared UI, resources, and test targets.

Explain:

- dependency direction and boundaries;
- state ownership and observation;
- navigation for calculator, results, annual detail, saved scenarios, education,
  settings/about, and future comparison;
- where formatting, validation, presets, target analysis, and chart projection live;
- how to avoid both a monolithic view model and premature multi-package complexity.

Include a small dependency diagram or equivalent compact visualization only if it makes
the boundaries materially clearer.

### 4. Calculation port and parity

Describe a pure Swift binary64 calculation engine that implements contract version 1
without intermediate rounding.

Cover:

- canonical Swift types and enum mapping;
- validation boundary versus calculation boundary;
- monthly simulation and annual aggregation;
- fee, inflation, timing, partial-year, and frequency-conversion behavior;
- target analysis outside the core growth engine;
- GBP presentation rounding outside the engine;
- preservation of monthly rows even though native 1.0 shows annual detail only.

The test target must consume `shared/fixtures/calculation-v1.json` directly as a bundled
test resource. Do not copy expected fixture values into Swift source and do not generate
new expectations from the Swift implementation. Specify the exact tolerance algorithm
from the shared contract and how fixture/schema versions fail safely.

### 5. Scenario model, persistence, and migration

Evaluate realistic first-party persistence options for this app, including at minimum
SwiftData and a simpler Codable/file-based approach. Recommend one and explain:

- why it is proportionate for iOS 17 and the accepted 1.0 workflows;
- data-store ownership and concurrency;
- mapping to `shared/schemas/scenario-v1.schema.json`;
- schema versioning and migrations;
- opaque stable IDs, with UUIDs for new native records;
- explicit `GBP`, decimal-rate units, preset IDs, optional today-value target, and UTC
  timestamps;
- save, rename, load, duplicate, delete, reset-all, and error/recovery behavior;
- multiple scenarios now and two-scenario comparison later;
- backup behavior and whether iCloud or device backup semantics need user-facing
  clarification;
- why PWA localStorage is not a native storage API.

The current PWA has legacy scenario records without `schemaVersion`, `currency`, or
stable `presetId`. Do not implement or silently specify a web migration under IGC-004.
Identify it as a separately tested Web concern and preserve future interchange options.

### 6. Feature availability and deferred premium

Propose the smallest replaceable feature-availability boundary that keeps views and
domain logic independent of a future entitlement source. The initial provider must
resolve only free/local availability.

Do not add StoreKit types, product IDs, receipt logic, account models, network
interfaces, backend protocols, remote flags, or premium screens. Explain what later
evidence/decision would justify expanding the boundary.

### 7. Privacy, security, and data lifecycle

Document local data categories, protection-at-rest assumptions, logging constraints,
backup considerations, delete/reset semantics, and failure recovery. Do not claim that
local-only data is not user data. Identify inputs the later App Store/privacy review
must verify.

### 8. Accessibility and adaptive interface architecture

Cover Dynamic Type, VoiceOver semantics and reading order, contrast, Reduce Motion,
touch targets, chart alternatives, keyboard behavior where applicable, validation
announcements, and adaptive iPad layout. Explain which concerns belong in architecture,
design specification, and QA respectively.

### 9. Test strategy

Define test layers and ownership:

- pure calculation fixture and invariant tests;
- semantic validation and preset tests;
- scenario encoding/schema/persistence/migration tests;
- target and annual-aggregation tests;
- view-model or feature-state tests;
- SwiftUI integration and navigation tests;
- accessibility and UI tests;
- adaptive iPhone/iPad coverage;
- manual App Store/privacy checks.

Identify what can run without a simulator, what requires simulator/device coverage, and
how failures distinguish shared regressions from iOS-only defects. Retain independent
TypeScript and Swift fixture consumers.

### 10. Delivery sequence

Recommend a low-risk implementation order after architecture acceptance. It should
start with project foundations and fixture-backed calculation parity, then reach a
small end-to-end vertical slice before expanding scenarios and secondary content.

Identify dependencies on IGC-005, IGC-006, and IGC-008. Do not start those tasks or
write their deliverables.

### 11. Alternatives and expensive-to-reverse decisions

For each material choice, provide:

- recommendation;
- realistic alternatives;
- consequences and failure modes;
- reversibility;
- what must be decided before project creation;
- what can safely wait until implementation or release review.

At minimum address persistence, navigation/state architecture, module/package
boundaries, dependency policy, scenario migration, bundle identifier/product module
naming, test-fixture packaging, and the feature-availability boundary.

Do not invent an Apple Developer team ID, bundle identifier, App Store SKU, StoreKit
product ID, signing setup, or final app-group/iCloud entitlement. Propose naming
options and constraints, recommend a convention, and flag owner-controlled identifiers
for confirmation before project creation.

## Explicit non-goals

Under IGC-004, do not:

- create `igc-ios/`, an Xcode project, Swift package, source file, test target, asset
  catalogue, or generated project;
- implement or modify any PWA behavior;
- modify shared contract values or regenerate fixture expectations;
- add dependencies or lockfiles;
- build a prototype or feasibility spike unless the Product Manager separately
  authorizes it;
- begin design-system, QA-plan, App Store submission, privacy-policy, or implementation
  tasks;
- create accounts, networking, sync, payments, premium functionality, analytics, or
  remote configuration;
- dispatch other specialists or broaden the task.

If you discover a genuine conflict in accepted requirements, stop that line of work,
record the exact conflict and evidence in the architecture document, and return it for
Product Manager resolution. Do not resolve product scope silently.

## Verification and completion

Before marking IGC-004 `Ready for review`:

1. confirm no `igc-ios/`, Xcode project, Swift source, dependency, or generated artifact
   was added;
2. confirm shared fixtures, schemas, accepted decisions, and PWA files are unchanged;
3. check every required architecture section is present;
4. check local Markdown links and cited official Apple URLs;
5. run `git diff --check`;
6. report all checks, skipped checks, assumptions, and open review decisions honestly;
7. commit the documentation-only changes on the isolated branch with a focused message;
8. return the branch name, commit SHA, files changed, executive recommendation, proposed
   decisions requiring Product Manager acceptance, and verification results.

No native build is expected because creating the native project is expressly out of
scope.
