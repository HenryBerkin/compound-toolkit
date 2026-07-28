const GROUPING_SEPARATOR_PATTERN = /[,\s]/g;
const DECIMAL_NUMBER_PATTERN = /^([+-]?)(\d+)(?:\.(\d+))?$/;
const GROUPED_NUMBER_FORMATTER = new Intl.NumberFormat('en-GB', {
  maximumFractionDigits: 20,
});

/** Remove common thousands separators and surrounding whitespace. */
export function normalizeNumericInput(value: string): string {
  return value.trim().replace(GROUPING_SEPARATOR_PATTERN, '');
}

/**
 * Parse a numeric string leniently after removing grouping separators.
 * Returns NaN for invalid or empty values.
 */
export function parseLooseNumber(value: string): number {
  const normalized = normalizeNumericInput(value);
  if (
    normalized === ''
    || normalized === '.'
    || normalized === '+'
    || normalized === '-'
  ) {
    return Number.NaN;
  }
  const parsed = Number(normalized);
  return Number.isFinite(parsed) ? parsed : Number.NaN;
}

/** Format a numeric input string with en-GB thousands separators for display. */
export function formatGroupedNumberInput(value: string): string {
  const normalized = normalizeNumericInput(value);
  if (normalized === '') return '';

  const decimalMatch = DECIMAL_NUMBER_PATTERN.exec(normalized);
  if (decimalMatch) {
    const sign = decimalMatch[1];
    const whole = decimalMatch[2];
    const fraction = decimalMatch[3];
    const groupedWhole = Number(whole).toLocaleString('en-GB', {
      maximumFractionDigits: 0,
    });
    return `${sign}${groupedWhole}${fraction !== undefined ? `.${fraction}` : ''}`;
  }

  const parsed = Number(normalized);
  if (!Number.isFinite(parsed)) return value;
  return GROUPED_NUMBER_FORMATTER.format(parsed);
}
