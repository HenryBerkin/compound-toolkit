# PWA recovery and product audit

Audit date: 2026-07-28
Reference commit: `428fb46432fedab770ae90934b537587a32d70f6`
Reference tag: `recovered-pwa-baseline-2026-07-28`

## Recovery evidence

- `origin/main` and the public remote `main` resolve to the reference commit.
- One annotated release tag existed before recovery: `v0.8.0`.
- Numerous remote topic branches remain, but `main` is the newest published commit.
- Original PWA version: `0.8.1`; package name: `compound-growth-toolkit`.
- Toolchain: React 18, TypeScript, Vite 5, Vitest 2, Recharts, and
  `vite-plugin-pwa`.
- No CI, hosting, deployment, backend, API, environment template, credential, or
  runtime environment dependency was found.
- `node_modules/`, `dist/`, environment files, logs, editor state, and TypeScript
  build caches are ignored.

## Command results at the original root

- Node `v22.23.1`; npm `10.9.8`.
- `npm install`: passed and ran `postinstall`; changed the lockfile version from
  `1.0.0` to `0.8.1` and overwrote six branded PNG icons with placeholder arrows.
- `npm run lint`: passed (`tsc --noEmit`; this is type-checking, not an ESLint pass).
- `npm test`: 58 tests passed in one file.
- `npm run build`: passed; generated an offline service worker and 29 precache entries.
- `npm run dev -- --host 127.0.0.1`: passed.
- Browser console: no warnings or errors during the audited flows.
- `npm audit --audit-level=low`: 15 transitive findings (1 low, 5 moderate, 8 high,
  1 critical). No fix was applied.

The automatic placeholder-icon generation is a recovery defect. The reorganisation
will remove only the automatic `postinstall` hook, preserve the manual generator,
restore branded assets, and verify that installation is non-mutating.

## Product topology

The app is a single responsive page rather than a route-based multi-screen product.
Its observable states are:

1. mobile-only optional quick-start card;
2. calculator form and optional target section;
3. standard results, insights, growth chart, and breakdown;
4. invalid-form result placeholder;
5. saved-scenario create/load/copy/delete and comparison selection;
6. two-scenario comparison summary and chart;
7. glossary modal;
8. collapsible assumptions and methodology;
9. PWA update banner when a new service worker is available.

On desktop (900px and wider), the form is a 380px sticky left column and results use
the wider right column. Mobile uses one column. The audit exercised 390×844 and
1280×900 viewports.

## Onboarding and presets

- Quick start appears only at 768px or below when it has not been dismissed, no preset
  interaction is stored, and there are no saved scenarios.
- “Choose preset” focuses the picker; “Not now” permanently records dismissal in
  browser storage.
- Presets change APR, inflation, fee, and compounding only.
- Presets: global index (7%/0.40%), balanced (6%/0.75%), equity-heavy (9%/1.00%),
  and savings (4%/0%); all use 3% inflation and monthly compounding.
- Finding: the picker initially shows global index as selected, but `DEFAULT_FORM`
  uses a 0.20% fee and no active preset. Selecting the already-visible first option
  may not fire a change. This is ambiguous product state and must be resolved before
  native implementation.

## Inputs and validation

- Starting balance: GBP, 0 to £1,000,000,000.
- Regular contribution: GBP, 0 to £1,000,000,000.
- At least one of those two amounts must be greater than zero.
- Contribution frequency: weekly, monthly, annual.
- APR: 0% to 999%.
- Compounding: daily, monthly, quarterly, annual.
- Optional inflation: 0% to 20%, blank treated as zero.
- Optional annual fee: 0% to 10%, blank treated as zero.
- Duration: whole years plus 0–11 months; 1 to 720 total months.
- Contribution timing: start or end of period.
- Optional target: parsed as a non-negative GBP amount, but invalid target text has no
  inline validation; it silently removes target analysis.
- Inputs recalculate after a 280ms debounce. Invalid core inputs replace results with a
  review-fields message.

Defaults are £10,000 starting balance, £250 monthly contribution, 7% APR, 3%
inflation, 0.20% fee, monthly compounding, 15 years, and start-of-period contributions.

## Calculation model

The pure engine simulates one month at a time using full JavaScript number precision;
display rounds to two decimal places.

- Contribution conversion:
  - weekly amount × 52 ÷ 12;
  - monthly amount unchanged;
  - annual amount ÷ 12 (spread monthly, not paid as one yearly lump).
- Monthly growth rate:
  - daily: `(1 + APR / 365)^(365 / 12) - 1`;
  - monthly: `APR / 12`;
  - quarterly: `(1 + APR / 4)^(1 / 3) - 1`;
  - annual: `(1 + APR)^(1 / 12) - 1`.
- Start timing adds the contribution before growth and fees.
- End timing applies growth and fee drag, then adds the contribution.
- Fees are an asset-based per-period drag derived from the annual fee and selected
  compounding convention; they are not subtracted from APR.
- Real values divide nominal values by `(1 + inflation)^elapsedYears`.
- “Real” contribution, interest, and fee totals are discounted once at the horizon,
  rather than discounting each historic cash flow separately.
- Partial years are simulated and represented in the last yearly row.

