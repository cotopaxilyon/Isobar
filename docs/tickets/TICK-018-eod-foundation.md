---
id: TICK-018
title: Evening check-in foundation (new entry type + soft-prompt card + empty-save shell)
status: testing
priority: high
wave: 2
created: 2026-04-20
updated: 2026-04-21
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-52
  test: ""
depends-on: [TICK-009, TICK-010, TICK-011, TICK-012]
supersedes: []
shipped: ""
---

# TICK-018: Evening Check-in Foundation

## Summary

First Stage 2 ticket. Introduces `evening_checkin` as a new entry type and stands up the full wiring — home-screen soft-prompt card after the configured evening hour, a new form view, save-to-DB, minimal log-view recognition, and a settings knob for the reminder hour. No field content yet; those arrive incrementally in TICK-019..022. The reason for shipping the shell as its own ticket is so the field tickets can each focus on one block without re-litigating navigation, storage shape, or card-dismissal state.

## Acceptance Criteria

- [ ] Home screen renders a new soft-prompt card (styled like `#backup-card` at `index.html:421-430`) when local time ≥ configured evening hour AND no `evening_checkin` with `entryDate === today` exists AND `eod:snoozedUntilDate` is not today. Card text: "Evening check-in (optional, ~1 min)". Insertion point: immediately after the action grid `div.action-grid` closing at `index.html:419`, before `#backup-card` at `:421`. Buttons: `Later` (snoozes via `DB.set('eod:snoozedUntilDate', localDateISO(new Date()))`) and `Start` (opens the form)
- [x] New view `#view-evening` (mirroring `#view-checkin` at `index.html:469-482`) with `#eod-title` / `#eod-sub` / `#eod-content` / `#eod-actions` hooks; `switchView('evening')` activates it; no progress bar (single-screen form, no steps)
- [x] `startEvening()` initializes `let eodData = { type: 'evening_checkin', timestamp: ISO, entryDate: localDateISO(now) }` (shell only — field keys added in follow-up tickets); `saveEod()` writes `await DB.set('entry:${new Date(eodData.timestamp).getTime()}', eodData)`, showToast, `goHome()`, `updateStats()` — mirrors `saveCheckin` at `index.html:1553-1572`
- [x] Settings view (`index.html:494-529`) gets a new `setting-row` before the Clear-All-Data row: label "Evening reminder hour", subtitle "When the evening check-in prompt appears (default 8pm)", a `<select>` of values 18..23 bound to `settings:eveningHour` via `DB.get` / `DB.set`; default 20 when unset
- [ ] Log view renders `evening_checkin` entries with type label "Evening check-in" and accent color distinct from morning "Check-in" — extend the ternary at `index.html:1592-1593, 1624` to recognize the new type. No chips or notes yet (those land in follow-ups); card shows only header + timestamp
- [x] `sw.js` `CACHE` constant bumped from `isobar-v10` → `isobar-v11`

## Agent Context

- Single-file PWA; all runtime code lives in `index.html`. `sw.js` is a 31-line service worker with the cache const at line 1.
- Soft-prompt card template is the existing backup-card: markup at `index.html:421-430`, render logic in `renderBackupCard()` at `index.html:1820-1838`, snooze-state keys `backup:snoozedUntil`. The EOD equivalent is a new `renderEodCard()` function called from `updateStats()` at `index.html:1637` alongside `renderBackupCard()`. Same markup shape, different keys.
- Snooze key: `eod:snoozedUntilDate` stores the YYYY-MM-DD string of the day the snooze applies to (not a timestamp) — this simplifies the "re-appears next evening regardless of dismissal" rule from `PLAN_irritability_and_severity_mapping.md` §"Part C — Soft prompt". Tomorrow's string ≠ today's string, so tomorrow's render shows it again.
- Today-logged detection: iterate `await DB.allEntries()` (helper at `index.html:1577`) and check for any `e.type === 'evening_checkin' && e.entryDate === localDateISO(new Date())`. Hide the card in that case.
- `DB` module: `index.html:553`. `localDateISO` helper: `index.html:1088`.
- Settings read happens inside `renderEodCard` (default 20 when unset). Settings UI is a plain `<select>` with options 18..23 — bind to an `onchange` that writes `DB.set('settings:eveningHour', Number(value))`. No new settings section; add the row into the existing card at `index.html:497-519`.
- `switchView` at `index.html:1805-1815`. Nav bar at `:534-543` — do NOT add a nav button for Evening; entry is card-gated only.
- `startApp` hooks: `renderEodCard()` must be called wherever `renderBackupCard()` is called, and must be called inside `updateStats()` so the card re-evaluates after any save.
- **Do not add field blocks in this ticket.** The form body `#eod-content` should render a single placeholder line ("More blocks coming in follow-up tickets — tap Save to store an empty record") and a `Save` button. TICK-019 / TICK-020 / TICK-021 / TICK-022 fill in the blocks.
- Export (`exportReport` at `index.html:1670-1792`) does NOT need to be modified in this ticket — it will still render an empty EOD entry as an uncategorized block (no type branch), which is acceptable for shell-only data. TICK-022 adds the dedicated `EVENING CHECK-INS` section.
- Run architecture check after changes: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

- **Why a new entry type, not a `period` field on `checkin`:** per plan §"Part C — Schema", "nearly every analytical query needs to filter morning vs. evening explicitly." Two types mean `entries.filter(e => e.type === 'evening_checkin')` without a compound filter.
- **Card appears live vs on-render:** the card only re-evaluates when something calls `updateStats()` (save, navigation, app open). A user sitting on home at 7:59pm won't see the card materialize at 8:00pm without interaction. This is acceptable — the plan's "no nag" principle accepts that the prompt surfaces on next interaction after threshold. Don't add a `setInterval` timer.
- **Snooze granularity:** one dismissal per day. No partial-day dismissals ("snooze 1 hour") — plan says re-appears next evening, not same evening.
- **Duplicate-day handling:** multiple EODs on the same day are allowed at the storage layer (each gets a unique `entry:${timestamp}` key). The card-hiding check uses `some()` so any same-day EOD hides the card. Later analytics pick the latest per day if needed.
- **Test sequence (behavioral — user runs during QA, not agent):**
  1. Open app before 8pm on a fresh day → no EOD card visible.
  2. Change system time to 8pm (or wait) → navigate nav → EOD card appears on home.
  3. Tap `Later` → card hides; reload app → card still hidden today.
  4. Wait until next day (or change system date) → card re-appears.
  5. Tap `Start` → evening form opens showing placeholder text and Save button.
  6. Tap `Save` → toast, return to home, stats "Days tracked" may increment, log shows new "Evening check-in" entry with timestamp only.
  7. Re-open home same day after save → EOD card is hidden (already logged today).
  8. Visit Settings → change reminder hour to 19 → verify EOD card appears from 7pm next time it evaluates.

## Ship Notes

_(pending)_
