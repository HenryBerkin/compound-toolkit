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

  it('annual fee = 0 behaves identically to the no-fee model', () => {
    const base = {
      principal: 10000,
      contribution: 250,
      contributionFrequency: 'monthly' as const,
      apr: 0.07,
      compoundFrequency: 'monthly' as const,
      years: 15,
      months: 3,
      timing: 'end' as const,
    };
    const noFee = calculate(base);
    const explicitZeroFee = calculate({ ...base, annualFeeRate: 0 });

    expect(explicitZeroFee.finalBalance).toBeCloseTo(noFee.finalBalance, 12);
    expect(explicitZeroFee.totalContributions).toBeCloseTo(noFee.totalContributions, 12);
    expect(explicitZeroFee.totalInterest).toBeCloseTo(noFee.totalInterest, 12);
    expect(explicitZeroFee.finalBalanceAfterFees).toBeCloseTo(noFee.finalBalance, 8);
    expect(explicitZeroFee.totalFeesPaidNominal).toBeCloseTo(0, 12);
    expect(explicitZeroFee.finalBalanceAfterFeesReal).toBeCloseTo(noFee.finalBalanceReal, 8);
    expect(explicitZeroFee.totalFeesPaidReal).toBeCloseTo(0, 12);
    expect(explicitZeroFee.yearlyBreakdown.every((row) => row.yearlyFeesPaid === 0)).toBe(true);
    expect(explicitZeroFee.yearlyBreakdown.every((row) => row.cumulativeFeesPaid === 0)).toBe(true);
    expect(
      explicitZeroFee.yearlyBreakdown.every(
        (row) => Math.abs(row.endingBalanceAfterFees - row.endingBalance) < 1e-8,
      ),
    ).toBe(true);
  });

  it('with annual fee > 0, final balance after fees is lower than nominal balance', () => {
    const result = calculate({
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly',
      apr: 0.06,
      annualFeeRate: 0.01,
      compoundFrequency: 'monthly',
      years: 20,
      months: 0,
      timing: 'end',
    });

    expect(result.totalFeesPaidNominal).toBeGreaterThan(0);
    expect(result.finalBalanceAfterFees).toBeLessThan(result.finalBalance);
  });

  it('totalFeesPaidNominal and yearly cumulative fees increase over time', () => {
    const result = calculate({
      principal: 50000,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0.05,
      annualFeeRate: 0.01,
      compoundFrequency: 'monthly',
      years: 10,
      months: 0,
      timing: 'end',
    });

    expect(result.totalFeesPaidNominal).toBeGreaterThan(0);
    for (let i = 1; i < result.yearlyBreakdown.length; i++) {
      expect(result.yearlyBreakdown[i].cumulativeFeesPaid)
        .toBeGreaterThanOrEqual(result.yearlyBreakdown[i - 1].cumulativeFeesPaid);
    }
    expect(
      result.yearlyBreakdown[result.yearlyBreakdown.length - 1].cumulativeFeesPaid,
    ).toBeCloseTo(result.totalFeesPaidNominal, 8);
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

  it('inflation + fee yields lower real after-fee balance than inflation-only case', () => {
    const base = {
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly' as const,
      apr: 0.06,
      inflationRate: 0.025,
      compoundFrequency: 'monthly' as const,
      years: 25,
      months: 0,
      timing: 'end' as const,
    };
    const inflationOnly = calculate(base);
    const inflationAndFee = calculate({ ...base, annualFeeRate: 0.01 });

    expect(inflationAndFee.finalBalanceAfterFeesReal)
      .toBeLessThan(inflationOnly.finalBalanceAfterFeesReal);
    expect(inflationAndFee.totalFeesPaidReal).toBeGreaterThan(0);
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

  it('remains numerically stable over very long durations with fee drag', () => {
    const result = calculate({
      principal: 10000,
      contribution: 200,
      contributionFrequency: 'monthly',
      apr: 0.07,
      annualFeeRate: 0.01,
      inflationRate: 0.03,
      compoundFrequency: 'monthly',
      years: 50,
      months: 0,
      timing: 'end',
    });

    expect(Number.isFinite(result.finalBalanceAfterFees)).toBe(true);
    expect(Number.isFinite(result.totalFeesPaidNominal)).toBe(true);
    expect(Number.isFinite(result.finalBalanceAfterFeesReal)).toBe(true);
    expect(Number.isFinite(result.totalFeesPaidReal)).toBe(true);
    expect(result.yearlyBreakdown.every((row) => Number.isFinite(row.endingBalanceAfterFees))).toBe(true);
    expect(result.yearlyBreakdown.every((row) => Number.isFinite(row.cumulativeFeesPaid))).toBe(true);
    expect(result.finalBalanceAfterFees).toBeLessThan(result.finalBalance);
  });

  it('advisor-grade accounting identities hold across nominal, fee, and real outputs', () => {
    const inputs = {
      principal: 12500,
      contribution: 275,
      contributionFrequency: 'weekly' as const,
      apr: 0.072,
      annualFeeRate: 0.006,
      inflationRate: 0.028,
      compoundFrequency: 'quarterly' as const,
      years: 17,
      months: 5,
      timing: 'start' as const,
    };
    const result = calculate(inputs);
    const totalYears = inputs.years + inputs.months / 12;
    const discount = Math.pow(1 + (inputs.inflationRate ?? 0), totalYears);

    // Nominal identity
    expect(result.finalBalance).toBeCloseTo(
      inputs.principal + result.totalContributions + result.totalInterest,
      8,
    );

    // Fee-path reconciliation: final after-fees decomposes into principal,
    // contributions, and net growth after fees.
    const netGrowthAfterFees =
      result.finalBalanceAfterFees - inputs.principal - result.totalContributions;
    expect(result.finalBalanceAfterFees).toBeCloseTo(
      inputs.principal + result.totalContributions + netGrowthAfterFees,
      8,
    );

    // Real outputs are horizon-discounted versions of nominal outputs.
    expect(result.finalBalanceReal).toBeCloseTo(result.finalBalance / discount, 12);
    expect(result.totalContributionsReal).toBeCloseTo(result.totalContributions / discount, 12);
    expect(result.totalInterestReal).toBeCloseTo(result.totalInterest / discount, 12);
    expect(result.totalFeesPaidReal).toBeCloseTo(result.totalFeesPaidNominal / discount, 12);
    expect(result.finalBalanceAfterFeesReal).toBeCloseTo(result.finalBalanceAfterFees / discount, 12);

    // Real identity with discounted principal term.
    expect(result.finalBalanceReal).toBeCloseTo(
      inputs.principal / discount + result.totalContributionsReal + result.totalInterestReal,
      8,
    );

    // Fee drag in real terms is consistent with nominal fee drag after discounting.
    expect(result.finalBalanceReal - result.finalBalanceAfterFeesReal).toBeCloseTo(
      (result.finalBalance - result.finalBalanceAfterFees) / discount,
      8,
    );
  });

  it('enforces ordering invariants for fee and inflation drag', () => {
    const result = calculate({
      principal: 20000,
      contribution: 300,
      contributionFrequency: 'monthly',
      apr: 0.065,
      annualFeeRate: 0.01,
      inflationRate: 0.03,
      compoundFrequency: 'monthly',
      years: 20,
      months: 0,
      timing: 'end',
    });

    expect(result.finalBalanceAfterFees).toBeLessThan(result.finalBalance);
    expect(result.finalBalanceReal).toBeLessThan(result.finalBalance);
    expect(result.finalBalanceAfterFeesReal).toBeLessThan(result.finalBalanceReal);
    expect(result.finalBalanceAfterFeesReal).toBeLessThan(result.finalBalanceAfterFees);

    for (const row of result.yearlyBreakdown) {
      expect(row.endingBalanceAfterFees).toBeLessThanOrEqual(row.endingBalance);
      expect(row.realEndingBalance).toBeLessThanOrEqual(row.endingBalance);
    }
  });

  it('is monotonic in APR for non-negative rates', () => {
    const base = {
      principal: 15000,
      contribution: 250,
      contributionFrequency: 'monthly' as const,
      compoundFrequency: 'monthly' as const,
      years: 25,
      months: 0,
      timing: 'end' as const,
    };
    const lowApr = calculate({ ...base, apr: 0.03 });
    const highApr = calculate({ ...base, apr: 0.08 });

    expect(highApr.finalBalance).toBeGreaterThan(lowApr.finalBalance);
    expect(highApr.finalBalanceAfterFees).toBeGreaterThan(lowApr.finalBalanceAfterFees);
  });

  it('is monotonic in annual fee drag while nominal path stays unchanged', () => {
    const base = {
      principal: 15000,
      contribution: 250,
      contributionFrequency: 'monthly' as const,
      apr: 0.07,
      inflationRate: 0.02,
      compoundFrequency: 'monthly' as const,
      years: 25,
      months: 0,
      timing: 'start' as const,
    };
    const lowFee = calculate({ ...base, annualFeeRate: 0.002 });
    const highFee = calculate({ ...base, annualFeeRate: 0.015 });

    // Fee drag should not alter the nominal no-fee projection path.
    expect(highFee.finalBalance).toBeCloseTo(lowFee.finalBalance, 12);
    expect(highFee.finalBalanceAfterFees).toBeLessThan(lowFee.finalBalanceAfterFees);
    expect(highFee.totalFeesPaidNominal).toBeGreaterThan(lowFee.totalFeesPaidNominal);
  });

  it('is monotonic in inflation for real outputs while nominal stays unchanged', () => {
    const base = {
      principal: 15000,
      contribution: 250,
      contributionFrequency: 'monthly' as const,
      apr: 0.07,
      annualFeeRate: 0.008,
      compoundFrequency: 'monthly' as const,
      years: 25,
      months: 0,
      timing: 'start' as const,
    };
    const lowInflation = calculate({ ...base, inflationRate: 0.01 });
    const highInflation = calculate({ ...base, inflationRate: 0.04 });

    expect(highInflation.finalBalance).toBeCloseTo(lowInflation.finalBalance, 12);
    expect(highInflation.finalBalanceAfterFees).toBeCloseTo(lowInflation.finalBalanceAfterFees, 12);
    expect(highInflation.finalBalanceReal).toBeLessThan(lowInflation.finalBalanceReal);
    expect(highInflation.finalBalanceAfterFeesReal).toBeLessThan(lowInflation.finalBalanceAfterFeesReal);
  });

  it('max duration boundary (60 years) remains finite and structurally consistent', () => {
    const result = calculate({
      principal: 20000,
      contribution: 300,
      contributionFrequency: 'monthly',
      apr: 0.06,
      annualFeeRate: 0.01,
      inflationRate: 0.03,
      compoundFrequency: 'monthly',
      years: 60,
      months: 0,
      timing: 'end',
    });

    expect(result.monthlyBreakdown.length).toBe(720);
    expect(result.yearlyBreakdown.length).toBe(60);
    expect(Number.isFinite(result.finalBalance)).toBe(true);
    expect(Number.isFinite(result.finalBalanceAfterFees)).toBe(true);
    expect(Number.isFinite(result.finalBalanceReal)).toBe(true);
    expect(Number.isFinite(result.finalBalanceAfterFeesReal)).toBe(true);
    expect(result.finalBalanceAfterFees).toBeLessThan(result.finalBalance);
  });

  it('handles all-zero numeric inputs without NaN/inf and keeps identities intact', () => {
    const result = calculate({
      principal: 0,
      contribution: 0,
      contributionFrequency: 'monthly',
      apr: 0,
      annualFeeRate: 0,
      inflationRate: 0,
      compoundFrequency: 'monthly',
      years: 1,
      months: 0,
      timing: 'end',
    });

    expect(result.finalBalance).toBe(0);
    expect(result.finalBalanceAfterFees).toBe(0);
    expect(result.totalContributions).toBe(0);
    expect(result.totalInterest).toBe(0);
    expect(result.totalFeesPaidNominal).toBe(0);
    expect(result.finalBalanceReal).toBe(0);
    expect(result.finalBalanceAfterFeesReal).toBe(0);
    expect(result.monthlyBreakdown.every((row) => row.endingBalance === 0)).toBe(true);
  });

  it('period indexing and partial-year handling have no off-by-one errors', () => {
    const result = calculate({
      principal: 0,
      contribution: 100,
      contributionFrequency: 'monthly',
      apr: 0,
      annualFeeRate: 0,
      inflationRate: 0,
      compoundFrequency: 'monthly',
      years: 1,
      months: 1,
      timing: 'end',
    });

    expect(result.monthlyBreakdown.length).toBe(13);
    expect(result.yearlyBreakdown.length).toBe(2);

    expect(result.monthlyBreakdown[0]).toMatchObject({ period: 1, year: 1, month: 1 });
    expect(result.monthlyBreakdown[11]).toMatchObject({ period: 12, year: 1, month: 12 });
    expect(result.monthlyBreakdown[12]).toMatchObject({ period: 13, year: 2, month: 1 });

    expect(result.yearlyBreakdown[0].year).toBe(1);
    expect(result.yearlyBreakdown[1].year).toBe(2);
    expect(result.yearlyBreakdown[0].contributions).toBeCloseTo(1200, 12);
    expect(result.yearlyBreakdown[1].contributions).toBeCloseTo(100, 12);
    expect(result.yearlyBreakdown[1].endingBalance).toBeCloseTo(1300, 12);
  });

  it('start timing remains greater than end timing even with fee drag', () => {
    const base = {
      principal: 0,
      contribution: 100,
      contributionFrequency: 'monthly' as const,
      apr: 0.06,
      annualFeeRate: 0.01,
      compoundFrequency: 'monthly' as const,
      years: 10,
      months: 0,
    };
    const end = calculate({ ...base, timing: 'end' });
    const start = calculate({ ...base, timing: 'start' });

    expect(start.finalBalance).toBeGreaterThan(end.finalBalance);
    expect(start.finalBalanceAfterFees).toBeGreaterThan(end.finalBalanceAfterFees);
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

  it('accepts missing annual fee input and defaults to 0', () => {
    const { annualFeePercent: _ignored, ...withoutAnnualFee } = DEFAULT_FORM;
    const result = parseAndValidate(withoutAnnualFee);
    expect(result.isValid).toBe(true);
    expect(result.inputs?.annualFeeRate).toBe(0);
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

  it('rejects negative annual fee', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, annualFeePercent: '-0.1' });
    expect(result.isValid).toBe(false);
    expect(result.errors.annualFeePercent).toBeTruthy();
  });

  it('rejects annual fee above maximum bound', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, annualFeePercent: '12' });
    expect(result.isValid).toBe(false);
    expect(result.errors.annualFeePercent).toBeTruthy();
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

  it('accepts comma-formatted currency inputs', () => {
    const result = parseAndValidate({
      ...DEFAULT_FORM,
      principal: '10,000',
      contribution: '1,250',
    });
    expect(result.isValid).toBe(true);
    expect(result.inputs?.principal).toBeCloseTo(10000, 10);
    expect(result.inputs?.contribution).toBeCloseTo(1250, 10);
  });

  it('accepts space-formatted and decimal currency inputs', () => {
    const result = parseAndValidate({
      ...DEFAULT_FORM,
      principal: '10 000.50',
      contribution: '250.75',
    });
    expect(result.isValid).toBe(true);
    expect(result.inputs?.principal).toBeCloseTo(10000.5, 10);
    expect(result.inputs?.contribution).toBeCloseTo(250.75, 10);
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

  it('converts annual fee percent to decimal correctly', () => {
    const result = parseAndValidate({ ...DEFAULT_FORM, annualFeePercent: '1.25' });
    expect(result.isValid).toBe(true);
    expect(result.inputs?.annualFeeRate).toBeCloseTo(0.0125, 10);
  });
});
