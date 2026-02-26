import { describe, it, expect } from 'vitest';
import {
  calculate,
  effectiveMonthlyRate,
  effectiveMonthlyContribution,
  parseAndValidate,
  DEFAULT_FORM,
} from './calc';

// ─── effectiveMonthlyRate ──────────────────────────────────────────────────────

describe('effectiveMonthlyRate', () => {
  it('returns 0 when APR is 0', () => {
    expect(effectiveMonthlyRate(0, 'monthly')).toBe(0);
    expect(effectiveMonthlyRate(0, 'daily')).toBe(0);
  });

  it('monthly: APR/12', () => {
    expect(effectiveMonthlyRate(0.12, 'monthly')).toBeCloseTo(0.01, 10);
  });

  it('annual rate compounds to APR over 12 months', () => {
    const r = effectiveMonthlyRate(0.12, 'annual');
    const annualised = Math.pow(1 + r, 12) - 1;
    expect(annualised).toBeCloseTo(0.12, 10);
  });

  it('quarterly rate compounds to APR over 4 quarters', () => {
    const r = effectiveMonthlyRate(0.12, 'quarterly');
    // 3 monthly periods = 1 quarter
    const quarterRate = Math.pow(1 + r, 3) - 1;
    expect(quarterRate).toBeCloseTo(0.12 / 4, 10);
  });

  it('daily rate compounds to APR over 365 days', () => {
    const r = effectiveMonthlyRate(0.12, 'daily');
    // 365/12 ≈ 30.4167 days per month
    const dailyRate = 0.12 / 365;
    const expected = Math.pow(1 + dailyRate, 365 / 12) - 1;
    expect(r).toBeCloseTo(expected, 10);
  });
});

// ─── effectiveMonthlyContribution ─────────────────────────────────────────────

describe('effectiveMonthlyContribution', () => {
  it('monthly passes through', () => {
    expect(effectiveMonthlyContribution(100, 'monthly')).toBe(100);
  });

  it('weekly: × 52 / 12', () => {
    expect(effectiveMonthlyContribution(100, 'weekly')).toBeCloseTo((100 * 52) / 12, 10);
  });

  it('annual: / 12', () => {
    expect(effectiveMonthlyContribution(1200, 'annual')).toBeCloseTo(100, 10);
  });
});

// ─── calculate ────────────────────────────────────────────────────────────────

