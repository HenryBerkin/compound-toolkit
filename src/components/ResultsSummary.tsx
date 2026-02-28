import type { FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP } from '../lib/format';

interface Props {
  result: CalcResult;
  inflationRate?: number;
  targetToday?: number;
  targetYears?: number;
  targetMonths?: number;
}

function formatDuration(years: number, months: number): string {
  if (years > 0 && months > 0) {
    return `${years} year${years === 1 ? '' : 's'} and ${months} month${months === 1 ? '' : 's'}`;
  }
  if (years > 0) {
    return `${years} year${years === 1 ? '' : 's'}`;
  }
  return `${months} month${months === 1 ? '' : 's'}`;
}

export const ResultsSummary: FC<Props> = ({
  result,
  inflationRate = 0,
  targetToday,
  targetYears = 0,
  targetMonths = 0,
}) => {
  const baseCapital = result.finalBalance - result.totalInterest;
  const rawInterestAfterFees = result.finalBalanceAfterFees - baseCapital;
  const interestAfterFees = Math.abs(rawInterestAfterFees) < 0.005 ? 0 : rawInterestAfterFees;
  const inflationLabel = `${(inflationRate * 100).toFixed(2)}%`;
  const totalYears = targetYears + targetMonths / 12;
  const hasTarget = typeof targetToday === 'number' && Number.isFinite(targetToday);
  const requiredFutureNominal = hasTarget
    ? targetToday * Math.pow(1 + inflationRate, totalYears)
    : 0;
  const difference = hasTarget ? result.finalBalanceAfterFees - requiredFutureNominal : 0;
  const absDifference = Math.abs(difference);
  const durationLabel = formatDuration(targetYears, targetMonths);

  return (
    <div className="results-summary">
      <div className="results-summary-headline">
        <div className="summary-card summary-card--invested">
          <span className="summary-label">Final Balance (After Fees)</span>
          <span className="summary-value">{formatGBP(result.finalBalanceAfterFees)}</span>
          <p className="summary-sub summary-sub--context">
            Purchasing power in today&apos;s terms: {formatGBP(result.finalBalanceAfterFeesReal)}
          </p>
          <p className="summary-sub summary-sub--context-note">
            (Assumes {inflationLabel} annual inflation)
          </p>

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

      {hasTarget && (
        <div className="summary-card summary-card--target">
          <span className="summary-label">Target Analysis</span>
          <p className="summary-sub summary-sub--target">
            To equal {formatGBP(targetToday)} today in {durationLabel}, you would need{' '}
            {formatGBP(requiredFutureNominal)}.
          </p>

          <dl className="summary-breakdown" aria-label="Target analysis values">
            <div className="summary-breakdown__row">
              <dt>Required future value (before inflation)</dt>
              <dd>{formatGBP(requiredFutureNominal)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Projected final balance (after fees)</dt>
              <dd>{formatGBP(result.finalBalanceAfterFees)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Difference</dt>
              <dd>{formatGBP(difference)}</dd>
            </div>
          </dl>

          <p className="summary-sub summary-sub--target-outcome">
            {difference < -0.005 && `You are projected to fall short by ${formatGBP(absDifference)}.`}
            {difference > 0.005 && `You exceed your target by ${formatGBP(absDifference)}.`}
            {Math.abs(difference) <= 0.005 && 'You are projected to meet your target.'}
          </p>
        </div>
      )}
    </div>
  );
};
