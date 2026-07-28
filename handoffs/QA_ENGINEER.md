# QA Engineer handoff

QA implementation work has not started. The verified PWA evidence is in
`docs/PWA_AUDIT.md`; calculation tests live in `igc-pwa/src/lib/calc.test.ts`.
Read `docs/PLATFORM_STRATEGY.md` for the shared-versus-platform-specific boundary.

IGC-003 and IGC-009 are complete; IGC-006 remains Proposed pending assignment.
`docs/CALCULATION_SPEC.md` and `shared/fixtures/calculation-v1.json` are the accepted
version 1 parity sources. The TypeScript client consumes that JSON directly: 27 contract
tests plus 58 existing tests pass. Future Swift tests must consume the same file without
copying expected values into Swift source.

Native comparison is deferred to iOS 1.1; native 1.0 presents annual detail only and no
export, while monthly engine parity remains required. Do not silently turn current PWA
quirks into requirements; distinguish approved behaviour, observed behaviour,
platform-specific behaviour, and defects.
