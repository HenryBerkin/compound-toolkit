import { describe, expect, it } from 'vitest';
import contractJson from '../../../shared/fixtures/calculation-v1.json';
import type {
  CalcInputs,
  CompoundFrequency,
  ContributionFrequency,
  ContributionTiming,
  FormState,
} from '../types';
import {
  calculate,
  effectiveMonthlyContribution,
  effectiveMonthlyRate,
  parseAndValidate,
} from './calc';

interface ContractInput {
  principal: number;
  contribution: number;
  contributionFrequency: ContributionFrequency;
  apr: number;
  inflationRate: number;
  annualFeeRate: number;
  compoundFrequency: CompoundFrequency;
  years: number;
  months: number;
  timing: ContributionTiming;
}

interface NumericRecord {
  [key: string]: number;
}

interface CalculationCase {
  id: string;
  input: ContractInput;
  expectedMonthlyRate: number;
  expectedMonthlyContribution: number;
  expected: NumericRecord & {
    monthlyCount: number;
    yearlyCount: number;
  };
  monthlyCheckpoints: Array<NumericRecord & { period: number }>;
  yearlyCheckpoints: Array<NumericRecord & { year: number }>;
}

interface ValidationCase {
  id: string;
  candidate: ContractInput;
  valid: boolean;
  errorFields: string[];
}

interface Contract {
  contractVersion: number;
  currency: string;
  tolerances: {
    absolute: number;
    relative: number;
    rateAbsolute: number;
  };
  calculationCases: CalculationCase[];
  validationCases: ValidationCase[];
}

const contract = contractJson as Contract;

function expectWithinTolerance(actual: number, expected: number): void {
  const allowed = Math.max(
    contract.tolerances.absolute,
    contract.tolerances.relative * Math.max(1, Math.abs(expected)),
  );
  expect(
    Math.abs(actual - expected),
    `expected ${String(actual)} to be within ${String(allowed)} of ${String(expected)}`,
  ).toBeLessThanOrEqual(allowed);
}

function formFromCanonical(input: ContractInput): FormState {
  return {
    principal: String(input.principal),
    contribution: String(input.contribution),
    contributionFrequency: input.contributionFrequency,
    apr: String(input.apr * 100),
    inflationPercent: String(input.inflationRate * 100),
    annualFeePercent: String(input.annualFeeRate * 100),
    compoundFrequency: input.compoundFrequency,
    years: String(input.years),
    months: String(input.months),
    timing: input.timing,
  };
}

describe('shared calculation contract v1', () => {
  it('identifies the accepted contract and currency', () => {
    expect(contract.contractVersion).toBe(1);
    expect(contract.currency).toBe('GBP');
  });

  for (const fixture of contract.calculationCases) {
    it(`reproduces ${fixture.id}`, () => {
      const input: CalcInputs = fixture.input;
      const result = calculate(input);

      expect(
        Math.abs(
          effectiveMonthlyRate(input.apr, input.compoundFrequency)
          - fixture.expectedMonthlyRate,
        ),
      ).toBeLessThanOrEqual(contract.tolerances.rateAbsolute);
      expectWithinTolerance(
        effectiveMonthlyContribution(input.contribution, input.contributionFrequency),
        fixture.expectedMonthlyContribution,
      );

      for (const [field, expected] of Object.entries(fixture.expected)) {
        if (field === 'monthlyCount') {
          expect(result.monthlyBreakdown).toHaveLength(expected);
        } else if (field === 'yearlyCount') {
          expect(result.yearlyBreakdown).toHaveLength(expected);
        } else {
          const actual = result[field as keyof typeof result];
          expect(typeof actual).toBe('number');
          expectWithinTolerance(actual as number, expected);
        }
      }

      for (const checkpoint of fixture.monthlyCheckpoints) {
        const actual = result.monthlyBreakdown.find((row) => row.period === checkpoint.period);
        expect(actual).toBeDefined();
        for (const [field, expected] of Object.entries(checkpoint)) {
          expectWithinTolerance(actual?.[field as keyof typeof actual] as number, expected);
        }
      }

      for (const checkpoint of fixture.yearlyCheckpoints) {
        const actual = result.yearlyBreakdown.find((row) => row.year === checkpoint.year);
        expect(actual).toBeDefined();
        for (const [field, expected] of Object.entries(checkpoint)) {
          expectWithinTolerance(actual?.[field as keyof typeof actual] as number, expected);
        }
      }
    });
  }

  for (const fixture of contract.validationCases) {
    it(`reproduces validation case ${fixture.id}`, () => {
      const result = parseAndValidate(formFromCanonical(fixture.candidate));
      expect(result.isValid).toBe(fixture.valid);
      expect(Object.keys(result.errors).sort()).toEqual([...fixture.errorFields].sort());
    });
  }
});
