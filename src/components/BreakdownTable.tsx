import { useState, type FC } from 'react';
import type { CalcResult } from '../types';
import { formatGBP, monthName } from '../lib/format';

interface Props {
  result: CalcResult;
}

export const BreakdownTable: FC<Props> = ({ result }) => {
  const [monthly, setMonthly] = useState(false);

  const yearly = result.yearlyBreakdown;
  const months = result.monthlyBreakdown;

  const totalMonths = months.length;
  const showMonthly = monthly && totalMonths <= 120; // cap at 10 years for readability

  return (
    <section className="breakdown-section card" aria-label="Year-by-year breakdown">
      <div className="breakdown-header">
        <h2 className="section-title">Year-by-Year Breakdown</h2>
        <div className="breakdown-controls">
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
          {monthly && totalMonths > 120 && (
            <p className="breakdown-note">
              Monthly view is limited to 10 years. Use the yearly view for longer durations.
            </p>
          )}
        </div>
      </div>

      <div className="table-scroll">
        <table className="breakdown-table">
          <thead>
            <tr>
              {showMonthly && <th scope="col">Month</th>}
              <th scope="col">Year</th>
              <th scope="col" className="num">Opening Balance</th>
              <th scope="col" className="num">Contributions</th>
              <th scope="col" className="num">Interest</th>
              <th scope="col" className="num">Closing Balance</th>
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
              {yearly.map((row) => (
                <tr key={row.year}>
                  <td className="year-cell">Year {row.year}</td>
                  <td className="num">{formatGBP(row.startingBalance)}</td>
                  <td className="num contrib-cell">{formatGBP(row.contributions)}</td>
                  <td className="num interest-cell">{formatGBP(row.interest)}</td>
                  <td className="num balance-cell">{formatGBP(row.endingBalance)}</td>
                </tr>
              ))}
            </tbody>
          )}

          <tfoot>
            <tr>
              {showMonthly && <td />}
              <td>
                <strong>Total</strong>
              </td>
              <td className="num" />
              <td className="num contrib-cell">
                <strong>{formatGBP(result.totalContributions)}</strong>
              </td>
              <td className="num interest-cell">
                <strong>{formatGBP(result.totalInterest)}</strong>
              </td>
              <td className="num balance-cell">
                <strong>{formatGBP(result.finalBalance)}</strong>
              </td>
            </tr>
          </tfoot>
        </table>
      </div>
    </section>
  );
};
