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
                How the projection runs
              </dt>
              <dd>
                <ul className="assumptions-bullets">
                  <li>The model advances one month at a time.</li>
                  <li>
                    APR is converted into an equivalent monthly growth rate based on your selected
                    compounding frequency ({COMPOUND_LABELS[compoundFrequency]}).
                  </li>
                  <li>Weekly contributions are converted into a monthly equivalent (52 weeks ÷ 12 months).</li>
                  <li>Annual contributions are spread as a monthly equivalent (amount ÷ 12).</li>
                </ul>
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">💸</span>
                What “After fees” means
              </dt>
              <dd>
                <ul className="assumptions-bullets">
                  <li>
                    Each month, the balance grows first, then the fee drag is applied to assets.
                  </li>
                  <li>
                    “After fees” balances show the projected value after this ongoing fee drag.
                  </li>
                </ul>
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">⏱</span>
                Contribution timing
              </dt>
              <dd>
                <ul className="assumptions-bullets">
                  <li>
                    <strong>Start of period:</strong> contribution is added before growth for that
                    month.
                  </li>
                  <li>
                    <strong>End of period:</strong> growth happens first, then the contribution is
                    added.
                  </li>
                </ul>
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">📊</span>
                Purchasing power (“today’s money”)
              </dt>
              <dd>
                <ul className="assumptions-bullets">
                  <li>
                    “Today’s money” estimates what the future balance could buy after inflation.
                  </li>
                  <li>
                    If inflation is 0%, this will match the standard (before-inflation) balance.
                  </li>
                  <li>
                    Inflation reduces what money can buy over time, even if the number itself increases.
                  </li>
                </ul>
              </dd>
            </div>

            <div className="assumption-item">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">🧩</span>
                Input assumptions
              </dt>
              <dd>
                <ul className="assumptions-bullets">
                  <li>Rates are assumed constant over the full period.</li>
                  <li>Contributions are assumed constant and on schedule.</li>
                  <li>Results are deterministic examples, not a forecast of market path.</li>
                </ul>
              </dd>
            </div>

            <div className="assumption-item assumption-item--warning">
              <dt>
                <span className="assumption-emoji" aria-hidden="true">🚫</span>
                What this projection does not include
              </dt>
              <dd>
                <ul className="assumptions-bullets">
                  <li>Taxes</li>
                  <li>Market volatility and sequence risk</li>
                  <li>Inflation variability</li>
                  <li>Contribution limits</li>
                  <li>Platform and transaction costs</li>
                  <li>Pension rules</li>
                  <li>Withdrawals and decumulation planning</li>
                </ul>
              </dd>
            </div>
          </dl>
        </div>
      )}
    </section>
  );
};
