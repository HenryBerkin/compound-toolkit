import { useState, type FC } from 'react';
import {
  LineChart,
  Line,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  type TooltipProps,
} from 'recharts';
import type { CalcInputs, CalcResult } from '../types';
import { formatGBP, formatGBPCompact } from '../lib/format';

interface Props {
  inputs: CalcInputs;
  result: CalcResult;
}

// ─── Custom tooltip ────────────────────────────────────────────────────────────

type ChartRow = {
  name: string;
  nominal: number;
  afterFees: number;
  real: number;
  realAfterFees: number;
};

const CustomTooltip: FC<TooltipProps<number, string>> = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;

  return (
    <div className="chart-tooltip">
      <p className="chart-tooltip__label">{label}</p>
      <ul className="chart-tooltip__list">
        {payload.map((entry) => (
          <li key={entry.dataKey}>
            <span
              className="chart-tooltip__dot"
              aria-hidden="true"
              style={{ background: entry.color }}
            />
            <span className="chart-tooltip__key">{entry.name}</span>
            <span className="chart-tooltip__val">{formatGBP(Number(entry.value ?? 0))}</span>
          </li>
        ))}
      </ul>
    </div>
  );
};

// ─── Chart ────────────────────────────────────────────────────────────────────

export const GrowthChart: FC<Props> = ({ inputs, result }) => {
  const [showReal, setShowReal] = useState(true);
  const [showRealAfterFees, setShowRealAfterFees] = useState(true);

  const data: ChartRow[] = [
    {
      name: 'Start',
      nominal: inputs.principal,
      afterFees: inputs.principal,
      real: inputs.principal,
      realAfterFees: inputs.principal,
    },
    ...result.yearlyBreakdown.map((row) => {
      const discount = row.realEndingBalance === 0 ? 1 : row.endingBalance / row.realEndingBalance;
      return {
        name: `Yr ${row.year}`,
        nominal: row.endingBalance,
        afterFees: row.endingBalanceAfterFees,
        real: row.realEndingBalance,
        realAfterFees: row.endingBalanceAfterFees / discount,
      };
    }),
  ];

  if (data.length < 2) return null;

  return (
    <section className="chart-section card" aria-label="Balance growth chart">
      <h2 className="section-title">Growth Over Time</h2>
      <div className="chart-controls">
        <span className="chart-controls-label">Lines:</span>
        <span className="chart-legend-item">
          <span className="chart-legend-dot chart-legend-dot--nominal" aria-hidden="true" />
          Nominal
        </span>
        <span className="chart-legend-item">
          <span className="chart-legend-dot chart-legend-dot--after-fee" aria-hidden="true" />
          After fees
        </span>
        <label className="toggle-label">
          <input
            type="checkbox"
            className="toggle-input"
            checked={showReal}
            onChange={(e) => setShowReal(e.target.checked)}
            aria-label="Show real balance line"
          />
          <span className="toggle-track" aria-hidden="true" />
          <span className="toggle-text">Real</span>
        </label>
        <label className="toggle-label">
          <input
            type="checkbox"
            className="toggle-input"
            checked={showRealAfterFees}
            onChange={(e) => setShowRealAfterFees(e.target.checked)}
            aria-label="Show real after-fees balance line"
          />
          <span className="toggle-track" aria-hidden="true" />
          <span className="toggle-text">Real after fees</span>
        </label>
      </div>
      <div className="chart-wrapper">
        <ResponsiveContainer width="100%" height={320}>
          <LineChart data={data} margin={{ top: 8, right: 16, left: 8, bottom: 0 }}>
            <CartesianGrid
              strokeDasharray="3 3"
              stroke="var(--color-border)"
              strokeOpacity={0.5}
            />
            <XAxis
              dataKey="name"
              tick={{ fontSize: 12, fill: 'var(--color-text-secondary)' }}
              axisLine={{ stroke: 'var(--color-border)' }}
              tickLine={false}
              interval="preserveStartEnd"
            />
            <YAxis
              tickFormatter={formatGBPCompact}
              tick={{ fontSize: 12, fill: 'var(--color-text-secondary)' }}
              axisLine={false}
              tickLine={false}
              width={72}
            />
            <Tooltip content={<CustomTooltip />} />
            <Line
              type="monotone"
              dataKey="nominal"
              name="Nominal"
              stroke="var(--color-chart-invested)"
              dot={false}
              activeDot={{ r: 4 }}
              strokeWidth={2}
            />
            <Line
              type="monotone"
              dataKey="afterFees"
              name="After fees"
              stroke="var(--color-chart-interest)"
              dot={false}
              activeDot={{ r: 4 }}
              strokeWidth={2}
            />
            {showReal && (
              <Line
                type="monotone"
                dataKey="real"
                name="Real"
                stroke="var(--color-chart-real)"
                strokeDasharray="6 4"
                dot={false}
                activeDot={{ r: 4 }}
                strokeWidth={2}
              />
            )}
            {showRealAfterFees && (
              <Line
                type="monotone"
                dataKey="realAfterFees"
                name="Real after fees"
                stroke="var(--color-chart-real-after-fee)"
                strokeDasharray="6 4"
                dot={false}
                activeDot={{ r: 4 }}
                strokeWidth={2}
              />
            )}
          </LineChart>
        </ResponsiveContainer>
      </div>
    </section>
  );
};
