---
id: TICK-012
title: JSON import for recovery
status: pending
priority: high
wave: 0
created: 2026-04-17
updated: 2026-04-17
plan: docs/plans/PLAN_data_persistence.md
test: null
linear:
  parent: ISO-42
  test: ""
depends-on: [TICK-009]
supersedes: []
shipped: ""
---

# TICK-012: JSON Import for Recovery

## Summary

Settings-screen button to restore a JSON backup produced by TICK-011. Closes the durability loop — without import, the weekly backups are write-only. Supports both merge (keep local, add missing) and replace (wipe + restore) modes, with a two-tap confirmation gate.

## Acceptance Criteria

- [ ] Settings screen has "Import from JSON" button → file picker (`accept="application/json"`)
- [ ] Payload validated against `{ version: 1, rows: [...] }` shape; invalid files rejected with a specific error
- [ ] Preview step shows row counts by prefix (`entry:`, `meal:entry:`, `pin`, other) and date range
- [ ] Two-tap confirmation: Merge (default) or Replace; second tap requires "I understand" chip
- [ ] Success summary: "Imported N rows; M skipped as duplicates"

## Agent Context

- Merge semantics: skip on key collision. Do NOT implement "newer wins" in v1 — just skip. Note in copy.
- Replace semantics: `kv.clear()` then bulk-put payload rows.
- PIN is part of the dataset — imported backups carry the PIN from their source. If the import's PIN differs from the current device's PIN, the user is locked out until they re-enter the imported PIN. This is intentional and documented in the confirm dialog.
- Wrap the whole import in one Dexie transaction. On any error, abort.
- Do NOT partial-merge fields within a row. Keys are atomic.
- File reader: use `FileReader.readAsText`, not streaming. Payloads will stay under ~50 MB for years.

## Implementation Notes

This ticket is the most user-facing risk in Stage 0 — a mis-tap that Replaces with a stale backup destroys recent data. Two-tap gate is non-negotiable. Consider wording: "This will replace everything. You'll lose anything logged since this backup was made. Tap 'I understand' to continue."

Recovery path after the lockout edge case: user restores via PIN reset flow (current behavior — `DB.remove('pin')` path at `index.html:657`). Not a new feature, just confirm the flow still works after import.

## Ship Notes

_(pending)_
