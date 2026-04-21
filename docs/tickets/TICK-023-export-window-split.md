---
id: TICK-023
title: Export window split — primer, prodrome-adjacent, prodrome
status: pending
priority: medium
wave: 7
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: null
linear:
  parent: ISO-57
  test: ""
depends-on: [TICK-006, TICK-007]
supersedes: []
shipped: ""
---

# TICK-023: Export window split — primer, prodrome-adjacent, prodrome

## Summary

Rewrite the pre-episode rendering in the export to split time into three named zones instead of a single "24h prior" lump: primer window (`prodrome_onset − 72h` to `prodrome_onset − 6h`, passive/objective signals), prodrome-adjacent band (last 6h pre-prodrome, rendered with a "interpret with caution" marker), and prodrome window (`prodrome_onset` → `ictal_onset`, rendered as "likely attack symptoms — not causes"). Prevents prodromal contamination from masquerading as a trigger in downstream analysis. Also annotates `directional_cold_airflow` chips logged at episode time as "reported at episode onset" rather than clean primer exposure. See `PLAN_trigger_trap.md` §Change 1.

## Acceptance Criteria

- [ ] Export renders three distinct pre-episode zones with labeled headers per the constants `PRIMER_WINDOW_HOURS=72`, `PRODROME_FLOOR_HOURS=6`
- [ ] When `prodrome_absent: true`, primer zone extends to `ictal_onset − 6h` and the prodrome section is explicitly marked empty
- [ ] Prodrome section is titled "Prodrome (likely symptoms of attack — not causes)" and never contains exposure chips
- [ ] `directional_cold_airflow` logged on the episode form renders as "reported at episode onset" in the export, not under primer window
- [ ] Old episodes without `prodrome_onset` render under a fallback "pre-episode window" heading without error

## Agent Context

- Entire app is in `index.html`. Likely touch points: `generateReport()` / `exportReport()` and whatever data-window helper those functions call.
- Constants live in PLAN_trigger_trap.md §Constants. Define them once as named consts at the top of the export function rather than magic numbers.
- Prodrome boundary is `episode.prodrome_onset` from TICK-006. If TICK-006 isn't shipped when this ticket starts, block.
- Do not persist any new field — this is export-render only.
- Bump SW cache version.

## Implementation Notes

The prodrome-adjacent band (last 6h pre-prodrome) is the literature-driven hedge: attack has probably already started centrally but the patient may still be logging things as primer-context. Rendering it as a third zone preserves the data without letting the reader silently merge it into primer analysis.

Cold-airflow annotation: the chip is on the episode form, so it's logged *at episode time* and may reflect already-started attack cold-intolerance. Until/unless it moves to a pre-episode form, the export annotation is how we flag the ambiguity.

## Ship Notes

_(pending)_
