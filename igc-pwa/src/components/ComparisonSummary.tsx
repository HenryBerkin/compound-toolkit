import type { FC } from 'react';
import type { CalcResult, Scenario } from '../types';
import { formatGBP } from '../lib/format';

interface ComparedScenario {
  label: 'A' | 'B';
  scenario: Scenario;
  result: CalcResult;
}

interface Props {
  compared: [ComparedScenario, ComparedScenario];
}

interface MetricRow {
  label: string;
  a: string;
  b: string;
}

function formatPercent(value: number): string {
  const asPercent = value * 100;
  return `${asPercent.toFixed(2).replace(/\.?0+$/, '')}%`;
}

function formatFeePercent(value: number): string {
  return `${(value * 100).toFixed(2).replace(/\.00$/, '')}%`;
}

function formatDuration(years: number, months: number): string {
  if (years > 0 && months > 0) return `${years}y ${months}m`;
  if (years > 0) return `${years}y`;
  return `${months}m`;
}

function frequencyLabel(freq: Scenario['inputs']['contributionFrequency']): string {
  if (freq === 'weekly') return 'week';
  if (freq === 'monthly') return 'month';
  return 'year';
}

function compoundingLabel(freq: Scenario['inputs']['compoundFrequency']): string {
  if (freq === 'daily') return 'daily';
  if (freq === 'monthly') return 'monthly';
  if (freq === 'quarterly') return 'quarterly';
  return 'annual';
}

function timingLabel(timing: Scenario['inputs']['timing']): string {
  return timing === 'start' ? 'start of period' : 'end of period';
}

