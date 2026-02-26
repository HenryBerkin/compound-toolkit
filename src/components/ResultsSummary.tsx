import type { FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP } from '../lib/format';

interface Props {
  result: CalcResult;
}

export const ResultsSummary: FC<Props> = ({ result }) => {
  return (
    <div className="results-summary">
      <div className="summary-card summary-card--balance">
        <span className="summary-label">Final Balance (Nominal)</span>
        <span className="summary-value">{formatGBP(result.finalBalance)}</span>
        <span className="summary-sub">before inflation adjustment</span>
      </div>

      <div className="summary-card summary-card--balance">
        <span className="summary-label">Final Balance (Real)</span>
        <span className="summary-value">{formatGBP(result.finalBalanceReal)}</span>
        <span className="summary-sub">inflation-adjusted purchasing power</span>
      </div>

      <div className="summary-card summary-card--invested">
        <span className="summary-label">Final Balance (After Fees)</span>
        <span className="summary-value">{formatGBP(result.finalBalanceAfterFees)}</span>
        <span className="summary-sub">nominal balance after fee drag</span>
      </div>

      <div className="summary-card summary-card--invested">
        <span className="summary-label">Final Balance (Real After Fees)</span>
        <span className="summary-value">{formatGBP(result.finalBalanceAfterFeesReal)}</span>
        <span className="summary-sub">inflation-adjusted after fee drag</span>
      </div>

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
  );
};