The test suite covers nominal compounding, frequency conversion, timing, inflation,
fees, partial durations, long horizons, parsing, boundaries, and invariants. A native
port needs exact fixtures in addition to narrative parity.

## Results and workflows

- Primary KPI: final balance after fees.
- Supporting values: purchasing power, starting balance, contributions, after-fee
  interest, pre-fee total, nominal and real fee totals.
- Optional insights explain inflation, fee impact, contribution/growth split,
  purchasing power, and target requirement.
- Target analysis inflates a today-value target to the selected horizon and compares it
  against projected after-fee nominal balance.
- Chart shows nominal and after-fee lines, with real and real-after-fee toggles.
- Yearly table offers nominal, real, after-fee, and real-after-fee views.
- Nominal monthly rows are available only up to 120 months. Longer durations show a
  limit note and retain yearly rows.
- CSV export uses six decimal places and a filename beginning `compound-toolkit_`.
- Saved scenarios include inputs, optional preset name, optional target, timestamps,
  and a generated ID. Users can load, copy, and delete with an inline two-step delete.
- Comparison selects exactly two saved scenarios, flags material comparability
  differences, presents outcome rows, and overlays after-fee/real lines.

## Persistence, privacy, and external activity

All product data stays in browser `localStorage`:

- `cgt-scenarios`
- `cgt-theme`
- `cgt-onboarding-dismissed-v1`
- `cgt-preset-interacted-v1`

There is no account, backend, analytics, advertising, tracking, cookie, external fetch,
or sensitive device permission. The service worker caches local application assets for
offline use. Scenarios are financial planning inputs and should still be treated as
user data in native privacy and deletion design.

## Accessibility observations

Positive evidence includes semantic headings/regions, labelled inputs, alerts, named
controls, table headers, focus-visible styling, keyboard Escape and focus trapping in
the glossary, dark mode, and mobile touch sizing.

Risks:

- the viewport disables zoom (`maximum-scale=1`, `user-scalable=no`);
- the graph is visually hidden from assistive technology and has no equivalent data
  summary tied to it;
- the glossary trap should be retested for focus restoration;
- custom toggle visuals rely on hidden native inputs and require native equivalents;
- no automated accessibility test suite exists;
- browser text scaling, contrast, reduced motion, and complete keyboard order were not
  independently certified.

## Branding and documentation findings

- User-facing UI, manifest, title, icon, and copy use Investment Growth Calculator/IGC.
- Repository, package, storage keys, CSV names, and old README still use compound
  toolkit/growth toolkit.
- Root README and existing architecture/decision docs are materially stale; they list
  already-delivered work as future or “upcoming.”
- The MIT licence stays at the repository root and is not changed by this work.

## Known ambiguities and risks

- Initial preset mismatch described above.
- Optional target accepts invalid text without an error.
- Extreme but permitted 999% APR can generate impractical projections.
- Annual contributions are modelled as monthly equivalents, which may surprise users.
- “APR” language for investment return is potentially imprecise and needs product/legal
  copy review.
- Projection disclaimers do not substitute for a current App Store, privacy, or
  regulated-financial-content review.
- PWA dependency vulnerabilities remain; many concern development/build tooling, but
  impact has not been individually triaged.

## Approved reorganisation plan

The following plan implements accepted decision IGC-D002 without product refactoring.

Tracked moves into `igc-pwa/`:

- `src/`, `public/`, `scripts/`
- `index.html`, `package.json`, `package-lock.json`
- `vite.config.ts`, `tsconfig.json`, `tsconfig.app.json`, `tsconfig.node.json`
- existing `README.md` to `igc-pwa/README.md`
- existing `CHANGELOG.md` to `igc-pwa/CHANGELOG.md`
- existing `docs/ARCHITECTURE.md` and `docs/DECISIONS.md` to `igc-pwa/docs/`

Generated `node_modules/` and `dist/` move into `igc-pwa/` to avoid leaving an
unexplained root copy; they remain ignored and are regenerated there.

Items remaining at root:

- `LICENSE` unchanged;
- `.gitignore`, expanded only if nested-output handling requires it;
- project-wide README, changelog, instructions, status, roadmap, tasks, decisions,
  specifications, and handoffs.

Narrow relocation/recovery adjustments:

- remove the automatic placeholder-icon `postinstall` hook;
- retain `npm run icons` and its script as historical/manual PWA tooling;
- restore the six branded tracked PNG files from the recovery commit;
- update PWA setup paths and root repository navigation;
- leave package name, storage keys, CSV filenames, formulas, styling, and UI behaviour
  unchanged.

Deployment/path risks:

- no deployment configuration exists to update;
- Vite and icon paths remain correct when commands run from `igc-pwa/` and the built app
  is hosted at a domain root;
- deployments under a URL subpath would already conflict with absolute `/icons/...`
  URLs and `start_url: "/"`; no subpath support will be invented during relocation.

Post-move verification:

```sh
cd igc-pwa
npm install
npm run lint
npm test
npm run build
npm run dev -- --host 127.0.0.1
```

Also verify `git status`, unchanged branded-icon hashes after install, mobile default
calculation output, saved-scenario persistence, and no browser errors.

Rollback is non-destructive: inspect or branch from
`recovered-pwa-baseline-2026-07-28`; after commit, revert the structural commit rather
than rewriting shared history.
