# IGC product specification and proposed native iOS 1.0 scope

Status: Ready for user review
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

Platform-appropriate differences are permitted for navigation, layout, chart rendering,
install/update lifecycle, accessibility APIs, local persistence technology, file
sharing, and other operating-system conventions. Feature parity is deliberate, not
automatic.

## Proposed native iOS 1.0 scope

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

## Supported PWA/web scope

Until separately changed, support the audited web calculator, target analysis, results
and insights, chart, annual/monthly breakdown, CSV export, saved scenarios, comparison,
glossary/methodology, responsive layout, dark mode, and offline capability.

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
- Technical: floating-point parity between JavaScript and Swift needs fixture/tolerance
  design; annual/weekly contribution conversion is non-obvious; two maintained engines
  create coordination and regression cost.
- Design: dense PWA output must be prioritised for a small screen without hiding
  essential context.
- Accessibility: charts and custom comparison layouts need meaningful non-visual
  alternatives.
- Privacy: locally stored financial scenarios still require accurate App Privacy
  answers and a clear deletion path; accounts or entitlement services would materially
  expand data handling.
- App Store: financial-content positioning, disclaimers, support/privacy URLs, and
  current submission requirements need official review after scope and data handling
  are accepted.

## Blocking product questions

All six must be answered or explicitly deferred before IGC-004 is revised and returned
to `Ready`:

1. Locale and currency: is UK English with GBP-only formatting accepted for native 1.0
   and the current web edition?
2. Scenario comparison: does two-scenario comparison ship in native 1.0 or remain
   web-only until a later native release?
3. Detail and export: is annual breakdown sufficient for native 1.0, with monthly detail
   and CSV export remaining supported on web but deferred on iOS?
4. Preset/default consistency: should both clients apply the Global Index preset’s
   0.40% fee by default, show an explicit Custom state for the existing 0.20% default,
   or adopt another approved default?
5. Public naming: is the cross-platform product and App Store name `IGC`,
   `Investment Growth Calculator`, or `IGC — Investment Growth Calculator`, subject to
   App Store metadata limits and availability?
6. Deployment target: what minimum iOS version and initial device family should native
   1.0 support?

Premium selection does not need to block architecture if the user explicitly accepts
the staged deferral in IGC-D008: no initial premium implementation, no account/backend,
and only a replaceable entitlement boundary in the proposal.
