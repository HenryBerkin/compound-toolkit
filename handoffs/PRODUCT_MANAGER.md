# Product Manager handoff

Current phase: IGC-007, IGC-012, and IGC-013 are Done, accepted, and integrated. The
IGC-007 foundation was development-signed, installed, and manually validated on a
physical iPhone. IGC-012 provides the accepted local native scenario lifecycle;
IGC-013 completes the accepted secondary content, app preferences, and global
local-data reset milestone.
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

IGC-D021 accepts corrected IGC-012 specialist head
`20af11c905a2c2bf16fe46af132725d97a1cf7f9`. Product Manager review independently
passed 40/40 unit/fixture/store tests, 16/16 UI tests, and the Release simulator build,
then integrated it with merge commit
`853555794173814a9299d257d6ff12786c7b26dc`. Exact-current-source recovery evidence,
Projection save gating, normal scenario CRUD/relaunch, shared fixture parity, and the
first-party local-only boundary are accepted. Physical-device execution remains
skipped under IGC-D019’s Xcode 26.2/iOS 27 compatibility rule.

IGC-D023 accepts exact IGC-013 specialist head
`425af8e302269e52a0971815fdb70241854404d2`. Product Manager review independently
passed 56/56 unit tests, 23/23 UI tests, the Release simulator build, source and
packaged privacy-manifest validation, scope checks, and clean-worktree checks. The
accepted head is integrated by merge commit
`a6a1e5fac3c66ea5c42bd71d8d93df93516e8ef6`. The native app now includes bundled
Education/disclaimer routes, contextual help, the first-launch coach, System/Light/
Dark persistence, Settings/About/Privacy, and verified global local-data reset, with
the sole UserDefaults required-reason declaration `CA92.1`.

Final legal/public copy, public Privacy/Support destinations, physical-device/manual
accessibility sign-off, signed archive/privacy report, TestFlight, upload and App Store
actions remain open. No next engineering milestone is authorised until Product Manager
roadmap review; do not push, upload, or alter Apple services without owner approval.
