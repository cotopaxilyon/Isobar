# Sleep Time Picker — 24h Fix

**Status:** Shipped — ISO-92  
**Date:** 2026-04-28  
**Scope:** Replace native `<input type="time">` for bed/wake times with a custom 24h picker, plus a non-destructive one-time annotation of the 8 historically corrupted sleep records.

---

## Root Cause

iOS `<input type="time">` in a 12-hour locale stores midnight ("12:00 AM") as `12:00` instead of `00:00`. The original `normaliseSleepTimes` heuristic attempted to detect and correct this post-hoc, but introduced new risks: destructive in-place overwrite of stored data, an unsupported `bh === 11` branch, and a migration that runs on every app startup with no version guard.

The correct fix is to remove the ambiguity at the source by replacing the native picker with a custom component that always produces unambiguous 24h values.

---

## Data Inventory

The 8 corrupted records, with exact computed values (verified):

| Date | `sleepBedTime` | `sleepWakeTime` | Raw `sleepHours` | `sleepBedTimeCorrected` | `sleepHoursCorrected` |
|---|---|---|---|---|---|
| 4/17 | `12:30` | `09:45` | 21.3h | `00:30` | 9.3h |
| 4/18 | `12:30` | `09:30` | 21.0h | `00:30` | 9.0h |
| 4/19 | `12:00` | `08:45` | 20.8h | `00:00` | 8.8h |
| 4/20 | `12:00` | `09:00` | 21.0h | `00:00` | 9.0h |
| 4/21 | `11:30` | `08:02` | 20.5h | `23:30` | 8.5h |
| 4/24 | `11:00` | `07:30` | 20.5h | `23:00` | 8.5h |
| 4/26 | `12:00` | `08:30` | 20.5h | `00:00` | 8.5h |
| 4/27 | `12:00` | `08:00` | 20.0h | `00:00` | 8.0h |

The three valid early-bed entries (`02:00`, `01:00`, `02:30`) are not affected — neither the `bh === 12` nor `bh === 11` conditions fire for those.

---

## What Changes

### Part 1 — Two helper functions (new code)

**`renderTimePicker24(id, value, onchangeExpr)`**

Renders two `<select>` elements: hour (00–23) and minute (00, 15, 30, 45). The `id` arg namespaces the select IDs so multiple pickers can coexist on the same form. `value` is an existing `"HH:MM"` string or `null`. `onchangeExpr` is an inline JS expression that calls `getTimePickerValue` to assemble the combined string.

The blank/null state is represented by a leading `"—"` option in the hour select. If hour is blank, the assembled value is `null`.

When `value` is non-null but the minute component is not a 15-minute multiple (the one known case: `08:02`), the hour is selected exactly and the minute rounds to the nearest 15 (`08:02` → hour `08`, minute `00`). **Known behavior:** if the user re-saves a check-in form where this rounding applied, `sleepWakeTime` will be written as `08:00`. The 2-minute delta has no clinical significance for sleep logging and is accepted.

**`getTimePickerValue(id)`**

Reads `document.getElementById(id + '-h')?.value` and `id + '-m'`. Returns `"HH:MM"` if hour is set, `null` otherwise. The optional chaining (`?.value`) is required — if the DOM element is missing (e.g. picker not yet rendered), the function returns `null` rather than throwing.

### Part 2 — Replace `<input type="time">` elements in the check-in form

Lines 1424 and 1428 (bed time, wake time). Replace with `renderTimePicker24` calls. The `oninput` attribute becomes `onchange` (selects fire `change`, not `input`). The stored value format (`"HH:MM"`) is unchanged — no schema impact.

Also replace line 1454 (`alc.lastDrinkTime`) — same picker pattern, same fix applied consistently.

### Part 3 — Non-destructive one-time migration (replaces `migrateCheckinSleepHours`)

```
async function migrateCheckinSleepHours() {
  if (await DB.get('migration:sleep_v1')) return;          // already ran
  const keys = await DB.keys('entry:');
  for (const k of keys) {
    const e = await DB.get(k);
    if (!e || e.type !== 'checkin' || !e.sleepBedTime || !e.sleepWakeTime) continue;
    if (e.sleepHoursCorrected != null) continue;           // partial-run guard
    if ((e.sleepHours ?? 0) <= 14) continue;               // not a corrupted record
    // compute correction (same arithmetic as normaliseSleepTimes)
    let [bh, bm] = e.sleepBedTime.split(':').map(Number);
    const [wh, wm] = e.sleepWakeTime.split(':').map(Number);
    let mins = (wh*60+wm) - (bh*60+bm);
    if (mins < 0) mins += 1440;
    if (mins > 840 && bh === 12) { bh = 0; mins -= 720; }
    else if (mins > 840 && bh === 11) { bh = 23; mins = (wh*60+wm)-(bh*60+bm); if (mins<0) mins+=1440; }
    const sleepBedTimeCorrected = String(bh).padStart(2,'0') + ':' + String(bm).padStart(2,'0');
    const sleepHoursCorrected = Math.round(mins / 6) / 10;
    const ok = await DB.set(k, { ...e, sleepBedTimeCorrected, sleepHoursCorrected });
    if (!ok) { showToast('Migration warning — sleep correction failed for ' + k, 'var(--warn)'); }
  }
  await DB.set('migration:sleep_v1', true);
}
```

