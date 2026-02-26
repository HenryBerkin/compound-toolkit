import type { FC } from 'react';
import {
  AreaChart,
  Area,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  type TooltipProps,
} from 'recharts';
import type { CalcInputs, CalcResult } from '../types';
import { buildChartData } from '../lib/calc';
import { formatGBP, formatGBPCompact } from '../lib/format';

interface Props {
  inputs: CalcInputs;
  result: CalcResult;
}

// ─── Custom tooltip ────────────────────────────────────────────────────────────

type TPayload = { invested: number; interest: number };

const CustomTooltip: FC<TooltipProps<number, string>> = ({ active, payload, label }) => {
  if (!active || !payload?.length) return null;

  const data = payload[0]?.payload as TPayload | undefined;
  if (!data) return null;

  const balance = (data.invested ?? 0) + (data.interest ?? 0);
  const invested = data.invested ?? 0;
  const interest = data.interest ?? 0;

  return (
    <div className="chart-tooltip">
      <p className="chart-tooltip__label">{label}</p>
      <ul className="chart-tooltip__list">
        <li>
          <span className="chart-tooltip__dot chart-tooltip__dot--balance" aria-hidden="true" />
          <span className="chart-tooltip__key">Total Balance</span>
          <span className="chart-tooltip__val">{formatGBP(balance)}</span>
        </li>
        <li>
          <span className="chart-tooltip__dot chart-tooltip__dot--invested" aria-hidden="true" />
          <span className="chart-tooltip__key">Invested</span>
          <span className="chart-tooltip__val">{formatGBP(invested)}</span>
        </li>
        <li>
          <span className="chart-tooltip__dot chart-tooltip__dot--interest" aria-hidden="true" />
          <span className="chart-tooltip__key">Interest</span>
          <span className="chart-tooltip__val">{formatGBP(interest)}</span>
        </li>
      </ul>
    </div>
  );
};

// ─── Chart ────────────────────────────────────────────────────────────────────

export const GrowthChart: FC<Props> = ({ inputs, result }) => {
  const data = buildChartData(inputs, result);

  if (data.length < 2) return null;

  return (
    <section className="chart-section card" aria-label="Balance growth chart">
      <h2 className="section-title">Growth Over Time</h2>
      <div className="chart-wrapper">
        <ResponsiveContainer width="100%" height={320}>
          <AreaChart data={data} margin={{ top: 8, right: 16, left: 8, bottom: 0 }}>
            <defs>
              <linearGradient id="colorInvested" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-chart-invested)" stopOpacity={0.9} />
                <stop offset="95%" stopColor="var(--color-chart-invested)" stopOpacity={0.5} />
              </linearGradient>
              <linearGradient id="colorInterest" x1="0" y1="0" x2="0" y2="1">
                <stop offset="5%" stopColor="var(--color-chart-interest)" stopOpacity={0.9} />
                <stop offset="95%" stopColor="var(--color-chart-interest)" stopOpacity={0.5} />
              </linearGradient>
            </defs>

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
            <Legend
              iconType="square"
              wrapperStyle={{ fontSize: '13px', paddingTop: '12px' }}
            />
            <Area
              type="monotone"
              dataKey="invested"
              stackId="balance"
              stroke="var(--color-chart-invested)"
              fill="url(#colorInvested)"
              name="Principal + Contributions"
              activeDot={{ r: 5 }}
              strokeWidth={2}
            />
            <Area
              type="monotone"
              dataKey="interest"
              stackId="balance"
              stroke="var(--color-chart-interest)"
              fill="url(#colorInterest)"
              name="Interest Earned"
              activeDot={{ r: 5 }}
              strokeWidth={2}
            />
          </AreaChart>
        </ResponsiveContainer>
      </div>
    </section>
  );
};
