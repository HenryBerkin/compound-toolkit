import { useState, type FC } from 'react';
import type { CalcInputs, Scenario } from '../types';
import { formatGBP } from '../lib/format';

interface Props {
  scenarios: Scenario[];
  activeId: string | null;
  currentInputs: CalcInputs | null;
  onLoad: (scenario: Scenario) => void;
  onSave: (name: string) => void;
  onDelete: (id: string) => void;
  onDuplicate: (id: string) => void;
}

export const ScenarioManager: FC<Props> = ({
  scenarios,
  activeId,
  currentInputs,
  onLoad,
  onSave,
  onDelete,
  onDuplicate,
}) => {
  const [saveOpen, setSaveOpen] = useState(false);
  const [name, setName] = useState('');
  const [confirmDeleteId, setConfirmDeleteId] = useState<string | null>(null);

  function handleSave() {
    if (!currentInputs) return;
    onSave(name || 'My Scenario');
    setName('');
    setSaveOpen(false);
  }

  function handleDelete(id: string) {
    if (confirmDeleteId === id) {
      onDelete(id);
      setConfirmDeleteId(null);
    } else {
      setConfirmDeleteId(id);
    }
  }

  return (
    <section className="scenarios-section card" aria-label="Saved scenarios">
      <div className="scenarios-header">
        <h2 className="section-title">Saved Scenarios</h2>
        <button
          type="button"
          className="btn btn-primary btn-sm"
          onClick={() => setSaveOpen((o) => !o)}
          disabled={!currentInputs}
        >
          {saveOpen ? 'Cancel' : '+ Save Current'}
        </button>
      </div>

      {saveOpen && (
        <div className="scenario-save-form">
          <label htmlFor="scenario-name" className="sr-only">
            Scenario name
          </label>
          <input
            id="scenario-name"
            type="text"
            className="form-control"
            placeholder="Scenario name…"
            value={name}
            onChange={(e) => setName(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSave()}
            autoFocus
            maxLength={80}
          />
          <button
            type="button"
            className="btn btn-primary"
            onClick={handleSave}
            disabled={!name.trim()}
          >
            Save
          </button>
        </div>
      )}

      {scenarios.length === 0 ? (
        <p className="scenarios-empty">
          No saved scenarios yet. Configure the calculator and click <strong>Save Current</strong>.
        </p>
      ) : (
        <ul className="scenario-list" role="list">
          {scenarios.map((s) => {
            const totalMonths = s.inputs.years * 12 + s.inputs.months;
            const durationLabel =
              totalMonths % 12 === 0
                ? `${totalMonths / 12}yr`
                : `${Math.floor(totalMonths / 12)}yr ${totalMonths % 12}mo`;
            const inflationLabel = `${((s.inputs.inflationRate ?? 0) * 100).toFixed(2)}% inflation`;
            const feeLabel = `${((s.inputs.annualFeeRate ?? 0) * 100).toFixed(2)}% annual fee`;
            const presetLabel = s.presetName ? `Preset: ${s.presetName} · ` : '';

            return (
              <li
                key={s.id}
                className={`scenario-item ${s.id === activeId ? 'scenario-item--active' : ''}`}
              >
                <div className="scenario-info">
                  <span className="scenario-name">{s.name}</span>
                  <span className="scenario-meta">
                    {presetLabel}
                    {formatGBP(s.inputs.principal)} · {(s.inputs.apr * 100).toFixed(2)}% APR ·{' '}
                    {inflationLabel} · {feeLabel} · {durationLabel}
                  </span>
                </div>
                <div className="scenario-actions">
                  <button
                    type="button"
                    className="btn btn-ghost btn-xs"
                    onClick={() => onLoad(s)}
                    aria-label={`Load scenario ${s.name}`}
                  >
                    Load
                  </button>
                  <button
                    type="button"
                    className="btn btn-ghost btn-xs"
                    onClick={() => onDuplicate(s.id)}
                    aria-label={`Duplicate scenario ${s.name}`}
                  >
                    Copy
                  </button>
                  <button
                    type="button"
                    className={`btn btn-xs ${confirmDeleteId === s.id ? 'btn-danger' : 'btn-ghost'}`}
                    onClick={() => handleDelete(s.id)}
                    aria-label={`Delete scenario ${s.name}`}
                    onBlur={() => {
                      if (confirmDeleteId === s.id) setConfirmDeleteId(null);
                    }}
                  >
                    {confirmDeleteId === s.id ? 'Confirm?' : 'Delete'}
                  </button>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </section>
  );
};
