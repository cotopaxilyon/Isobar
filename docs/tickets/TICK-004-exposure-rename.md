---
id: TICK-004
title: Exposure rename — triggers to exposures
status: done
priority: high
wave: 4
created: 2026-04-15
updated: 2026-04-16
plan: docs/plans/PLAN_trigger_surface_expansion.md
test: docs/testing/TEST-004-exposure-rename.md
linear:
  parent: ISO-6
  test: ISO-11
  derived-refactor: ISO-14
  bugs-resolved-by-arch: [ISO-7, ISO-8, ISO-9, ISO-10]
  bundled: [ISO-13]
depends-on: []
supersedes: ["UPDATES #6 framing"]
shipped: "2026-04-16"
---

# TICK-004: Exposure Rename — Triggers to Exposures

## Summary

Rename "triggers" to "exposures" throughout the app. The current framing implies the user knows what caused an event; "exposure" captures what conditions were present without demanding causal attribution. This is how a specialist reads the data anyway. Backward-compatible read of existing `triggers` arrays.

## Acceptance Criteria

- [x] Episode form step title: "What was going on today?" with subtitle "Select anything that was present"
- [x] All UI labels use "exposures" not "triggers"
- [x] Internal field name changes: `triggers` → `exposures`, `trigOpts` → `exposureOpts`
- [x] Existing entries with `triggers` arrays read correctly (backward-compat)
- [x] Export section titled "Exposures" not "Triggers"
- [x] "Hours since last meal" relabeled to "Hours fasted at episode onset"
- [x] Fasted-hours derived live from meal history (not snapshot — see Architecture Pivot)
- [x] No per-episode override — meal log is the single source of truth
- [x] First-load migration seeds `meal:entry:*` from existing `meal:last`
- [x] Existing entries saved before this PR continue to render fasted-hours via legacy snapshot fallback

## Architecture Pivot (2026-04-16)

Initial ship used a snapshot model — `fastedHours` written to each episode at save-time with an Edit/Use-calculated UI. QA surfaced ISO-7/8/9/10 against that ship. On triage, all four bugs traced to the snapshot model itself, not to the patches that papered over them.

Switched to a **derived model**: `fastedHours` is never stored. It is computed live at every display point (form, export) from a `meal:entry:*` history searched against `episode.timestamp`.

Properties this gives:
- Editing a meal time retroactively updates fasted-hours displays for past episodes that anchored on that meal.
- Backdated episodes pick up the correct historical meal automatically.
- Negative deltas are structurally impossible (the search only returns meals with `timestamp ≤ episode.timestamp`).
- The UI collapses to a single passive read-only display with a meal-time caption — no Edit button, no mode flag, no input field.

Bugs resolved by architecture: ISO-7, ISO-8, ISO-9, ISO-10. Drink chip drop (ISO-12) shipped independently. Service worker registration (ISO-13) bundled in same PR — the rogue unregister-on-load was the actual cause of the cache-bump-not-reaching-users symptom.

## Agent Context

- Entire app is in `index.html`.
- Key locations: `EP_STEPS` array, `renderEpStep()` case 4, `exposureOpts` array, `saveEpisode()`, `saveMeal()`, `logMeal()`, `exportReport()`, `initApp()`.
- Read-time compat patterns:
  - Exposures: `e.exposures || e.triggers || []`
  - Fasted-hours: `fastedHoursFor(e.timestamp) ?? e.fastedHours`
  - Meal size: `findMealForEpisode(e.timestamp)?.mealSize ?? e.lastMealSize`
- Schema additions: `meal:entry:<ts-ms>` records appended on every meal log (not drinks). `meal:last` and `meal:last_drink` retained as convenience pointers for the home-card and risk engine.
- Helpers added: `migrateMealsToHistory()`, `findMealForEpisode(episodeTs)`, `fastedHoursFor(episodeTs)`.

## Implementation Notes

This ticket covers the rename plus the derived-fasting refactor. New exposure chips (alcohol, sleep hours, cycle proxies, directional cold, etc.) ship in Wave 6 as part of TICK-006.

## Ship Notes

**First ship (snapshot model) — 2026-04-16, reverted same day**
- Rename triggers → exposures throughout (UI labels, field names, export sections).
- Fasting auto-populated from `meal:last` with Edit/Use-calculated UI.
- SW cache bumped to v3.
- Result: QA failed on ISO-7/8/9/10.

**Final ship (derived model) — 2026-04-16**
- Schema: `meal:entry:<ts-ms>` append-only history added; first-load migration seeds from existing `meal:last`. Drinks excluded from history.
- Helpers: `findMealForEpisode()`, `fastedHoursFor()`, `migrateMealsToHistory()`.
- Episode form case 4: passive read-only display showing live computation + meal-time caption ("since light meal at Wed, 2:00 PM" or "no meal logged before this episode"). No input, no Edit button, no `fastedMode` flag.
- `epData` no longer carries `fastedHours` or `fastedMode`. `saveEpisode()` no longer snapshots `lastMealSize` / `lastMealTimestamp`.
- `exportReport()` computes fasted-hours live per episode, with legacy snapshot fields as fallback for entries saved before this PR.
- `saveMeal()` writes `meal:entry:<ts>` on every non-drink log; edits remove the prior `meal:entry` record before writing the new one.
- ISO-12: Fasting chip removed from `exposureOpts` (count 10 → 9).
- ISO-13: removed rogue unregister-on-load block (root cause of `getRegistrations()` returning 0); added proper register-on-load with relative `sw.js` path.
- SW cache bumped to v4.

**Smoke verification:** 10/10 Playwright checks pass against local dev build (page load clean, helpers present, SW registers, derive helpers correct, migration idempotent + drink-aware, case 4 derived display present + no Edit button + no number input, "no meal logged" copy on empty state, Fasting chip absent, edit-meal updates re-render).
