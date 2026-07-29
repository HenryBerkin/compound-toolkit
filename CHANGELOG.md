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
  slice, later cleared for dispatch when the complete Apple Team identity was supplied.
- Issued the final IGC-007 specialist prompt from exact base
  `dc521186d9d0f30add2f45c06cb02d6d98d35195`.
- Implemented IGC-007’s first-party SwiftUI Calculator-to-Projection vertical slice,
  pure fixture-parity core, annual detail, accessibility alternatives, and native tests.
- Recorded the successful IGC-007 physical-device signing, installation, direct-launch,
  and manual smoke gate, with debugger-attached execution explicitly skipped for the
  unsupported Xcode 26.2/iOS 27 pairing.
- Added and approved IGC-012 for native V1 scenario lifecycle and persistence.
- Implemented IGC-012’s exact native V1 scenario mapping, protected actor-backed
  Codable Application Support store, durable save/Save-as-new, deterministic Saved
  root, load, rename, duplicate, confirmed delete, non-destructive recovery states,
  relaunch persistence, accessibility behaviour, and focused store/UI tests without
  changing shared contracts or adding a dependency, network, sync, analytics, premium,
  or App Store path.

### Changed

- Isolated the preserved PWA under `igc-pwa/`.
- Accepted and integrated IGC-007 after its Product Manager correction review; the
  independent gate passed 27/27 tests and the Release simulator build.
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
  IGC-D018 while keeping the owner-controlled signing identity as a pre-dispatch gate.
- Recorded owner-confirmed Apple Developer Team ID `2FKVFS8X67`; the exact Team Name
  `Henry Berkin` completes the pre-dispatch signing identity for IGC-007.
- Accepted the physical-device gate under IGC-D019 and fixed the future attached-debug
  boundary to a documented compatible Xcode/device pairing without project workarounds.
- Authorised IGC-012 under IGC-D020 and withdrew the earlier prompt based on
  `212cf6056bd37ca22d5aff9db542f9aab4acdd19`.
- Corrected IGC-012 recovery so preserved evidence must exactly match the current
  corrupt or unsupported document before reset, including later corruption episodes,
  and aligned Projection Save availability with loading/unavailable/corrupt/
  unsupported store states using visible accessible explanations.
- Accepted and integrated corrected IGC-012 at specialist head
  `20af11c905a2c2bf16fe46af132725d97a1cf7f9`; the independent Product Manager gate
  passed 40/40 unit/fixture/store tests, 16/16 UI tests, and the Release simulator
  build before merge commit `853555794173814a9299d257d6ff12786c7b26dc`.

### Not changed

- PWA calculation logic, workflows, styling, storage keys, dependencies, and licence.
- Native IGC-007 source, signing settings, capabilities, entitlements, and shared Xcode
  scheme formatting; Xcode’s incidental scheme-only reformat was discarded.
