---
id: TICK-029
title: Export integration — primer-window stays with three-way split
status: pending
priority: medium
wave: 9
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: null
linear:
  parent: ISO-63
  test: ""
depends-on: [TICK-023, TICK-028]
supersedes: []
shipped: ""
---

# TICK-029: Export integration — primer-window stays with three-way split

## Summary

Extend the export's primer-window section (established in TICK-023) to include reconstructed stays per place, rendered with the same three-way counter-example split used in the Places view (episode / aborted / clean). Reuses the pure stay-reconstruction helper from TICK-028. Places with `stay_count < STAY_COUNT_MIN` render "not enough data yet" instead of a ratio. See `PLAN_trigger_trap.md` §Change 2 + §Change 3 (export half).

## Acceptance Criteria

- [ ] Export primer-window section includes a "Places" subsection listing each place with reconstructed stay count and three-way split over the query window
- [ ] Places below `STAY_COUNT_MIN = 5` render "not enough data yet" — no ratio, no episode count split
- [ ] Each stay's duration in the export uses "observed dwell (lower bound)" framing, matching the Places view
- [ ] Stays are associated with episodes when `ictal_onset` falls during the stay or within `POST_STAY_EPISODE_WINDOW_HOURS = 48` after close
- [ ] Unnamed places render as "Place near (lat, lon)" rounded to 3 decimals

## Agent Context

- Entire app is in `index.html`. Reuses the stay-reconstruction helper introduced in TICK-028 — do not reimplement.
- Uses the primer-window boundaries from TICK-023 (`PRIMER_WINDOW_HOURS=72`, `PRODROME_FLOOR_HOURS=6`). Constants must come from the same shared block.
- No new data — this is a render-only change.
- Bump SW cache version.

## Implementation Notes

This ticket exists as a split from TICK-028 so that the Places view can ship independently of export changes if needed, and so that each ticket stays under the sizing cap. The stay-reconstruction helper is the shared dependency.

## Ship Notes

_(pending)_
