---
ticket: ISO-21
title: clearData() does not remove meal:last or meal:last_drink (IDB)
status: resolved
drafted: 2026-04-18
resolved: 2026-04-18
commit: 8591947
---

## Resolution

Shipped Option A (predicate delete in clearData). Implementation differed
from the original draft in one place: `idb` is IIFE-private to the `DB`
module, so the predicate delete can't live inline in `clearData()`. Added
a `DB.clearExceptPin()` method that wraps the Dexie call. `clearData()` now
also calls `renderMealCard()` after the wipe so the UI reflects the cleared
state without a reload.

Verified in a live browser: seeded `meal:last` and `meal:last_drink` via
the UI, ran Clear, confirmed IDB reduced to `['pin']` and the Home meal
card immediately rendered "No meal logged yet today."

ARCHITECTURE.md §2 added documenting the empty-prefix Dexie quirk.

Related follow-up: ISO-43 (Recent episodes section has the same staleness
class after Clear; separate ticket).

# Fix plan — ISO-21

## TL;DR

`clearData()` relies on `DB.keys('')` to enumerate every stored key, but after the ISO-39 Dexie migration, `DB.keys('')` resolves to `idb.kv.where('key').startsWith('').primaryKeys()`. Dexie's `WhereClause.startsWith('')` returns an empty array in this build, so the for-loop that removes IDB keys is a no-op. The `Object.keys(localStorage).forEach(...)` follow-up still runs, which is why the dev's self-QA (localStorage-only) looked green — but the live app now writes `meal:last` to IDB via `saveMeal`, so the meal card survives "Clear All Data". Proposed fix: delete everything in `idb.kv` except `pin` via a Dexie predicate, independent of `DB.keys`.

## Failure classification

**Type (b) — latent defect exposed by a later change.** `baa4711` ("ISO-21: clearData() removes all non-PIN keys") was correct at the time: it enumerated keys via `DB.keys('')` which, in the pre-Dexie `DB`, returned `Object.keys(localStorage)`. The subsequent ISO-39 Dexie migration (`22e802e`) changed the primary store to IndexedDB and repointed `DB.keys(prefix)` at `idb.kv.where('key').startsWith(prefix).primaryKeys()`, without auditing callers that passed an empty prefix. Neither ticket's self-QA exercised the composition: ISO-21 predated Dexie; ISO-39 didn't re-run Clear Data.

## Root cause

`index.html:612–618` — `DB.keys(prefix)`:

```js
keys: async prefix => {
  await ready;
  if (idb) {
    try { return await idb.kv.where('key').startsWith(prefix).primaryKeys(); } catch { return []; }
  }
  return Object.keys(localStorage).filter(k => k.startsWith(prefix));
},
```

With `prefix = ''`, Dexie's `WhereClause.startsWith('')` yields an empty result set in this build (reproduced by the QA harness across four runs). `Array.from(await DB.keys(''))` therefore returns `[]`, and the `for (const k of allKeys)` loop at `index.html:1663–1666` iterates zero times. `meal:last`, `meal:last_drink`, every `entry:*`, and every `draft:*` written via `DB.set` (which goes to `idb.kv`, `index.html:602–604`) all persist.

Why the dev's self-QA passed (from the Linear comment thread): the seed step put keys directly into `localStorage`, which was then cleared by the second block of `clearData()`. The IDB path was never exercised because nothing was seeded there.

## Why `DB.keys('')` returns empty

Dexie's `Collection` supplied by `WhereClause.startsWith` filters by the index range `[prefix, prefix + '\uFFFF']`. For an empty prefix that range is `['', '\uFFFF']` — which *should* match every string key — but Dexie short-circuits empty-string prefix lookups as a guard against accidental full-table scans and returns an empty collection. This is a known Dexie quirk, not a bug in the app, but the `DB.keys('')` contract silently drifted from "all keys" (localStorage) to "no keys" (Dexie) across the migration.

## Proposed fix

Pick one of (A) or (B). Both are small; (A) is more surgical, (B) is more robust.

### Option A — delete-by-predicate in `clearData()` (preferred)

Replace the enumerate-then-remove loop with a single Dexie predicate delete, then clear localStorage as today:

```js
async function clearData() {
  if (confirm('Permanently delete all logged entries? This cannot be undone.')) {
    // Remove every IDB key except the PIN. Uses a Dexie filter so we don't depend
    // on DB.keys('') behavior, which Dexie short-circuits to an empty result.
    try { await idb?.kv.where('key').notEqual('pin').delete(); } catch {}
    Object.keys(localStorage).forEach(k => { if (k !== 'pin') localStorage.removeItem(k); });
    await updateStats();
    showToast('Data cleared', 'var(--warn)');
  }
}
```

