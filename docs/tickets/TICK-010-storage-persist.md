---
id: TICK-010
title: Enable navigator.storage.persist() for eviction-resistance
status: pending
priority: high
wave: 0
created: 2026-04-17
updated: 2026-04-17
plan: docs/plans/PLAN_data_persistence.md
test: null
linear:
  parent: ISO-40
  test: ""
depends-on: [TICK-009]
supersedes: []
shipped: ""
---

# TICK-010: Storage Persistence Opt-In

## Summary

Call `navigator.storage.persist()` once on boot after Dexie opens, and surface the grant state in the settings screen. Layer 2 of the three-layer durability strategy — best-effort browser eviction-resistance. Real durability still rides on the weekly backup (TICK-011).

## Acceptance Criteria

- [ ] `navigator.storage.persist()` called once per boot, after successful `db.open()`
- [ ] Result stored at `kv` key `storage:persistGranted` (boolean)
- [ ] Settings screen shows "Storage: persistent ✓" or "Storage: best-effort" based on the stored flag
- [ ] No prompt shown if the API is unavailable (older Safari); treated as best-effort
- [ ] Persist call doesn't block boot — fire-and-forget with a catch

## Agent Context

- Hook the call into the same boot path as TICK-009's `db.open()`. One place, one call.
- Do NOT prompt the user or add UI for requesting permission — browsers handle that themselves if needed.
- Firefox prompts the user. Accept whatever they answer; do not retry on deny.
- Safari/iOS: API exists but [WebKit eviction policy](https://webkit.org/blog/14403/updates-to-storage-policy/) still applies. Persist is not a guarantee here — don't imply otherwise in settings copy.
- Settings screen location: search for the current settings view in `index.html` (reset-data button area) — add the indicator there.
- Re-check the grant state on every boot. Don't cache it forever — the user may revoke.

## Implementation Notes

Tiny ticket — expect ~20 LOC. Kept separate from TICK-009 so that the Dexie migration can be reviewed/reverted independently of persist-API plumbing.

Settings copy suggestion: `"Storage: persistent"` (green check) or `"Storage: best-effort — back up regularly"` (amber).

## Ship Notes

_(pending)_
