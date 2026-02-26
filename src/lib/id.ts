function randomSuffix(): string {
  if (
    typeof globalThis.crypto !== 'undefined'
    && typeof globalThis.crypto.getRandomValues === 'function'
  ) {
    const bytes = new Uint8Array(8);
    globalThis.crypto.getRandomValues(bytes);
    return Array.from(bytes, (b) => b.toString(16).padStart(2, '0')).join('');
  }

  return Math.random().toString(36).slice(2, 12);
}

export function createId(): string {
  if (
    typeof globalThis.crypto !== 'undefined'
    && typeof globalThis.crypto.randomUUID === 'function'
  ) {
    return globalThis.crypto.randomUUID();
  }

  return `${Date.now().toString(36)}-${randomSuffix()}`;
}
