# PLAN: Data Persistence Hardening (Stage 0)

**Status:** specced 2026-04-17 — ready for ticket implementation
**Precondition for:** every accumulating-data stage after this point. Ships before Stage 1 of the irritability/severity build.
**Origin:** items 1 + 2 of `PLAN_irritability_and_severity_mapping.md` → "Critical Review Walkthrough" § Data persistence hardening.

This plan is **separate from** the irritability plan because it's infrastructure, not clinical design. The irritability plan treats Stage 0 as a black box; this doc is the inside of that box.

---

## Why now

Two concrete threats to the dataset:

1. **localStorage cap (~5 MB).** At the current growth rate (≈2 KB/entry, ~5 entries/day) the app is fine for months but becomes fragile as soon as attachments, longer EOD notes, or retained axis-configs start landing in Waves 5+. A full reset caused by a quota overflow would be catastrophic — nothing here is replayable.
2. **iOS Safari 7-day storage eviction.** Apple aggressively evicts storage from PWAs that aren't opened frequently. The user is the only patient and uses the app daily right now, but any gap in usage (hospitalization, travel, accidental uninstall-reinstall) risks silent data loss. A single eviction during a symptomatic episode could wipe the clinical timeline.

The response is three layers:
- **IndexedDB via Dexie.js** — removes the quota ceiling.
- **`navigator.storage.persist()`** — opts into eviction-resistance where the browser honors it.
- **Weekly prompted backup to iCloud** + **JSON import** — the only mechanism that survives a hardware loss or a browser-level wipe. User-held, E2EE via Apple, no third-party trust.

Dexie Cloud was considered and rejected: not E2EE by default, single-maintainer commercial venture, no HIPAA compliance. The weekly-prompt flow gives durability without ceding custody.

---

## Current storage surface

All reads/writes go through a single `DB` object in `index.html` (currently ~lines 527–537). Four key shapes are in use:

| Key pattern | Rows | Contents |
|---|---|---|
| `pin` | 1 | 4-digit PIN (plaintext today — out of scope for this plan) |
| `entry:<ISO-timestamp>` | N | Episode + check-in events (polymorphic by `type` field) |
| `meal:entry:<ms>` | N | Meal history |
| `meal:last`, `meal:last_drink` | 2 | Latest-meal denormalized pointers |

Because every caller goes through `DB.get / set / remove / keys / allEntries`, the migration can preserve the caller contract and swap only the implementation. **No non-storage code should change in Stage 0.**

---

## Target schema (Dexie)

One table, keyed by the existing string key, preserves the abstraction exactly:

```js
const db = new Dexie('isobar');
db.version(1).stores({
  kv: '&key'           // primary key: the existing string key
});
// row shape: { key: string, value: any, updatedAt: number }
```

Rationale for single-table over typed tables:
- **Smallest migration.** Every `DB.keys('entry:')` prefix scan maps to `db.kv.where('key').startsWith('entry:')` — no caller rewrites.
- **Idempotent.** Re-running the migration on an already-migrated app is a no-op.
- **Future-safe.** When Stage 2 needs true indexed queries (e.g. "all EOD entries between dates"), we add a typed table alongside `kv` via a Dexie version bump — non-breaking.

`updatedAt` is new; populated on every write. Cheap to add, useful for the "last backup covers through" UI in TICK-011.

---

## Migration strategy

One-shot, at app boot, before any `DB.*` call resolves:

1. Await `db.open()`.
2. If `db.kv` is empty **and** `localStorage.length > 0`: iterate `localStorage`, write each key/value into `kv` in a single bulk transaction, then set `localStorage.setItem('__migrated_to_idb', '1')`.
3. Leave the localStorage rows in place for one release cycle (safety net; the user can downgrade). Wave 1 of a later ticket deletes them after a confirmed-good week.

The `DB` abstraction is rewritten to be `async`. All callers must `await` — that's the only visible change in the codebase, and it's mechanical.

Failure mode: if `db.open()` throws (Safari private mode, quota denied, corrupted store), fall back to localStorage with a visible banner. The user has ultimate recovery via JSON import (TICK-012) from the last weekly backup.

---

## `navigator.storage.persist()`

