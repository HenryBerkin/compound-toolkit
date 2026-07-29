# IGC project status

Updated: 2026-07-28
Owner: Product Manager and Technical Lead

## Current state

- Phase: IGC-007 is accepted, integrated, signed, installed, and manually validated on
  a physical iPhone; IGC-012 native scenario lifecycle is approved and Ready.
- Working branch: `project/ios-migration-audit`.
- Verified public source: `main` at
  `428fb46432fedab770ae90934b537587a32d70f6`.
- Recovery point: annotated tag `recovered-pwa-baseline-2026-07-28`.
- Verified structural migration commit: `78f2415`.
- Native implementation: IGC-007 Calculator-to-Projection vertical slice integrated
  into `project/ios-migration-audit` and passed its physical-device gate under
  IGC-D019.
- PWA status: supported IGC web edition and behavioural reference; maintenance may
  continue alongside the native client.
- Public product/App Store name: **Investment Growth Calculator**.
- Shorthand/icon identity: **IGC**; long-form marketing:
  **IGC — Investment Growth Calculator**.
- Native application bundle identifier: `uk.co.mochadesigns.igc` (IGC-D018).
- Apple Developer Team ID: `2FKVFS8X67` (owner-confirmed).
- Apple Developer Team Name: `Henry Berkin` (owner-confirmed).
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

IGC-008 is Done and its early App Store/privacy planning baseline is accepted in
IGC-D016. The specialist head
`1bc787858ae991a706d009214b14bc3867f36baf` is integrated into
`project/ios-migration-audit` by merge commit `7dc3e08`. The review records current
Apple submission gates, provisional local-only App Privacy answers, owner inputs,
financial-content/legal review flags, and phase-gated release evidence; it makes no
submission or native-compliance claim.

IGC-005 is Done and its corrected native design system is accepted in IGC-D017. The
specialist head `3f176284a0badeb342bf48bfa737a0c6fd52543b` is integrated into
`project/ios-migration-audit` by merge commit `004af38`. It fixes the four-tab
hierarchy, explicit Calculator-to-Projection flow, scenario interaction/recovery,
results and annual detail, accessibility intent, adaptive behaviour, and semantic
visual foundations without adding native implementation.

The IGC-007 native implementation was completed in its required specialist worktree
from exact base `dc521186d9d0f30add2f45c06cb02d6d98d35195`. It uses bundle identifier
`uk.co.mochadesigns.igc`, Apple Developer Team Name `Henry Berkin`, and Team ID
`2FKVFS8X67`. Initial implementation commit
`ab45c935853fc4edab0fce2d25291d74255b49d1` and correction commit
`76b1e39db01830642b4de7481ea7efc85ae568f1` are integrated by merge commit
`c26d25a13a65d47f487fc55cebaeb216b7a8eb62`.

IGC-006 is Done and its behavioural inventory is accepted in IGC-D015. The specialist
head `7e4f462ef6ec78fa22dea81dbda772e9032af2f9` is integrated into
`project/ios-migration-audit` by merge commit `c895476`.

IGC-007 is Done. Product Manager review accepted its corrected SwiftUI
Calculator-to-Projection slice, pure calculation core, direct root-fixture parity
tests, annual detail, adaptive tab navigation, and accessibility alternatives. The
independent review gate passed 27/27 tests with no failures or skips, plus the Release
simulator build and store-bundle validation. Focused simulator evidence covers
representative small, standard, large, and iPad devices plus Dark Mode, AX XXXL,
Reduce Motion, VoiceOver-enabled semantics, supported landscape, and a non-UK locale
retaining GBP. Release inspection found no third-party SDK, network, persistence,
analytics, entitlement, collected-data, tracking, or required-reason API surface, so
no privacy manifest is required for this slice.

The owner then used Xcode 26.2 to sign and install the unchanged integrated application
on an iPhone running iOS 27.0. Direct launch from the installed Home Screen icon and
every requested manual smoke item passed, including calculations, validation, chart,
navigation, accessibility, offline operation, and expected non-persistent relaunch.
Calculator scroll position remained local to its tab as specified. Debugger-attached
launch was skipped because Apple documents Xcode 26.2 device support only through iOS
26.2; the initial debugger failures are not an established IGC defect. IGC-D019 records
the accepted gate and future compatible-toolchain/device rule.

IGC-012 is **Ready for review** under IGC-D020. The specialist implementation is on
`codex/igc-012-native-scenario-lifecycle` from exact base
`9b5f17b41d768bf72af12c215b096d2e101962e0`; implementation commit
`802ff473b9b6a091103591eefd87b79745116f4f` adds the exact native V1 mapping,
actor-backed Codable Application Support store, save/Save-as-new, deterministic Saved
root, load, rename, duplicate, confirmed delete, recovery states, and persistence
coverage. Final evidence is 37/37 unit/fixture/store tests, 15/15 iPhone UI tests, a
passing focused iPad UI smoke, passing Debug and Release simulator builds, clean
install/relaunch/offline-dependency checks, and a first-party privacy/dependency/API
inventory. All 27 accepted IGC-007 tests remain passing. Physical-device execution was
skipped under the accepted Xcode 26.2/iOS 27 compatibility boundary. Global Settings
reset, appearance/onboarding persistence, comparison, export, networking, premium,
TestFlight, archive/upload, and App Store work remain excluded.

## Known issues and deferred work

- The preset picker initially displays “Global index (DIY)” while the untouched
  defaults use the accepted Custom 0.20% fee. The decision is resolved; the supported
  PWA correction belongs to a separately verified Web task.
- Committed PWA documentation and package naming lag behind product behaviour.
- The web viewport disables pinch zoom, an accessibility risk not to reproduce natively.
- Dependency vulnerabilities remain in the preserved PWA toolchain.
- Current PWA saved records predate explicit `schemaVersion`, `currency`, and
  `presetId`; a Web migration must be scoped and tested before changing localStorage.
- Debugger-attached physical execution on the owner’s iOS 27.0 device is unavailable
  with Xcode 26.2. Use Xcode 27 on a compatible Mac or a device within the maintained
  Xcode toolchain’s documented device-support range when attached debugging is needed;
  no project workaround is authorised without separate evidence.
- Premium features, pricing, purchase type, entitlement sharing, and account strategy
  remain deliberately deferred and excluded from implementation.
