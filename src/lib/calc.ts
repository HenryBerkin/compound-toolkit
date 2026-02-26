/**
 * calc.ts — Pure calculation engine for the Compound Growth Toolkit.
 *
 * Design principles:
 *  - No side-effects; all functions are pure.
 *  - Internal arithmetic uses full floating-point precision.
 *  - Caller is responsible for display rounding (2 dp).
 *  - Monthly simulation model: every period is one calendar month.
 *    Contribution frequencies are converted to an effective monthly equivalent.
 *    Compounding frequencies are converted to an effective monthly rate so that
 *    the nominal APR is preserved across all compounding modes.
 */

import type {
  CalcInputs,
  CalcResult,
  ChartPoint,
  CompoundFrequency,
  ContributionFrequency,
  FormState,
  MonthlyBreakdown,
  ValidationErrors,
  YearlyBreakdown,
} from '../types';

// ─── Rate helpers ──────────────────────────────────────────────────────────────

/**
 * Convert nominal APR (decimal) to an equivalent monthly rate that preserves
 * the compounding convention specified by `compound`.
 *
 * daily     → (1 + r/365)^(365/12) − 1
 * monthly   → r / 12
 * quarterly → (1 + r/4)^(1/3) − 1
 * annual    → (1 + r)^(1/12) − 1
 */
export function effectiveMonthlyRate(apr: number, compound: CompoundFrequency): number {
  if (apr === 0) return 0;
  switch (compound) {
    case 'daily':
      return Math.pow(1 + apr / 365, 365 / 12) - 1;
    case 'monthly':
      return apr / 12;
    case 'quarterly':
      return Math.pow(1 + apr / 4, 1 / 3) - 1;
    case 'annual':
      return Math.pow(1 + apr, 1 / 12) - 1;
  }
}

/**
 * Convert a periodic contribution to its effective monthly equivalent.
 *
 * weekly  → contribution × 52 / 12  (average weeks per month)
 * monthly → contribution
 * annual  → contribution / 12
 */
export function effectiveMonthlyContribution(
  contribution: number,
  frequency: ContributionFrequency,
): number {
  switch (frequency) {
    case 'weekly':
      return (contribution * 52) / 12;
    case 'monthly':
      return contribution;
    case 'annual':
      return contribution / 12;
  }
}

// ─── Core simulation ───────────────────────────────────────────────────────────

/**
 * Run the full month-by-month compound growth simulation.
 *
 * Timing convention:
 *  'start' — contribution is added before interest accrues → earns a full month of interest.
 *  'end'   — interest accrues on the existing balance first, then contribution is added.
 *
 * Rounding: none — every value is kept at full double precision.
 */
export function calculate(inputs: CalcInputs): CalcResult {
  const {
    principal,
    contribution,
    contributionFrequency,
    apr,
    compoundFrequency,
    years,
    months: additionalMonths,
    timing,
  } = inputs;

  const totalMonths = years * 12 + additionalMonths;
  const monthlyRate = effectiveMonthlyRate(apr, compoundFrequency);
  const monthlyContrib = effectiveMonthlyContribution(contribution, contributionFrequency);

  const monthlyBreakdown: MonthlyBreakdown[] = [];
  let balance = principal;
  let cumulativeContributions = 0;
  let cumulativeInterest = 0;

  for (let m = 1; m <= totalMonths; m++) {
    const startingBalance = balance;
    let periodContrib: number;
    let periodInterest: number;

    if (timing === 'start') {
      // Contribution earns a full period of interest
      balance += monthlyContrib;
      periodContrib = monthlyContrib;
      periodInterest = balance * monthlyRate;
      balance += periodInterest;
    } else {
      // Interest applied to current balance, then contribution added
      periodInterest = balance * monthlyRate;
      balance += periodInterest;
      periodContrib = monthlyContrib;
      balance += monthlyContrib;
    }

    cumulativeContributions += periodContrib;
    cumulativeInterest += periodInterest;

    monthlyBreakdown.push({
      period: m,
      year: Math.ceil(m / 12),
      month: ((m - 1) % 12) + 1,
      startingBalance,
      contributions: periodContrib,
      interest: periodInterest,
      endingBalance: balance,
      cumulativeContributions,
      cumulativeInterest,
    });
  }

  // ── Aggregate into yearly rows ──────────────────────────────────────────────
  const yearlyBreakdown: YearlyBreakdown[] = [];
  const maxYear = monthlyBreakdown.length > 0
    ? monthlyBreakdown[monthlyBreakdown.length - 1].year
    : 0;

  for (let y = 1; y <= maxYear; y++) {
    const rows = monthlyBreakdown.filter((r) => r.year === y);
    if (rows.length === 0) continue;

    yearlyBreakdown.push({
      year: y,
      startingBalance: rows[0].startingBalance,
      contributions: rows.reduce((s, r) => s + r.contributions, 0),
      interest: rows.reduce((s, r) => s + r.interest, 0),
      endingBalance: rows[rows.length - 1].endingBalance,
      cumulativeContributions: rows[rows.length - 1].cumulativeContributions,
      cumulativeInterest: rows[rows.length - 1].cumulativeInterest,
    });
  }

  return {
    finalBalance: balance,
    totalContributions: cumulativeContributions,
    totalInterest: cumulativeInterest,
    yearlyBreakdown,
    monthlyBreakdown,
  };
}

