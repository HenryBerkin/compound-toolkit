# App Store Reviewer handoff

IGC-008 is Done and accepted under IGC-D016. The documentation-only deliverables are
`docs/APP_STORE_SUBMISSION.md`, `docs/PRIVACY.md`, and `docs/RELEASE_CHECKLIST.md`.
They record current Apple requirements checked 2026-07-28, explicit owner inputs,
release-time binary checks, and legal/regulatory review flags. Product scope is
accepted; current architecture evidence indicates local-only scenario data, no account,
no backend, no analytics, and no device permissions, but no native binary exists.

The accepted specialist head is
`1bc787858ae991a706d009214b14bc3867f36baf`, based on
`c2995d9b5638c1ab7a64992e6ec3c1104aae3d2a`. Its planning answers remain provisional
until the release archive and operational support path provide the evidence required
by the checklist.

Use current official Apple sources for policy and submission claims. Separate confirmed
requirements, recommendations, assumptions, and unresolved questions. Do not treat the
PWA disclaimer as sufficient App Store or financial-content review. Premium
implementation is deferred; if it is later proposed, recheck StoreKit, multiplatform
services, external purchase communication, subscriptions, privacy, and account
requirements against then-current official guidance.

IGC-005 is accepted under IGC-D017. Use `docs/DESIGN_SYSTEM.md` as the intended native
hierarchy when reviewing disclaimer placement, privacy/support destinations,
accessibility claims, and truthful screenshot states; final copy and release evidence
remain subject to IGC-D016.
