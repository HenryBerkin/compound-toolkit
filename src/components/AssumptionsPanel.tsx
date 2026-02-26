import { useState, type FC } from 'react';
import type { CompoundFrequency } from '../types';

interface Props {
  compoundFrequency: CompoundFrequency;
}

const COMPOUND_LABELS: Record<CompoundFrequency, string> = {
  daily: 'daily (365×/year)',
  monthly: 'monthly (12×/year)',
  quarterly: 'quarterly (4×/year)',
  annual: 'annually (1×/year)',
};

export const AssumptionsPanel: FC<Props> = ({ compoundFrequency }) => {
  const [open, setOpen] = useState(false);

  return (
    <section className="assumptions-panel card">
      <button
        type="button"
        className="assumptions-toggle"
        onClick={() => setOpen((o) => !o)}
        aria-expanded={open}
      >
        <span className="assumptions-icon" aria-hidden="true">ℹ</span>
        <span>Assumptions &amp; Methodology</span>
        <span className={`chevron ${open ? 'chevron--open' : ''}`} aria-hidden="true">▾</span>
      </button>

      {open && (
        <div className="assumptions-body">
          <dl className="assumptions-list">
            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">📐</span>
                Simulation model
              </dt>
              <dd>
                All calculations step forward one calendar month at a time. The nominal APR is
                converted to an equivalent monthly rate that preserves the compounding convention
                you've selected ({COMPOUND_LABELS[compoundFrequency]}). Weekly and annual
                contributions are converted to effective monthly equivalents using 52 weeks/year.
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">⏱</span>
                Contribution timing
              </dt>
              <dd>
                <strong>Start of period:</strong> your contribution is deposited before interest
                accrues, so it earns a full month of interest.{' '}
                <strong>End of period:</strong> interest accrues on the existing balance first;
                the contribution is added afterwards and earns interest from the following month.
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">📊</span>
                APR (Annual Percentage Rate)
              </dt>
              <dd>
                APR is the nominal annual interest rate before compounding. It does{' '}
                <em>not</em> account for inflation, tax, platform fees, or any other costs.
                Real investment returns will differ.
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">🔢</span>
                Precision &amp; rounding
              </dt>
              <dd>
                All internal arithmetic uses full double-precision floating-point. Values are
                rounded to 2 decimal places only at the point of display, not during calculation.
              </dd>
            </div>

            <div className="assumption-item assumption-item--warning">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">⚠️</span>
                Projection only
              </dt>
              <dd>
                This tool produces illustrative projections. It assumes a constant interest rate
                over the full duration. Actual returns will vary. Past performance does not
                guarantee future results. This is not financial advice.
              </dd>
            </div>
          </dl>
        </div>
      )}
    </section>
  );
};
