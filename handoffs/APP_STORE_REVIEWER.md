# App Store Reviewer handoff

Submission work has not started. Product scope and architecture are accepted; IGC-008
is Ready from `c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`. Use the standalone prompt
`prompts/IGC-008-EARLY-PRIVACY-APP-STORE-REVIEW.md` in branch
`codex/igc-008-app-store-privacy-review`.

The accepted native data handling and delivery assumptions are in
`docs/IOS_ARCHITECTURE.md`. Current evidence indicates local-only scenario data, no
account, no backend, no analytics, and no device permissions.

Use current official Apple sources for policy and submission claims. Separate confirmed
requirements, recommendations, assumptions, and unresolved questions. Do not treat the
PWA disclaimer as sufficient App Store or financial-content review. Premium
implementation is deferred; if it is later proposed, recheck StoreKit, multiplatform
services, external purchase communication, subscriptions, privacy, and account
requirements against then-current official guidance.
