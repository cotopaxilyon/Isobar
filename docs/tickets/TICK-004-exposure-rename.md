---
id: TICK-004
title: Exposure rename — triggers to exposures
status: pending
priority: high
wave: 4
created: 2026-04-15
updated: 2026-04-15
plan: docs/plans/PLAN_trigger_surface_expansion.md
test: null
depends-on: []
supersedes: ["UPDATES #6 framing"]
shipped: ""
---

# TICK-004: Exposure Rename — Triggers to Exposures

## Summary

Rename "triggers" to "exposures" throughout the app. The current framing implies the user knows what caused an event; "exposure" captures what conditions were present without demanding causal attribution. This is how a specialist reads the data anyway. Backward-compatible read of existing `triggers` arrays.

## Acceptance Criteria

- [ ] Episode form step title: "What was going on today?" with subtitle "Select anything that was present"
- [ ] All UI labels use "exposures" not "triggers"
- [ ] Internal field name changes: `triggers` → `exposures`, `trigOpts` → `exposureOpts`
- [ ] Existing entries with `triggers` arrays read correctly (backward-compat)
- [ ] Export section titled "Exposures" not "Triggers"
- [ ] "Hours since last meal" relabeled to "Hours fasted at episode onset"
- [ ] Fasting hours auto-populated from `meal:last` with calculated value
- [ ] Manual override available if no meal logged or user wants to correct
- [ ] No data migration — read-time compat only

## Agent Context

- Entire app is in `index.html`.
- Key locations: `EP_STEPS` array, `renderEpStep()` case 4, `trigOpts` array, `saveEpisode()`, `renderLog()`, `generateReport()`.
- Read-time compat pattern: `const exposures = entry.exposures || entry.triggers || []`.
- Auto-fasting reads `DB.get('meal:last')` and computes elapsed hours. Pre-populate `epData.fastedHours` if not manually set.
- Full design spec in PLAN_trigger_surface_expansion.md (Tier 1 chip additions are Wave 6, not this ticket).
- Bump SW cache version.

## Implementation Notes

This ticket covers the **rename and auto-fasting** only. The new exposure chips (alcohol, sleep hours, cycle proxies, directional cold, etc.) ship in Wave 6 as part of TICK-006.

## Ship Notes

_(pending)_
