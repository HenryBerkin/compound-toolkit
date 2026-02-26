import type { FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP } from '../lib/format';

interface Props {
  result: CalcResult;
  principal: number;
}

export const ResultsSummary: FC<Props> = ({ result, principal }) => {
  const { finalBalance, totalContributions, totalInterest } = result;
  const totalInvested = principal + totalContributions;
  const growthPct = totalInvested > 0 ? (totalInterest / totalInvested) * 100 : 0;

  return (
    <div className="results-summary">
      <div className="summary-card summary-card--balance">
        <span className="summary-label">Final Balance</span>
        <span className="summary-value">{formatGBP(finalBalance)}</span>
        <span className="summary-sub">after all contributions &amp; interest</span>
      </div>

      <div className="summary-card summary-card--invested">
        <span className="summary-label">Total Invested</span>
        <span className="summary-value">{formatGBP(totalInvested)}</span>
        <span className="summary-sub">
          {formatGBP(principal)} initial + {formatGBP(totalContributions)} contributions
        </span>
      </div>

      <div className="summary-card summary-card--interest">
        <span className="summary-label">Interest Earned</span>
        <span className="summary-value">{formatGBP(totalInterest)}</span>
        <span className="summary-sub">
          {growthPct.toFixed(1)}% growth on invested capital
        </span>
      </div>
    </div>
  );
};
