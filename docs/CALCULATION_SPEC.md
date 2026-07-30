# IGC shared calculation contract

Status: Accepted contract version 1
Owner: Product Manager and Technical Lead
Applies to: Shared / iOS / Web

## Purpose and authority

This document defines the language-neutral calculation and validation behaviour for
Investment Growth Calculator. Swift and TypeScript remain independent implementations.
The versioned specification and JSON fixtures are the cross-platform source of truth;
neither implementation is the specification for the other.

Contract version 1 preserves the verified PWA model. A mathematical change requires an
accepted decision, a contract-version assessment, updated fixtures, and regression
verification in both clients.

Canonical assets:

- `shared/fixtures/calculation-v1.json`
- `shared/schemas/calculation-fixture-v1.schema.json`
- `shared/schemas/scenario-v1.schema.json`
- `shared/examples/scenario-v1.example.json`

## Canonical input

All monetary values are numeric GBP amounts. All rates are decimal annual rates:
`0.07` means 7%. JSON field names and enum values are stable contract identifiers.

| Field | Meaning | Valid values |
| --- | --- | --- |
| `principal` | Starting balance | finite number from 0 to 1,000,000,000 |
| `contribution` | Amount at the selected frequency | finite number from 0 to 1,000,000,000 |
| `contributionFrequency` | Contribution conversion convention | `weekly`, `monthly`, `annual` |
| `apr` | Nominal annual growth rate | finite decimal from 0 to 9.99 |
| `inflationRate` | Annual inflation assumption | finite decimal from 0 to 0.20; default 0 |
| `annualFeeRate` | Annual asset-based fee assumption | finite decimal from 0 to 0.10; default 0 |
| `compoundFrequency` | Nominal APR and fee conversion convention | `daily`, `monthly`, `quarterly`, `annual` |
| `years` | Whole years | integer, 0 or more |
| `months` | Extra months after the whole years | integer from 0 to 11 |
| `timing` | When each monthly-equivalent contribution is applied | `start`, `end` |

At least one of `principal` and `contribution` must be greater than zero. The duration
`years × 12 + months` must be from 1 through 720 months inclusive. A conforming client
rejects non-finite numeric values before calculation.

User-entered currency parsing is platform-specific. The current PWA accepts commas and
spaces in currency fields. That parsing convenience is not a portable financial-model
rule; each client should use an accessible UK-English input experience and produce the
canonical numeric values above.

## Accepted initial state and presets

The initial state is explicitly **Custom**, not a selected preset:

| Field | Initial value |
| --- | ---: |
| Principal | £10,000 |
| Contribution | £250 monthly |
| APR | 7% |
| Inflation | 3% |
| Annual fee | 0.20% |
| Compounding | Monthly |
| Duration | 15 years, 0 extra months |
| Contribution timing | Start |
| Currency | GBP |
| Preset identifier | `null` |

The curated presets are:

| Preset ID | APR | Inflation | Annual fee | Compounding |
| --- | ---: | ---: | ---: | --- |
| `global-index-diy` | 7% | 3% | 0.40% | Monthly |
| `balanced-portfolio` | 6% | 3% | 0.75% | Monthly |
| `equity-heavy-portfolio` | 9% | 3% | 1.00% | Monthly |
| `savings-account` | 4% | 3% | 0% | Annual |

A preset is active only after deliberate selection and only while all preset-controlled
fields still match it. Editing one of those fields changes the state to Custom.
Preset names are presentation copy; the stable identifier is persisted.

`savings-account` uses annual compounding deliberately. UK savings accounts advertise an
effective annual rate (AER), and annual compounding is the only convention under which
the entered rate is also the effective rate. Under monthly compounding the same 4% would
produce 4.0742% effective growth, overstating an advertised 4% AER account.

## User-facing terminology

`apr` is a stable contract identifier and must not be renamed in schemas, fixtures, or
persisted scenarios. It is **not** the user-facing term. Both clients present this field
as **annual growth rate** and describe it as a nominal rate.

In the United Kingdom, APR is a defined measure of the cost of credit rather than of
investment growth, so no client surfaces "APR" as the name of this assumption. Because
the rate is nominal, daily, monthly and quarterly compounding produce a slightly higher
effective yearly growth than the figure entered; only annual compounding returns exactly
that figure. Each client states the effective figure rather than leaving it to be
inferred.

## Conversion formulae

Let:

- `r` be `apr`;
- `f` be `annualFeeRate`;
- `C` be `contribution`;
- `r_m` be the effective monthly growth rate;
- `f_m` be the effective monthly fee drag rate; and
- `C_m` be the effective monthly contribution.

Effective monthly growth:

| Compounding | `r_m` |
| --- | --- |
| Daily | `(1 + r / 365)^(365 / 12) - 1` |
| Monthly | `r / 12` |
| Quarterly | `(1 + r / 4)^(1 / 3) - 1` |
| Annual | `(1 + r)^(1 / 12) - 1` |

Effective monthly fee drag:

| Compounding | `f_m` |
| --- | --- |
| Daily | `1 - (1 - f / 365)^(365 / 12)` |
| Monthly | `f / 12` |
| Quarterly | `1 - (1 - f / 4)^(1 / 3)` |
| Annual | `1 - (1 - f)^(1 / 12)` |

Effective monthly contribution:

| Contribution frequency | `C_m` |
| --- | --- |
| Weekly | `C × 52 / 12` |
| Monthly | `C` |
| Annual | `C / 12` |

If the corresponding annual rate is zero, its monthly rate is exactly zero.

## Monthly simulation and operation order

The engine runs exactly `years × 12 + months` calendar-month periods using binary64
floating-point values. In the formulae below, `B` and `F` mean the opening balances for
the period. The engine maintains:

- the nominal no-fee path `B`; and
- the nominal after-fee path `F`.

No intermediate value is rounded.

For `timing = start`:

1. add `C_m` to the no-fee opening balance;
2. calculate interest as `(B + C_m) × r_m`;
3. add `C_m` to the after-fee opening balance;
4. apply growth to that balance;
5. calculate the period fee on that post-growth balance; and
6. subtract the period fee.

Equivalently:

- `B_next = (B + C_m) × (1 + r_m)`
- `fee = (F + C_m) × (1 + r_m) × f_m`
- `F_next = (F + C_m) × (1 + r_m) - fee`

For `timing = end`:

1. calculate and add growth to `B`;
2. add `C_m` to `B`;
3. apply growth to `F`;
4. calculate and subtract the fee from the post-growth balance; and
5. add `C_m` to `F`.

Equivalently:

- `B_next = B × (1 + r_m) + C_m`
- `fee = F × (1 + r_m) × f_m`
- `F_next = F × (1 + r_m) - fee + C_m`

`totalInterest` is the accumulated interest on the no-fee path. `totalFeesPaidNominal`
is the sum of period fees. The difference between `finalBalance` and
`finalBalanceAfterFees` may exceed total fees because fee deductions also lose future
growth.

## Monthly and annual output

Each monthly row is one-based:

- `period`: 1 through total months;
- `year`: `ceil(period / 12)`;
- `month`: `((period - 1) mod 12) + 1`;
- `startingBalance`: no-fee balance before that period;
- `contributions`: `C_m`;
- `interest`: no-fee interest for that period;
- `endingBalance`: no-fee balance after growth and contribution;
- `cumulativeContributions`; and
- `cumulativeInterest`.

Annual rows group months by the one-based `year`, including a final partial year. Each
row contains the first monthly starting balance, sums of that row's contributions,
interest, and fees, final no-fee and after-fee balances, and cumulative totals at the
row end. Therefore 13 months produces two annual rows: 12 months and 1 month.

Monthly calculations and rows remain part of the shared engine even when a client does
not display them. Native iOS 1.0 displays annual detail only; the PWA continues to
display both monthly and annual detail and supports CSV export.

## Inflation-adjusted values

For elapsed years `t`, the discount divisor is:

`D(t) = (1 + inflationRate)^t`

The final value uses `t = totalMonths / 12`. Each annual row uses
`t = rowEndPeriod / 12`, including a partial final year.

The model divides the corresponding nominal value by `D(t)`:

- `finalBalanceReal`;
- `totalContributionsReal`;
- `totalInterestReal`;
- `totalFeesPaidReal`; and
- `finalBalanceAfterFeesReal`.

Annual real ending balance, cumulative contributions, and cumulative interest use the
row-end divisor. This is horizon discounting of accumulated totals, not
cashflow-by-cashflow inflation adjustment. Preserve this convention unless an accepted
future model change replaces it.

A client that presents an annual row as an additive breakdown in today's money must
apply that row's single row-end divisor to every amount in the row, including the
opening balance. Mixing divisors within one row produces a breakdown that does not sum
to its own closing balance. A consequence of this convention is that an opening balance
in today's money is not the previous row's closing balance, because the two use
different divisors; a client presenting both must say so.

## Presentation and target rules

- Calculations and persistence retain unrounded binary64 values.
- Standard monetary display uses UK English, GBP, and two decimal places.
- Halfway monetary values round to the nearest penny away from zero.
- Compact chart labels are presentational and are not parity evidence.
- Rates shown as percentages are derived from decimal rates; normal detailed display
  uses two decimal places.
- A today-value target is an optional non-negative GBP amount outside the growth
  engine. Compare it with `finalBalanceAfterFeesReal`.
- The nominal future amount corresponding to a today-value target is
  `targetToday × (1 + inflationRate)^(totalMonths / 12)`.

The fixture expectations are raw values. A client must compare raw calculation values
before display formatting.

## Portable fixtures and tolerance

`shared/fixtures/calculation-v1.json` contains:

- seven valid calculation cases covering every enum, both contribution timings,
  partial years, zero rates, fees, inflation, the accepted default, and the 60-year
  boundary;
- expected scalar outputs and row counts;
- selected monthly and annual checkpoints; and
- semantic validation cases.

For general numeric values, parity passes when:

`abs(actual - expected) <= max(absolute, relative × max(1, abs(expected)))`

Contract v1 sets `absolute = 0.000001` and `relative = 1e-12`. Effective monthly rate
comparisons use `rateAbsolute = 1e-14`. Integer counts, enum values, and identifiers
must match exactly. These tolerances accommodate standard-library `pow` differences
while remaining far below one penny.

## Test responsibilities

The TypeScript suite must load the shared JSON fixture directly, reproduce all valid
outputs/checkpoints within tolerance, and reproduce every validation result. Existing
unit and invariant tests remain valuable and are not replaced.

The future Swift suite must load the same JSON asset without translating expected
values into Swift source. It must test the Swift engine and validator independently
using the same tolerance algorithm. UI tests verify presentation, not raw parity.

Each client may add platform-specific parsing, formatting, persistence, and accessibility
tests. Platform-specific tests cannot weaken this shared contract.

## Change control

1. Open a Shared task and record the proposed product/model decision.
2. State whether the change is backward compatible or requires a new contract and
   scenario schema version.
3. Update this specification, JSON Schema, fixtures, and both implementations in one
   coordinated change set.
4. Run both fixture consumers plus each platform's regression suite.
5. Record deliberate fixture changes in the project changelog. An unexplained fixture
   delta is a regression, not an update.
