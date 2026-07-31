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

  const isAfterFeesView = view === 'afterFees' || view === 'realAfterFees';
  const isTodayMoneyView = view === 'real' || view === 'realAfterFees';

  /**
   * The row-end discount factor the engine already applied to this row's real
   * ending balance. Every amount in a row is divided by this one factor, so the
   * row reconciles against its own closing balance. Mixing divisors within a row
   * produces a breakdown that does not add up.
   */
  function yearEndDiscount(index: number): number {
    if (!isTodayMoneyView) return 1;
    const row = yearly[index];
    if (row.realEndingBalance === 0) return 1;
    const factor = row.endingBalance / row.realEndingBalance;
    return Number.isFinite(factor) && factor > 0 ? factor : 1;
  }

  function finalDiscount(): number {
    if (result.finalBalanceReal === 0) return 1;
    const factor = result.finalBalance / result.finalBalanceReal;
    return Number.isFinite(factor) && factor > 0 ? factor : 1;
  }

  /** Opening balance on the after-fee path: the previous row's after-fee close. */
  function openingAfterFees(index: number): number {
    if (index === 0) return yearly[0].startingBalance;
    return yearly[index - 1].endingBalanceAfterFees;
  }

  function viewLabels() {
    return {
      opening: 'Opening Balance',
      contributions: 'Contributions',
      growth: isAfterFeesView ? 'Growth After Fees' : 'Growth',
      fees: isAfterFeesView ? 'Fees Deducted' : null,
      closing: 'Closing Balance',
    };
  }

  function rowValues(index: number) {
    const row = yearly[index];
    const discount = yearEndDiscount(index);
    const opening = isAfterFeesView ? openingAfterFees(index) : row.startingBalance;
    const closing = isAfterFeesView ? row.endingBalanceAfterFees : row.endingBalance;
    // On the after-fee path growth is the residual, so it is already net of the
    // fee shown alongside it. On the no-fee path it is the interest itself.
    const growth = isAfterFeesView ? closing - opening - row.contributions : row.interest;

    return {
      opening: opening / discount,
      contributions: row.contributions / discount,
      growth: growth / discount,
      fees: isAfterFeesView ? row.yearlyFeesPaid / discount : null,
      closing: closing / discount,
    };
  }

  function totals() {
    const principal = yearly.length > 0 ? yearly[0].startingBalance : 0;

    switch (view) {
      case 'real':
        return {
          contributions: result.totalContributionsReal,
          growth: result.totalInterestReal,
          fees: null,
          closing: result.finalBalanceReal,
        };
      case 'afterFees':
        return {
          contributions: result.totalContributions,
          growth: result.finalBalanceAfterFees - principal - result.totalContributions,
          fees: result.totalFeesPaidNominal,
          closing: result.finalBalanceAfterFees,
        };
      case 'realAfterFees':
        return {
          contributions: result.totalContributionsReal,
          growth:
            result.finalBalanceAfterFeesReal
            - principal / finalDiscount()
            - result.totalContributionsReal,
          fees: result.totalFeesPaidReal,
          closing: result.finalBalanceAfterFeesReal,
        };
      case 'nominal':
      default:
        return {
          contributions: result.totalContributions,
          growth: result.totalInterest,
          fees: null,
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
      labels.growth,
      ...(labels.fees ? [labels.fees] : []),
      labels.closing,
    ];
    const rows: Array<Array<string | number>> = yearly.map((row, idx) => {
      const values = rowValues(idx);
      return [
        row.year,
        values.opening,
        values.contributions,
        values.growth,
        ...(labels.fees ? [values.fees ?? 0] : []),
        values.closing,
      ];
    });
    rows.push([
      'Total',
      '',
      totalsRow.contributions,
      totalsRow.growth,
      ...(labels.fees ? [totalsRow.fees ?? 0] : []),
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
              <th scope="col" className="num">{labels.growth}</th>
              {labels.fees && <th scope="col" className="num">{labels.fees}</th>}
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
                    <td className="num interest-cell">{formatGBP(values.growth)}</td>
                    {labels.fees && (
                      <td className="num">{formatGBP(values.fees ?? 0)}</td>
                    )}
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
                  <strong>{formatGBP(totalsRow.growth)}</strong>
                </td>
                {labels.fees && (
                  <td className="num">
                    <strong>{formatGBP(totalsRow.fees ?? 0)}</strong>
                  </td>
                )}
                <td className="num balance-cell">
                  <strong>{formatGBP(totalsRow.closing)}</strong>
                </td>
              </tr>
            </tfoot>
          )}
        </table>
      </div>

      {!showMonthly && (
        <p className="breakdown-note">
          Opening balance, contributions and growth add up to the closing balance in
          every year.
          {isAfterFeesView
            && ' Growth after fees is already net of the fee shown, so the fee column is'
              + ' context rather than a further subtraction.'}
          {isTodayMoneyView
            && ' Each year’s amounts use that year’s end as their today’s-money basis,'
              + ' so an opening balance is not the previous year’s closing balance, and'
              + ' the Total row — which is expressed at the end of the projection — is'
              + ' not the sum of the column above it.'}
        </p>
      )}

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
