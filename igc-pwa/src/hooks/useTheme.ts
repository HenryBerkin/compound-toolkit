import { useState, useEffect } from 'react';

type Theme = 'light' | 'dark';

function getInitialTheme(): Theme {
  try {
    const stored = localStorage.getItem('cgt-theme');
    if (stored === 'dark' || stored === 'light') return stored;
    return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
  } catch {
    return 'light';
  }
}

export function useTheme() {
  const [theme, setTheme] = useState<Theme>(getInitialTheme);

  useEffect(() => {
    document.documentElement.setAttribute('data-theme', theme);
    try {
      localStorage.setItem('cgt-theme', theme);
    } catch {
      // storage unavailable — ignore
    }
  }, [theme]);

  const toggleTheme = () => setTheme((t) => (t === 'light' ? 'dark' : 'light'));

  return { theme, toggleTheme };
}
