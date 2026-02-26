# Architectural Decisions

## Inflation Modelling
Decision: Dual-line nominal + real projection.

Reason:
- Preserves nominal integrity.
- Avoids distorting APR.
- Enables long-term realism without breaking engine math.

## Fee Modelling
Decision: Asset-based fee drag (not APR subtraction).

Reason:
- Mathematically cleaner.
- Reflects real-world fee charging.
- Extensible to performance fees in future.