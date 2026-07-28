# IGC project status

Updated: 2026-07-28
Owner: Product Manager and Technical Lead

## Current state

- Phase: PWA recovery, audit, and repository reorganisation.
- Working branch: `project/ios-migration-audit`.
- Verified public source: `main` at
  `428fb46432fedab770ae90934b537587a32d70f6`.
- Recovery point: annotated tag `recovered-pwa-baseline-2026-07-28`.
- Native implementation: not started.
- Current product name: **IGC — Investment Growth Calculator**.
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

## Current gates

1. Complete and verify the move into `igc-pwa/`.
2. Review the proposed native version 1.0 scope with the user.
3. Complete `IGC-004`, the proportionate SwiftUI architecture proposal.
4. Do not begin substantive SwiftUI implementation until these gates are accepted.

## Known issues requiring decisions

- The preset picker initially displays “Global index (DIY)” while the untouched
  defaults use a different fee, so visible selection and active assumptions disagree.
- Committed PWA documentation and package naming lag behind product behaviour.
- The web viewport disables pinch zoom, an accessibility risk not to reproduce natively.
- Dependency vulnerabilities remain in the preserved PWA toolchain.
