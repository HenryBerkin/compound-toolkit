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

  it('converts APR percent to decimal correctly', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, apr: '7.5' });
    expect(result.isValid).toBe(true);
    expect(result.inputs?.apr).toBeCloseTo(0.075, 10);
  });
});
