---
id: TICK-003
title: Meal logging — capture meal size + edit time
status: done
priority: high
wave: 3
created: 2026-04-12
updated: 2026-04-15
plan: null
test: docs/testing/TEST-003-meal-size.md
depends-on: []
supersedes: []
shipped: ""
---

# TICK-003: Meal Size + Edit Time

## Summary

The one-tap "I just ate" button now opens a size picker (drink / snack / light / full) with an adjustable timestamp. Fasting thresholds scale with meal size. Drinks don't reset the fasting clock. Past logs are editable from the resting meal card. This gives the compound-risk alert accurate fasting data and makes the meal reminder clinically useful instead of generic.

## Acceptance Criteria

- [x] Tapping "I just ate" opens a picker with 4 size options + datetime input
- [x] Drink logs to `meal:last_drink`, does NOT reset fasting clock
- [x] Snack / light / full apply correct thresholds (2.5h / 4h / 5h)
- [x] Future timestamps rejected with toast
- [x] Timestamps >24h ago rejected with toast
- [x] Resting meal card shows "Edit" (ok state) or "Edit time" (alert state)
- [x] Edit reopens picker with pre-populated size + time
- [x] Reminder copy references the meal size
- [x] Episode export includes `(last: size)` on fasting line
- [x] `mealSize` NOT exported as standalone field (operational data)
- [x] Card state updates immediately after save/edit
- [x] Data persists across reload
- [x] Old entries without `mealSize` render without error

## Agent Context

- Entire app is in `index.html` (single-file PWA).
- Key functions: `logMeal()`, `saveMeal()`, `getMealSuggestion()`, `renderMealCard()`.
- `meal:last` is the localStorage key for the most recent real-food log.
- `meal:last_drink` is a separate key for drink-only logs.
- Compound-risk alert flag is `inConcerningWindow` (per consolidated plan).
- Bump service worker cache version on any UI change.
- Do NOT create new files.

## Implementation Notes

Full spec was in UPDATES.md #3 (now retired). Key decisions:

- **Drink isolation:** `drink` writes to `meal:last_drink` only. `getMealSuggestion()` ignores it for fasting calculation.
- **Guardrails in `saveMeal()`:** reject future (>now+1min) and stale (>24h ago). Show toast, don't save.
- **Preserve existing fields:** `{ ...existing, timestamp, mealSize: size }` so future fields survive edits.
- **Episode snapshot:** `saveEpisode()` captures `lastMealSize` and `lastMealTimestamp` for export context.

## Ship Notes

All 16 UAT scenarios passed (2026-04-15, Playwright). Smoke test clean.
