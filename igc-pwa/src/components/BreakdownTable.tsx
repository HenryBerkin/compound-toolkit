import { useState, type FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP, monthName } from '../lib/format';
import { buildCsv, downloadCsv } from '../lib/exportCsv';

interface Props {
  result: CalcResult;
}

type TableView = 'nominal' | 'real' | 'afterFees' | 'realAfterFees';

export const BreakdownTable: FC<Props> = ({ result }) => {
  const [monthly, setMonthly] = useState(false);
  const [view, setView] = useState<TableView>('nominal');
  const [expanded, setExpanded] = useState(false);

  const yearly = result.yearlyBreakdown;
  const months = result.monthlyBreakdown;

  const totalMonths = months.length;
  const showMonthly = monthly && totalMonths <= 120 && view === 'nominal'; // cap at 10 years for readability
  const previewYears = 3;
  const canCollapseYearly = !showMonthly && yearly.length > previewYears;
  const showCollapsedYearly = canCollapseYearly && !expanded;
  const visibleYearly = showCollapsedYearly ? yearly.slice(0, previewYears) : yearly;

  function yearEndDiscount(index: number): number {
    const row = yearly[index];
    if (row.realEndingBalance === 0) return 1;
    return row.endingBalance / row.realEndingBalance;
  }

  function yearlyOpeningAfterFees(index: number): number {
    if (index === 0) return yearly[0].startingBalance;
    return yearly[index - 1].endingBalanceAfterFees;
  }

  function yearlyOpeningRealAfterFees(index: number): number {
    if (index === 0) return yearly[0].startingBalance;
    const prev = yearly[index - 1];
    const prevDiscount = yearEndDiscount(index - 1);
    return prev.endingBalanceAfterFees / prevDiscount;
  }

  function viewLabels() {
    switch (view) {
      case 'real':
        return {
          opening: 'Opening Balance',
          contributions: 'Cumulative Contributions',
          middle: 'Cumulative Interest',
          closing: 'Closing Balance',
        };
      case 'afterFees':
        return {
          opening: 'Opening Balance',
          contributions: 'Contributions',
          middle: 'Fees Paid',
          closing: 'Closing Balance',
        };
      case 'realAfterFees':
        return {
          opening: 'Opening Balance',
          contributions: 'Cumulative Contributions',
          middle: 'Cumulative Fees Paid',
          closing: 'Closing Balance',
        };
      case 'nominal':
      default:
        return {
          opening: 'Opening Balance',
          contributions: 'Contributions',
          middle: 'Interest',
          closing: 'Closing Balance',
        };
    }
  }

  function rowValues(index: number) {
    const row = yearly[index];
    const discount = yearEndDiscount(index);

    switch (view) {
      case 'real':
        return {
          opening: index === 0 ? row.startingBalance : yearly[index - 1].realEndingBalance,
          contributions: row.realCumulativeContributions,
          middle: row.realCumulativeInterest,
          closing: row.realEndingBalance,
        };
      case 'afterFees':
        return {
          opening: yearlyOpeningAfterFees(index),
          contributions: row.contributions,
          middle: row.yearlyFeesPaid,
          closing: row.endingBalanceAfterFees,
        };
      case 'realAfterFees':
        return {
          opening: yearlyOpeningRealAfterFees(index),
          contributions: row.realCumulativeContributions,
          middle: row.cumulativeFeesPaid / discount,
          closing: row.endingBalanceAfterFees / discount,
        };
      case 'nominal':
      default:
        return {
          opening: row.startingBalance,
          contributions: row.contributions,
          middle: row.interest,
          closing: row.endingBalance,
        };
    }
  }

  function totals() {
    switch (view) {
      case 'real':
        return {
          contributions: result.totalContributionsReal,
          middle: result.totalInterestReal,
          closing: result.finalBalanceReal,
        };
      case 'afterFees':
        return {
          contributions: result.totalContributions,
          middle: result.totalFeesPaidNominal,
          closing: result.finalBalanceAfterFees,
        };
      case 'realAfterFees':
        return {
          contributions: result.totalContributionsReal,
          middle: result.totalFeesPaidReal,
          closing: result.finalBalanceAfterFeesReal,
        };
      case 'nominal':
      default:
        return {
          contributions: result.totalContributions,
          middle: result.totalInterest,
          closing: result.finalBalance,
        };
    }
  }

  const labels = viewLabels();
  const totalsRow = totals();

  function exportCsv(): void {
    const granularity = showMonthly ? 'monthly' : 'yearly';
    const viewSlug = {
      nominal: 'nominal',
      real: 'real',
      afterFees: 'after-fees',
      realAfterFees: 'real-after-fees',
    }[view];

    const date = new Date().toISOString().slice(0, 10);
    const filename = `compound-toolkit_${viewSlug}_${granularity}_${date}.csv`;

    if (showMonthly) {
      const headers = [
        'Period',
        'Year',
        'Month',
        'Opening Balance',
        'Contributions',
        'Interest',
        'Closing Balance',
      ];
      const rows = months.map((row) => [
        row.period,
        row.year,
        monthName(row.month),
        row.startingBalance,
        row.contributions,
        row.interest,
        row.endingBalance,
      ]);
      const csv = buildCsv(headers, rows);
      downloadCsv(filename, csv);
      return;
    }

    const headers = [
      'Year',
      labels.opening,
      labels.contributions,
      labels.middle,
      labels.closing,
    ];
    const rows: Array<Array<string | number>> = yearly.map((row, idx) => {
      const values = rowValues(idx);
      return [
        row.year,
        values.opening,
        values.contributions,
        values.middle,
        values.closing,
      ];
    });
    rows.push([
      'Total',
      '',
      totalsRow.contributions,
      totalsRow.middle,
      totalsRow.closing,
    ]);
    const csv = buildCsv(headers, rows);
    downloadCsv(filename, csv);
  }

  return (
    <section className="breakdown-section card" aria-label="Year-by-year breakdown">
      <div className="breakdown-header">
        <h2 className="section-title">Year-by-Year Breakdown</h2>
        <div className="breakdown-controls">
          <label className="breakdown-select-label" htmlFor="breakdown-view">
            View:
            <select
              id="breakdown-view"
              className="form-control breakdown-select"
              value={view}
              onChange={(e) => setView(e.target.value as TableView)}
            >
              <option value="nominal">Nominal</option>
              <option value="real">Real</option>
              <option value="afterFees">After Fees</option>
              <option value="realAfterFees">Real After Fees</option>
            </select>
          </label>
          <label className="toggle-label">
            <input
              type="checkbox"
              className="toggle-input"
              checked={monthly}
              onChange={(e) => setMonthly(e.target.checked)}
              aria-label="Show monthly detail"
            />
            <span className="toggle-track" aria-hidden="true" />
            <span className="toggle-text">Monthly view</span>
          </label>
          <button
            type="button"
            className="btn btn-ghost btn-sm"
            onClick={exportCsv}
            aria-label="Export current breakdown view as CSV"
          >
            Export CSV
          </button>
          {monthly && view !== 'nominal' && (
            <p className="breakdown-note">
              Monthly view is available for Nominal mode only.
            </p>
          )}
          {monthly && totalMonths > 120 && view === 'nominal' && (
            <p className="breakdown-note">
              Monthly view is limited to 10 years. Use the yearly view for longer durations.
            </p>
          )}
        </div>
      </div>

      <div
        id="breakdown-full-table"
        className={`table-scroll ${expanded && !showMonthly ? 'table-scroll--expanded' : ''}`}
      >
        <table className={`breakdown-table ${!showMonthly ? 'breakdown-table--year-sticky' : ''}`}>
          <thead>
            <tr>
              {showMonthly && <th scope="col">Month</th>}
              <th scope="col" className="col-year">Year</th>
              <th scope="col" className="num">{labels.opening}</th>
              <th scope="col" className="num">{labels.contributions}</th>
              <th scope="col" className="num">{labels.middle}</th>
              <th scope="col" className="num">{labels.closing}</th>
            </tr>
          </thead>

          {showMonthly ? (
            <tbody>
              {months.map((row) => (
                <tr key={row.period}>
                  <td>
                    <span className="month-badge">{monthName(row.month)}</span>
                  </td>
                  <td className="year-cell">{row.year}</td>
                  <td className="num">{formatGBP(row.startingBalance)}</td>
                  <td className="num contrib-cell">{formatGBP(row.contributions)}</td>
                  <td className="num interest-cell">{formatGBP(row.interest)}</td>
                  <td className="num balance-cell">{formatGBP(row.endingBalance)}</td>
                </tr>
              ))}
            </tbody>
          ) : (
            <tbody>
              {visibleYearly.map((row, idx) => {
                const values = rowValues(idx);
                return (
                  <tr key={row.year}>
                    <td className="year-cell">Year {row.year}</td>
                    <td className="num">{formatGBP(values.opening)}</td>
                    <td className="num contrib-cell">{formatGBP(values.contributions)}</td>
                    <td className="num interest-cell">{formatGBP(values.middle)}</td>
                    <td className="num balance-cell">{formatGBP(values.closing)}</td>
                  </tr>
                );
              })}
            </tbody>
          )}

          {(!showCollapsedYearly || showMonthly) && (
            <tfoot>
              <tr>
                {showMonthly && <td />}
                <td className="year-cell">
                  <strong>Total</strong>
                </td>
                <td className="num" />
                <td className="num contrib-cell">
                  <strong>{formatGBP(totalsRow.contributions)}</strong>
                </td>
                <td className="num interest-cell">
                  <strong>{formatGBP(totalsRow.middle)}</strong>
                </td>
                <td className="num balance-cell">
                  <strong>{formatGBP(totalsRow.closing)}</strong>
                </td>
              </tr>
            </tfoot>
          )}
        </table>
      </div>

      {canCollapseYearly && (
        <div className="breakdown-expand-row">
          <button
            type="button"
            className="btn btn-ghost btn-sm breakdown-expand-btn"
            onClick={() => setExpanded((open) => !open)}
            aria-expanded={expanded}
            aria-controls="breakdown-full-table"
          >
            <span>{expanded ? 'Show fewer years' : 'View full breakdown'}</span>
            <span
              className={`breakdown-expand-chevron ${expanded ? 'breakdown-expand-chevron--open' : ''}`}
              aria-hidden="true"
            />
          </button>
        </div>
      )}
    </section>
  );
};
