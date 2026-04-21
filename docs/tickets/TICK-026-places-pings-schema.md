---
id: TICK-026
title: Dexie schema — places + locationPings collections
status: pending
priority: medium
wave: 9
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: null
linear:
  parent: ISO-60
  test: ""
depends-on: [TICK-009]
supersedes: []
shipped: ""
---

# TICK-026: Dexie schema — places + locationPings collections

## Summary

Add two new Dexie collections to support the opportunistic-ping stay model: `places` (name + coords + radiusM, no exposure data) and `locationPings` (append-only ping log with timestamp, coords, accuracy). No persisted `stays` collection — stays are reconstructed at query time in TICK-028. Schema-only ticket; no UI and no capture path yet. See `PLAN_trigger_trap.md` §Change 2.

## Acceptance Criteria

- [ ] Dexie version bumped; `places` store defined with fields `id`, `name` (nullable), `lat`, `lon`, `radiusM`, `createdAt`
- [ ] Dexie `locationPings` store defined with fields `id`, `ts`, `lat`, `lon`, `accuracyM` (nullable); index on `ts`
- [ ] Migration step is a no-op for existing users (both stores created empty)
- [ ] `places` has no `exposures` field, no tags, no severity flags — schema enforces the trigger-trap commitment
- [ ] SW cache bumped; existing data loads without error after upgrade

## Agent Context

- Entire app is in `index.html`. Dexie init/migration block only — no UI.
- Constant `PING_RADIUS_M_DEFAULT = 75` is referenced by downstream tickets (TICK-027, TICK-028); define in a shared consts block the export/capture paths can import.
- Do not add any reverse-geocoding, altitude lookup, or exposure-tagging fields on `places` even speculatively. Plan is explicit: name + coords only.
- Depends on TICK-009 (Dexie migration, shipped).

## Implementation Notes

The whole point of keeping `places` minimal is that any stored field becomes a hypothesis the analysis layer confirms against itself. Future sessions that want to "just add a tags field" should be blocked by this ticket's explicit scope.

## Ship Notes

_(pending)_
