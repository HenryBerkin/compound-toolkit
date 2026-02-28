import { useEffect, useState, type FC, type ChangeEvent } from 'react';
import type { FormState, ValidationErrors } from '../types';
import { STARTER_PRESETS, type StarterPresetId } from '../lib/presets';
import { formatGroupedNumberInput, normalizeNumericInput } from '../lib/inputFormat';

interface Props {
  form: FormState;
  errors: ValidationErrors;
  onChange: (patch: Partial<FormState>) => void;
  activePresetName: string | null;
  onApplyPreset: (presetId: StarterPresetId) => void;
}

// ─── Small reusable atoms ──────────────────────────────────────────────────────

const Field: FC<{
  id: string;
  label: string;
  error?: string;
  hint?: string;
  children: React.ReactNode;
}> = ({ id, label, error, hint, children }) => (
  <div className={`form-group ${error ? 'form-group--error' : ''}`}>
    <label htmlFor={id} className="form-label">
      {label}
    </label>
    {children}
    {hint && !error && <p className="form-hint">{hint}</p>}
    {error && (
      <p className="form-error" role="alert" id={`${id}-error`}>
        {error}
      </p>
    )}
  </div>
);

const CurrencyInput: FC<{
  id: string;
  value: string;
  placeholder: string;
  error?: string;
  onValueChange: (nextValue: string) => void;
}> = ({ id, value, placeholder, error, onValueChange }) => {
  const [isFocused, setIsFocused] = useState(false);
  const displayValue = isFocused ? value : formatGroupedNumberInput(value);

  return (
    <input
      id={id}
      type="text"
      inputMode="decimal"
      className="form-control"
      value={displayValue}
      onChange={(e) => onValueChange(e.target.value)}
      onFocus={() => {
        setIsFocused(true);
        const normalized = normalizeNumericInput(value);
        if (normalized !== value) onValueChange(normalized);
      }}
      onBlur={() => {
        setIsFocused(false);
        const normalized = normalizeNumericInput(value);
        if (normalized !== value) onValueChange(normalized);
      }}
      aria-describedby={error ? `${id}-error` : undefined}
      placeholder={placeholder}
      autoComplete="off"
    />
  );
};

// ─── Main form ────────────────────────────────────────────────────────────────

