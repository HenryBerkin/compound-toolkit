# Product Manager handoff

Current phase: IGC-007 is Done, accepted, integrated, development-signed, installed,
and manually validated on a physical iPhone. IGC-012 native scenario lifecycle is
approved and Ready for specialist dispatch from the exact Product Manager base.
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
until release evidence. IGC-D018 fixes bundle identifier `uk.co.mochadesigns.igc` and
Team Name `Henry Berkin` / Team ID `2FKVFS8X67`.

IGC-D019 accepts the physical-device gate. Xcode 26.2 successfully development-signed
and installed the unchanged integrated build on an iOS 27.0 iPhone; direct launch and
every requested manual smoke item passed. Debugger-attached execution is skipped
because Apple documents Xcode 26.2 device support through iOS 26.2. This is not an
established IGC defect. Future attached debugging uses Xcode 27 on a compatible Mac for
iOS 27, or a device in the maintained Xcode toolchain’s documented range. No toolchain
switch or project workaround is currently authorised. Calculator scroll retention
across tab visits is expected feature-local state.

IGC-D020 authorises IGC-012 in `TASKS.md`. Dispatch it in thread
`IGC-012 — Native Scenario Lifecycle and Persistence` to the iOS Engineer using
`gpt-5.6-sol` at `xhigh`, with required isolated worktree
`/private/tmp/igc-012-native-scenario-lifecycle` and branch
`codex/igc-012-native-scenario-lifecycle`. Use only the exact base in the reissued
Product Manager prompt. The earlier prompt based on
`212cf6056bd37ca22d5aff9db542f9aab4acdd19` is withdrawn. Do not implement in the
integration checkout, push, merge, upload, or alter Apple services.
