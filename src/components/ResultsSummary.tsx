import type { FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP } from '../lib/format';

interface Props {
  result: CalcResult;
  inflationRate?: number;
}

export const ResultsSummary: FC<Props> = ({ result, inflationRate = 0 }) => {
  const baseCapital = result.finalBalance - result.totalInterest;
  const rawInterestAfterFees = result.finalBalanceAfterFees - baseCapital;
  const interestAfterFees = Math.abs(rawInterestAfterFees) < 0.005 ? 0 : rawInterestAfterFees;

  const realSubtext = inflationRate > 0
    ? `Inflation-adjusted purchasing power (${(inflationRate * 100).toFixed(2)}% annual inflation).`
    : 'Inflation-adjusted purchasing power.';

  return (
    <div className="results-summary">
      <div className="results-summary-headline">
        <div className="summary-card summary-card--invested">
          <span className="summary-label">Final Balance (After Fees)</span>
          <span className="summary-value">{formatGBP(result.finalBalanceAfterFees)}</span>
          <span className="summary-sub">Before inflation</span>

          <dl className="summary-breakdown" aria-label="Final balance breakdown">
            <div className="summary-breakdown__row">
              <dt>Contributions</dt>
              <dd>{formatGBP(result.totalContributions)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Interest earned (after fees)</dt>
              <dd>{formatGBP(interestAfterFees)}</dd>
            </div>
            <div className="summary-breakdown__row summary-breakdown__row--muted">
              <dt>Before fees</dt>
              <dd>{formatGBP(result.finalBalance)}</dd>
            </div>
          </dl>
        </div>

        <div className="summary-card summary-card--balance">
          <span className="summary-label">In today&apos;s money</span>
          <span className="summary-value">{formatGBP(result.finalBalanceAfterFeesReal)}</span>
          <span className="summary-sub">{realSubtext}</span>
        </div>
      </div>

      <div className="results-summary-fees">
        <div className="summary-card summary-card--interest">
          <span className="summary-label">Total Fees Paid (Nominal)</span>
          <span className="summary-value">{formatGBP(result.totalFeesPaidNominal)}</span>
          <span className="summary-sub">cumulative asset-based fees</span>
        </div>

        <div className="summary-card summary-card--interest">
          <span className="summary-label">Total Fees Paid (Real)</span>
          <span className="summary-value">{formatGBP(result.totalFeesPaidReal)}</span>
          <span className="summary-sub">inflation-adjusted fee total</span>
        </div>
      </div>
    </div>
  );
};