Key properties:
- **Exactly once**: version key checked at entry; written at end only after all records succeed.
- **Crash-safe**: per-record guard (`sleepHoursCorrected != null`) means a partial run on re-startup skips already-annotated records and processes only the remainder.
- **Non-destructive**: original `sleepBedTime` and `sleepHours` are never touched.
- **Failure surface**: if `DB.set` returns false for a record, a toast is shown. The migration continues rather than aborting — partial annotation is better than no annotation.

### Part 4 — `saveCheckin` — remove heuristic, add direct calculation

Remove the `normaliseSleepTimes` call. Replace with:

```javascript
if (ciData.sleepBedTime && ciData.sleepWakeTime) {
  const [bh, bm] = ciData.sleepBedTime.split(':').map(Number);
  const [wh, wm] = ciData.sleepWakeTime.split(':').map(Number);
  let mins = (wh * 60 + wm) - (bh * 60 + bm);
  if (mins < 0) mins += 1440;
  ciData.sleepHours = Math.round(mins / 6) / 10;
}
```

No heuristic. The 24h picker guarantees unambiguous values; this is pure arithmetic.

### Part 5 — Display: use corrected value where available

Use `e.sleepHoursCorrected ?? e.sleepHours` at all display and export points:

- `renderLog` line 1721 — sleep chip in log list
- `exportReport` day-by-day timeline line 1914 — morning block
- `exportReport` appendix line 2084 — full check-in detail

### Part 6 — Remove data quality note from physician report Period Summary

The current `exportReport` Period Summary contains a hardcoded sentence noting that sleep hours logged as 20–21h are a computation artifact. After this migration runs, that note is factually wrong — the corrected values appear correctly. Remove the hardcoded sentence from the Period Summary section of `exportReport`. This is in scope here; it must not be left in.

### Part 7 — Delete `normaliseSleepTimes`

No callers remain after Parts 3 and 4 are implemented. Remove the function entirely.

---

## What This Plan Does Not Change

- The stored `"HH:MM"` string format for `sleepBedTime` / `sleepWakeTime` — no schema change.
- **`alc.lastDrinkTime` historical correction**: The picker replacement (Part 2) fixes future entries. Existing stored `lastDrinkTime` values are not migrated. The field is display-only in the physician report appendix (raw time string, no computed value derived from it), so a corrupted historical value has no clinical calculation impact. Accepted known limitation.
- **Episode time inputs** (`prodromeTime`, `firstJerkTime` at lines 1182/1186): Same iOS `<input type="time">` with the same potential AM/PM corruption. These drive prodrome duration and episode span calculations in the physician report. Out of scope here but not deferred indefinitely — a Linear ticket must be opened before this plan closes.
- The `PLAN_physician_report.md` export restructure — still valid and unblocked once this plan is implemented.

---

## Acceptance Criteria

All items are code-verifiable by the implementer before marking Ready for QA.

**Migration**
- [ ] After first app load: `migration:sleep_v1` key exists in DB
- [ ] All 8 dates in the data inventory table have `sleepHoursCorrected` matching the table values (±0.1h tolerance)
- [ ] All 8 dates retain their original `sleepBedTime` and `sleepHours` values unchanged
- [ ] Entries with original `sleepHours ≤ 14` (the `02:00`, `01:00`, `02:30` bed-time entries) have no `sleepHoursCorrected` field
- [ ] Second app load: migration function returns immediately; no DB writes occur

**New saves**
- [ ] Enter bed=`23:30`, wake=`07:30` → stored `sleepHours = 8.0`, no `sleepHoursCorrected`
- [ ] Enter bed=`00:00`, wake=`09:00` → stored `sleepHours = 9.0`
- [ ] Enter bed=`00:30`, wake=`09:45` → stored `sleepHours = 9.3`

**Picker — null/empty state**
- [ ] Check-in form with no prior bed/wake values renders hour select showing `—`; assembled value is `null`; Save completes without error

**Display**
- [ ] Log list: all 8 affected entries show corrected hours (8–9.3h range), not 20–21h
- [ ] Physician report day-by-day timeline: affected check-ins show corrected hours
- [ ] Physician report appendix: affected check-ins show corrected hours
- [ ] Physician report Period Summary: data quality note about 20–21h sleep artifact is absent

**No regressions**
- [ ] Unaffected check-in entries display the same sleep hours as before
- [ ] Episode form still renders (prodromeTime / firstJerkTime inputs unchanged)
