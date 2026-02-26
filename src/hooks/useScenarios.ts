import { useState, useEffect } from 'react';
import type { CalcInputs, Scenario } from '../types';
import { createId } from '../lib/id';

const STORAGE_KEY = 'cgt-scenarios';

function loadFromStorage(): Scenario[] {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? (JSON.parse(raw) as Scenario[]) : [];
  } catch {
    return [];
  }
}

function saveToStorage(scenarios: Scenario[]): void {
  try {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(scenarios));
  } catch {
    // storage unavailable — ignore
  }
}

export function useScenarios() {
  const [scenarios, setScenarios] = useState<Scenario[]>(loadFromStorage);

  useEffect(() => {
    saveToStorage(scenarios);
  }, [scenarios]);

  function saveScenario(
    name: string,
    inputs: CalcInputs,
    meta?: { presetName?: string },
  ): Scenario {
    const now = new Date().toISOString();
    const scenario: Scenario = {
      id: createId(),
      name: name.trim() || 'Untitled',
      inputs,
      presetName: meta?.presetName,
      createdAt: now,
      updatedAt: now,
    };
    setScenarios((prev) => [...prev, scenario]);
    return scenario;
  }

  function deleteScenario(id: string): void {
    setScenarios((prev) => prev.filter((s) => s.id !== id));
  }

  function duplicateScenario(id: string): Scenario | undefined {
    const source = scenarios.find((s) => s.id === id);
    if (!source) return undefined;
    const now = new Date().toISOString();
    const copy: Scenario = {
      ...source,
      id: createId(),
      name: `${source.name} (Copy)`,
      createdAt: now,
      updatedAt: now,
    };
    setScenarios((prev) => [...prev, copy]);
    return copy;
  }

  return { scenarios, saveScenario, deleteScenario, duplicateScenario };
}
