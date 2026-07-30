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
- Added and authorised IGC-013 as the next native milestone for bundled secondary
  content, contextual education, first-launch and appearance preferences, Settings/
  About/Privacy, coordinated local-data reset, accessibility/adaptive coverage, and
  the exact UserDefaults required-reason privacy-manifest boundary.
- Implemented IGC-013’s bundled offline Education hierarchy, feature-local contextual
  education, first-launch coach, persisted System/Light/Dark appearance, Settings/
  About/Privacy, verified Delete all app data coordination, app-only UserDefaults
  boundary, and exact `NSPrivacyAccessedAPICategoryUserDefaults` / `CA92.1` app-target
  privacy manifest. Final evidence is 56/56 unit and 23/23 UI tests plus passing
  focused iPad, compact accessibility-size Dark Mode, unreachable-proxy offline,
  Debug, Release, manifest, and static privacy/dependency checks. Final legal/public
  Support/Privacy/release work remains open.

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
- Selected native secondary content and preferences as the dependency-ordered next
  task under IGC-D022 while retaining final legal copy, public Support/Privacy
  destinations, TestFlight, archive/upload, and App Store work as later release gates.
- Accepted and integrated IGC-013 at specialist head
  `425af8e302269e52a0971815fdb70241854404d2`; the independent Product Manager gate
  passed 56/56 unit tests, 23/23 UI tests, the Release simulator build, and packaged
  privacy-manifest validation before merge commit
  `a6a1e5fac3c66ea5c42bd71d8d93df93516e8ef6`.
- Added the established IGC mark as the native app icon and changed the Calculator
  screen title to **IGC**, while retaining **Calculator** as the functional tab label.
- Prepared the native `1.0 (1)` release candidate with explicit iPhone and iPad
  orientation declarations. Xcode 26.6 / iOS 26.5 release-gate evidence passes 56/56
  unit tests, 23/23 iPhone UI tests, a focused adaptive-iPad route, and a signed
  zero-warning archive inspection without adding a capability, entitlement,
  dependency, network path or App Store action.
- Accepted and integrated release-candidate commit
  `36eff61d12f7cf0c0a6afcc8cebd3dc33c8a9109` by merge commit
  `fe1231e0007d0485afa72c7b4cd0127452b8a46a`.
- Prepared the exact initial App Store Connect record fields and separated them from
  later metadata/submission inputs; no Apple record or external-service change was
  made.
- Recorded owner approval of immutable App Store SKU `IGC-IOS-001` and Full Access;
  record creation was retained as a separately authorised external operation.
- Registered explicit App ID `uk.co.mochadesigns.igc` under Team `2FKVFS8X67` and,
  after separate owner approval, created App Store Connect app ID `6796327865` with
  the approved iOS, name, English (U.K.), SKU and Full Access values. Version `1.0`
  is **Prepare for Submission**; no build upload, TestFlight or submission occurred.
- Added approved public IGC Privacy and Support pages for the supported PWA, using the
  existing IGC identity, the confirmed Mocha Designs trading disclosure, and
  `support@mochadesigns.co.uk` without analytics, tracking, forms, or dynamic services.
- Published the complete supported PWA on static Cloudflare Pages at
  `https://igc.mochadesigns.co.uk/`, with active SSL and clean public
  `/privacy` and `/support` routes. No analytics, tracking, Function, database,
  account or paid service was enabled.
- Corrected the supported PWA’s initial preset display to explicit **Custom** while
  preserving the verified 7% / 3% / 0.20% baseline. Deliberate Global Index selection
  applies 0.40%, and editing a preset-controlled assumption returns the selector to
  Custom.
- Restored browser zoom by removing the maximum-scale and user-scalable restrictions
  from the PWA viewport declaration.
- Excluded the public Privacy and Support paths from the PWA calculator’s app-shell
  navigation fallback so an existing service worker cannot replace those pages with
  the calculator.
- Released the supported Web edition as patch version 0.8.2 so its visible footer
  reflects the post-0.8.1 hosting and routing release.

### Not changed

- PWA calculation formulae, result behaviour, saved-scenario storage format and keys,
  dependencies, and licence.
- Native IGC-007 source, signing settings, capabilities, entitlements, and shared Xcode
  scheme formatting; Xcode’s incidental scheme-only reformat was discarded.
