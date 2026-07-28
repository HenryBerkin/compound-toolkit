# iOS Engineer handoff

No native code exists. IGC-004 is Ready for an architecture proposal because IGC-003
and IGC-009 are Done. Use only the revised standalone prompt issued after the accepted
2026-07-28 decisions; the earlier prompt is withdrawn. The revised prompt is
`prompts/IGC-004-IOS-ARCHITECTURE.md`, based at
`3bf1e517636d543e368b610b8a006cafd271e836`.

Read `AGENTS.md`, `PROJECT_STATUS.md`, `TASKS.md`, `DECISIONS.md`,
`docs/PRODUCT_SPEC.md`, `docs/CALCULATION_SPEC.md`, `docs/SCENARIO_SCHEMA.md`,
`docs/PWA_AUDIT.md`, `docs/PLATFORM_STRATEGY.md`, and this file before work. Inspect
`shared/fixtures/calculation-v1.json` and both schemas directly.

The proposal must address two maintained clients, direct Swift consumption of portable
fixtures, schema version 1, GBP-explicit scenarios, future native comparison, and a
proportionate replaceable feature-availability boundary. It must not add payments,
StoreKit, accounts, sync, a backend, analytics, or remote configuration.

IGC-004 is documentation-only. Do not implement features, create `igc-ios/`, generate
an Xcode project, or modify the PWA.
