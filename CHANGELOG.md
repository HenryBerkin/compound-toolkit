# IGC changelog

Project-wide changes are recorded here. Historical PWA releases remain unchanged in
`igc-pwa/CHANGELOG.md`.

## Unreleased — Native migration preparation

### Added

- Verified recovery tag for the public PWA baseline.
- Product audit, proposed native 1.0 scope, task register, decision log, roadmap,
  operating instructions, and specialist handoffs.
- Dual-client product strategy for maintained web and native iOS surfaces, including
  shared-contract planning and preliminary premium-access options.
- Accepted version 1 shared calculation specification, portable scenario schema, JSON
  Schemas, representative calculation/validation fixtures, and direct TypeScript
  fixture-consumer tests.
- Revised standalone IGC-004 brief for a documentation-only native iOS architecture
  proposal based on the accepted shared contract.
- Proposed the documentation-only native iOS architecture: a SwiftUI feature structure,
  pure fixture-backed calculation engine, Codable local scenario store, local-free
  feature-availability boundary, and staged accessibility, test, and delivery plan.
- Added standalone concurrent specialist briefs for IGC-005 native design, IGC-006
  behavioural QA planning, and IGC-008 privacy/App Store review.
- Added the IGC-006 behavioural QA inventory covering V1 fixture parity, platform
  boundaries, persistence recovery, accessibility evidence, known Web findings, and
  release gates without implementing tests or native features.
- Added IGC-008’s documentation-only App Store, privacy, and phase-gated release-risk
  review with current Apple-source checks and no native or App Store action.
- Defined the implementation-ready native IGC design system, interaction hierarchy,
  accessible results and annual-detail presentation, and local scenario recovery flows.
- Added the blocked standalone IGC-007 implementation brief for the project foundation,
  pure fixture-backed Swift core, and accessible Calculator-to-Projection vertical
  slice; dispatch remains gated on the activated Apple Team Name and Team ID.

### Changed

- Isolated the preserved PWA under `igc-pwa/`.
- Removed automatic placeholder-icon generation from PWA dependency installation so
  normal setup preserves the branded IGC assets.
- Reclassified the PWA from frozen legacy reference to a supported IGC web
  edition while retaining iOS as the immediate release priority.
- Accepted the six architecture-blocking product choices and staged premium deferral.
- Set native iOS 1.0 to iOS 17, iPhone-primary/adaptive iPad, annual detail without
  export, with two-scenario comparison deferred to iOS 1.1.
- Established Investment Growth Calculator as the public/App Store name, IGC as the
  shorthand/icon identity, and an explicit Custom 7% / 3% / 0.20% baseline.
- Accepted the IGC-004 native architecture under IGC-D014, including the single-module
  SwiftUI structure, actor-backed Codable scenario store, direct fixture parity gate,
  first-party dependency policy, and local-free availability seam.
- Accepted the IGC-006 behavioural QA inventory under IGC-D015, including direct
  cross-client fixture parity, intentional platform-difference testing, evidence
  classification, accessibility/persistence coverage, and staged release gates.
- Accepted the IGC-008 early App Store/privacy planning baseline under IGC-D016,
  retaining provisional binary-dependent declarations, owner inputs, legal review
  flags, and current-rule recheck gates.
- Accepted the corrected IGC-005 native design system and DS-01 through DS-07 under
  IGC-D017, including raw target status, schema-valid scenario naming, and safe
  preset-mismatch handling.
- Fixed the native application bundle identifier as `uk.co.mochadesigns.igc` under
  IGC-D018 while retaining Apple Developer Team Name and Team ID as a blocking owner
  input until programme activation completes.

### Not changed

- PWA calculation logic, workflows, styling, storage keys, dependencies, and licence.
