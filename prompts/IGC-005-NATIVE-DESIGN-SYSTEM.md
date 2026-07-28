# Standalone specialist prompt — IGC-005 native design system

You are the native Product Designer for **Investment Growth Calculator** (IGC).
Complete **IGC-005 — Define native design system** as a documentation and design-
specification task. Do not create or implement the iOS application.

## Thread and work isolation

- Exact thread name: `IGC-005 — Native Design System`
- Recommended model: `gpt-5.6-sol`
- Recommended reasoning effort: `high`
- Repository: `HenryBerkin/compound-toolkit`
- Exact accepted base commit:
  `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`
- Worktree: required
- Worktree path: `/private/tmp/igc-005-native-design-system`
- Branch: `codex/igc-005-native-design-system`

Create an isolated worktree and the named branch from the exact base commit. Do not
work on or merge into `project/ios-migration-audit`. IGC-006 and IGC-008 may run in
parallel from the same base, so do not edit their deliverables or handoffs.

## Read before designing

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
- `handoffs/DESIGNER.md`
- `handoffs/IOS_ENGINEER.md`
- `handoffs/QA_ENGINEER.md`

Inspect the PWA in `igc-pwa/` as product evidence. You may run its existing development
server and inspect mobile/desktop behavior if useful. Use it to understand workflows,
terminology, identity, and density—not as a pixel-for-pixel template for native iOS.

Use current official Apple Human Interface Guidelines and accessibility documentation
for time-sensitive platform recommendations. Cite direct Apple links near claims.
Clearly distinguish accepted product requirements, Apple requirements, design
recommendations, and decisions still requiring Product Manager review.

## Accepted inputs that must not be reopened

- Public/App Store name: `Investment Growth Calculator`.
- Shorthand and icon identity: `IGC`.
- Optional long-form marketing: `IGC — Investment Growth Calculator`.
- Native SwiftUI application, minimum iOS 17.
- iPhone-primary, adaptively iPad-compatible; no bespoke iPad experience for 1.0.
- UK English and GBP-only in 1.0.
- Initial state is explicitly Custom at £10,000 principal, £250 monthly contribution,
  7% APR, 3% inflation, 0.20% annual fee, monthly compounding, 15 years, and
  start-of-period timing.
- Global Index applies its 0.40% fee only after deliberate preset selection.
- Native 1.0 supports multiple saved scenarios but not two-scenario comparison.
- Native 1.0 displays annual detail only; monthly detail and CSV remain Web-only.
- Monthly calculations still exist internally.
- Calculation, terminology, preset, validation, target, and scenario semantics are
  shared contracts and may not be changed through design.
- Native architecture is accepted under IGC-D014: one SwiftUI module, feature-local
  state, first-party frameworks, Codable local scenarios, direct shared-fixture tests,
  and a local-free feature-availability seam.
- All 1.0 features are free. Do not design locked, premium, purchase, account, sync,
  analytics, advertising, or remote-content states.
- No backend, network requirement, live data, market data, tax modelling, withdrawals,
  export, widgets, notifications, or financial integrations.

## Objective

Create an implementation-ready native design system and interaction specification that
translates IGC's useful identity and product behavior into clear iOS patterns. It must
help a later SwiftUI engineer build the calculator without inventing hierarchy, states,
copy behavior, accessibility intent, or adaptive-layout rules.

The primary deliverable is:

- `docs/DESIGN_SYSTEM.md`

Optional design-support files may be added only under:

- `docs/design/`

Use optional files only when they materially clarify a component, state transition, or
layout. Prefer Markdown, Mermaid, simple SVG, or concise wireframes. Do not create final
app icons, marketing artwork, screenshots, raster mockups, or an asset catalogue.

## Required design coverage

### 1. Design thesis and product hierarchy

Define:

- design principles appropriate for an educational investment calculator;
- the hierarchy of primary action, assumptions, outcome, context, and education;
- how users distinguish projection from advice or forecast;
- how IGC identity appears without overpowering financial clarity;
- which PWA patterns should be preserved, adapted, or deliberately rejected.

### 2. Information architecture and navigation

