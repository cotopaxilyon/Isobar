---
id: TICK-025
title: Export counter-example framing — base-rate denominators for exposures
status: pending
priority: medium
wave: 7
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: null
linear:
  parent: ISO-59
  test: ""
depends-on: [TICK-023]
supersedes: []
shipped: ""
---

# TICK-025: Export counter-example framing — base-rate denominators for exposures

## Summary

Replace episode-conditioned exposure summaries ("alcohol within 72h — 6 episodes") with counter-example framing that includes the non-episode denominator ("alcohol within 72h primer window — 6 episode-day hits, 14 non-episode-day hits"). When the non-episode denominator is unavailable or below a usable threshold, the export prints "(base rate unavailable)" instead of fabricating a ratio. Prevents the reader from drawing causal conclusions from episode-only counts. See `PLAN_trigger_trap.md` §Change 3 (exposure half).

## Acceptance Criteria

- [ ] Every exposure row in the export shows both numerator (episode-day hits in primer window) and denominator (non-episode-day hits over the same window length)
- [ ] When the non-episode denominator is zero or the window has too few non-episode days to be meaningful, the row prints "(base rate unavailable)" — no ratio rendered
- [ ] Exposures logged in the prodrome-adjacent band (last 6h pre-prodrome, per TICK-023) count in a third sub-row flagged "ambiguous — may reflect already-started attack"
- [ ] Prodrome-window exposures never appear in the exposure summary — they belong to TICK-024's prodrome tracks
- [ ] Old export regression: episodes without `prodrome_onset` fall back to a clearly labeled "legacy pre-episode window" exposure block with no denominator claim

## Agent Context

- Entire app is in `index.html`. Export function only.
- Uses the window boundaries established in TICK-023 — both tickets must share the same constants (`PRIMER_WINDOW_HOURS`, `PRODROME_FLOOR_HOURS`).
- The non-episode-day denominator is computed from morning-checkin records (Wave 5, shipped) plus any ad-hoc exposure logs on non-episode days. Define "non-episode-day" explicitly in code: a 24h period containing no `ictal_onset`.
- Do not persist counts — compute at export time.
- Bump SW cache version.

## Implementation Notes

The "(base rate unavailable)" path is deliberately conservative. If the user has logged only a handful of non-episode days, any ratio would be noise pretending to be signal. The plan explicitly chooses clarity over false precision here.

## Ship Notes

_(pending)_