export const CalculatorForm: FC<Props> = ({ form, errors, onChange, activePresetName, onApplyPreset }) => {
  const [selectedPresetId, setSelectedPresetId] = useState<StarterPresetId>(STARTER_PRESETS[0].id);
  const [showTargetSection, setShowTargetSection] = useState(false);

  useEffect(() => {
    if ((form.targetToday ?? '').trim() !== '') {
      setShowTargetSection(true);
    }
  }, [form.targetToday]);

  function field(key: keyof FormState) {
    return (e: ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
      onChange({ [key]: e.target.value } as Partial<FormState>);
  }

  function currencyField(key: 'principal' | 'contribution') {
    return (value: string) => onChange({ [key]: value } as Partial<FormState>);
  }

  return (
    <form
      className="calculator-form"
      onSubmit={(e) => e.preventDefault()}
      noValidate
      aria-label="Investment growth calculator"
    >
      {/* ── Quick Start Presets ───────────────────────────────────────────── */}
      <fieldset className="form-section">
        <legend className="form-section-title">Quick Start</legend>

        <div className="quickstart-row">
          <label className="sr-only" htmlFor="preset-selector">
            Starter preset
          </label>
          <select
            id="preset-selector"
            className="form-control quickstart-select"
            value={selectedPresetId}
            onChange={(e) => setSelectedPresetId(e.target.value as StarterPresetId)}
          >
            {STARTER_PRESETS.map((preset) => (
              <option key={preset.id} value={preset.id}>
                {preset.name}
              </option>
            ))}
          </select>
          <button
            type="button"
            className="btn btn-primary btn-sm quickstart-apply"
            onClick={() => onApplyPreset(selectedPresetId)}
          >
            Apply preset
          </button>
        </div>

        <p className="form-hint">Example assumptions for planning only.</p>
        {activePresetName && <p className="form-hint preset-active">Preset: {activePresetName}</p>}
      </fieldset>

      {/* ── Optional target ───────────────────────────────────────────────── */}
      <fieldset className="form-section">
        <button
          type="button"
          className="optional-section-toggle"
          aria-expanded={showTargetSection}
          onClick={() => setShowTargetSection((open) => !open)}
        >
          <span className="form-section-title optional-section-title">Target (Optional)</span>
          <span className={`chevron ${showTargetSection ? 'chevron--open' : ''}`} aria-hidden="true">
            ▾
          </span>
        </button>

        {showTargetSection && (
          <Field
            id="targetToday"
            label="Target in today&apos;s money"
            hint="Set a goal in today&apos;s purchasing power."
          >
            <div className="input-group">
              <span className="input-prefix">£</span>
              <CurrencyInput
                id="targetToday"
                value={form.targetToday ?? ''}
                onValueChange={(value) => onChange({ targetToday: value })}
                placeholder="e.g. 500,000"
              />
            </div>
          </Field>
        )}
      </fieldset>

      {/* ── Investment Setup ──────────────────────────────────────────────── */}
      <fieldset className="form-section">
        <legend className="form-section-title">Investment</legend>

        <Field
          id="principal"
          label="Initial Investment"
          error={errors.principal}
          hint="How much you're starting with. Can be £0."
        >
          <div className="input-group">
            <span className="input-prefix">£</span>
            <CurrencyInput
              id="principal"
              value={form.principal}
              onValueChange={currencyField('principal')}
              error={errors.principal}
              placeholder="0.00"
            />
          </div>
        </Field>

        <div className="form-row">
          <Field
            id="contribution"
            label="Regular Contribution"
            error={errors.contribution}
          >
            <div className="input-group">
              <span className="input-prefix">£</span>
              <CurrencyInput
                id="contribution"
                value={form.contribution}
                onValueChange={currencyField('contribution')}
                error={errors.contribution}
                placeholder="0.00"
              />
            </div>
          </Field>

          <Field id="contributionFrequency" label="Frequency">
            <select
              id="contributionFrequency"
              className="form-control"
              value={form.contributionFrequency}
              onChange={field('contributionFrequency')}
            >
              <option value="weekly">Weekly</option>
              <option value="monthly">Monthly</option>
              <option value="annual">Annual</option>
            </select>
          </Field>
        </div>
      </fieldset>

      {/* ── Growth Rate ───────────────────────────────────────────────────── */}
      <fieldset className="form-section">
        <legend className="form-section-title">Growth Rate</legend>

        <div className="form-row">
          <Field
            id="apr"
            label="Annual Interest Rate (APR)"
            error={errors.apr}
            hint="Nominal APR before compounding."
          >
            <div className="input-group">
              <input
                id="apr"
                type="number"
                inputMode="decimal"
                className="form-control"
                value={form.apr}
                onChange={field('apr')}
                min="0"
                max="999"
                step="any"
                aria-describedby={errors.apr ? 'apr-error' : undefined}
                placeholder="5.00"
              />
              <span className="input-suffix">%</span>
            </div>
          </Field>

          <Field id="compoundFrequency" label="Compounding">
            <select
              id="compoundFrequency"
              className="form-control"
              value={form.compoundFrequency}
              onChange={field('compoundFrequency')}
            >
              <option value="daily">Daily</option>
              <option value="monthly">Monthly</option>
              <option value="quarterly">Quarterly</option>
              <option value="annual">Annual</option>
            </select>
          </Field>
        </div>

        <div className="form-row">
          <Field
            id="inflationPercent"
            label="Inflation Rate"
            error={errors.inflationPercent}
            hint="Optional. Used for real-terms projections."
          >
            <div className="input-group">
              <input
                id="inflationPercent"
                type="number"
                inputMode="decimal"
                className="form-control"
                value={form.inflationPercent ?? ''}
                onChange={field('inflationPercent')}
                min="0"
                max="20"
                step="any"
                aria-describedby={errors.inflationPercent ? 'inflationPercent-error' : undefined}
                placeholder="0.00"
              />
              <span className="input-suffix">%</span>
            </div>
          </Field>

          <Field
            id="annualFeePercent"
            label="Annual Fee"
            error={errors.annualFeePercent}
            hint="Optional. Asset-based fee drag."
          >
            <div className="input-group">
              <input
                id="annualFeePercent"
                type="number"
                inputMode="decimal"
                className="form-control"
                value={form.annualFeePercent ?? ''}
                onChange={field('annualFeePercent')}
                min="0"
                max="10"
                step="any"
                aria-describedby={errors.annualFeePercent ? 'annualFeePercent-error' : undefined}
                placeholder="0.00"
              />
              <span className="input-suffix">%</span>
            </div>
          </Field>
        </div>
      </fieldset>

      {/* ── Time Period ───────────────────────────────────────────────────── */}
      <fieldset className="form-section">
        <legend className="form-section-title">Time Period</legend>

        {errors.duration && (
          <p className="form-error" role="alert">
            {errors.duration}
          </p>
        )}

        <div className="form-row">
          <Field id="years" label="Years" error={errors.years}>
            <input
              id="years"
              type="number"
              inputMode="numeric"
              className="form-control"
              value={form.years}
              onChange={field('years')}
              min="0"
              max="60"
              step="1"
              aria-describedby={errors.years ? 'years-error' : undefined}
              placeholder="10"
            />
          </Field>

          <Field
            id="months"
            label="Extra Months"
            error={errors.months}
            hint="0–11 additional months"
          >
            <input
              id="months"
              type="number"
              inputMode="numeric"
              className="form-control"
              value={form.months}
              onChange={field('months')}
              min="0"
              max="11"
              step="1"
              aria-describedby={errors.months ? 'months-error' : undefined}
              placeholder="0"
            />
          </Field>
        </div>
      </fieldset>

      {/* ── Contribution Timing ───────────────────────────────────────────── */}
      <fieldset className="form-section">
        <legend className="form-section-title">Contribution Timing</legend>

        <div className="timing-options" role="radiogroup" aria-label="Contribution timing">
          <label className={`timing-option ${form.timing === 'end' ? 'timing-option--active' : ''}`}>
            <input
              type="radio"
              name="timing"
              value="end"
              checked={form.timing === 'end'}
              onChange={() => onChange({ timing: 'end' })}
              className="sr-only"
            />
            <span className="timing-icon" aria-hidden="true">⬇</span>
            <span className="timing-label">End of period</span>
            <span className="timing-desc">Standard — interest accrues first</span>
          </label>

          <label className={`timing-option ${form.timing === 'start' ? 'timing-option--active' : ''}`}>
            <input
              type="radio"
              name="timing"
              value="start"
              checked={form.timing === 'start'}
              onChange={() => onChange({ timing: 'start' })}
              className="sr-only"
            />
            <span className="timing-icon" aria-hidden="true">⬆</span>
            <span className="timing-label">Start of period</span>
            <span className="timing-desc">Contribution earns full-period interest</span>
          </label>
        </div>
      </fieldset>

    </form>
  );
};
