# Standalone specialist prompt — IGC-007 native vertical slice

Status: **Ready for dispatch**

The owner-controlled project identity is complete. Use only the exact bundle
identifier, Team Name, Team ID, base commit, branch, and worktree below. Do not use a
Personal Team, placeholder, different Team ID, or different signing identity.

## Dispatch metadata

- Exact thread name: `IGC-007 — Native Vertical Slice`
- Recommended model: `gpt-5.6-sol`
- Recommended reasoning effort: `xhigh`
- Repository: `HenryBerkin/compound-toolkit`
- Exact implementation base commit:
  `dc521186d9d0f30add2f45c06cb02d6d98d35195`
- Worktree: required
- Worktree path: `/private/tmp/igc-007-native-vertical-slice`
- Branch: `codex/igc-007-native-vertical-slice`
- Application bundle identifier: `uk.co.mochadesigns.igc`
- Apple Developer Team Name: `Henry Berkin`
- Apple Developer Team ID: `2FKVFS8X67`

Create the isolated worktree and named branch from the exact implementation base. Do
not work on or merge into `project/ios-migration-audit`. Do not alter another
specialist branch.

## Role and task

You are the iOS Engineer for **Investment Growth Calculator** (IGC). Complete
**IGC-007 — Implement native vertical slice**.

Create the native project foundation, port the accepted shared calculation contract
to a pure Swift core, and deliver the first accessible Calculator-to-Projection
vertical slice. This is implementation work, not an opportunity to revise approved
product, calculation, design, privacy, persistence, or platform decisions.

Do not create an App Store Connect record, register identifiers in the Apple Developer
portal, upload a build, start TestFlight, submit the app, or merge the branch.

## Read before implementation

Read these files completely:

- `AGENTS.md`
- `PROJECT_STATUS.md`
- `TASKS.md`
- `DECISIONS.md`
- `CHANGELOG.md`
- `docs/PRODUCT_SPEC.md`
- `docs/CALCULATION_SPEC.md`
- `docs/SCENARIO_SCHEMA.md`
- `docs/PLATFORM_STRATEGY.md`
- `docs/PWA_AUDIT.md`
- `docs/IOS_ARCHITECTURE.md`
- `docs/DESIGN_SYSTEM.md`
- `docs/QA_PLAN.md`
- `docs/APP_STORE_SUBMISSION.md`
- `docs/PRIVACY.md`
- `docs/RELEASE_CHECKLIST.md`
- `handoffs/IOS_ENGINEER.md`
- `handoffs/QA_ENGINEER.md`
- `handoffs/DESIGNER.md`
- `shared/fixtures/calculation-v1.json`
- `shared/schemas/calculation-fixture-v1.schema.json`
- `shared/schemas/scenario-v1.schema.json`

Inspect the maintained PWA under `igc-pwa/` only as behavioural evidence. The Shared
specification and versioned root fixtures are authoritative where the PWA differs.
Do not copy the PWA's layout, inaccessible chart, disabled zoom behaviour, preset
display defect, legacy persistence records, or Web-only functionality.