export const ComparisonSummary: FC<Props> = ({ compared }) => {
  const [a, b] = compared;
  const summaryA = `${a.scenario.name} (APR ${formatPercent(a.scenario.inputs.apr)} | Fee ${formatFeePercent(
    a.scenario.inputs.annualFeeRate ?? 0,
  )} | Infl. ${formatPercent(a.scenario.inputs.inflationRate ?? 0)} | ${formatDuration(
    a.scenario.inputs.years,
    a.scenario.inputs.months,
  )})`;
  const summaryB = `${b.scenario.name} (APR ${formatPercent(b.scenario.inputs.apr)} | Fee ${formatFeePercent(
    b.scenario.inputs.annualFeeRate ?? 0,
  )} | Infl. ${formatPercent(b.scenario.inputs.inflationRate ?? 0)} | ${formatDuration(
    b.scenario.inputs.years,
    b.scenario.inputs.months,
  )})`;

  const comparabilityDiffs: string[] = [];
  if (a.scenario.inputs.principal !== b.scenario.inputs.principal) {
    comparabilityDiffs.push(
      `Starting amount: A ${formatGBP(a.scenario.inputs.principal)} vs B ${formatGBP(b.scenario.inputs.principal)}.`,
    );
  }

  const contributionDiffers =
    a.scenario.inputs.contribution !== b.scenario.inputs.contribution ||
    a.scenario.inputs.contributionFrequency !== b.scenario.inputs.contributionFrequency;
  if (contributionDiffers) {
    comparabilityDiffs.push(
      `Contributions: A ${formatGBP(a.scenario.inputs.contribution)} per ${frequencyLabel(
        a.scenario.inputs.contributionFrequency,
      )} vs B ${formatGBP(b.scenario.inputs.contribution)} per ${frequencyLabel(
        b.scenario.inputs.contributionFrequency,
      )}.`,
    );
  }

  if (
    a.scenario.inputs.years !== b.scenario.inputs.years ||
    a.scenario.inputs.months !== b.scenario.inputs.months
  ) {
    comparabilityDiffs.push(
      `Duration: A ${formatDuration(a.scenario.inputs.years, a.scenario.inputs.months)} vs B ${formatDuration(
        b.scenario.inputs.years,
        b.scenario.inputs.months,
      )}.`,
    );
  }

  if (a.scenario.inputs.compoundFrequency !== b.scenario.inputs.compoundFrequency) {
    comparabilityDiffs.push(
      `Compounding: A ${compoundingLabel(a.scenario.inputs.compoundFrequency)} vs B ${compoundingLabel(
        b.scenario.inputs.compoundFrequency,
      )}.`,
    );
  }

  if (a.scenario.inputs.timing !== b.scenario.inputs.timing) {
    comparabilityDiffs.push(
      `Contribution timing: A ${timingLabel(a.scenario.inputs.timing)} vs B ${timingLabel(
        b.scenario.inputs.timing,
      )}.`,
    );
  }

  const hasComparabilityDifferences = comparabilityDiffs.length > 0;
  const listedDifferences = comparabilityDiffs.slice(0, 3);

  const rows: MetricRow[] = [
    {
      label: 'Final Balance (After Fees)',
      a: formatGBP(a.result.finalBalanceAfterFees),
      b: formatGBP(b.result.finalBalanceAfterFees),
    },
    {
      label: 'Final Balance (Real After Fees)',
      a: formatGBP(a.result.finalBalanceAfterFeesReal),
      b: formatGBP(b.result.finalBalanceAfterFeesReal),
    },
    {
      label: 'Total Contributions',
      a: formatGBP(a.result.totalContributions),
      b: formatGBP(b.result.totalContributions),
    },
    {
      label: 'Total Fees Paid (Nominal)',
      a: formatGBP(a.result.totalFeesPaidNominal),
      b: formatGBP(b.result.totalFeesPaidNominal),
    },
    {
      label: 'Total Fees Paid (Real)',
      a: formatGBP(a.result.totalFeesPaidReal),
      b: formatGBP(b.result.totalFeesPaidReal),
    },
  ];

  const hasAnyTarget = typeof a.scenario.targetToday === 'number' || typeof b.scenario.targetToday === 'number';
  if (hasAnyTarget) {
    const aTargetGap = typeof a.scenario.targetToday === 'number'
      ? a.result.finalBalanceAfterFeesReal - a.scenario.targetToday
      : null;
    const bTargetGap = typeof b.scenario.targetToday === 'number'
      ? b.result.finalBalanceAfterFeesReal - b.scenario.targetToday
      : null;
    rows.push({
      label: 'Target gap (Real After Fees)',
      a: aTargetGap === null ? '—' : formatGBP(aTargetGap),
      b: bTargetGap === null ? '—' : formatGBP(bTargetGap),
    });
  }

  return (
    <section className="comparison-summary card" aria-label="Comparison summary">
      <h2 className="section-title">Comparison Summary</h2>
      <div className="comparison-meta">
        <p className="comparison-meta__line">
          <span className="comparison-meta__label">A:</span> <strong>{summaryA}</strong>
        </p>
        <p className="comparison-meta__line">
          <span className="comparison-meta__label">B:</span> <strong>{summaryB}</strong>
        </p>
      </div>

      {hasComparabilityDifferences && (
        <div className="comparison-note" role="note" aria-label="Comparability note">
          <p className="comparison-note__text">
            Note: These scenarios use different contributions or starting amounts. Results may not be directly comparable.
          </p>
          <ul className="comparison-note__list">
            {listedDifferences.map((diff) => (
              <li key={diff}>{diff}</li>
            ))}
          </ul>
        </div>
      )}

      <div className="comparison-grid" role="table" aria-label="Scenario comparison table">
        <div className="comparison-grid__header" role="row">
          <span className="comparison-grid__metric-head" role="columnheader">Metric</span>
          <span className="comparison-grid__scenario-head" role="columnheader">A</span>
          <span className="comparison-grid__scenario-head" role="columnheader">B</span>
        </div>

        {rows.map((row) => (
          <div className="comparison-grid__row" role="row" key={row.label}>
            <span className="comparison-grid__metric" role="rowheader">{row.label}</span>
            <span className="comparison-grid__value" role="cell">{row.a}</span>
            <span className="comparison-grid__value" role="cell">{row.b}</span>
          </div>
        ))}
      </div>
    </section>
  );
};