describe('calculate', () => {
  it('0% APR: outcome is independent of compounding and contribution timing', () => {
    const base = {
      principal: 2500,
      contribution: 75,
      contributionFrequency: 'weekly' as const,
      apr: 0,
      years: 1,
      months: 6,
    };
    const expectedFinal =
      base.principal
      + effectiveMonthlyContribution(base.contribution, base.contributionFrequency) * 18;

    const monthlyEnd = calculate({
      ...base,
      compoundFrequency: 'monthly',
      timing: 'end',
    });
    const dailyStart = calculate({
      ...base,
      compoundFrequency: 'daily',
      timing: 'start',
    });

    expect(monthlyEnd.finalBalance).toBeCloseTo(expectedFinal, 10);
    expect(dailyStart.finalBalance).toBeCloseTo(expectedFinal, 10);
    expect(monthlyEnd.totalInterest).toBe(0);
    expect(dailyStart.totalInterest).toBe(0);
  });

  it('zero APR, no contribution: balance stays flat', () => {
    const result = calculate({
      principal: 1000,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0,
      compoundFrequency: 'monthly',
      years: 5,
      months: 0,
      timing: 'end',
    });
    expect(result.finalBalance).toBeCloseTo(1000, 6);
    expect(result.totalInterest).toBeCloseTo(0, 6);
    expect(result.totalContributions).toBeCloseTo(0, 6);
  });

  it('inflation=0 keeps real outputs equal to nominal outputs', () => {
    const result = calculate({
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly',
      apr: 0.05,
      inflationRate: 0,
      compoundFrequency: 'monthly',
      years: 10,
      months: 6,
      timing: 'end',
    });

    expect(result.finalBalanceReal).toBeCloseTo(result.finalBalance, 12);
    expect(result.totalContributionsReal).toBeCloseTo(result.totalContributions, 12);
    expect(result.totalInterestReal).toBeCloseTo(result.totalInterest, 12);
    for (const row of result.yearlyBreakdown) {
      expect(row.realEndingBalance).toBeCloseTo(row.endingBalance, 12);
      expect(row.realCumulativeContributions).toBeCloseTo(row.cumulativeContributions, 12);
      expect(row.realCumulativeInterest).toBeCloseTo(row.cumulativeInterest, 12);
    }
  });

  it('with inflation > 0, real final balance is lower than nominal final balance', () => {
    const result = calculate({
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly',
      apr: 0.06,
      inflationRate: 0.025,
      compoundFrequency: 'monthly',
      years: 20,
      months: 0,
      timing: 'end',
    });

    expect(result.finalBalance).toBeGreaterThan(0);
    expect(result.finalBalanceReal).toBeLessThan(result.finalBalance);
  });

  it('applies partial-year inflation discount using years + months/12', () => {
    const result = calculate({
      principal: 1200,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0,
      inflationRate: 0.04,
      compoundFrequency: 'monthly',
      years: 2,
      months: 6,
      timing: 'end',
    });

    const t = 2 + 6 / 12;
    const discount = Math.pow(1 + 0.04, t);
    const expectedRealFinal = 1200 / discount;
    expect(result.finalBalance).toBeCloseTo(1200, 12);
    expect(result.finalBalanceReal).toBeCloseTo(expectedRealFinal, 12);
    expect(result.yearlyBreakdown[result.yearlyBreakdown.length - 1].realEndingBalance)
      .toBeCloseTo(expectedRealFinal, 12);
  });

  it('no principal, monthly contributions, 0% APR: balance = contributions total', () => {
    const result = calculate({
      principal: 0,
      contribution: 100,
      contributionFrequency: 'monthly',
      apr: 0,
      compoundFrequency: 'monthly',
      years: 1,
      months: 0,
      timing: 'end',
    });
    expect(result.totalContributions).toBeCloseTo(1200, 6);
    expect(result.finalBalance).toBeCloseTo(1200, 6);
    expect(result.totalInterest).toBeCloseTo(0, 6);
  });

  it('basic 1-year monthly compound interest on principal only', () => {
    // £1000 at 12% APR monthly compounded for 1 year = 1000 * 1.01^12
    const expected = 1000 * Math.pow(1.01, 12);
    const result = calculate({
      principal: 1000,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0.12,
      compoundFrequency: 'monthly',
      years: 1,
      months: 0,
      timing: 'end',
    });
    expect(result.finalBalance).toBeCloseTo(expected, 4);
    expect(result.totalInterest).toBeCloseTo(expected - 1000, 4);
  });

  it('0 contributions: start/end timing is identical', () => {
    const base = {
      principal: 5000,
      contribution: 0,
      contributionFrequency: 'monthly' as const,
      apr: 0.08,
      compoundFrequency: 'monthly' as const,
      years: 25,
      months: 0,
    };
    const end = calculate({ ...base, timing: 'end' });
    const start = calculate({ ...base, timing: 'start' });

    expect(start.finalBalance).toBeCloseTo(end.finalBalance, 12);
    expect(start.totalInterest).toBeCloseTo(end.totalInterest, 12);
    expect(start.totalContributions).toBe(0);
    expect(end.totalContributions).toBe(0);
  });

  it('start-of-period yields more interest than end-of-period', () => {
    const base = {
      principal: 0,
      contribution: 100,
      contributionFrequency: 'monthly' as const,
      apr: 0.06,
      compoundFrequency: 'monthly' as const,
      years: 5,
      months: 0,
    };
    const end = calculate({ ...base, timing: 'end' });
    const start = calculate({ ...base, timing: 'start' });
    expect(start.finalBalance).toBeGreaterThan(end.finalBalance);
  });

  it('contribution timing start vs end matches one-month closed form', () => {
    const r = 0.12 / 12;
    const end = calculate({
      principal: 1000,
      contribution: 100,
      contributionFrequency: 'monthly',
      apr: 0.12,
      compoundFrequency: 'monthly',
      years: 0,
      months: 1,
      timing: 'end',
    });
    const start = calculate({
      principal: 1000,
      contribution: 100,
      contributionFrequency: 'monthly',
      apr: 0.12,
      compoundFrequency: 'monthly',
      years: 0,
      months: 1,
      timing: 'start',
    });

    const expectedEnd = 1000 * (1 + r) + 100;
    const expectedStart = (1000 + 100) * (1 + r);
    expect(end.finalBalance).toBeCloseTo(expectedEnd, 12);
    expect(start.finalBalance).toBeCloseTo(expectedStart, 12);
    expect(start.finalBalance - end.finalBalance).toBeCloseTo(100 * r, 12);
  });

  it('weekly contributions with monthly compounding match annuity formula', () => {
    const months = 24;
    const r = 0.06 / 12;
    const c = (100 * 52) / 12;
    const expected = c * ((Math.pow(1 + r, months) - 1) / r);

    const result = calculate({
      principal: 0,
      contribution: 100,
      contributionFrequency: 'weekly',
      apr: 0.06,
      compoundFrequency: 'monthly',
      years: 2,
      months: 0,
      timing: 'end',
    });

    expect(result.finalBalance).toBeCloseTo(expected, 8);
    expect(result.totalContributions).toBeCloseTo(c * months, 10);
  });

  it('yearlyBreakdown has correct number of rows for full years', () => {
    const result = calculate({
      principal: 1000,
      contribution: 100,
      contributionFrequency: 'monthly',
      apr: 0.05,
      compoundFrequency: 'monthly',
      years: 3,
      months: 0,
      timing: 'end',
    });
    expect(result.yearlyBreakdown.length).toBe(3);
  });

  it('additional months produce a partial year row', () => {
    const result = calculate({
      principal: 1000,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0.05,
      compoundFrequency: 'monthly',
      years: 2,
      months: 6,
      timing: 'end',
    });
    expect(result.monthlyBreakdown.length).toBe(30);
    expect(result.yearlyBreakdown.length).toBe(3); // year 3 = 6 months
    expect(result.yearlyBreakdown[2].year).toBe(3);
  });

  it('finalBalance = principal + totalContributions + totalInterest', () => {
    const result = calculate({
      principal: 5000,
      contribution: 150,
      contributionFrequency: 'monthly',
      apr: 0.07,
      compoundFrequency: 'monthly',
      years: 10,
      months: 0,
      timing: 'end',
    });
    const expected = 5000 + result.totalContributions + result.totalInterest;
    expect(result.finalBalance).toBeCloseTo(expected, 6);
  });

  it('monthly compounding yields more than annual compounding for the same APR', () => {
    // Monthly compounding: effective annual ≈ (1 + 0.05/12)^12 ≈ 5.116%
    // Annual  compounding: effective annual = exactly 5.000%
    // So monthly should produce a strictly higher final balance.
    const base = {
      principal: 10000,
      contribution: 0,
      contributionFrequency: 'monthly' as const,
      apr: 0.05,
      years: 10,
      months: 0,
      timing: 'end' as const,
    };
    const monthly = calculate({ ...base, compoundFrequency: 'monthly' });
    const annual  = calculate({ ...base, compoundFrequency: 'annual'  });
    expect(monthly.finalBalance).toBeGreaterThan(annual.finalBalance);
    // Sanity: annual result matches classical formula P*(1+r)^n
    expect(annual.finalBalance).toBeCloseTo(10000 * Math.pow(1.05, 10), 2);
  });

  it('keeps full precision internally (no per-period cent rounding)', () => {
    const repeating = calculate({
      principal: 0,
      contribution: 100,
      contributionFrequency: 'weekly',
      apr: 0,
      compoundFrequency: 'monthly',
      years: 1,
      months: 0,
      timing: 'end',
    });
    const tinyInterest = calculate({
      principal: 1,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0.01,
      compoundFrequency: 'monthly',
      years: 0,
      months: 1,
      timing: 'end',
    });

    const monthlyWeekly = (100 * 52) / 12;
    expect(repeating.monthlyBreakdown[0].contributions).toBeCloseTo(monthlyWeekly, 12);
    expect(repeating.totalContributions).toBeCloseTo(5200, 10);
    expect(Math.abs(repeating.monthlyBreakdown[0].contributions - Number(monthlyWeekly.toFixed(2))))
      .toBeGreaterThan(0.001);

    expect(tinyInterest.monthlyBreakdown[0].interest).toBeCloseTo(1 * (0.01 / 12), 12);
    expect(tinyInterest.monthlyBreakdown[0].interest).toBeGreaterThan(0);
  });

  it('remains numerically stable over very long durations (50 years)', () => {
    const result = calculate({
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly',
      apr: 0.07,
      compoundFrequency: 'monthly',
      years: 50,
      months: 0,
      timing: 'end',
    });

    expect(result.monthlyBreakdown.length).toBe(600);
    expect(result.yearlyBreakdown.length).toBe(50);
    expect(Number.isFinite(result.finalBalance)).toBe(true);
    expect(result.monthlyBreakdown.every((row) => Number.isFinite(row.endingBalance))).toBe(true);
    expect(result.monthlyBreakdown.every((row) => Number.isFinite(row.interest))).toBe(true);
    expect(result.finalBalance).toBeCloseTo(
      10000 + result.totalContributions + result.totalInterest,
      6,
    );
  });

  it('remains numerically stable over very long durations with inflation-adjusted outputs', () => {
    const result = calculate({
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly',
      apr: 0.07,
      inflationRate: 0.03,
      compoundFrequency: 'monthly',
      years: 50,
      months: 0,
      timing: 'end',
    });

    expect(Number.isFinite(result.finalBalanceReal)).toBe(true);
    expect(Number.isFinite(result.totalContributionsReal)).toBe(true);
    expect(Number.isFinite(result.totalInterestReal)).toBe(true);
    expect(result.yearlyBreakdown.every((row) => Number.isFinite(row.realEndingBalance))).toBe(true);
    expect(
      result.yearlyBreakdown.every((row) => Number.isFinite(row.realCumulativeContributions)),
    ).toBe(true);
    expect(result.yearlyBreakdown.every((row) => Number.isFinite(row.realCumulativeInterest))).toBe(true);
    expect(result.finalBalanceReal).toBeLessThan(result.finalBalance);
  });
});

