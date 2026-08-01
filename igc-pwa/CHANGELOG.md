# Changelog

All notable changes to this project will be documented here.

---

## 1.0.1 – Browser Favicon Correction

### Fixed
- Use a dedicated full-bleed SVG favicon with no transparent rounded perimeter or
  outer stroke. Safari and other browsers that composite transparent favicon corners
  onto a light system plate no longer produce an apparent white rim.
- Give the corrected SVG a new filename so browsers do not reuse the previous cached
  favicon rendition.

### Not changed
- PWA, Home Screen and native iOS application icons retain their existing artwork.
- Calculation behaviour, saved scenarios and product features are unchanged.

## 1.0.0 – Supported Web 1.0

### Changed
- Present the maintained PWA as a supported 1.0 product following the accepted
  terminology, preset, results-presentation, accessibility and update-delivery
  corrections.
- Serve the generated service-worker entry point with a no-cache policy so browsers
  check promptly for a replacement worker. Fingerprinted application assets retain
  their normal caching behaviour.

### Compatibility
- Calculation behaviour, contract version, saved-scenario storage and browser-storage
  keys are unchanged from 0.8.2.
- A visitor still controlled by the earlier `autoUpdate` worker may need to close all
  IGC tabs or standalone windows once so the waiting 1.0 worker can activate.

## 0.8.2 – Supported Web Edition

### Fixed
- Keep the public Privacy and Support pages outside the calculator service worker's
  app-shell navigation fallback.

### Published
- Deploy the supported PWA at `https://igc.mochadesigns.co.uk/` with public Privacy
  and Support routes.

## 0.8.1 – UX Refinement Release

### Improved
- Consolidated Scenario Results into structured report-style card
- Integrated fee totals into main results hierarchy
- Refined semantic colour usage (green primary KPI, neutral fee totals)
- Collapsible Year-by-Year Breakdown (default collapsed)
- Improved Scenario Insights empty-state behaviour
- Reduced layout imbalance on desktop

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
