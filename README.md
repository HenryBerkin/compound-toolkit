# IGC — Investment Growth Calculator

IGC is being rebuilt as a native SwiftUI application for eventual Apple App Store
release. The verified React PWA remains in this repository as the functional and
behavioural reference; the native implementation has not started.

## Repository map

- `igc-pwa/` — preserved PWA source, tests, assets, and historical PWA docs
- `igc-ios/` — reserved for the approved native project when implementation begins
- `docs/` — current product, audit, architecture, design, QA, privacy, and release docs
  as those workstreams become active
- `handoffs/` — concise role-to-role project context
- `PROJECT_STATUS.md` — current phase, evidence, and gates
- `TASKS.md` — task ownership, dependencies, acceptance criteria, and status
- `DECISIONS.md` — accepted and proposed material decisions
- `ROADMAP.md` — phase-level delivery sequence

Do not create `igc-ios/` merely as an empty directory. IGC-004 defines the architecture
before an Xcode project is introduced.

## PWA reference setup

```sh
cd igc-pwa
npm install
npm run lint
npm test
npm run build
npm run dev
```

The verified public baseline is commit
`428fb46432fedab770ae90934b537587a32d70f6`, preserved by annotated tag
`recovered-pwa-baseline-2026-07-28`.

## Current product direction

- Native SwiftUI rather than a web-view wrapper
- Local-first calculations and scenario storage
- Deliberately limited version 1.0
- Correctness, clarity, privacy, accessibility, and maintainability before expansion

Read `AGENTS.md` and the current task/specification files before substantive work.

## Licence

The existing MIT licence remains at the repository root. No licensing terms were
changed during recovery or reorganisation.
