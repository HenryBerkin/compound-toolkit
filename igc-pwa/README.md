# IGC web edition

Historical repository/package name: **Compound Toolkit**.

A progressive web app (PWA) for modelling compound growth scenarios with configurable contribution schedules and compounding frequencies.

Built with Vite, React, and TypeScript.

This is a supported responsive IGC product surface and the verified behavioural
reference for the native rebuild. Project-wide status, shared specifications, tasks,
and decisions live one directory above.

---

## 🚀 Features

- Compound growth projections
- Configurable:
  - Initial principal
  - Recurring contributions
  - Contribution frequency
  - Compounding frequency
  - Duration
  - Contribution timing (start vs end of period)
- Yearly breakdown table
- Interactive growth chart
- Scenario save/load (browser local storage)
- Offline-capable PWA
- Dark mode support

---

## 🧱 Tech Stack

- Vite
- React
- TypeScript
- PWA (service worker + manifest)

---

## 📦 Getting Started

Install dependencies:

npm install

Run development server:

npm run dev

Run type-checking and tests:

npm run lint

npm test

---

## 🏗 Build

Create production build:

npm run build

Preview production build locally:

npm run preview

---

## 📂 Project Structure

igc-pwa/
├── src/
│   ├── components/    # UI components
│   ├── hooks/         # Custom React hooks
│   ├── lib/           # Pure calculation logic + utilities
│   └── main.tsx
├── public/            # PWA assets (manifest, icons)
├── docs/              # Roadmap + planning notes
├── package.json
├── tsconfig.json
└── vite.config.ts

---

## 🧠 Engineering Principles

- Calculation logic in `src/lib/` must remain UI-independent.
- All projection math should be covered by unit tests.
- Internal calculations use full precision.
- Rounding occurs only at presentation/display level.
- Generated folders (`node_modules/`, `dist/`, `*.tsbuildinfo`) are ignored via `.gitignore`.

---

## 🛣 Roadmap

The checklist below is preserved historical PWA documentation and is not the current
IGC roadmap. See `../ROADMAP.md` for current plans.

- [ ] Expand calculation engine test coverage
- [ ] Add inflation-adjusted projections
- [ ] Add annual fee drag modelling
- [ ] Add goal-based contribution mode
- [ ] Add multi-scenario comparison mode
- [ ] Add export (CSV / summary image)

---

## ⚠️ Disclaimer

This tool provides projections based on user inputs and mathematical compounding formulas. It does not account for market volatility, taxes, or real-world investment risk unless explicitly configured.

For educational and planning purposes only.

## Icon tooling

The tracked PNG files are the approved IGC-branded PWA icons. `npm run icons` is a
historical placeholder generator and will replace several of them with an arrow design;
do not run it as part of normal setup.
