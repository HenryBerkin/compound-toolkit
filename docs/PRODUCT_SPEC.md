# Proposed native iOS 1.0 product specification

Status: Ready for user review
Owner: Product Manager and Technical Lead

## Product summary

IGC helps a UK investor explore how a starting balance, regular contributions, return,
inflation, fees, time, and contribution timing affect long-term investment growth. It
is an educational planning calculator, not advice or a forecast.

The native app should make the main question fast to answer: “Given these assumptions,
what might my investment be worth, and what could that amount buy in today’s money?”

## Proposed 1.0 scope

### Calculator

- Starting balance and regular contribution in GBP.
- Weekly, monthly, or annual contribution frequency.
- Annual growth rate, compounding choice, inflation, and annual fee.
- Whole years plus extra months and start/end contribution timing.
- Curated presets whose selected state always matches the applied assumptions.
- Clear validation and a locally calculated default scenario.

### Results

- Final balance after fees as the primary KPI.
- Nominal, after-fee, and inflation-adjusted context.
- Starting balance, contributions, growth, and fee impact.
- Optional today-value target and above/below target result.
- Accessible growth visual plus a concise text/data alternative.
- Expandable annual breakdown; monthly detail is not required for 1.0.
- Plain-language assumptions, terminology, and financial-projection disclaimer.

### Scenarios

- Save, name, load, duplicate, and delete scenarios on-device.
- Compare two saved scenarios with a warning when core cash-flow assumptions differ.
- Persist appearance and onboarding state locally.
- Provide an understandable way to delete/reset all local app data.

### Native quality

- SwiftUI rather than a web view.
- Light/dark appearance, Dynamic Type, VoiceOver labels/order, sufficient contrast,
  reduced-motion awareness, and standard touch targets.
- No network required for calculation or saved scenarios.
- Tested parity for approved calculation fixtures and boundary validation.

## Explicit 1.0 exclusions

- Accounts, sign-in, backend, cross-device sync, collaboration, or sharing.
- Analytics, advertising, tracking, subscriptions, or in-app purchases.
- Live prices, portfolio connections, financial institution integrations, or market data.
- Tax, ISA/pension rules, contribution limits, volatility, sequence risk, withdrawals,
  or retirement-income planning.
- Multi-currency, currency conversion, or localisation beyond UK English/GBP.
- CSV/image/PDF export, widgets, Shortcuts, notifications, and a bespoke iPad layout.
- Changes to the mathematical model unless separately accepted.

## Later candidates

Exports, iCloud sync, additional currencies/locales, variable-return scenarios,
withdrawal modelling, tax-wrapper education, widgets, accessibility enhancements based
on user testing, and optional privacy-preserving diagnostics.

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
- Technical: floating-point parity between JavaScript and Swift needs fixture/tolerance
  design; annual/weekly contribution conversion is non-obvious.
- Design: dense PWA output must be prioritised for a small screen without hiding
  essential context.
- Accessibility: charts and custom comparison layouts need meaningful non-visual
  alternatives.
- Privacy: locally stored financial scenarios still require accurate App Privacy
  answers and a clear deletion path.
- App Store: financial-content positioning, disclaimers, support/privacy URLs, and
  current submission requirements need official review after scope and data handling
  are accepted.

## Questions for the user

1. Is UK English with GBP-only formatting acceptable for version 1.0?
2. Should two-scenario comparison ship in 1.0, or be deferred to make the first release
   smaller?
3. Is annual breakdown sufficient for 1.0, with monthly detail and CSV export deferred?
4. Should the native default use the visible Global Index preset’s 0.40% fee, preserve
   the current hidden 0.20% default, or show “Custom” until a preset is chosen?
5. Is the intended public product name “IGC”, “Investment Growth Calculator”, or
   “IGC — Investment Growth Calculator” in the App Store?
6. What minimum iOS version and device set should be supported? The architecture task
   can recommend a default if there is no business constraint.
