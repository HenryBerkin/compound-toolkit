# iOS Engineer handoff

## IGC-004 completed proposal context

No native code exists. The completed proposal followed the revised standalone prompt
in `prompts/IGC-004-IOS-ARCHITECTURE.md`, based at
`3bf1e517636d543e368b610b8a006cafd271e836`; the earlier prompt remains withdrawn.

IGC-004 is Done and accepted in IGC-D014. The documentation-only proposal is
`docs/IOS_ARCHITECTURE.md`; its corrected specialist head is
`1940e3f95427f5fc0b3ca2dab07801e887650821` on
`codex/igc-004-ios-architecture`, based on
`3bf1e517636d543e368b610b8a006cafd271e836`.

The recommendation is a single SwiftUI app module with feature-local state, a pure
Swift binary64 calculation engine, direct test-bundle consumption of the version-1
shared fixture, an actor-backed Codable Application Support scenario store, and a
small local-free feature-availability seam. It defers SwiftData, packages, third-party
dependencies, StoreKit, accounts, networking, sync, analytics, remote configuration,
and backend work.

Native V1 scenarios map exactly to the portable schema: UUID opaque IDs, explicit GBP,
decimal rates, stable preset IDs, optional today-value target, and UTC timestamps.
Unknown future versions must fail safely and be preserved for recovery. PWA legacy
localStorage migration is a separately tested Web concern. Native comparison remains
deferred to 1.1; annual detail is native 1.0 only while monthly rows remain required in
the engine and parity tests.

## Accepted decisions and verification

Product Manager accepted the persistence choice, single-module and first-party
dependency policy, direct shared-resource parity gate, and local-free availability
seam. Product Owner confirmation of the reverse-DNS bundle identifier and Apple
Developer Team remains a gate before project creation. App Store SKU waits until the
App Store Connect record; App Groups and iCloud remain absent from 1.0.

Verification completed: required project/specification/fixture/PWA evidence read;
official Apple primary sources checked for current upload SDK, data, testing, and
accessibility claims; all architecture sections present; cited Apple links opened;
`git diff --check` passed; no `igc-ios/`, Xcode project, Swift source, dependency, or
generated artifact was added; shared assets, accepted decisions, and PWA files remain
unchanged. No native build was run because native project creation is out of scope.

Before future implementation work, read the accepted behavioural inventory in
`docs/QA_PLAN.md` and preserve its direct-fixture gate and planned-versus-executed
evidence rules.
