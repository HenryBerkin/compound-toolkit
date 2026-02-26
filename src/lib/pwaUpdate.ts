import { registerSW } from 'virtual:pwa-register';

const UPDATE_EVENT = 'cgt:pwa-update-available';

let registered = false;
let updateSW: ((reloadPage?: boolean) => Promise<void>) | null = null;

export function initPwaUpdateHandling(): void {
  if (registered || typeof window === 'undefined') return;

  updateSW = registerSW({
    immediate: true,
    // Trigger a lightweight UI prompt when a new SW is waiting.
    onNeedRefresh() {
      window.dispatchEvent(new CustomEvent(UPDATE_EVENT));
    },
  });

  registered = true;
}

export function onPwaUpdateAvailable(listener: () => void): () => void {
  const handler = () => listener();
  window.addEventListener(UPDATE_EVENT, handler);
  return () => window.removeEventListener(UPDATE_EVENT, handler);
}

export async function applyPwaUpdate(): Promise<void> {
  if (updateSW) {
    await updateSW(true);
    return;
  }
  window.location.reload();
}
