# IGC project status

Updated: 2026-07-28
Owner: Product Manager and Technical Lead

## Current state

- Phase: Cross-platform product direction and native version 1.0 scope review.
- Working branch: `project/ios-migration-audit`.
- Verified public source: `main` at
  `428fb46432fedab770ae90934b537587a32d70f6`.
- Recovery point: annotated tag `recovered-pwa-baseline-2026-07-28`.
- Verified structural migration commit: `78f2415`.
- Native implementation: not started.
- PWA status: supported IGC web edition and behavioural reference; maintenance may
  continue alongside the native client.
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

The same install, lint/type-check, 58-test suite, build, development server, mobile
default-result check, saved-scenario persistence check, desktop load, and fresh browser
console check passed after relocation into `igc-pwa/`. Installation left the branded
icon hashes unchanged.

## Current gates

1. Resolve or explicitly defer the six product questions in `docs/PRODUCT_SPEC.md`.
2. Accept the shared-versus-platform-specific product contract and staged premium
   direction in `docs/PLATFORM_STRATEGY.md`.
3. Complete IGC-009, the shared calculation specification and fixture plan.
4. Revise IGC-004 against the agreed direction before returning it to `Ready`.
5. Do not dispatch IGC-004 or begin substantive SwiftUI implementation before these
   gates are satisfied.

## Known issues requiring decisions

- The preset picker initially displays “Global index (DIY)” while the untouched
  defaults use a different fee, so visible selection and active assumptions disagree.
- Committed PWA documentation and package naming lag behind product behaviour.
- The web viewport disables pinch zoom, an accessibility risk not to reproduce natively.
- Dependency vulnerabilities remain in the preserved PWA toolchain.
- A canonical cross-platform calculation specification and language-neutral fixtures do
  not yet exist.
- Premium features, pricing, purchase type, entitlement sharing, and account strategy
  are unapproved and excluded from implementation.
