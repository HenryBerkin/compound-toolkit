import { useEffect, useRef, type FC, type KeyboardEvent as ReactKeyboardEvent } from 'react';

interface Props {
  onClose: () => void;
}

export const GlossaryModal: FC<Props> = ({ onClose }) => {
  const dialogRef = useRef<HTMLDivElement>(null);
  const closeButtonRef = useRef<HTMLButtonElement>(null);

  useEffect(() => {
    closeButtonRef.current?.focus();

    function onKeyDown(event: KeyboardEvent) {
      if (event.key === 'Escape') {
        event.preventDefault();
        onClose();
      }
    }

    document.addEventListener('keydown', onKeyDown);
    return () => {
      document.removeEventListener('keydown', onKeyDown);
    };
  }, [onClose]);

  function trapFocus(event: ReactKeyboardEvent<HTMLDivElement>) {
    if (event.key !== 'Tab') return;
    const container = dialogRef.current;
    if (!container) return;
    const focusables = container.querySelectorAll<HTMLElement>(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
    );
    if (focusables.length === 0) return;
    const first = focusables[0];
    const last = focusables[focusables.length - 1];

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault();
      last.focus();
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault();
      first.focus();
    }
  }

  return (
    <div
      className="modal-overlay"
      role="presentation"
      onMouseDown={(event) => {
        if (event.target === event.currentTarget) onClose();
      }}
    >
      <div
        className="modal-dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby="glossary-title"
        aria-describedby="glossary-intro"
        ref={dialogRef}
        onKeyDown={trapFocus}
      >
        <div className="modal-header">
          <h2 id="glossary-title" className="modal-title">Understanding the terms</h2>
          <button
            ref={closeButtonRef}
            type="button"
            className="modal-close-icon"
            onClick={onClose}
            aria-label="Close glossary"
          >
            ×
          </button>
        </div>

        <p id="glossary-intro" className="modal-intro">
          This tool uses standard financial assumptions to model long-term investment growth.
          The definitions below explain what each term means and how it affects your projection.
        </p>

        <section className="glossary-section">
          <h3>Annual Growth Rate (APR)</h3>
          <p>
            The assumed average yearly growth rate before fees and inflation are applied.
            In this tool, APR represents the expected annual return of the investment itself.
            Fees and inflation are modelled separately so their impact can be shown clearly.
            If £10,000 grows at 7% for one year, it becomes £10,700, assuming no fees and
            no additional contributions during that year.
          </p>
        </section>

        <section className="glossary-section">
          <h3>Compounding</h3>
          <p>
            Growth earned on both your original investment and previous growth.
            When returns are reinvested, future growth is calculated on a larger amount.
            In this tool, growth is modelled monthly to reflect regular contributions and
            fee calculations. Over long periods, compounding significantly increases total returns.
          </p>
        </section>

        <section className="glossary-section">
          <h3>Inflation</h3>
          <p>
            The rate at which prices increase over time.
            Inflation reduces what money can buy in the future. Even if your investment
            balance increases, its purchasing power may grow more slowly.
            At 3% inflation, something that costs £100 today would cost about £134 in ten years.
          </p>
        </section>

        <section className="glossary-section">
          <h3>Fees</h3>
          <p>
            The annual cost of holding and managing investments.
            Fees are typically charged as a percentage of your investment each year.
            Even small percentage differences can meaningfully reduce long-term growth.
            A 1% annual fee on £100,000 is £1,000 per year before growth.
          </p>
        </section>

        <section className="glossary-section">
          <h3>Purchasing Power (&ldquo;Today&rsquo;s money&rdquo;)</h3>
          <p>
            The value of future money adjusted for inflation.
            This shows what your projected balance would be worth in today&rsquo;s terms,
            helping you compare future goals realistically.
          </p>
        </section>

        <section className="glossary-section">
          <h3>Contribution Timing</h3>
          <p>
            Whether contributions are added before or after each growth period.
            Start of period means the contribution grows immediately.
            End of period means growth is calculated first, then the contribution is added.
            Over long periods, the difference compounds but is usually modest.
          </p>
        </section>

        <div className="modal-actions">
          <button type="button" className="btn btn-primary btn-sm" onClick={onClose}>
            Close
          </button>
        </div>
      </div>
    </div>
  );
};

