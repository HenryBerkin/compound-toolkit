# Investment Growth Calculator product specification and native iOS 1.0 scope

Status: Accepted for architecture
Owner: Product Manager and Technical Lead

## Product summary

IGC helps a UK investor explore how a starting balance, regular contributions, return,
inflation, fees, time, and contribution timing affect long-term investment growth. It
is an educational planning calculator, not advice or a forecast.

IGC may be delivered through two supported clients:

1. a native SwiftUI iOS application, which is the immediate release priority; and
2. a responsive PWA/web edition, which also remains the behavioural reference.

Both should make the main question fast to answer: “Given these assumptions, what might
my investment be worth, and what could that amount buy in today’s money?”

The public product and intended App Store name is **Investment Growth Calculator**.
`IGC` is the shorthand and icon identity. Long-form marketing may use
**IGC — Investment Growth Calculator**.

## Cross-platform product contract

The following must remain aligned unless an accepted decision explicitly authorises a
platform difference:

- calculation formulas, operation order, units, and numerical tolerances;
- input meaning, validation bounds, defaults, presets, and error semantics;
- presentation rounding and canonical example outputs;
- financial terminology, assumptions, exclusions, and disclaimers;
- scenario field meaning, stable identifiers, schema versioning, and migration intent;
- target and comparison semantics;
- which capabilities are free or premium.

The accepted version 1 calculation and scenario contracts are
`docs/CALCULATION_SPEC.md` and `docs/SCENARIO_SCHEMA.md`, backed by portable assets in
`shared/`.

Platform-appropriate differences are permitted for navigation, layout, chart rendering,
install/update lifecycle, accessibility APIs, local persistence technology, file
sharing, and other operating-system conventions. Feature parity is deliberate, not
automatic.

## Accepted native iOS 1.0 scope

### Calculator

- UK-English presentation with starting balance and regular contribution in GBP.
- Weekly, monthly, or annual contribution frequency.
- Annual growth rate, compounding choice, inflation, and annual fee.
- Whole years plus extra months and start/end contribution timing.
- An explicit Custom initial state using the verified 7% APR, 3% inflation, and 0.20%
  fee baseline. The Global Index preset applies its 0.40% fee only after selection.
- Curated presets whose selected state always matches the applied assumptions.
- Clear validation and a locally calculated default scenario with `currency: GBP`.

### Results

- Final balance after fees as the primary KPI.
- Nominal, after-fee, and inflation-adjusted context.
- Starting balance, contributions, growth, and fee impact.
- Optional today-value target and above/below target result.
- Accessible growth visual plus a concise text/data alternative.
- Expandable annual breakdown. Monthly rows remain internal but are not presented in
  native 1.0.
- Plain-language assumptions, terminology, and financial-projection disclaimer.

### Scenarios

- Save, name, load, duplicate, and delete scenarios on-device.
- Support multiple scenarios in the data model; two-scenario comparison is deferred to
  native iOS 1.1.
- Persist appearance and onboarding state locally.
- Provide an understandable way to delete/reset all local app data.

### Native quality

- SwiftUI rather than a web view.
- Minimum iOS 17; iPhone-primary and adaptively iPad-compatible without a bespoke iPad
  experience.
- Light/dark appearance, Dynamic Type, VoiceOver labels/order, sufficient contrast,
  reduced-motion awareness, and standard touch targets.
- No network required for calculation or saved scenarios.
- Tested parity for approved calculation fixtures and boundary validation.

## Supported PWA/web scope

Until separately changed, support the audited web calculator, target analysis, results
and insights, chart, annual/monthly breakdown, CSV export, saved scenarios, comparison,
glossary/methodology, responsive layout, dark mode, and offline capability.

The accepted Custom initial-state correction remains a Web follow-up: the current PWA
selector visibly implies Global Index even though the verified initial calculation uses
the Custom 0.20% fee. Correcting the selector must preserve the baseline and browser
data.

Security, compatibility, accessibility, dependency, and correctness maintenance may
continue during the iOS programme. Non-critical redesign and new web features should
wait until after the first iOS release unless they unblock a shared contract or correct
a material defect.

## Explicit native 1.0 exclusions

- Accounts, sign-in, backend, cross-device sync, collaboration, or sharing.
- Analytics, advertising, tracking, subscriptions, premium access, or in-app purchases.
- Live prices, portfolio connections, financial institution integrations, or market data.
- Tax, ISA/pension rules, contribution limits, volatility, sequence risk, withdrawals,
  or retirement-income planning.
- Multi-currency, currency conversion, or localisation beyond UK English/GBP.
- CSV/image/PDF export, widgets, Shortcuts, notifications, and a bespoke iPad layout.
- Native two-scenario comparison until iOS 1.1.
- Changes to the mathematical model unless separately accepted.

## Later shared or platform-specific candidates

Exports, iCloud sync, additional currencies/locales, variable-return scenarios,
withdrawal modelling, tax-wrapper education, widgets, accessibility enhancements based
on user testing, optional privacy-preserving diagnostics, accounts, cross-platform
scenario sync, and unified premium entitlements.

## Acceptance themes

- Correct: fixture outputs match the approved model within a documented tolerance.
- Clear: users can distinguish nominal, after-fee, and today-value results.
- Honest: assumptions and exclusions remain visible and comprehensible.
- Private: all scenario data remains on-device unless a later decision changes that.
- Native: navigation and controls follow current iOS conventions.
- Recoverable: user data operations include deliberate delete/reset behaviour.

## Risks

- Product: investment return terminology and preset assumptions could be read as
  recommendations.
- Technical: floating-point parity between JavaScript and Swift requires continued
  fixture/tolerance discipline; annual/weekly contribution conversion is non-obvious;
  two maintained engines create coordination and regression cost.
- Design: dense PWA output must be prioritised for a small screen without hiding
  essential context.
- Accessibility: charts and custom comparison layouts need meaningful non-visual
  alternatives.
- Privacy: locally stored financial scenarios still require accurate App Privacy
  answers and a clear deletion path; accounts or entitlement services would materially
  expand data handling.
- App Store: financial-content positioning, disclaimers, support/privacy URLs, and
  current submission requirements need official review after the architecture defines
  native data handling.

## Resolved architecture inputs

- UK English and GBP-only in 1.0, with `GBP` explicit in currency-ready scenario data.
- Native comparison deferred to iOS 1.1; supported PWA comparison retained.
- Native annual detail only and no export; monthly calculation retained internally;
  supported PWA monthly detail and CSV retained.
- Explicit Custom initial state preserving 7% / 3% / 0.20%; Global Index applies 0.40%
  only when selected.
- Public name Investment Growth Calculator; shorthand/icon IGC; optional long-form
  marketing name IGC — Investment Growth Calculator.
- Minimum iOS 17, iPhone-primary and adaptively iPad-compatible.
- Staged premium deferral accepted: no initial premium, StoreKit, account, backend,
  sync, or remote entitlement implementation. Architecture proposes only a proportionate
  replaceable feature-availability boundary.
