# Product Manager handoff

Current phase: native product contract, architecture, design system, QA inventory, and
early release-risk planning accepted; bundle identifier and Apple Developer Team
confirmed; IGC-007 is Ready for specialist dispatch.
Branch: `project/ios-migration-audit`.
Baseline: `recovered-pwa-baseline-2026-07-28`.

Read `PROJECT_STATUS.md`, `TASKS.md`, `DECISIONS.md`, `docs/PWA_AUDIT.md`,
`docs/PRODUCT_SPEC.md`, `docs/CALCULATION_SPEC.md`, `docs/SCENARIO_SCHEMA.md`,
`docs/IOS_ARCHITECTURE.md`, and `docs/PLATFORM_STRATEGY.md`.

The recovery and reorganisation are verified in commit `78f2415`. The PWA is now a
supported web edition, not only a frozen reference. The six product choices and staged
premium deferral are accepted. IGC-003 and IGC-009 are Done, including portable
calculation fixtures and scenario schema version 1.

IGC-004 is accepted in IGC-D014, IGC-006 in IGC-D015, IGC-008 in IGC-D016, and the
corrected IGC-005 native design system in IGC-D017. Privacy answers remain provisional
until binary evidence. IGC-D018 fixes the native application bundle identifier as
`uk.co.mochadesigns.igc` and records Apple Developer Team Name `Henry Berkin` and Team
ID `2FKVFS8X67`. The owner-controlled project signing gate is complete. Native work
must still begin only in the specialist worktree from the exact issued base.

The final standalone brief is `prompts/IGC-007-NATIVE-VERTICAL-SLICE.md`, issued from
exact implementation base `dc521186d9d0f30add2f45c06cb02d6d98d35195`. Dispatch it
in thread `IGC-007 — Native Vertical Slice` using `gpt-5.6-sol` at `xhigh` reasoning,
with the required `/private/tmp/igc-007-native-vertical-slice` worktree and
`codex/igc-007-native-vertical-slice` branch. Do not begin the implementation on the
integration branch.
