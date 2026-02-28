# Changelog

All notable changes to this project will be documented here.

---

## [v0.8.0] - Compare Mode & Education Layer

### Added
- Side-by-side scenario comparison (A vs B)
- Comparability warning for mismatched inputs
- Education glossary modal ("Understanding the terms")
- Clearer scenario assumption labels (APR | Fee | Inflation | Duration)

### Improved
- Compare chart overlays for A/B (nominal + real after fees)
- Mobile readability and layout tightening
- Preset labelling clarity
- Performance via code-splitting

### Internal
- No changes to calculation engine logic
- All existing tests passing

## [v0.7.0] - Performance & UX Polish
- Implemented code-splitting with React.lazy for non-critical panels (Chart, Breakdown, Scenarios, Assumptions).
- Reduced main bundle size from ~571kB to ~30kB (lazy-loaded vendor and charts chunks).
- Improved mobile-first spacing, hierarchy, and tone across form and results.
- Refined form labels and helper text (APR clarified in helper copy).
- Improved error messaging tone and scenario save wording.

## [v0.6.0] - Target Mode & Product Refinement
- Added optional “Target in today’s money” analysis with required future balance calculation.
- Introduced professional UK-focused default assumptions (ETF-style baseline).
- Added formatted currency input behavior with thousands separators.
- Refined assumptions and methodology copy for advisor-grade clarity.
- Updated product naming to “Investment Growth Calculator”.

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