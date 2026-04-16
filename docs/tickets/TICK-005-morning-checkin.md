---
id: TICK-005
title: Morning check-in restructure
status: pending
priority: high
wave: 5
created: 2026-04-15
updated: 2026-04-15
plan: docs/plans/PLAN_morning_checkin.md
test: null
depends-on: [TICK-004]
supersedes: ["UPDATES #8B Arizona label tightening"]
shipped: ""
---

# TICK-005: Morning Check-in Restructure

## Summary

Convert the 6-step "Daily Check-in" into a 5-step "Morning Check-in" optimized for capturing baseline / pre-episode state. Drops evening-natural questions (exhaustion, work capacity, cancelled plans, heat therapy). Adds overnight events and morning stiffness. Replaces the Arizona comparison with a functional-today daily scale (Good day / OK day / Scaled back / Bad day). Home button relabeled "Morning Check-in."

## Acceptance Criteria

- [ ] Home button says "Morning Check-in" not "Daily Check-in"
- [ ] 5 steps: Sleep, Overnight Events, Communication, Body, Functional-Today + Notes
- [ ] Step 1 (Sleep): bedtime, wake time, sleep quality, hours slept
- [ ] Step 2 (Overnight Events): overnight chips including "Slept through — nothing noticed" (mutually exclusive, pinned to bottom)
- [ ] Step 2 includes "Morning stiffness" with duration prompt and "Woke up locked / couldn't move" as separate chip
- [ ] Step 3 (Communication): unchanged from UPDATE-1 four-value scale
- [ ] Step 4 (Body): pain locations via body map
- [ ] Step 5: functional-today scale (Good / OK / Scaled back / Bad) — NOT Arizona comparison
- [ ] Step 5 includes notes textarea
- [ ] Old check-in entries without new fields render without error in log and export
- [ ] Export uses functional-today labels for new entries, falls through gracefully for old entries
- [ ] `hormonalSymptoms` field removed (per Q3 resolution)
- [ ] No orthostatic step (per Q4 resolution)

## Agent Context

- Entire app is in `index.html`.
- Key locations: `CI_STEPS` array, `renderCiStep()` cases 0–5, `startCheckin()`, `saveCheckin()`, `renderLog()`, `generateReport()`.
- Full design spec in PLAN_morning_checkin.md — all 5 open questions resolved.
- Functional-today scale anchors are in project_baseline_reframe.md (memory file) — locked 4-level scale.
- Arizona moves to a separate export section in Wave 7 (TICK-007), not removed entirely.
- Bump SW cache version.

## Implementation Notes

This is the largest single-ticket UI rewrite. The plan doc has step-by-step implementation guidance. Key risk: the overnight events step is entirely new UI with no existing pattern to follow — will need a chip grid similar to the exposure step.

Tier 1 exposure additions (alcohol24h, cycle proxy, numeric sleep hours) from PLAN_trigger_surface_expansion also land here per the consolidated plan. Sleep hours on the check-in is derived from bedtime/wake time, not a separate input.

## Ship Notes

_(pending)_
