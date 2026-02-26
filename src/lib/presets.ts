import type { CompoundFrequency } from '../types';

export type StarterPresetId =
  | 'savings-account'
  | 'low-cost-index-fund'
  | 'robo-investor'
  | 'high-growth-portfolio';

export interface StarterPreset {
  id: StarterPresetId;
  name: string;
  apr: number;
  annualFeePercent: number;
  inflationPercent: number;
  compoundFrequency: CompoundFrequency;
}

export const STARTER_PRESETS: StarterPreset[] = [
  {
    id: 'savings-account',
    name: 'Savings account',
    apr: 4.0,
    annualFeePercent: 0.0,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
  {
    id: 'low-cost-index-fund',
    name: 'Low-cost index fund',
    apr: 7.0,
    annualFeePercent: 0.2,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
  {
    id: 'robo-investor',
    name: 'Robo-investor',
    apr: 6.0,
    annualFeePercent: 0.8,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
  {
    id: 'high-growth-portfolio',
    name: 'High-growth portfolio',
    apr: 9.0,
    annualFeePercent: 1.0,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
];
