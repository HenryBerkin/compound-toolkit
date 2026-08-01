# IGC App Store listing copy

Status: Submitted to App Review 2026-07-31 with build 1.0 (6); awaiting result
Owner: Product Manager
Applies to: iOS 1.0

The accessibility paragraph of the description was corrected on 2026-08-01, while the
version was still Waiting for Review, after an audit found the previous wording
("Full Dynamic Type support", "VoiceOver labels throughout") stronger than the
evidence supports. Metadata is editable in that state; only a new build requires
removing the version from review.

All copy is UK English. It must not describe IGC as advice, a forecast, a
recommendation, or a regulated service, and must not imply account connection, live
market data, or tax-wrapper modelling that the app does not perform.

## Fixed fields

| Field | Value | Limit |
| --- | --- | --- |
| Name | Investment Growth Calculator | 28 / 30 |
| Primary language | English (U.K.) | — |
| Bundle ID | `uk.co.mochadesigns.igc` | — |
| Availability | United Kingdom only (IGC-D029) | — |
| Support URL | `https://igc.mochadesigns.co.uk/support` | — |
| Privacy Policy URL | `https://igc.mochadesigns.co.uk/privacy` | — |
| Marketing URL | `https://igc.mochadesigns.co.uk/` | — |

## Subtitle — 30 characters

**Recommended:** `After fees, in today's money` (28)

It names both differentiators at once: this calculator subtracts charges, and it tells
you what the result is worth in present purchasing power. Most compound-interest
calculators do neither.

Alternatives:

- `Compound growth after fees` (26) — clearer to a cold reader, drops inflation
- `Compound growth in GBP` (22) — leads with the currency constraint instead
- `Fees and inflation included` (27) — benefit-led, slightly generic

## Promotional text — 170 characters

Editable at any time without a new build, so use it for seasonal or responsive copy.

> Most calculators show a number that ignores charges and inflation. IGC shows what
> your projection is worth after fees, in today's money, and says what it leaves out.

(165 characters.)

## Keywords — 100 characters

```
compound,interest,fees,inflation,savings,GBP,UK,projection,compounding,retirement,ISA,money
```

(90 characters.) The app name is already indexed, so "investment", "growth" and
"calculator" are deliberately omitted to avoid wasting the field.

**`ISA` is included.** An ISA is a tax-free wrapper: there is no tax on growth inside
it and none on withdrawal, so IGC's projection is directly and correctly applicable to
ISA savings. What IGC does not model is the annual subscription limit, which changes
how much you may pay in rather than how the balance grows. Someone searching for an ISA
calculator gets a tool that genuinely answers their growth question.

**`pension` is excluded.** For a pension the tax treatment is not neutral: relief on
contributions and income tax on drawdown are usually the dominant factors in the
outcome, and IGC models neither. A projection that ignores both would give a materially
incomplete answer to someone searching for a pension calculator. Revisit if the
wrapper modelling in IGC-D028 is ever built.

## Description

> Investment Growth Calculator works out what regular investing could become. Unlike
> most compound-interest calculators, it shows the result after charges and in today's
> money.
>
> Enter a starting balance, a regular contribution, an assumed annual growth rate, an
> inflation assumption and an annual fee. IGC runs the calculation month by month and
> shows what those assumptions produce.
>
> WHAT YOU SEE
>
> • Final balance after fees, as the headline figure
> • The same balance in today's money, using your inflation assumption
> • A breakdown of your starting balance, contributions and growth that adds up
> • Fee impact, including why the difference exceeds the fees paid
> • A year-by-year table, in future pounds or today's money
> • An accessible chart with a spoken summary
>
> BUILT TO BE HONEST
>
> Rates and contributions are held constant, so this is one deterministic projection,
> not a probability. IGC does not model taxes, market volatility or the order of
> returns, changing inflation, contribution limits, platform or transaction charges
> beyond the annual fee you enter, pension or ISA rules, withdrawals, or losses along a
> market path. The Education section states all of this inside the app.
>
> Set an optional target in today's money and see whether the projection lands above or
> below it. That comparison is arithmetic, not a judgement about whether a plan suits
> you.
>
> PRIVATE BY DESIGN
>
> Everything is calculated on your device. There is no account, no sign-in, no
> analytics, no advertising, no tracking, and no network connection. Saved scenarios
> stay in the app's protected storage, and you can delete all app data at any time.
>
> BUILT FOR UK USERS
>
> UK English and GBP only. Savings rates are treated the way UK accounts advertise
> them, and the growth rate is described as a nominal rate rather than an APR. In the
> UK, APR measures the cost of credit, not investment growth.
>
> ACCESSIBILITY
>
> IGC supports Dynamic Type, including accessibility text sizes, with monetary figures
> laid out to stay readable as text grows. It supports VoiceOver, Reduce Motion, and
> Light and Dark appearance, and the year-by-year table is a complete alternative to
> the chart.
>
> Investment Growth Calculator is an educational tool. It is not financial advice, a
> forecast, or a recommendation. Actual outcomes may be higher or lower.

## What's New — version 1.0

