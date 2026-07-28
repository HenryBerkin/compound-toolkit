# IGC project status

Updated: 2026-07-28
Owner: Product Manager and Technical Lead

## Current state

- Phase: Native product contract, architecture, and QA inventory accepted; design and
  early release-risk definition next.
- Working branch: `project/ios-migration-audit`.
- Verified public source: `main` at
  `428fb46432fedab770ae90934b537587a32d70f6`.
- Recovery point: annotated tag `recovered-pwa-baseline-2026-07-28`.
- Verified structural migration commit: `78f2415`.
- Native implementation: not started.
- PWA status: supported IGC web edition and behavioural reference; maintenance may
  continue alongside the native client.
- Public product/App Store name: **Investment Growth Calculator**.
- Shorthand/icon identity: **IGC**; long-form marketing:
  **IGC — Investment Growth Calculator**.
- Historical repository/package names still include `compound-toolkit` and
  `compound-growth-toolkit`.

## Verified checks at the original PWA root

| Check | Result |
| --- | --- |
| `npm install` | Passed; exposed lockfile-version drift and branded-icon overwrite |
| `npm run lint` | Passed |
| `npm test` | Passed: 58/58 tests |
| `npm run build` | Passed |
| `npm run dev -- --host 127.0.0.1` | Passed after local port permission |
| Mobile and desktop browser audit | Passed with findings in `docs/PWA_AUDIT.md` |
| `npm audit --audit-level=low` | 15 transitive findings: 1 low, 5 moderate, 8 high, 1 critical |

No audit fix or dependency upgrade has been applied.

The same install, lint/type-check, 58-test suite, build, development server, mobile
default-result check, saved-scenario persistence check, desktop load, and fresh browser
console check passed after relocation into `igc-pwa/`. Installation left the branded
icon hashes unchanged.

IGC-009 added a direct shared-fixture consumer: 27 cross-platform contract tests pass
alongside the original 58 tests (85 total), and lint/type-check plus production build
pass.

## Current gates and next action

The six product decisions, dual-client direction, staged premium deferral, calculation
contract, fixture schema, representative outputs, validation cases, and portable
scenario schema are accepted and complete. IGC-003 and IGC-009 are Done.

IGC-004 is Done and its architecture is accepted in IGC-D014. The corrected specialist
head is `1940e3f95427f5fc0b3ca2dab07801e887650821`; the proposal was integrated into
`project/ios-migration-audit` by merge commit `856f156`.

Native implementation remains not started. Do not create an Xcode project or begin
IGC-007 until the relevant IGC-005 design inputs are accepted and the Product Owner
confirms the bundle identifier and Apple Developer Team.

IGC-006 is Done and its behavioural inventory is accepted in IGC-D015. The specialist
head `7e4f462ef6ec78fa22dea81dbda772e9032af2f9` is integrated into
`project/ios-migration-audit` by merge commit `c895476`.

IGC-005 and IGC-008 remain Ready from
`c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a` in their named isolated worktrees. Their
standalone prompts are in `prompts/`. IGC-007 remains Proposed and must not begin.

The revised standalone prompt is `prompts/IGC-004-IOS-ARCHITECTURE.md`. Its exact
accepted base is `3bf1e517636d543e368b610b8a006cafd271e836`.

## Known issues and deferred work

- The preset picker initially displays “Global index (DIY)” while the untouched
  defaults use the accepted Custom 0.20% fee. The decision is resolved; the supported
  PWA correction belongs to a separately verified Web task.
- Committed PWA documentation and package naming lag behind product behaviour.
- The web viewport disables pinch zoom, an accessibility risk not to reproduce natively.
- Dependency vulnerabilities remain in the preserved PWA toolchain.
- Current PWA saved records predate explicit `schemaVersion`, `currency`, and
  `presetId`; a Web migration must be scoped and tested before changing localStorage.
- Premium features, pricing, purchase type, entitlement sharing, and account strategy
  remain deliberately deferred and excluded from implementation.
