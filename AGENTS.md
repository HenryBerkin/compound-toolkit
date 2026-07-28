# IGC repository instructions

Read `PROJECT_STATUS.md`, `TASKS.md`, `DECISIONS.md`, and the relevant handoff
and specification files before substantive work.

## Working rules

- Use task IDs in the form `IGC-###`; one role owns an implementation task at a time.
- Do not change approved scope, calculation behaviour, financial terminology, or
  persistence semantics silently. Record material proposals in `DECISIONS.md`.
- The legacy reference PWA belongs in `igc-pwa/`. Native iOS work belongs in
  `igc-ios/`. Project-wide coordination and accepted specifications stay at the root
  or in `docs/`.
- Work from the branch or isolated worktree named in the task. Do not merge directly
  into an integration branch without Product Manager review.
- Preserve user changes and Git history. Do not rewrite shared history, overwrite
  recovery tags, or commit generated output.
- Generated PWA directories (`node_modules/`, `dist/`, `*.tsbuildinfo`) remain ignored.
- Report failed, skipped, and untested checks honestly. Uncertainty is a result, not
  permission to guess.
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
