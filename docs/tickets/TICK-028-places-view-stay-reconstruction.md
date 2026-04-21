---
id: TICK-028
title: Places view — stay reconstruction + three-way counter-example split
status: pending
priority: medium
wave: 9
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: docs/testing/TEST-028-places-view.md
linear:
  parent: ISO-62
  test: ISO-64
depends-on: [TICK-006, TICK-027]
supersedes: []
shipped: ""
---

# TICK-028: Places view — stay reconstruction + three-way counter-example split

## Summary

Add an in-app Places view that lists all known places with reconstructed stays and per-place counter-example framing: "18 stays, 4 with episode, 2 aborted, 12 clean" over the last 90 days. Stays are derived at query time by clustering in-radius pings (2h gap closes a cluster); every stay renders with "observed dwell (lower bound)" framing. Places below `STAY_COUNT_MIN = 5` show "not enough data yet." View supports rename, radius adjust, merge, and delete (pings stay on delete). Export integration for primer-window stays lives in TICK-029. See `PLAN_trigger_trap.md` §Change 2 + §Change 3.

## Acceptance Criteria

- [ ] Places view lists all places with reconstructed stay count and three-way split (episode / aborted / clean) over the last 90 days; shows "not enough data yet" placeholder when `stay_count < 5`
- [ ] Each listed stay displays "observed dwell (lower bound)" with the computed span, never a bare duration claim
- [ ] Rename, adjust radius, merge, and delete actions each work end-to-end; delete preserves pings so the place can re-form on next out-of-radius ping
- [ ] Episode-association window is `POST_STAY_EPISODE_WINDOW_HOURS = 48` after stay close (or during the stay); aborted events counted in the middle bucket
- [ ] Opt-in place naming prompt is reachable from this view and not from anywhere else in the app

## Agent Context

- Entire app is in `index.html`. New view + shared stay-reconstruction helper (the helper is also consumed by TICK-029's export integration).
- Stay reconstruction algorithm: filter pings inside `place.radiusM` within query window → cluster consecutive in-radius pings with gap >2h closing a cluster → per cluster `arrived = first.ts`, `left = last.ts`, `observed_dwell = left − arrived`.
- Constants live in the shared consts block from TICK-026/TICK-023. Do not redefine.
- Depends on TICK-006 for `episode.ictal_onset` (episode-association calculation) and TICK-027 for ping capture.
- Bump SW cache version.

## Implementation Notes

The three-way split (episode / aborted / clean) exists to preserve the aborted-event signal as intervention-efficacy evidence — binary "episode vs no episode" would lose it. See PLAN_trigger_trap.md Q6 resolution.

Stay-reconstruction helper should be written as a pure function that takes `(place, pings, windowDays)` and returns an array of stay records. TICK-029 reuses it directly.

Test file: `docs/testing/TEST-028-places-view.md` (separate sub-issue in Linear).

## Ship Notes

_(pending)_