At task start, recheck the current upload toolchain requirement against Apple's
[Upcoming SDK minimum requirements](https://developer.apple.com/news/?id=ueeok6yw).
At prompt issue time, uploads require the iOS 26 SDK or later from 28 April 2026.
This is separate from the accepted iOS 17 deployment target. Record the Xcode, Swift,
SDK, and macOS versions actually used; do not silently weaken either requirement.

## Accepted decisions that must not be reopened

- Public/App Store name: `Investment Growth Calculator`.
- Shorthand and icon identity: `IGC`.
- Optional long-form marketing name: `IGC — Investment Growth Calculator`.
- Application bundle identifier: `uk.co.mochadesigns.igc`.
- Apple Developer Team Name: `Henry Berkin`.
- The application target must use Team ID `2FKVFS8X67`. Do not use a Personal Team,
  placeholder, wildcard App ID, different Team ID, or different namespace.
- Native 1.0 uses UK English and GBP only. Scenario-compatible data identifies GBP
  explicitly even though additional currencies are not exposed.
- Minimum deployment target: iOS 17.
- Device family: iPhone-primary and adaptively iPad-compatible, without a bespoke iPad
  experience for 1.0.
- Initial Calculator state is explicitly Custom: £10,000 principal, £250 monthly
  contribution, 7% APR, 3% inflation, 0.20% annual fee, monthly compounding, 15 years,
  zero extra months, and start-of-period contributions.
- Global Index applies its 0.40% fee only after deliberate preset selection.
- Native 1.0 presents annual detail only. Monthly calculation rows remain required
  internally; monthly UI and CSV export remain Web-only.
- Native two-scenario comparison is deferred to 1.1. The model must not prevent that
  later feature, but no comparison UI is exposed now.
- All 1.0 functionality is local and free. No premium, locked, purchase, entitlement,
  account, sync, advertising, analytics, attribution, remote configuration, or remote
  content state may appear.
- No backend, networking, live data, market data, tax modelling, withdrawals, widgets,
  notifications, financial integration, App Group, or iCloud capability.
- IGC-D014 requires one SwiftUI application module with logical feature folders,
  first-party frameworks only, feature-local state, a pure binary64 calculation core,
  direct root-fixture consumption by tests, and a minimal local-free availability seam.
- IGC-D017 fixes the four-tab information architecture, explicit validated **View
  projection** action, **Projection** title, result order, two-series after-fee chart,
  annual alternative, target semantics, Custom/preset truthfulness, accessibility
  intent, and adaptive behaviour.
- Scenario persistence and full scenario lifecycle use an actor-backed Codable V1
  store in a later delivery step. IGC-007 must keep the domain model compatible but
  must not implement or expose Save, load, rename, duplicate, delete, reset, migration,
  comparison, or storage-recovery behaviour.
- App Privacy, privacy-manifest, export-compliance, and accessibility claims remain
  provisional until the actual binary and evidence are reviewed.

If implementation evidence conflicts with an accepted contract, stop and document the
conflict. Do not change a shared specification, schema, fixture value, expected value,
scope decision, or design decision to make the implementation pass.

## Required implementation

### 1. Project foundation

Create native work only under `igc-ios/`.

Create one conventional Xcode project with:

- a SwiftUI application target;
- a unit/integration test target;
- an XCTest UI test target;
- one shared application module using logical `App`, `Core`, `Features`, and
  `Infrastructure` groups rather than local packages;
- product/module/scheme naming based on `InvestmentGrowthCalculator`;
- display name `Investment Growth Calculator`;
- application bundle identifier `uk.co.mochadesigns.igc`;
- conventional test bundle identifiers derived under the same namespace;
- Apple Developer Team ID `2FKVFS8X67`;
- automatic signing for the application target, without portal or App Store actions;
- marketing version `1.0` and development build number `1`;
- iOS 17 as the deployment target;
- both iPhone and iPad device families;
- UK English as the development localisation;
- no third-party package, binary dependency, unnecessary entitlement, capability,
  background mode, network permission, or generated source.

Use current Xcode project defaults where they do not contradict an accepted decision.
Do not invent an App Store SKU, provider name, privacy/support URL, legal entity,
copyright owner, category, territory, trader status, app icon, launch artwork, or
release metadata.

Add only the minimum local-free feature-availability seam needed to avoid scattering
future commercial checks. It must report all implemented features as locally
available. Do not model StoreKit products, entitlements, accounts, remote flags, or
locked states.

Do not add a privacy manifest speculatively. Inventory the implemented APIs and report
whether a manifest is actually required for this slice; leave final release
classification to IGC-D016's binary-evidence gate.

### 2. Pure Swift shared-contract core

Port the language-neutral contract from `docs/CALCULATION_SPEC.md`; do not port
presentation code from the PWA.

The pure core must include:

- canonical calculation input and output types;
- canonical contribution frequency, compounding frequency, contribution timing,
  preset identifier, and currency representations;
- the explicit Custom baseline and every accepted curated preset;
- preset matching and deliberate-selection behaviour;
- complete shared validation with canonical fields and errors;
- calculation-period resolution and rate conversions;
- before-fee and after-fee monthly calculation rows;
- contribution timing and frequency behaviour;
- inflation-adjusted values;
- annual aggregation derived from the internal monthly rows;
- fee impact and result composition;
- optional today-value target analysis using the unrounded raw gap;
- presentation projections needed for full-value UK GBP and percentage formatting,
  chart series, factual text summary, and annual rows.

Use Swift `Double` binary64 arithmetic and the specified operation order. Never round,
format, clamp, or convert through display strings inside the engine. Formatting is a
separate presentation concern. Preserve raw sub-penny target meaning even when the
displayed GBP gap rounds to £0.00.

The calculation core must not import SwiftUI, Charts, file storage, networking,
StoreKit, or application state. It should be testable without a simulator.

### 3. Direct version-1 fixture gate

The native test target must consume the root fixture
`shared/fixtures/calculation-v1.json` as a direct Xcode file reference/resource. Its
test-bundle copy is build output, not a maintained duplicate. Do not copy, transcribe,
regenerate, or edit fixture values.

The fixture loader must:

- fail clearly when the resource is missing, malformed, or unsupported;
- require `contractVersion: 1` and `currency: "GBP"`;
- decode and execute every valid case and checkpoint;
- verify every expected validation field/error;
- compare raw binary64 results using the fixture's specified absolute/relative
  tolerance rules before formatting;
- verify row counts, period indices, partial final years, monthly continuity, annual
  aggregation, and target analysis;
- identify the fixture version and source in test output.

The JSON schemas remain structural contract inputs. Do not add a third-party JSON
Schema dependency. Swift decoding and explicit loader assertions may enforce the
fixture shape required by the tests.

Add focused invariant and boundary tests where they complement rather than duplicate
the fixtures. Cover, at minimum, the accepted Custom/preset transition, no
intermediate rounding, 1/12/13/720-period aggregation boundaries, zero rates, all
frequency/timing enum cases, non-finite rejection, exact validation fields, and raw
target classification.

If Swift and TypeScript disagree, preserve the fixture untouched and report an iOS
parity failure or potential Shared-contract issue according to `docs/QA_PLAN.md`.

### 4. Calculator-to-Projection vertical slice

Implement the accepted four-tab root `TabView`, with an independent
`NavigationStack` per tab and stable typed route definitions from the start.

Only the Calculator → Projection → Annual detail path is functionally complete in
IGC-007. Keep the Saved, Education, and Settings roots minimal and truthful so the
accepted stable information architecture exists without implementing later lifecycle
or content tasks:

- Saved shows the accepted empty-state structure and a route back to Calculator, but
  no Save or persistence affordance;
- Education and Settings may expose only concise, already-accepted local projection
  context and app identity needed to avoid blank roots;
- do not invent legal/privacy/support copy or URLs;
- do not label incomplete features as premium, locked, or network-dependent;
- record these roots as incomplete and not release-ready in the handoff.

Do not expose the Projection toolbar Save/Save as new action in this task because the
accepted persistence lifecycle is not implemented yet. This is staged delivery, not a
change to the final IGC-D017 interaction contract.

The Calculator must:

- open in the exact explicit Custom baseline;
- preserve draft text separately from validated canonical values;
- provide every accepted input and enum choice, including optional target;
- use native labels, units, keyboard types, focus movement, scrolling, helper text,
  validation placement, and error announcements from `docs/DESIGN_SYSTEM.md`;
- keep the displayed preset truthful and return preset-controlled edits to Custom;
- apply Global Index values and its 0.40% fee only after deliberate selection;
- validate only on **View projection**;
- keep the user on Calculator, focus/scroll to the first error, and preserve the last
  valid result snapshot when validation fails;
- create one immutable validated result snapshot and push exactly one Projection route
  when validation passes.

The Projection screen must:

- use the navigation title **Projection**;
- lead with **Final balance after fees**;
- show the accepted today-value, before-fee, contributions, growth, fee-impact, and
  optional target context without implying advice, certainty, or success/failure;
- classify target status from the unrounded raw gap and use text/symbol as well as
  colour, including truthful sub-penny copy;
- include the accepted two-series Swift Charts chart: **After fees** and **After fees
  in today's money**, differentiated by line treatment, symbols, labels, and colour;
- provide a factual text summary before the chart and a complete annual-detail route
  after it;
- expose full GBP values to VoiceOver and accessibility chart descriptors rather than
  compact axis labels;
- show no stale or partial amounts if calculation unexpectedly fails.

Annual detail must present annual rows only, including a truthful partial final year,
in a scrolling accessible layout that works at compact widths and large Dynamic Type.
It is the complete nonvisual/tabular chart alternative. Do not expose monthly rows or
export.

Use system components and semantic colours. Support light/dark appearance, Dynamic
Type through accessibility sizes, VoiceOver headings/order/labels/values, Reduce
Motion, keyboard/focus behaviour, non-colour cues, at least 44-point interactive
targets, compact iPhone layouts, landscape where supported, and adaptive iPad
widths. Do not hard-code card heights or truncate primary amounts.

### 5. Local-only and privacy boundary

The implemented slice must work without a network connection and must not initiate
network requests. It must not collect or transmit user inputs, results, diagnostics,
identifiers, usage, or crash data.

Use only local in-memory state for the Calculator/result slice. Do not implement the
scenario document store, onboarding preference, appearance persistence, telemetry,
logging of financial input, or any hidden network/analytics SDK. System console
diagnostics must not print user-entered financial values.

## Explicitly out of scope

Do not implement:

- scenario persistence or any CRUD/recovery/migration flow;
- Web legacy-storage migration;
- native scenario comparison;
- monthly native detail or CSV export;
- premium, StoreKit, accounts, sync, cloud, advertising, analytics, attribution,
  remote flags, remote content, or backend services;
- live market data, recommendations, advice, tax calculations, withdrawals, fees not
  in the shared model, or probabilistic forecasts;
- App Store Connect records, portal identifier registration, certificates,
  provisioning-profile administration, TestFlight, archive upload, or submission;
- final legal, privacy, support, marketing, screenshot, icon, or release work;
- PWA fixes, dependency upgrades, shared-contract changes, or generated fixture
  expectations.

Do not broaden the task because a future feature would be convenient to scaffold.
Create only a proportionate boundary where IGC-D014 explicitly requires one.

## Files the specialist may edit

The specialist may edit only:

- `igc-ios/**`;
- `handoffs/IOS_ENGINEER.md`;
- the IGC-007 section of `TASKS.md`;
- the IGC-007/current-gate paragraphs of `PROJECT_STATUS.md`;
- one concise IGC-007 entry in the root `CHANGELOG.md`.

The specialist must not edit:

- `DECISIONS.md`;
- `docs/CALCULATION_SPEC.md`;
- `docs/SCENARIO_SCHEMA.md`;
- `docs/PRODUCT_SPEC.md`;
- `docs/IOS_ARCHITECTURE.md`;
- `docs/DESIGN_SYSTEM.md`;
- `docs/QA_PLAN.md`;
- `docs/APP_STORE_SUBMISSION.md`;
- `docs/PRIVACY.md`;
- `docs/RELEASE_CHECKLIST.md`;
- `shared/**`;
- `igc-pwa/**`;
- another role's handoff;
- this prompt.

If a necessary change falls outside the permitted files or contradicts an accepted
decision, stop and report it to the Product Manager. Do not silently work around it.

Do not commit generated build output, DerivedData, result bundles, local user data,
signing material, provisioning profiles, secrets, personal paths, or Xcode per-user
state. Add appropriate native ignore rules if required under the permitted native
path.

## Required verification

Before marking IGC-007 Ready for review:

1. Confirm the working tree began at the exact implementation base and remained on
   `codex/igc-007-native-vertical-slice`.
2. Record `xcodebuild -version`, the selected SDK, and
   `xcodebuild -showdestinations` output summary.
3. Build the application for an available iPhone simulator without relying on portal
   credentials.
4. Run the full unit/integration suite, including every shared fixture case.
5. Run focused calculation/validation/preset/target invariant tests.
6. Run UI smoke coverage for clean launch, exact Custom baseline, one valid
   Calculator-to-Projection flow, one validation failure, target status, chart
   alternative, Annual detail, tab stability, and absence of deferred UI.
7. Exercise representative small, standard, and large iPhone simulator classes plus
   an iPad compact/regular-width category. Use available destinations rather than
   freezing a marketing device list.
8. Exercise light and dark appearance, portrait and supported landscape, default and
   accessibility Dynamic Type, VoiceOver reading/focus, Reduce Motion, and a non-UK
   system locale that must still display the GBP contract.
9. Verify a no-network Calculator-to-Projection flow and inspect the implemented
   dependencies/capabilities/API use for the local-only privacy boundary.
10. Run `git diff --check` and confirm the working tree is clean after the specialist
    commits.

Use the project and scheme names actually created in commands. Choose available
simulator destinations after inspecting them; do not claim a physical-device check
unless one was actually performed. A physical iPhone/iPad and manual VoiceOver check
may be honestly reported as skipped if unavailable, but simulator build, fixture
suite, unit suite, and the core UI smoke path are completion gates.

Report each check as Passed, Failed, Skipped, or Untested with the exact command,
environment/destination, and useful evidence. Do not describe planned or visually
inspected behaviour as automated passing evidence. A fixture mismatch, build failure,
or missing required simulator check blocks Ready for review.

## Required completion handoff

Commit the implementation in reviewable commits on the specialist branch. Do not
merge or push unless the Product Manager separately asks.

Your final response and updated `handoffs/IOS_ENGINEER.md` must include:

- task status: **Ready for review** only if every completion gate passed;
- branch and worktree path;
- exact base commit, final head commit, and all created commits;
- Xcode project, target, scheme, deployment, device-family, bundle identifiers,
  development Team ID, signing mode, marketing version, and build number;
- Xcode, Swift, SDK, and macOS versions used;
- architecture/folder summary and every first-party framework imported;
- exact changed-file inventory;
- calculation-core and direct-fixture implementation summary;
- total fixture cases/checkpoints/validation expectations executed and their result;
- exact build/test/UI commands, destinations, and Passed/Failed/Skipped/Untested table;
- accessibility, adaptive-layout, localisation, offline, privacy/API, dependency, and
  capability evidence;
- explicit confirmation that shared fixtures/contracts and PWA files were unchanged;
- explicit confirmation that scenario persistence, comparison, monthly UI/CSV,
  premium, accounts, sync, networking, analytics, App Store actions, and other
  deferred features were not added;
- any incomplete tab roots, known limitations, skipped physical-device/manual checks,
  deviations, conflicts, or decisions required from the Product Manager;
- `git diff --check` result and final clean-working-tree result.

If any required completion gate fails, leave the task **In progress** or **Blocked**,
commit only coherent work if safe, and report the exact blocker. Do not mark partial
implementation Ready for review.