// ─── parseAndValidate ─────────────────────────────────────────────────────────

describe('parseAndValidate', () => {
  it('validates the default form without errors', () => {
    const result = parseAndValidate(DEFAULT_FORM);
    expect(result.isValid).toBe(true);
    expect(Object.keys(result.errors)).toHaveLength(0);
  });

  it('rejects empty principal', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, principal: '' });
    expect(result.isValid).toBe(false);
    expect(result.errors.principal).toBeTruthy();
  });

  it('rejects negative APR', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, apr: '-1' });
    expect(result.isValid).toBe(false);
    expect(result.errors.apr).toBeTruthy();
  });

  it('accepts missing inflation input and defaults to 0', () => {
    const { inflationPercent: _ignored, ...withoutInflation } = DEFAULT_FORM;
    const result = parseAndValidate(withoutInflation);
    expect(result.isValid).toBe(true);
    expect(result.inputs?.inflationRate).toBe(0);
  });

  it('rejects negative inflation', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, inflationPercent: '-0.5' });
    expect(result.isValid).toBe(false);
    expect(result.errors.inflationPercent).toBeTruthy();
  });

  it('rejects inflation above maximum bound', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, inflationPercent: '25' });
    expect(result.isValid).toBe(false);
    expect(result.errors.inflationPercent).toBeTruthy();
  });

  it('rejects zero duration', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, years: '0', months: '0' });
    expect(result.isValid).toBe(false);
    expect(result.errors.duration).toBeTruthy();
  });

  it('rejects duration > 60 years', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, years: '61', months: '0' });
    expect(result.isValid).toBe(false);
    expect(result.errors.duration).toBeTruthy();
  });

  it('rejects non-integer years', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, years: '1.5' });
    expect(result.isValid).toBe(false);
    expect(result.errors.years).toBeTruthy();
  });

  it('rejects non-integer months', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, months: '2.5' });
    expect(result.isValid).toBe(false);
    expect(result.errors.months).toBeTruthy();
  });

  it('converts APR percent to decimal correctly', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, apr: '7.5' });
    expect(result.isValid).toBe(true);
    expect(result.inputs?.apr).toBeCloseTo(0.075, 10);
  });

  it('converts inflation percent to decimal correctly', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, inflationPercent: '2.5' });
    expect(result.isValid).toBe(true);
    expect(result.inputs?.inflationRate).toBeCloseTo(0.025, 10);
  });
});
