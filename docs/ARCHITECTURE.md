# Architecture Overview

## Calculation Layers

The projection engine produces:

1. Nominal projection
2. Inflation-adjusted (real) projection
3. (Upcoming) Fee-adjusted projection
4. Combined real + fee projection

## Core Design Principles

- Nominal math is primary source of truth.
- Inflation and fees are applied as transformations.
- Internal math uses full precision.
- Rounding occurs only at display layer.
- Engine logic is UI-independent.

## Compounding Model

Per period:
balance = balance * (1 + growthRatePerPeriod)

Inflation discount:
real = nominal / (1 + inflationRate)^t