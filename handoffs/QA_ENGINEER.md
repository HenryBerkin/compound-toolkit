# QA Engineer handoff

QA implementation work has not started. The verified PWA evidence is in
`docs/PWA_AUDIT.md`; calculation tests live in `igc-pwa/src/lib/calc.test.ts`.
Read `docs/PLATFORM_STRATEGY.md` for the shared-versus-platform-specific boundary.

IGC-006 remains Proposed until IGC-003 and IGC-009 are complete. Cross-platform fixtures
must test independent Swift and TypeScript implementations against the same contract.
Do not silently turn current PWA quirks into requirements; distinguish approved
behaviour, observed behaviour, platform-specific behaviour, and defects.
