import { useState, useEffect, useCallback } from 'react';
import type { CalcInputs, CalcResult, FormState, Scenario } from './types';
import { calculate, parseAndValidate, DEFAULT_FORM, inputsToForm } from './lib/calc';
import { applyPwaUpdate, onPwaUpdateAvailable } from './lib/pwaUpdate';
import { STARTER_PRESETS, type StarterPresetId } from './lib/presets';
import { useDebounce } from './hooks/useDebounce';
import { useTheme } from './hooks/useTheme';
import { useScenarios } from './hooks/useScenarios';

import { DarkModeToggle } from './components/DarkModeToggle';
import { CalculatorForm } from './components/CalculatorForm';
import { ResultsSummary } from './components/ResultsSummary';
import { GrowthChart } from './components/GrowthChart';
import { BreakdownTable } from './components/BreakdownTable';
import { ScenarioManager } from './components/ScenarioManager';
import { AssumptionsPanel } from './components/AssumptionsPanel';

const ONBOARDING_DISMISSED_KEY = 'cgt-onboarding-dismissed';

export default function App() {
  const { theme, toggleTheme } = useTheme();
  const { scenarios, saveScenario, deleteScenario, duplicateScenario } = useScenarios();

  const [form, setForm] = useState<FormState>(DEFAULT_FORM);
  const [result, setResult] = useState<CalcResult | null>(null);
  const [validInputs, setValidInputs] = useState<CalcInputs | null>(null);
  const [errors, setErrors] = useState<ReturnType<typeof parseAndValidate>['errors']>({});
  const [activeScenarioId, setActiveScenarioId] = useState<string | null>(null);
  const [showUpdatePrompt, setShowUpdatePrompt] = useState(false);
  const [activePresetName, setActivePresetName] = useState<string | null>(null);
  const [showOnboarding, setShowOnboarding] = useState(false);

  const debouncedForm = useDebounce(form, 280);

  // ── Re-run calculation whenever form changes (debounced) ──────────────────
  useEffect(() => {
    const parsed = parseAndValidate(debouncedForm);
    setErrors(parsed.errors);
    if (parsed.isValid && parsed.inputs) {
      setValidInputs(parsed.inputs);
      setResult(calculate(parsed.inputs));
    } else {
      setValidInputs(null);
      setResult(null);
    }
  }, [debouncedForm]);

  // ── Immediately calculate on mount with defaults ──────────────────────────
  useEffect(() => {
    const parsed = parseAndValidate(DEFAULT_FORM);
    if (parsed.isValid && parsed.inputs) {
      setValidInputs(parsed.inputs);
      setResult(calculate(parsed.inputs));
    }
  }, []);

  useEffect(() => onPwaUpdateAvailable(() => setShowUpdatePrompt(true)), []);

  useEffect(() => {
    try {
      const dismissed = localStorage.getItem(ONBOARDING_DISMISSED_KEY) === '1';
      setShowOnboarding(!dismissed && scenarios.length === 0);
    } catch {
      setShowOnboarding(scenarios.length === 0);
    }
  }, [scenarios.length]);

  const handleFormChange = useCallback((patch: Partial<FormState>) => {
    setForm((prev) => ({ ...prev, ...patch }));
    setActiveScenarioId(null);
  }, []);

  const handleApplyPreset = useCallback((presetId: StarterPresetId) => {
    const preset = STARTER_PRESETS.find((item) => item.id === presetId);
    if (!preset) return;

    setForm((prev) => ({
      ...prev,
      apr: String(preset.apr),
      inflationPercent: String(preset.inflationPercent),
      annualFeePercent: String(preset.annualFeePercent),
      compoundFrequency: preset.compoundFrequency,
    }));
    setActivePresetName(preset.name);
    setActiveScenarioId(null);
  }, []);

  const handleLoadScenario = useCallback((scenario: Scenario) => {
    setForm(inputsToForm(scenario.inputs));
    setActiveScenarioId(scenario.id);
    setActivePresetName(scenario.presetName ?? null);
  }, []);

  const handleSaveScenario = useCallback(
    (name: string) => {
      if (!validInputs) return;
      saveScenario(name, validInputs, { presetName: activePresetName ?? undefined });
    },
    [activePresetName, validInputs, saveScenario],
  );

  const dismissOnboarding = useCallback(() => {
    setShowOnboarding(false);
    try {
      localStorage.setItem(ONBOARDING_DISMISSED_KEY, '1');
    } catch {
      // localStorage unavailable — ignore
    }
  }, []);

  const focusPresetSelector = useCallback(() => {
    const select = document.getElementById('preset-selector') as HTMLSelectElement | null;
    if (!select) return;
    select.scrollIntoView({ behavior: 'smooth', block: 'center' });
    select.focus();
  }, []);

  const hasErrors = Object.keys(errors).length > 0;

  return (
    <div className="app">
      {showUpdatePrompt && (
        <div className="update-banner" role="status" aria-live="polite">
          <span className="update-banner__text">Update available</span>
          <div className="update-banner__actions">
            <button
              type="button"
              className="btn btn-primary btn-sm"
              onClick={() => {
                void applyPwaUpdate();
              }}
            >
              Refresh
            </button>
            <button
              type="button"
              className="btn btn-ghost btn-sm"
              onClick={() => setShowUpdatePrompt(false)}
            >
              Dismiss
            </button>
          </div>
        </div>
      )}

      {/* ── Header ──────────────────────────────────────────────────────────── */}
      <header className="app-header">
        <div className="header-inner">
          <div className="header-brand">
            <svg
              className="brand-icon"
              viewBox="0 0 40 40"
              fill="none"
              aria-hidden="true"
              focusable="false"
            >
              <rect width="40" height="40" rx="10" fill="var(--color-primary)" />
              <rect x="5" y="27" width="6" height="9" rx="1.5" fill="rgba(255,255,255,0.6)" />
              <rect x="13" y="21" width="6" height="15" rx="1.5" fill="rgba(255,255,255,0.75)" />
              <rect x="21" y="15" width="6" height="21" rx="1.5" fill="rgba(255,255,255,0.88)" />
              <rect x="29" y="8" width="6" height="28" rx="1.5" fill="rgba(255,255,255,1)" />
              <polyline
                points="8,24 16,18 24,12 32,5"
                stroke="white"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
              <circle cx="8" cy="24" r="2" fill="white" />
              <circle cx="16" cy="18" r="2" fill="white" />
              <circle cx="24" cy="12" r="2" fill="white" />
              <circle cx="32" cy="5" r="2" fill="white" />
            </svg>
            <div>
              <h1 className="brand-title">Compound Growth Toolkit</h1>
              <p className="brand-subtitle">Investment growth calculator · Works offline</p>
            </div>
          </div>
          <DarkModeToggle theme={theme} onToggle={toggleTheme} />
        </div>
      </header>

      {/* ── Main ────────────────────────────────────────────────────────────── */}
      <main className="app-main">
        {showOnboarding && (
          <section className="onboarding-card card" aria-label="Getting started">
            <p className="onboarding-copy">
              Model growth including fees and inflation. Start with a preset, then tweak inputs.
            </p>
            <div className="onboarding-actions">
              <button type="button" className="btn btn-primary btn-sm" onClick={focusPresetSelector}>
                Choose a preset
              </button>
              <button type="button" className="btn btn-ghost btn-sm" onClick={dismissOnboarding}>
                Dismiss
              </button>
            </div>
          </section>
        )}

        <div className="app-layout">
          {/* Left column: form */}
          <aside className="form-column">
            <div className="card form-card">
              <CalculatorForm
                form={form}
                errors={errors}
                onChange={handleFormChange}
                activePresetName={activePresetName}
                onApplyPreset={handleApplyPreset}
              />
            </div>
          </aside>

          {/* Right column: results */}
          <section className="results-column" aria-label="Results">
            {hasErrors && !result && (
              <div className="error-banner" role="alert">
                <span aria-hidden="true">⚠</span> Please fix the highlighted errors to see results.
              </div>
            )}

            {result && validInputs && (
              <>
                <ResultsSummary result={result} />
                <GrowthChart inputs={validInputs} result={result} />
                <BreakdownTable result={result} />
              </>
            )}
          </section>
        </div>

        {/* Full-width lower sections */}
        <div className="app-lower">
          <ScenarioManager
            scenarios={scenarios}
            activeId={activeScenarioId}
            currentInputs={validInputs}
            onLoad={handleLoadScenario}
            onSave={handleSaveScenario}
            onDelete={deleteScenario}
            onDuplicate={duplicateScenario}
          />

          {validInputs && (
            <AssumptionsPanel compoundFrequency={validInputs.compoundFrequency} />
          )}
        </div>
      </main>

      {/* ── Footer ──────────────────────────────────────────────────────────── */}
      <footer className="app-footer">
        <p>
          Compound Growth Toolkit — illustrative projections only, not financial advice.&nbsp;
          Assumes constant APR, inflation and fee rates; excludes tax and market volatility.
        </p>
      </footer>
    </div>
  );
}
