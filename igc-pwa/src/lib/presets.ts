import type { CompoundFrequency } from '../types';

export type StarterPresetId =
  | 'global-index-diy'
  | 'balanced-portfolio'
  | 'equity-heavy-portfolio'
  | 'savings-account';

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
    id: 'global-index-diy',
    name: 'Global index (DIY) | 7% APR, 0.40% fee',
    apr: 7.0,
    annualFeePercent: 0.4,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
  {
    id: 'balanced-portfolio',
    name: 'Balanced portfolio | 6% APR, 0.75% fee',
    apr: 6.0,
    annualFeePercent: 0.75,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
  {
    id: 'equity-heavy-portfolio',
    name: 'Equity-heavy portfolio | 9% APR, 1.00% fee',
    apr: 9.0,
    annualFeePercent: 1.0,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
  {
    id: 'savings-account',
    name: 'Savings account | 4% APR',
    apr: 4.0,
    annualFeePercent: 0.0,
    inflationPercent: 3.0,
    compoundFrequency: 'monthly',
  },
];
