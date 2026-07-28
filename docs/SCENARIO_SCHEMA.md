# IGC portable scenario contract

Status: Accepted schema version 1
Owner: Product Manager and Technical Lead
Applies to: Shared / iOS / Web

## Purpose

`shared/schemas/scenario-v1.schema.json` defines the portable meaning of a saved IGC
scenario. It is a product data contract, not a promise of cloud sync or export in
version 1.0.

The accepted example is `shared/examples/scenario-v1.example.json`.

## Version 1 rules

- `schemaVersion` is the integer `1`.
- `id` is an opaque, stable, non-empty string. New native records should use UUIDs.
  Existing web fallback identifiers remain valid and must not be rewritten merely for
  formatting.
- `name` is trimmed, non-empty user-visible text, with a 120-character portable limit.
- `currency` is explicitly `GBP`. This makes the data currency-ready without adding
  currency selection or conversion.
- `inputs` uses the canonical fields, decimal-rate units, enums, and validation bounds
  from `docs/CALCULATION_SPEC.md`.
- `presetId` is a stable preset identifier or `null` for Custom. Names are derived
  display copy and are not persisted as contract identity.
- `targetToday`, when present, is a non-negative GBP amount in today's purchasing
  power.
- `createdAt` and `updatedAt` are ISO 8601 timestamps normalised to UTC for interchange.
- Absence and zero are distinct where a field is optional; required calculation rates
  are stored explicitly even when zero.

In addition to JSON Schema validation, `principal` and `contribution` cannot both be
zero, and the total duration must be 1 through 720 months.

## Persistence boundaries

The native iOS persistence mechanism and browser localStorage representation are
platform-specific. Both must be able to map to this contract without changing field
meaning or raw values.

The current PWA records predate `schemaVersion`, `currency`, and stable `presetId`; they
store a display `presetName`. That representation is legacy web storage, not schema
version 1. A separately tested Web task must define read migration, fallback handling,
and rollback before changing the `cgt-scenarios` storage payload. IGC-009 does not
rewrite user browser data.

Native iOS 1.0 should persist schema version 1 from its first saved scenario. The model
must support multiple saved scenarios even though two-scenario comparison is deferred
to native 1.1.

## Evolution and synchronisation guardrails

- Treat unknown future schema versions as unsupported; do not partially decode them as
  version 1.
- Preserve unknown records until a deliberate recovery or deletion decision; avoid
  destructive migration fallback.
- A breaking field, unit, or semantic change requires a new schema version and migration
  tests.
- Do not make local database keys, browser storage keys, Swift type names, or
  TypeScript type names part of the portable format.
- Do not introduce accounts, backend identifiers, sync metadata, or entitlement data
  into scenarios speculatively.
- If export or sync is later approved, define container, conflict, deletion, and
  privacy semantics before treating this schema as a public interchange format.
