---
ticket: ISO-97
status: shipped
filed: 2026-05-01
---

# ISO-97 QA Fail — Intervention strip write-back uses wrong IDB key

## QA verdict

AC-F8 (Save writes entry + updates intervention:recent:category) marked FAIL.
18/19 ACs passed. One advisory finding (exportReport label copy — out of AC scope).

## QA's stated root cause vs. what the code actually shows

**QA claimed:** Entry key is `entry:${ts.getTime()}` with a 15-min picker quantization. A
`DB.get(key)` guard at `index.html:3125–3126` rejects the second save with "Already saved" toast.

**Independent trace (this session):** That description does not match the code.

- `index.html:3125` is `const key = \`entry:${Date.now()}\`` — wall-clock ms at save time, not picker ms.
- Lines 3125–3137: no `DB.get(key)` guard. Goes directly to `DB.set(key, entry)` at line 3137.
- The "Already saved" toast does not exist in `saveIntervention`. The function shows "Intervention saved ✓" on success, "Save failed — try again" on DB failure.

QA's root cause appears to have been extrapolated from the guard pattern in `saveEpisode`/`saveCheckin`/`saveEvening` (lines 1406, 1738, 2548 respectively) and misapplied to `saveIntervention`. Those functions use `ts.getTime()` keys with DB.get guards; `saveIntervention` uses `Date.now()` with no guard.

## The real bug

**Strip write-back silently fails because the IDB key used by the strip doesn't match the key used at save time.**

### Key mismatch

`saveIntervention` (`index.html:3125`):
```js
const key = `entry:${Date.now()}`;       // wall-clock ms when save is pressed
```

`renderInterventionStrip` (`index.html:3162`):
```js
const ivKey = `entry:${new Date(iv.timestamp).getTime()}`;  // picker-time ms
```

`iv.timestamp` is `ts.toISOString()` from the time picker (line 3124), which resolves to the
nearest 15-min boundary (00/15/30/45). The picker rounds minutes to 15-min slots (line 1705–1710).
`Date.now()` is always in the current second. These two values are always different.

### Impact

The three strip interaction functions all call `DB.get(ivKey)` with the wrong key:
- `applyStripEffect` (`index.html:3180–3181`): `if (!entry) return;` → silently exits; `perceived_effect` never written
- `applyStripTTE` (`index.html:3202–3203`): same → `time_to_effect_min` never written
- `dismissStripPrompt` (`index.html:3210–3211`): same → `_promptDismissed` never set to `true`

Visual behavior appears correct (strip hides on tap via `el.style.display = 'none'`), but nothing
is persisted. On next home-screen render, the same entry still has `perceived_effect: null` and
`_promptDismissed: false`, so the strip will reappear.

## Proposed fix

**Option A (recommended) — store the IDB key in the entry body at save time.**

In `saveIntervention`, add `_idbKey: key` to the entry:

```js
const key = `entry:${Date.now()}`;
const entry = {
  type: 'intervention_event',
  timestamp,
  _idbKey: key,   // ← add this
  episode_id: null,
  ...
};
```

In `renderInterventionStrip`, use `iv._idbKey` directly:

```js
const ivKey = iv._idbKey || `entry:${new Date(iv.timestamp).getTime()}`;
```

The fallback keeps old entries (none exist yet) gracefully handled.

**Why not Option B (change key to `ts.getTime()` like other saves)?**

Other saves use `ts.getTime()` because they are once-per-event (episode/checkin/eod) — the
guard prevents double-saves of the same moment. Interventions are valid multiple-per-session;
two saves at the same 15-min picker value are plausible (e.g., two doses taken within the same
quarter-hour). Using `ts.getTime()` would silently overwrite the first.

## Advisory — exportReport severity-label copy

The ISO-TICK-035 commit also changed `exportReport()` severity labels from:
- `Somewhat worse` → `Somewhat worse than baseline`
- `Much worse` → `Much worse than baseline`

Confirmed in `git show a7e7d52 -- index.html`. This is outside ISO-97's acceptance criteria but
the change is cosmetically valid (labels now match their description text). No action required
unless the user wants to track it as a separate improvement ticket.

## Files to change

- `index.html` — `saveIntervention()` (~line 3125): add `_idbKey: key` to entry body
- `index.html` — `renderInterventionStrip()` (~line 3162): use `iv._idbKey || ...` for ivKey

No schema version bump needed (additive field; existing readers ignore unknown fields).
SW cache bump required (shell asset change per architecture check).
