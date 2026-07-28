# Cross-platform and premium strategy options

Status: Accepted direction; premium implementation deferred

## Supported product shape

IGC should be treated as one product with two platform-appropriate clients:

- native SwiftUI iOS, the immediate release priority;
- responsive PWA/web, an actively supportable edition and behavioural reference.

The repository layout supports this: shared project records remain at the root,
TypeScript web code lives in `igc-pwa/`, and future Swift code will live in `igc-ios/`.
The canonical shared product/calculation contract and portable fixtures now live in
`docs/CALCULATION_SPEC.md`, `docs/SCENARIO_SCHEMA.md`, and `shared/`. They are
documentation/data assets, not a shared runtime or backend.

## Behaviour boundaries

### Shared

- formulas, operation order, units, validation, rounding, defaults, and presets;
- terminology, disclaimer meaning, target and comparison semantics;
- scenario field meaning, stable identifiers, schema versions, and canonical examples;
- free/premium capability classification when premium exists.

### Platform-specific

- navigation, layout, charts, accessibility APIs, and control presentation;
- browser service worker versus App Store lifecycle;
- localStorage versus native persistence;
- web downloads versus native share/export surfaces;
- platform-specific onboarding and settings conventions.

Current web capabilities remain supported. Native 1.0 deliberately defers
two-scenario comparison to iOS 1.1 and keeps monthly detail and CSV Web-only while the
native engine still calculates monthly rows.

## Architecture guardrails

- Maintain separate Swift and TypeScript calculation engines against one versioned,
  language-neutral specification and JSON fixtures.
- Use opaque stable string scenario identifiers, UUIDs for new native records, explicit
  schema versions, canonical field names/units/enums, and portable timestamps.
- Keep rounding at presentation boundaries and record cross-language numerical
  tolerances.
- Separate feature availability from UI so a future entitlement provider can be
  replaced without rewriting calculations or views.
- Use a local/free entitlement provider initially. Do not add accounts, payment SDKs,
  backend verification, cloud sync, or remote configuration speculatively.
- Define future export/sync formats before promising data portability; do not treat
  today's browser localStorage representation as a permanent API.
- Reserve product, bundle, StoreKit product, and web package identifiers deliberately
  after the public naming decision.

## Premium access options

### Option A — Independent platform purchases

- User experience: simple within each platform, but users may pay twice and cannot
  assume web/iOS access transfers.
- Complexity and cost: lowest; iOS can use StoreKit without accounts/backend, while web
  payments can be separate or absent.
- Privacy: low incremental impact if no account is introduced.
- Support: refund/restore questions and explaining separate entitlements.
- App Store: digital iOS feature unlocks use In-App Purchase. Avoid in-app calls to a
  web checkout unless current storefront rules and entitlements are reviewed.
- Migration: difficult to merge later because independent purchases need identity,
  account linking, and a policy for recognising historical customers.
- First-release fit: feasible, but unattractive unless premium revenue is essential.

### Option B — Unified cross-platform entitlement

- User experience: best long-term continuity; one account recognises access everywhere.
- Complexity and cost: highest; requires identity, web payments, StoreKit transaction
  association/verification, backend entitlements, security, monitoring, and operations.
- Privacy: materially higher because account, purchase, and possibly scenario data are
  linked.
- Support: password/account recovery, purchase reconciliation, refunds, chargebacks,
  entitlement delays, deletion, and platform-price differences.
- App Store: cross-platform features bought elsewhere may be accessible on iOS when
  those features are also offered as IAP in the app; exact storefront/link rules require
  current review.
- Migration: easiest only if designed before selling; expensive and risky to build
  before demand.
- First-release fit: poor.

### Option C — Staged

- User experience: launch remains simple; cross-platform premium continuity is deferred
  and must be communicated honestly if/when a purchase is introduced.
- Complexity and cost: low initially; architecture preserves a replaceable entitlement
  boundary and portable scenario schema.
- Privacy: retains local-first operation until accounts are justified.
- Support: minimal at launch; later migration still requires careful purchase and
  account policy.
- App Store: if premium is later introduced on iOS, use StoreKit for digital feature
  unlocks. Prefer a non-consumable purchase unless the product genuinely provides
  ongoing subscription value.
- Migration: manageable if identifiers, schemas, feature keys, and entitlement
  boundaries are stable before the first paid offering.
- First-release fit: best.

## Accepted staged direction

Option C is accepted. Exclude premium implementation from initial iOS 1.0. Keep the PWA
supported and free during the first native release. Architect only a small replaceable
entitlement interface with a local “free” provider; do not build StoreKit, accounts,
web checkout, verification, or a backend yet.

If early premium becomes commercially mandatory, prefer a simple iOS StoreKit
non-consumable entitlement with transparent platform-specific access. Do not promise
cross-platform recognition until a unified identity and migration policy are approved.

## Current Apple guidance considered

- App Review Guideline 3.1.1 requires In-App Purchase for digital features or
  functionality unlocked within an iOS app.
- Guideline 3.1.3(b) permits multiplatform access to features acquired on another
  platform when those features are also available as IAP in the app.
- Storefront-specific external purchase links are conditional and should not be a
  baseline architecture assumption.
- StoreKit 2 exposes verified current entitlements on-device; server verification is an
  additional option when a backend is justified.
- Since 2026-04-28, App Store uploads must use Xcode 26 or later with the iOS 26 SDK or
  later. This build-SDK requirement is separate from the app's deployment target.

Official sources:

- https://developer.apple.com/app-store/review/guidelines/
- https://developer.apple.com/storekit/
- https://developer.apple.com/documentation/storekit/transaction/currententitlements
- https://developer.apple.com/news/upcoming-requirements/

Recheck all payment and submission rules immediately before implementation and release.