Specify the accepted architecture's tabs and navigation:

- Calculator;
- Saved scenarios;
- Education;
- Settings/About;
- Results and annual detail routes;
- future comparison route reserved but not exposed in 1.0.

Show screen relationships, entry/exit behavior, back behavior, deep screen titles,
loading a saved scenario into Calculator, and state preservation when switching tabs.
Do not add product routes or features outside accepted scope.

### 3. Screen-by-screen specification

Provide implementation-ready hierarchy and behavior for:

- first launch/onboarding, if retained;
- Calculator;
- optional target section;
- Results overview;
- accessible growth visualization;
- annual detail;
- Saved scenarios list;
- save, rename, duplicate, load, delete, and reset-all flows;
- Education/assumptions/glossary;
- Settings/About, privacy/support/disclaimer entry points;
- empty, invalid, unavailable-storage, corrupt-data recovery, and destructive-confirmation
  states.

For each screen, state:

- purpose and primary user question;
- ordered content hierarchy;
- primary and secondary actions;
- navigation behavior;
- compact and expanded/adaptive layout;
- VoiceOver reading order;
- Dynamic Type and scrolling behavior;
- empty/error/recovery behavior;
- implementation notes tied to `docs/IOS_ARCHITECTURE.md`.

### 4. Calculator form and input behavior

Specify native controls and interaction rules for:

- GBP principal and contribution;
- weekly/monthly/annual contribution frequency;
- growth/APR, inflation, and fee percentages;
- daily/monthly/quarterly/annual compounding;
- years plus extra months;
- start/end contribution timing;
- optional today-value target;
- presets and truthful Custom state.

Cover keyboard type, focus movement, Done behavior, field labels, units, helper text,
validation placement, error announcements, invalid drafts, recalculation trigger, and
how edits to preset-controlled fields return to Custom. Do not change shared validation
bounds or parsing semantics.

### 5. Results and financial communication

Define the hierarchy for:

- final balance after fees as primary KPI;
- nominal, after-fee, and inflation-adjusted context;
- starting balance, contributions, growth, and fee impact;
- today-value target above/below result;
- annual detail;
- assumptions and projection disclaimer.

Specify terminology, visual grouping, number formatting intent, positive/negative
target treatment without colour-only meaning, and how uncertainty is communicated.
The chart is supplementary: provide a text summary and annual table alternative.
Do not expose monthly native detail or export.

### 6. Saved scenarios

Specify list rows, sorting recommendation, names, metadata, Custom/preset indication,
load behavior, duplicate naming, rename, delete confirmation, reset-all separation,
mutation success/failure feedback, and corrupt/unsupported-data recovery.

The design must support multiple saved scenarios without implying that native 1.0 can
compare them. Do not invent sync, sharing, folders, tags, or cloud states.

### 7. Component inventory

Define purpose, variants, states, anatomy, accessibility, and usage rules for at least:

- app/tab navigation;
- section/header treatment;
- currency and percentage fields;
- picker/menu/segmented controls;
- preset/Custom selector;
- optional-section disclosure;
- primary/secondary/destructive buttons;
- KPI/result card;
- assumption/context rows;
- target-status treatment;
- chart and nonvisual alternative;
- annual data row/table;
- scenario row;
- empty/error/recovery banner;
- confirmation dialog;
- toast, inline status, or other feedback recommendation;
- glossary/education disclosure.

Prefer standard SwiftUI/system components. Any custom component needs a clear reason
and native accessibility behavior.

### 8. Visual foundations

Specify implementable foundations without inventing final brand assets:

- semantic colour roles in light/dark mode;
- typography using Dynamic Type text styles;
- spacing and layout scale;
- corner, border, divider, and elevation approach;
- icon approach using appropriate SF Symbols where possible;
- chart series differentiation;
- number alignment and tabular figures where appropriate;
- minimum touch targets;
- animation/motion principles and Reduce Motion response.

Give semantic token names and intent rather than hard-coding a large design-token
framework. Verify contrast recommendations against current official Apple guidance;
do not claim conformance without evidence.

### 9. Accessibility specification

Cover:

