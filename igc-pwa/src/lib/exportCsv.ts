type CsvCell = string | number | null | undefined;

const DECIMALS = 6;

function formatCell(value: CsvCell): string {
  if (value == null) return '';
  if (typeof value === 'number') {
    if (!Number.isFinite(value)) return '';
    return value.toFixed(DECIMALS);
  }
  return value;
}

function escapeCell(value: string): string {
  if (value.includes('"') || value.includes(',') || value.includes('\n') || value.includes('\r')) {
    return `"${value.replace(/"/g, '""')}"`;
  }
  return value;
}

export function buildCsv(headers: string[], rows: CsvCell[][]): string {
  const headerLine = headers.map((h) => escapeCell(h)).join(',');
  const dataLines = rows.map((row) => row.map((cell) => escapeCell(formatCell(cell))).join(','));
  return [headerLine, ...dataLines].join('\n');
}

export function downloadCsv(filename: string, csv: string): void {
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = filename;
  anchor.rel = 'noopener';
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
  URL.revokeObjectURL(url);
}
