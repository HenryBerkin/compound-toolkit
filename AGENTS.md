# IGC repository instructions

Read `PROJECT_STATUS.md`, `TASKS.md`, `DECISIONS.md`, and the relevant handoff
and specification files before substantive work.

## Working rules

- Use task IDs in the form `IGC-###`; one role owns an implementation task at a time.
- Do not change approved scope, calculation behaviour, financial terminology, or
  persistence semantics silently. Record material proposals in `DECISIONS.md`.
- The maintained PWA/web edition belongs in `igc-pwa/`. Native iOS work belongs in
  `igc-ios/`. Shared product contracts, coordination, and accepted specifications stay
  at the root, in `docs/`, or in `shared/`.
- Label substantive tasks and release notes as Shared, iOS, or Web. Platform-specific
  UI may differ; shared calculation, validation, terminology, and schema behaviour may
  not drift silently.
- Work from the branch or isolated worktree named in the task. Do not merge directly
  into an integration branch without Product Manager review.
- Preserve user changes and Git history. Do not rewrite shared history, overwrite
  recovery tags, or commit generated output.
- Generated PWA directories (`node_modules/`, `dist/`, `*.tsbuildinfo`) remain ignored.
- Report failed, skipped, and untested checks honestly. Uncertainty is a result, not
  permission to guess.
- Treat `docs/CALCULATION_SPEC.md`, `docs/SCENARIO_SCHEMA.md`, and the versioned assets
  in `shared/` as cross-platform contracts. Do not regenerate expected fixture values
  to make a failing implementation pass without an accepted Shared model decision.
- Update the owning handoff file when work changes another role's starting context.

## Current PWA checks

Run from `igc-pwa/` after the repository reorganisation:

```sh
npm install
npm run lint
npm test
npm run build
npm run dev
```

Do not run forced dependency upgrades during recovery work.
