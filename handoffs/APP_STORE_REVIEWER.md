# App Store Reviewer handoff

IGC-008 is Ready for review. The documentation-only deliverables are
`docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`, and `docs/RELEASE_CHECKLIST.md`.
They record current Apple requirements checked 2026-07-28, explicit owner inputs,
release-time binary checks, and legal/regulatory review flags. Product scope is
accepted; current architecture evidence indicates local-only scenario data, no account,
no backend, no analytics, and no device permissions, but no native binary exists.

Use current official Apple sources for policy and submission claims. Separate confirmed
requirements, recommendations, assumptions, and unresolved questions. Do not treat the
PWA disclaimer as sufficient App Store or financial-content review. Premium
implementation is deferred; if it is later proposed, recheck StoreKit, multiplatform
services, external purchase communication, subscriptions, privacy, and account
requirements against then-current official guidance.
