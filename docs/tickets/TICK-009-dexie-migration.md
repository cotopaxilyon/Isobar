---
id: TICK-009
title: Dexie.js migration from localStorage
status: pending
priority: high
wave: 0
created: 2026-04-17
updated: 2026-04-17
plan: docs/plans/PLAN_data_persistence.md
test: null
linear:
  parent: ISO-39
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-009: Dexie.js Migration from localStorage

## Summary

Replace the `localStorage`-backed `DB` abstraction with an IndexedDB-backed version using Dexie.js. Removes the ~5 MB quota ceiling that would eventually destroy the clinical dataset as per-entry payloads grow in later waves. Foundation ticket for Stage 0 — every later persistence ticket depends on this.

## Acceptance Criteria

- [ ] Dexie is vendored locally (no CDN) and cached by the service worker
- [ ] `DB.get / set / remove / keys / allEntries` all return Promises; every caller awaits
- [ ] One-shot boot migration copies all localStorage keys into the `kv` IDB table idempotently
- [ ] localStorage rows remain in place for this release (rollback safety net)
- [ ] SW cache version bumped

## Agent Context

- Single-file PWA; all code lives in `index.html`.
- `DB` abstraction is at `index.html:527-537`. The only storage surface in the app — no direct `localStorage.*` calls exist outside `DB` except `index.html:1566` (a reset path) and two calls inside `DB` itself.
- Schema: one Dexie store `kv` with primary key `&key`. Row shape `{ key, value, updatedAt }`.
- Callers at `index.html:573, 603, 630, 657, 1114, 1115, 1361, 1362, 1370, 1418, 1448, 1566, 1616, 1617, 1620, 1628, 1629, 1647, 1688, 1695, 1698, 1699, 1700, 1772` — all become `await DB.*`. Mechanical change but touches many call sites; verify every one.
- Do NOT add a typed table (episodes/checkins/meals). Single `kv` table preserves the prefix-scan contract exactly.
- Migration flag key: `__migrated_to_idb` (written into `kv`, not localStorage).
- Run the architecture check after changes: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

Surface area is small but blast radius is total (every write goes through this). Test sequence:
1. Load app on a fresh profile — migration is a no-op, app works.
2. Load app on a profile with existing localStorage entries — rows copy into IDB, app still reads them.
3. Reload — migration is skipped (flag present), rows read from IDB.
4. Add an entry — it lives in IDB, not localStorage.

Failure mode: if `db.open()` throws, fall back to a localStorage-backed `DB` and show a banner. Banner copy TBD during implementation.

## Ship Notes

_(pending)_
