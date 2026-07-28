# IGC — Investment Growth Calculator

IGC is one product with a responsive PWA/web edition and a planned native SwiftUI
application for eventual Apple App Store release. The verified React PWA remains both
a supported product surface and the current behavioural reference; native
implementation has not started.

## Repository map

- `igc-pwa/` — maintained PWA/web source, tests, assets, and web-specific docs
- `igc-ios/` — reserved for the approved native project when implementation begins
- `docs/` — current product, audit, architecture, design, QA, privacy, and release docs
  as those workstreams become active
- `shared/` — versioned language-neutral fixtures, schemas, and examples consumed by
  the independent Swift and TypeScript clients
- `handoffs/` — concise role-to-role project context
- `PROJECT_STATUS.md` — current phase, evidence, and gates
- `TASKS.md` — task ownership, dependencies, acceptance criteria, and status
- `DECISIONS.md` — accepted and proposed material decisions
- `ROADMAP.md` — phase-level delivery sequence
- `docs/PLATFORM_STRATEGY.md` — cross-platform boundaries and premium options
- `docs/CALCULATION_SPEC.md` — accepted shared calculation and validation contract
- `docs/SCENARIO_SCHEMA.md` — accepted portable scenario contract

Do not create `igc-ios/` merely as an empty directory. IGC-004 defines the architecture
before an Xcode project is introduced.

## PWA/web edition setup

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
- Coherent shared behaviour across native iOS and web, with platform-appropriate UI
- Local-first calculations and scenario storage
- Deliberately limited iOS 1.0 targeting iOS 17, iPhone-first with adaptive iPad support
- GBP-only UK-English presentation with currency-explicit scenario data
- Native comparison deferred to iOS 1.1; monthly detail and CSV retained on web
- Premium, accounts, backend, and sync deliberately deferred
- Correctness, clarity, privacy, accessibility, and maintainability before expansion

Read `AGENTS.md` and the current task/specification files before substantive work.

## Licence

The existing MIT licence remains at the repository root. No licensing terms were
changed during recovery or reorganisation.