Called once on app boot after a successful `db.open()`. Semantics per [MDN](https://developer.mozilla.org/en-US/docs/Web/API/StorageManager/persist):

- **Chrome/Edge:** granted silently if the site is installed as PWA or has notification permission. Isobar is installed → expected grant.
- **Firefox:** prompts the user. We take whatever they answer; no retry.
- **Safari/iOS:** the method exists but [WebKit storage policy](https://webkit.org/blog/14403/updates-to-storage-policy/) still applies the 7-day eviction rule. Persist helps edge cases (added to Home Screen) but is not a guarantee. **This is the reason TICK-011 exists** — persist is layer 2; backup is layer 3.

Store the returned boolean in `kv` as `storage:persistGranted` so the settings screen can surface it, and so we can detect if it flips to false later.

---

## Weekly backup flow (TICK-011)

Goal: the user pushes a button once a week and a full JSON snapshot ends up in iCloud Drive.

- **Trigger:** on app boot, if `Date.now() - lastBackupAt > 7 * 86_400_000`, surface a non-blocking card on home: *"Back up your data — 7 days since last backup."* Dismiss-to-snooze for 24h. No auto-export; the user is in control.
- **Payload:** `{ version: 1, exportedAt, appVersion, rows: [...all kv rows] }`. Pretty-printed JSON.
- **Delivery:** `navigator.share({ files: [File] })` with a `.json` MIME. iOS treats this as a share sheet; user picks "Save to Files" → iCloud Drive. No server hop, no third-party custody.
- **Fallback:** if `navigator.canShare({ files })` is false (desktop Chrome), trigger a download via anchor. Same payload.
- **Confirmation:** user taps "Done" in a follow-up toast; we write `backup:lastAt` to `kv`. No silent confirmation — the share-sheet completion event is unreliable across browsers.

We deliberately do **not** keep a rolling history of prior backups in localStorage/IDB. Point-in-time snapshots are the user's responsibility in iCloud. We only track "when did you last acknowledge a backup."

---

## Import flow (TICK-012)

Settings-screen button: *"Import from JSON."* Opens `<input type="file" accept="application/json">`. On file read:

1. Validate `{ version: 1, rows: [...] }` shape. Reject anything else with a specific error.
2. Preview: show row counts by prefix (`entry:`, `meal:entry:`, etc.) and the oldest/newest `updatedAt` in the payload.
3. Confirm: show two modes — **Merge** (write rows that don't exist locally, skip existing) and **Replace** (clear `kv` first). Default to Merge. Both require a second-tap "I understand" to avoid a mis-tap wiping data.
4. Execute in one transaction. On success, show a summary: *"Imported N rows; M skipped as duplicates."*
5. PIN is imported along with everything else. If the imported backup's PIN differs from the current one, the user is locked out until they re-enter the imported PIN — this is intentional; the PIN belongs to the data.

No partial imports, no field-level merging, no conflict resolution beyond "newer `updatedAt` wins" (future — v1 just skips on key collision in Merge mode).

---

## Ticket breakdown

Four tickets. Each fits inside the ≤200 LOC / ≤5 AC sizing rule. All four together ship Stage 0.

| Ticket | Scope | Depends on |
|---|---|---|
| **TICK-009** Dexie migration | Add Dexie, rewrite `DB` as async, boot-time one-shot migration from localStorage | — |
| **TICK-010** Storage persistence opt-in | `navigator.storage.persist()` on boot + settings indicator | TICK-009 |
| **TICK-011** Weekly backup prompt | Home-screen card + Web Share JSON export + `backup:lastAt` tracking | TICK-009 |
| **TICK-012** JSON import | Settings button + validation + merge/replace | TICK-009 |

Build order: TICK-009 ships first and alone. TICK-010 / 011 / 012 can ship in any order and can land in the same PR if convenient.

---

## Cache/version interactions

- SW cache version must bump on TICK-009 (new Dexie bundle vendored into the PWA shell).
- Dexie must be vendored, not CDN'd — the app is origin-agnostic per `docs/ARCHITECTURE.md` §1.
- IDB schema version stays at 1 through all four tickets. First bump will be in Stage 2 if we add a typed `eod_entries` table for indexed queries.

---

## Risk register

| Risk | Mitigation |
|---|---|
| Migration corrupts a value (JSON roundtrip edge case) | Dry-run logs row count + size before write; keep localStorage for one release as rollback |
| iOS denies persist silently | TICK-011 backup is the real safety net; persist is best-effort |
| User never taps "Back up" | Weekly prompt repeats; no silent skip. If they dismiss for 30 days, escalate copy ("4 weeks since last backup"). Out of scope for v1 of TICK-011 — add in follow-up if prompt is ignored. |
| Web Share unsupported | Anchor-download fallback covers desktop |
| Import of a PIN'd backup locks user out | Documented in the import confirm dialog. This is correct behavior — PIN is part of the dataset. |

---

## Out of scope

- PIN encryption / key derivation. Current 4-digit PIN remains plaintext. Separate future ticket.
- Automatic backup (background sync, scheduled export). The user stays in control; no silent exfil.
- Multi-device sync. Single-patient PWA — not needed.
- Dexie Cloud. Considered, rejected (see "Why now").
- Cross-device conflict resolution. Not applicable.
