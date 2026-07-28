import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import './index.css';
import App from './App';
import { initPwaUpdateHandling } from './lib/pwaUpdate';

// Register SW update listeners once at app boot.
initPwaUpdateHandling();

const root = document.getElementById('root');
if (!root) throw new Error('Root element not found');

createRoot(root).render(
  <StrictMode>
    <App />
  </StrictMode>,
);