// ─── Chart data ────────────────────────────────────────────────────────────────

/** Build stacked-area chart data from a completed CalcResult. */
export function buildChartData(inputs: CalcInputs, result: CalcResult): ChartPoint[] {
  const points: ChartPoint[] = [
    { name: 'Start', invested: inputs.principal, interest: 0 },
  ];

  for (const row of result.yearlyBreakdown) {
    points.push({
      name: `Yr ${row.year}`,
      invested: inputs.principal + row.cumulativeContributions,
      interest: row.cumulativeInterest,
    });
  }

  return points;
}

// ─── Validation & parsing ──────────────────────────────────────────────────────

export interface ParseResult {
  isValid: boolean;
  errors: ValidationErrors;
  inputs?: CalcInputs;
}

/** Parse FormState strings → numbers, validate, and return CalcInputs or errors. */
export function parseAndValidate(form: FormState): ParseResult {
  const errors: ValidationErrors = {};

  // ── principal ───────────────────────────────────────────────────────────────
  const principal = parseFloat(form.principal);
  if (form.principal.trim() === '' || isNaN(principal)) {
    errors.principal = 'Enter a valid initial investment (0 or more).';
  } else if (principal < 0) {
    errors.principal = 'Initial investment cannot be negative.';
  } else if (principal > 1_000_000_000) {
    errors.principal = 'Value exceeds the maximum of £1,000,000,000.';
  }

  // ── contribution ────────────────────────────────────────────────────────────
  const contribution = parseFloat(form.contribution);
  if (form.contribution.trim() === '' || isNaN(contribution)) {
    errors.contribution = 'Enter a valid contribution amount (0 or more).';
  } else if (contribution < 0) {
    errors.contribution = 'Contribution cannot be negative.';
  } else if (contribution > 1_000_000_000) {
    errors.contribution = 'Value exceeds the maximum of £1,000,000,000.';
  }

  if (!errors.principal && !errors.contribution && principal === 0 && contribution === 0) {
    errors.principal =
      'At least one of initial investment or regular contribution must be greater than zero.';
  }

  // ── APR ─────────────────────────────────────────────────────────────────────
  const aprPct = parseFloat(form.apr);
  if (form.apr.trim() === '' || isNaN(aprPct)) {
    errors.apr = 'Enter a valid interest rate (e.g. 5 for 5%).';
  } else if (aprPct < 0) {
    errors.apr = 'Interest rate cannot be negative.';
  } else if (aprPct > 999) {
    errors.apr = 'Interest rate must be 999% or less.';
  }

  // ── years ───────────────────────────────────────────────────────────────────
  const yearsRaw = Number(form.years.trim());
  if (
    form.years.trim() === ''
    || !Number.isFinite(yearsRaw)
    || !Number.isInteger(yearsRaw)
  ) {
    errors.years = 'Enter a whole number of years.';
  } else if (yearsRaw < 0) {
    errors.years = 'Years cannot be negative.';
  }

  // ── months ──────────────────────────────────────────────────────────────────
  const monthsRaw = form.months.trim() === '' ? 0 : Number(form.months.trim());
  if (
    !Number.isFinite(monthsRaw)
    || !Number.isInteger(monthsRaw)
    || monthsRaw < 0
    || monthsRaw > 11
  ) {
    errors.months = 'Additional months must be 0–11.';
  }

  // ── duration ────────────────────────────────────────────────────────────────
  if (!errors.years && !errors.months) {
    const totalMonths = (isNaN(yearsRaw) ? 0 : yearsRaw) * 12 + (isNaN(monthsRaw) ? 0 : monthsRaw);
    if (totalMonths === 0) {
      errors.duration = 'Duration must be at least 1 month.';
    } else if (totalMonths > 720) {
      errors.duration = 'Maximum duration is 60 years (720 months).';
    }
  }

  if (Object.keys(errors).length > 0) {
    return { isValid: false, errors };
  }

  return {
    isValid: true,
    errors: {},
    inputs: {
      principal,
      contribution,
      contributionFrequency: form.contributionFrequency,
      apr: aprPct / 100,
      compoundFrequency: form.compoundFrequency,
      years: yearsRaw,
      months: monthsRaw,
      timing: form.timing,
    },
  };
}

// ─── Form ↔ Scenario helpers ───────────────────────────────────────────────────

export const DEFAULT_FORM: FormState = {
  principal: '10000',
  contribution: '200',
  contributionFrequency: 'monthly',
  apr: '5',
  compoundFrequency: 'monthly',
  years: '10',
  months: '0',
  timing: 'end',
};

export function inputsToForm(inputs: CalcInputs): FormState {
  return {
    principal: String(inputs.principal),
    contribution: String(inputs.contribution),
    contributionFrequency: inputs.contributionFrequency,
    apr: String(inputs.apr * 100),
    compoundFrequency: inputs.compoundFrequency,
    years: String(inputs.years),
    months: String(inputs.months),
    timing: inputs.timing,
  };
}
