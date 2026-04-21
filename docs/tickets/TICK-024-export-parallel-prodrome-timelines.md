---
id: TICK-024
title: Export parallel prodrome timelines — real-time vs retrospective
status: pending
priority: medium
wave: 7
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: null
linear:
  parent: ISO-58
  test: ""
depends-on: [TICK-006, TICK-023]
supersedes: []
shipped: ""
---

# TICK-024: Export parallel prodrome timelines — real-time vs retrospective

## Summary

Split the prodrome section of the export into two tracks rendered side by side: Track A (real-time-captured `prodrome_symptoms`, `captured_retrospectively: false`) and Track B (retrospectively backfilled, `captured_retrospectively: true`). Any prodrome timing or correlation math uses Track A only — Track B renders as narrative context with a visible "backfilled" marker. Prevents hindsight-bias-contaminated entries from silently flattening into the same evidence stream as real-time captures, while keeping them visible to the clinician. See `PLAN_trigger_trap.md` §Change 1 (resolves Q5).

## Acceptance Criteria

- [ ] Export prodrome section renders two labeled tracks: "Track A — real-time" and "Track B — retrospective (backfilled)"
- [ ] Each Track B entry carries an explicit backfill marker inline (not only in a section header)
- [ ] Any correlation/timing computation (e.g. prodrome duration, symptom count in window) uses Track A entries only; Track B is excluded from math and labeled accordingly in the export
- [ ] Episodes with only retrospective entries render Track A as "none captured in real time" and Track B populated — no silent merge
- [ ] Old episodes without `captured_retrospectively` on their prodrome entries default to Track A (backward compat)

## Agent Context

- Entire app is in `index.html`. Export function only — no schema change.
- Flag source: `prodrome_symptoms[].captured_retrospectively` (defined in PLAN_episode_phases.md Tier 3 amendments, lands with TICK-006).
- Depends on TICK-023 for the overall three-zone export skeleton; this ticket lives inside the Prodrome zone defined there.
- Do not alter the real-time-capture UX — that's TICK-006's surface. This is pure render.
- Bump SW cache version.

## Implementation Notes

The two-track framing is how the plan resolves the Q5 tension: excluding retrospective data entirely loses real clinical signal; silently merging it pollutes timing computation with hindsight. Parallel rendering keeps both visible without blending.

## Ship Notes

_(pending)_