> First release.
>
> • Month-by-month projections with fees and inflation modelled explicitly
> • Final balance after fees, plus the same figure in today's money
> • Year-by-year detail in future pounds or today's money
> • Optional target comparison in today's money
> • Save, rename, duplicate and delete scenarios on device
> • Education covering the method, a glossary, and what the projection excludes
> • Works entirely offline with no account and no tracking

## Copyright

App Store Connect wants the year the rights were obtained followed by the name of the
person or entity that owns them. **Do not type the © symbol**; Apple renders it.

**Suggested:** `2026 Henry Berkin`

This is an open owner input, already tracked in `docs/RELEASE_CHECKLIST.md` under
provider and copyright. The Apple Developer account is registered to **Henry Berkin**,
so that is the entity that actually holds the rights and the name that appears as the
seller on the listing. `2026 Mocha Designs` is equally legitimate if you trade under
that name, and it matches the bundle identifier and support domain, but the copyright
line should name the real rights holder rather than the brand. If the two differ, the
seller name and the copyright line will not match, which is permitted but looks
inconsistent to a reader.

Decide it before submission rather than at the last moment; it is displayed publicly on
the listing.

## EU trader status — not applicable to this release

**Do not select any EU territory.** IGC-D029 sets availability to the **United Kingdom
only**, which is not an EU storefront, so the Digital Services Act trader declaration
does not apply.

This matters because the declaration publishes the trader's name, address, telephone
number and email address on the public listing. On an individual developer account that
address is a home address, and the owner has declined to publish one.

If an EU territory is ever added, resolve a publishable address first: a business or
registered-office address, or incorporation. Adding a territory is a metadata change
requiring no new build, so the decision stays reversible in one direction only — the
address has to exist before the territory is selected, not after.

Verify the current requirement in App Store Connect at submission time; these rules
have changed repeatedly.

## Category

**Finance.** Owner decision, 2026-07-31. It is where people look for this, and the
honesty of the copy is an asset in the category that attracts the most scrutiny.
Education was the defensible alternative but carries far lower browse traffic.

## Screenshot appearance

**Dark.** Owner decision, 2026-07-31. `igc-ios/screenshots/` holds the dark sets at
both required sizes. Regenerate after any UI change; see the README in that directory.

Seven frames per device. Suggested order, leading with the result rather than the
form: `02` headline, `01` calculator, `03` chart, `04` annual detail, `07` exclusions.
Only the first three appear on installation sheets. Placing the exclusions screen in
the visible set signals the honesty that distinguishes IGC from the many general
compound-interest calculators.

## App Privacy questionnaire

The answer is **Data Not Collected** for every category. Supporting evidence:

- no networking of any kind in the app target — no `URLSession`, no `URLRequest`, no
  web view, no HTTP(S) endpoint;
- no analytics, advertising, attribution or crash-reporting SDK, and no third-party
  dependency at all;
- the only required-reason API is `NSPrivacyAccessedAPICategoryUserDefaults` with
  reason `CA92.1`, declared in the privacy manifest, used solely for appearance and
  onboarding preferences;
- scenarios are stored in the app's own Application Support container and never leave
  the device.

The Support screen offers a web address and an email address. Choosing either hands
over to the browser or mail app; IGC sends nothing itself, so it does not constitute
data collection.

## Age rating

**4+.** No objectionable content, no user-generated content, no web browsing, no
gambling, no unrestricted external links.

## Remaining fields, and where they live

A field-by-field pass over App Store Connect, so nothing is discovered late again.

| Field | Screen | Value |
| --- | --- | --- |
| Name, Subtitle | App Information | Above |
| Category | App Information | Finance, no secondary |
| **Copyright** | App Information | Above; owner decision |
| Content Rights | App Information | Contains no third-party content |
| Age Rating | App Information | 4+ |
| Privacy Policy URL | App Information | Above |
| Price | Pricing and Availability | Free |
| Availability | Pricing and Availability | United Kingdom only |
| **EU trader status** | Business / App Information | Above; see the warning |
| Data collection | App Privacy | Data Not Collected |
| Screenshots | Version page | 6.9-inch and 13-inch slots |
| Promotional text, Description, Keywords | Version page | Above |
| Support URL, Marketing URL | Version page | Above |
| Build | Version page | Latest verified archive |
| Version Release | Version page | **Manually release this version** |
| Sign-in required | App Review Information | No; the app has no account |
| Contact and Notes | App Review Information | Owner contact; notes below |

Left at their defaults deliberately: the standard Apple licence agreement, no
promotional artwork, no app previews, no pre-orders, no phased release, and no routing
coverage file, none of which apply to this release.

## Review notes

> IGC is an offline educational calculator. It requires no account and no sign-in, and
> there is nothing to configure before use. Launching the app shows a worked example
> immediately.
>
> The app makes no network requests. All calculations run on device and saved scenarios
> are stored locally.
>
> The app is deliberately GBP-only and uses UK English terminology, and availability is
> limited to the United Kingdom.
>
> The projection is explicitly illustrative. Disclaimers appear on the Calculator and
> Projection screens, and Settings and Education both contain the full disclaimer and a
> list of what the calculation excludes.
