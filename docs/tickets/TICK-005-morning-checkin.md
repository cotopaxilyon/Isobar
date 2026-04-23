---
id: TICK-005
title: Morning check-in restructure
status: done
priority: high
wave: 5
created: 2026-04-15
updated: 2026-04-22
plan: docs/plans/PLAN_morning_checkin.md
test: null
linear:
  fulfilled-by: [ISO-47, ISO-48, ISO-28, ISO-29, ISO-35, ISO-36, ISO-38, ISO-51]
  note: "All acceptance criteria shipped piecemeal between 2026-04-18 and 2026-04-21; this ticket never ran as a single bundle."
depends-on: [TICK-004]
supersedes: ["UPDATES #8B Arizona label tightening"]
shipped: "2026-04-21"
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

**Closed as housekeeping 2026-04-22** — all acceptance criteria shipped piecemeal rather than as a single bundled ticket. Diff against current `index.html` (2026-04-22) confirms every AC satisfied:

| Acceptance criterion | Shipped via |
|---|---|
| Home button says "Morning Check-in" | index.html:416 — shipped pre-TICK-005 drafting |
| 5 steps: Sleep / Overnight Events / Communication / Body / Functional-Today + Notes | `CI_STEPS` at index.html:1349–1355 |
| Step 1 (Sleep) — bedtime, wake time, awakenings, sleep quality | index.html:1403–1445 |
| Step 2 (Overnight Events) — chips + "Slept through" mutually exclusive + morning stiffness duration | index.html:1448–1512 |
| Step 3 (Communication) — UPDATE-1 four-value scale | index.html:1515–1550 |
| Step 4 (Body) — body map | index.html:1552–1555 |
| Step 5 — functional-today scale Good/OK/Scaled back/Bad + notes | index.html:1556–1576 |
| Old entries render without error | `exportReport` presence-guards at index.html:1798–1831 |
| `hormonalSymptoms` field removed | removed per Q3 |
| No orthostatic step | removed per Q4 |

**Additional scope landed under the same surface** (not in original AC list, but within the spirit of the bundle):
- Morning irritability block — ISO-47 / TICK-013 (2026-04-20).
- Cycle-phase `moodShift` → `cycleRelatedDay` rename — ISO-48 / TICK-014 (2026-04-21).
- Cycle proxy toggles render as log chips — ISO-51 (2026-04-21).
- Body-map L/R mirror convention — ISO-29, ISO-36 (2026-04-20, 2026-04-18).
- Functional-today voice fix — ISO-28 (2026-04-18).

**Why this was closed as housekeeping, not actually shipped as a bundle:** the rollout plan specced a single TICK-005 bundle. What actually happened: the irritability plan's Part A1 broke out as TICK-013, the cycle rename as TICK-014, and the other ACs landed as incremental polish tickets. No single commit delivers TICK-005's full scope — it accreted across ~10 commits between 2026-04-18 and 2026-04-21. The plan `PLAN_morning_checkin.md` remains the authoritative spec for what the morning check-in should look like; this ticket file is preserved as the historical bundle record.
