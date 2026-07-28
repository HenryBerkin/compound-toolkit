import { useState, type FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP } from '../lib/format';

interface Props {
  result: CalcResult;
  principal: number;
  inflationRate?: number;
  annualFeeRate?: number;
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
  principal,
  inflationRate = 0,
  annualFeeRate = 0,
  targetToday,
  targetYears = 0,
  targetMonths = 0,
}) => {
  const [showInsights, setShowInsights] = useState(false);
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
  const feeImpact = Math.max(0, result.finalBalance - result.finalBalanceAfterFees);
  const inflationIncreasePct =
    inflationRate > 0 && totalYears > 0 ? (Math.pow(1 + inflationRate, totalYears) - 1) * 100 : 0;
  const startingBalance = Math.abs(principal) < 0.005 ? 0 : principal;
  const contributionsAdded = baseCapital;
  const growthContribution = result.finalBalanceAfterFees - contributionsAdded;

  const insights: string[] = [];
  if (inflationRate > 0 && totalYears > 0) {
    insights.push(
      `At ${(inflationRate * 100).toFixed(2)}% inflation, prices are about ${Math.round(inflationIncreasePct)}% higher over ${durationLabel}.`,
    );
  }
  if (annualFeeRate > 0 && feeImpact > 0.005) {
    insights.push(
      `Fees reduce the final balance by about ${formatGBP(Math.round(feeImpact))} compared with no-fee growth.`,
    );
  }
  insights.push(
    `Of your final balance (after fees), ${formatGBP(Math.round(contributionsAdded))} is contributions and ${formatGBP(Math.round(growthContribution))} is growth.`,
  );
  if (inflationRate > 0) {
    insights.push(
      `${formatGBP(result.finalBalanceAfterFees)} in the future has purchasing power similar to ${formatGBP(result.finalBalanceAfterFeesReal)} today.`,
    );
  }
  if (hasTarget) {
    insights.push(
      `To hit your target in today’s money, you need about ${formatGBP(requiredFutureNominal)} at the horizon.`,
    );
  }

  return (
    <div className="results-summary">
      <div className="results-summary-headline">
        <div className="summary-card summary-card--invested">
          <span className="summary-label">Scenario Results</span>
          <span className="summary-kpi-label">Final balance (after fees)</span>
          <span className="summary-value">{formatGBP(result.finalBalanceAfterFees)}</span>
          <p className="summary-sub summary-sub--context">
            Purchasing power in today&apos;s terms: {formatGBP(result.finalBalanceAfterFeesReal)}
          </p>
          <p className="summary-sub summary-sub--context-note">
            (Assumes {inflationLabel} annual inflation)
          </p>

          <dl className="summary-breakdown" aria-label="Final balance breakdown">
            <div className="summary-breakdown__row">
              <dt>Starting balance</dt>
              <dd>{formatGBP(startingBalance)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Ongoing contributions</dt>
              <dd>{formatGBP(result.totalContributions)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Interest earned (after fees)</dt>
              <dd>{formatGBP(interestAfterFees)}</dd>
            </div>
            <div className="summary-breakdown__row summary-breakdown__row--muted">
              <dt>Total (before fees)</dt>
              <dd>{formatGBP(result.finalBalance)}</dd>
            </div>
          </dl>

          <section className="summary-fees" aria-label="Fee summary">
            <div className="summary-fees__row">
              <span className="summary-fees__label">Total fees paid (nominal)</span>
              <span className="summary-fees__value">{formatGBP(result.totalFeesPaidNominal)}</span>
            </div>
            <p className="summary-sub summary-sub--fee-note">cumulative asset-based fees</p>
            {inflationRate > 0 && (
              <>
                <div className="summary-fees__row">
                  <span className="summary-fees__label">Inflation-adjusted fee total (today&apos;s terms)</span>
                  <span className="summary-fees__value">{formatGBP(result.totalFeesPaidReal)}</span>
                </div>
                <p className="summary-sub summary-sub--fee-real">
                  (Assumes {inflationLabel} annual inflation)
                </p>
              </>
            )}
          </section>

          <section className="summary-insights" aria-label="Scenario insights">
            <div className="summary-insights__header">
              <span className="summary-insights__title">Scenario Insights</span>
              <button
                type="button"
                className="btn btn-ghost btn-xs summary-insights__toggle"
                onClick={() => setShowInsights((prev) => !prev)}
                aria-expanded={showInsights}
                aria-controls="results-insights"
              >
                <span>{showInsights ? 'Hide' : 'Show'}</span>
                <span
                  className={`summary-insights__chevron ${showInsights ? 'summary-insights__chevron--open' : ''}`}
                  aria-hidden="true"
                />
              </button>
            </div>
            {showInsights && (
              <>
                <ul id="results-insights" className="summary-insights-list">
                  {insights.slice(0, 5).map((line) => (
                    <li key={line}>{line}</li>
                  ))}
                </ul>
                {!hasTarget && (
                  <p className="summary-insights-helper">
                    Add an optional target above to compare this projection with your goal.
                  </p>
                )}
              </>
            )}
          </section>
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
              <dt>Required balance at horizon</dt>
              <dd>{formatGBP(requiredFutureNominal)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Projected balance (after fees)</dt>
              <dd>{formatGBP(result.finalBalanceAfterFees)}</dd>
            </div>
            <div className="summary-breakdown__row">
              <dt>Gap</dt>
              <dd>{formatGBP(difference)}</dd>
            </div>
          </dl>

          <p className="summary-sub summary-sub--target-outcome">
            {difference < -0.005 && `You are currently projected to be ${formatGBP(absDifference)} below this target.`}
            {difference > 0.005 && `You are currently projected to be ${formatGBP(absDifference)} above this target.`}
            {Math.abs(difference) <= 0.005 && 'You are currently projected to be on target.'}
          </p>
        </div>
      )}
    </div>
  );
};
