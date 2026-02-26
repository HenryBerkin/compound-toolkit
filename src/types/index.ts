// ─── Domain types ─────────────────────────────────────────────────────────────

export type CompoundFrequency = 'daily' | 'monthly' | 'quarterly' | 'annual';
export type ContributionFrequency = 'weekly' | 'monthly' | 'annual';
export type ContributionTiming = 'start' | 'end';

/** Fully-typed, validated inputs to the calculation engine. APR is a decimal (0.05 = 5%). */
export interface CalcInputs {
  principal: number;
  contribution: number;
  contributionFrequency: ContributionFrequency;
  /** Decimal — 0.05 = 5% */
  apr: number;
  /** Optional decimal inflation rate — 0.02 = 2% */
  inflationRate?: number;
  compoundFrequency: CompoundFrequency;
  years: number;
  /** 0–11 additional months */
  months: number;
  timing: ContributionTiming;
}

// ─── Result types ──────────────────────────────────────────────────────────────

export interface MonthlyBreakdown {
  /** Sequential month number from 1 */
  period: number;
  /** Year number from 1 */
  year: number;
  /** Month within the year (1–12) */
  month: number;
  startingBalance: number;
  contributions: number;
  interest: number;
  endingBalance: number;
  cumulativeContributions: number;
  cumulativeInterest: number;
}

export interface YearlyBreakdown {
  year: number;
  startingBalance: number;
  contributions: number;
  interest: number;
  endingBalance: number;
  cumulativeContributions: number;
  cumulativeInterest: number;
  /** Inflation-adjusted ending balance at this row end date */
  realEndingBalance: number;
  /** Inflation-adjusted cumulative contributions at this row end date */
  realCumulativeContributions: number;
  /** Inflation-adjusted cumulative interest at this row end date */
  realCumulativeInterest: number;
}

export interface CalcResult {
  finalBalance: number;
  totalContributions: number;
  totalInterest: number;
  finalBalanceReal: number;
  totalContributionsReal: number;
  totalInterestReal: number;
  yearlyBreakdown: YearlyBreakdown[];
  monthlyBreakdown: MonthlyBreakdown[];
}

// ─── Chart ────────────────────────────────────────────────────────────────────

export interface ChartPoint {
  name: string;
  /** principal + cumulative contributions */
  invested: number;
  /** cumulative interest earned */
  interest: number;
}

// ─── Scenarios ────────────────────────────────────────────────────────────────

export interface Scenario {
  id: string;
  name: string;
  inputs: CalcInputs;
  createdAt: string;
  updatedAt: string;
}

// ─── Form ─────────────────────────────────────────────────────────────────────

/** String-based form state so HTML inputs can be uncontrolled-friendly. */
export interface FormState {
  principal: string;
  contribution: string;
  contributionFrequency: ContributionFrequency;
  apr: string;
  inflationPercent?: string;
  compoundFrequency: CompoundFrequency;
  years: string;
  months: string;
  timing: ContributionTiming;
}

export type ValidationErrors = Partial<Record<keyof FormState | 'duration', string>>;