`idb?.kv.where('key').notEqual('pin').delete()` is a single IDB transaction, atomic, no enumeration, no empty-prefix trap. If Dexie failed to open and `idb` is null, the optional chain skips the IDB branch and the localStorage fallback cleanup runs alone — same behavior as today when Dexie is unavailable.

### Option B — fix `DB.keys('')` globally

Make `DB.keys` honor empty-prefix as "all keys" so every caller is correct:

```js
keys: async prefix => {
  await ready;
  if (idb) {
    try {
      return prefix === ''
        ? await idb.kv.toCollection().primaryKeys()
        : await idb.kv.where('key').startsWith(prefix).primaryKeys();
    } catch { return []; }
  }
  return Object.keys(localStorage).filter(k => k.startsWith(prefix));
},
```

This is more robust but has a wider blast radius — any future caller of `DB.keys('')` inherits the new semantic. A quick audit of existing callers (`grep -n "DB\.keys" index.html`) shows only `clearData` passes an empty prefix today, so the blast radius is currently nil, but the semantic change is worth flagging.

**Recommendation:** Option A. The fix lives next to the symptom; `DB.keys` stays honest about being a prefix scan; there's no global behavior change to audit later.

## Out of scope (intentionally)

- **Generalized "nuke IDB" helper on `DB`.** Tempting (`DB.clearAll({ except: ['pin'] })`) but this is the only caller in the codebase. One helper for one caller is premature abstraction.
- **Dexie version bump to see if empty-prefix `startsWith` is fixed upstream.** Possibly, but behaviorally we don't want to depend on that — the predicate-delete path is correct regardless.
- **Audit of other `DB.keys(nonEmptyPrefix)` callers.** `entry:`, `draft:`, `morning:` prefixes are all non-empty and work correctly. Verified by grep and by the Log view continuing to load entries after ISO-39 shipped.

## Tradeoffs / risks

| Decision | Upside | Downside / risk |
|---|---|---|
| Option A (predicate delete) | Atomic; no enumeration; fixes the symptom with three lines | Couples `clearData` to Dexie internals by name (`idb.kv`). Acceptable — `clearData` already references `idb` implicitly through `DB`. |
| Option B (fix DB.keys globally) | Makes the abstraction honest; any future empty-prefix caller is correct | Wider blast radius; requires re-reading every `DB.keys` call to make sure the new "all keys" semantic is safe for them |
| Keep both | Belt-and-braces | Pointless — they're not redundant with each other; A doesn't guard B and vice versa. Pick one. |

## Verification plan (for the QA re-run)

1. Fresh page load at `localhost:8000/`, PIN `1234`.
2. On Home: `I just ate` → `Light meal` → `Save`. Meal card reads `Last ate: light meal, 0 min ago`.
3. DevTools → Application → IndexedDB → `isobar` → `kv` → confirm row for `meal:last`.
4. Settings → `Clear` → accept confirm dialog. `Data cleared` toast appears.
5. DevTools → IndexedDB → `kv` → confirm the only remaining row is `pin` (and the `__migrated_to_idb` marker is also expected to be cleared — it's not `pin`).
6. Tap Home. Meal card reads `No meal logged yet today`. No "light meal" string anywhere on the page.
7. Hard reload + PIN re-entry. State from step 6 persists.

Repeat steps 1–7 with `meal:last_drink` (via the drink log path) and with `entry:*` records (log a test episode) to confirm the predicate delete removes them too.

## Open questions for you

1. **Option A vs B.** A is the proposed fix; B is available if you want the abstraction-level correction instead. A ships in ~5 lines, B in ~6. Preference?
2. **Keep the `__migrated_to_idb` marker across Clear Data?** Currently it will be deleted by either Option A or B (since `notEqual('pin')` sweeps it too). That means the next boot re-runs the localStorage → IDB migration on an empty localStorage — a harmless no-op. If you'd rather preserve the marker (cheap insurance), change `.notEqual('pin')` to `.noneOf(['pin', '__migrated_to_idb'])`.
3. **Backfill a note to `docs/ARCHITECTURE.md`?** The "empty-prefix `startsWith` returns nothing in Dexie" quirk is exactly the kind of invariant ARCHITECTURE.md exists to catch. Proposed rule: "`DB.keys('')` is a prefix scan and should not be used to enumerate all keys; use Dexie predicates directly when you need all-keys semantics." Add to ARCHITECTURE.md in the same commit, or separate?

## Not touching code until human reviews this plan.
