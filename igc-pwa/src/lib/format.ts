/**
 * format.ts — Locale-aware formatting utilities.
 * Locale: en-GB, currency: GBP.
 * All monetary display values are rounded to 2 dp at the point of formatting.
 */

const CURRENCY_FORMATTER = new Intl.NumberFormat('en-GB', {
  style: 'currency',
  currency: 'GBP',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

const CURRENCY_COMPACT_FORMATTER = new Intl.NumberFormat('en-GB', {
  style: 'currency',
  currency: 'GBP',
  notation: 'compact',
  minimumFractionDigits: 0,
  maximumFractionDigits: 1,
});

const NUMBER_FORMATTER = new Intl.NumberFormat('en-GB', {
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

/** Format a number as GBP currency to 2 decimal places. */
export function formatGBP(value: number): string {
  return CURRENCY_FORMATTER.format(value);
}

/** Compact GBP format for axis labels (e.g. £1.2M, £340K). */
export function formatGBPCompact(value: number): string {
  return CURRENCY_COMPACT_FORMATTER.format(value);
}

/** Format a number to 2 decimal places without currency symbol. */
export function formatNumber(value: number): string {
  return NUMBER_FORMATTER.format(value);
}

/** Format an APR decimal (e.g. 0.05) as a percentage string "5.00%". */
export function formatPercent(value: number, decimals = 2): string {
  return `${(value * 100).toFixed(decimals)}%`;
}

/** Short month name from 1-indexed month number. */
export const MONTH_NAMES = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

export function monthName(monthNumber: number): string {
  return MONTH_NAMES[(monthNumber - 1) % 12];
}