- Dynamic Type through accessibility sizes;
- VoiceOver labels, values, hints, grouping, rotor/heading use, and reading order;
- validation focus and announcements;
- chart alternative and annual-data navigation;
- contrast and non-colour cues;
- Reduce Motion and Reduce Transparency where relevant;
- button/touch sizes;
- keyboard and switch-control considerations;
- content that must remain visible rather than hidden in tooltips;
- accessible destructive and recovery flows.

Separate design intent from later QA evidence. Do not reproduce the PWA's disabled zoom
or inaccessible-chart risks.

### 10. Adaptive iPhone/iPad behavior

Define behavior for:

- compact iPhone widths;
- large iPhone widths;
- portrait and landscape where supported;
- iPad compact and regular widths;
- split-screen/multitasking;
- very large Dynamic Type.

Do not require a bespoke iPad design. State when one-column navigation remains
appropriate and when optional multi-column use may improve readability without
changing feature behavior.

### 11. State and interaction matrix

Provide a compact matrix covering enabled, focused, edited, invalid, loading, empty,
success, failure, offline, destructive confirmation, storage unavailable, corrupt data,
and unsupported schema where relevant. Identify impossible or out-of-scope states.

### 12. Content and terminology guardrails

List required terms, labels, disclaimer placement, and phrases that need Product
Manager/App Store review. Preserve accepted financial meaning. Do not write legal
assurances or imply guaranteed returns, personalised advice, regulated suitability,
live prices, or account security.

### 13. Implementation and QA handoff

Map the design system to the accepted feature folders and identify:

- what the engineer can implement directly;
- what requires IGC-006 test coverage;
- what IGC-008 must review;
- any design choices that are expensive to reverse;
- proposed decisions needing Product Manager acceptance;
- open questions that can safely wait.

## Files you may edit

Only:

- `docs/DESIGN_SYSTEM.md`
- optional files under `docs/design/`
- `handoffs/DESIGNER.md`
- `TASKS.md` — IGC-005 status and verification fields only
- `PROJECT_STATUS.md` — IGC-005 review-state update only
- `CHANGELOG.md` — one concise IGC-005 entry only

Do not edit:

- `DECISIONS.md`;
- any other handoff;
- `docs/PRODUCT_SPEC.md`, `docs/CALCULATION_SPEC.md`,
  `docs/SCENARIO_SCHEMA.md`, `docs/IOS_ARCHITECTURE.md`, or
  `docs/PLATFORM_STRATEGY.md`;
- `shared/`;
- `igc-pwa/`;
- `igc-ios/` or any native source/project file;
- prompts for other tasks.

If an accepted requirement appears inconsistent, document the exact conflict in
`docs/DESIGN_SYSTEM.md` and return it for Product Manager resolution. Do not silently
change scope or accepted contracts.

## Explicit non-goals

Do not:

- create an Xcode project, Swift code, asset catalogue, app icon, screenshot set, or
  implementation prototype;
- redesign the PWA;
- implement native comparison, monthly detail, export, sync, accounts, payments,
  premium states, analytics, or backend behavior;
- select final legal/privacy copy;
- modify calculations, fixtures, validation, scenario schema, persistence semantics,
  or architecture;
- start IGC-006, IGC-007, or IGC-008;
- dispatch another specialist or merge branches.

## Required completion handoff

When work begins, set only IGC-005 to `In progress`. Mark it `Ready for review` only
after the deliverable and checks are complete.

Before completion:

1. verify every required section is present;
2. verify all local links and official Apple citations;
3. run `git diff --check` before committing;
4. confirm no protected contract, PWA, native implementation, or other specialist file
   changed;
5. commit the documentation-only result with a focused message;
6. run `git diff --check
   c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a..HEAD`;
7. confirm the working tree is clean.

Return:

- status: `Ready for review`;
- thread name;
- branch and worktree path;
- base commit;
- final commit SHA;
- files changed;
- concise design recommendation;
- proposed decisions requiring Product Manager acceptance;
- dependencies or questions for QA/App Store review;
- checks run, passed, skipped, or not applicable;
- explicit confirmation that no iOS implementation or IGC-007 work began.
