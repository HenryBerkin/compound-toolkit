# Changelog

All notable changes to this project will be documented here.

---

## [v0.5.0] - UI: Inflation + Fees
- Added UI inputs for Inflation rate (%) and Annual fee (%).
- Updated results summary to show:
  - Final balance (Nominal / Real / After fees / Real after fees)
  - Total fees paid (Nominal / Real)
- Added breakdown table view selector (Nominal / Real / After fees / Real after fees).
- Improved breakdown table readability:
  - Professional header wording (removed “CUM” abbreviations)
  - Wrapped headers to reduce horizontal scrolling
  - Sticky “Year” column support for easier navigation
- Updated chart to compare Nominal vs After fees by default, with toggles for Real and Real after fees.
- Updated assumptions/methodology copy and scenario metadata display.

## [v0.4.0] - Fee Model
- Added annual fee drag modelling using an asset-based per-period fee (not APR subtraction).
- Added after-fee outputs including total fees paid (nominal) and after-fee balances.
- Integrated inflation + fee interaction (real after-fee outputs).
- Expanded engine tests for fee drag behaviour and long-horizon stability.

## [v0.3.0] - Inflation Model
- Added inflation-adjusted real terms projection.
- Added dual nominal vs real outputs.
- Added partial-year inflation discounting.
- Extended engine tests for inflation stability and edge cases.

## [v0.2.0] - Engine Hardening
- Expanded test coverage for calculation engine.
- Fixed fractional duration truncation bug.
- Verified numerical stability over 50-year horizons.
- Enforced deterministic rounding strategy.

## [v0.1.0] - MVP
- Initial compound growth PWA.
- Nominal projection engine.
- Scenario storage.
- PWA support.