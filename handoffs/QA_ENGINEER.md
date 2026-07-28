# QA Engineer handoff

QA implementation work has not started. The verified PWA evidence is in
`docs/PWA_AUDIT.md`; calculation tests live in `igc-pwa/src/lib/calc.test.ts`.
Read `docs/PLATFORM_STRATEGY.md` for the shared-versus-platform-specific boundary.
Read `docs/IOS_ARCHITECTURE.md` for accepted native boundaries and proposed test
layers.

IGC-003, IGC-004, IGC-006, and IGC-009 are complete. IGC-006 is accepted under
IGC-D015; its specialist head is
`7e4f462ef6ec78fa22dea81dbda772e9032af2f9`, based on
`c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`.

`docs/QA_PLAN.md` defines the Shared/iOS/Web behavioural inventory, direct-fixture
parity protocol, platform boundaries, persistence recovery, accessibility evidence,
change control, and release gates. It records current PWA
selector/target/storage/accessibility risks as findings rather than requirements; no
native test or product implementation began.
`docs/CALCULATION_SPEC.md` and `shared/fixtures/calculation-v1.json` are the accepted
version 1 parity sources. The TypeScript client consumes that JSON directly: 27 contract
tests plus 58 existing tests pass. Future Swift tests must consume the same file without
copying expected values into Swift source.

Native comparison is deferred to iOS 1.1; native 1.0 presents annual detail only and no
export, while monthly engine parity remains required. Do not silently turn current PWA
quirks into requirements; distinguish approved behaviour, observed behaviour,
platform-specific behaviour, and defects.

IGC-005 should add only accepted design assertions to the marked Design-pending cases.
IGC-008 should supply the current privacy/App Store evidence before the corresponding
release gate can pass.
