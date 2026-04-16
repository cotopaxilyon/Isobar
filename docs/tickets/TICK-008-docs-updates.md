---
id: TICK-008
title: Documentation updates
status: pending
priority: low
wave: 8
created: 2026-04-15
updated: 2026-04-15
plan: null
test: null
depends-on: [TICK-007]
supersedes: []
shipped: ""
---

# TICK-008: Documentation Updates

## Summary

Update project documentation to reflect all shipped changes from Waves 1–7. Covers MEDICAL_PURPOSE.md (Arizona paragraph rewrite under two-reference framing), FINDINGS patch (C1–C3 corrections only per consolidated plan), and README.md updates.

## Acceptance Criteria

- [ ] MEDICAL_PURPOSE.md Arizona paragraph rewritten: Arizona is trigger-evidence, not baseline
- [ ] MEDICAL_PURPOSE.md references clinical timeline (summers 2022/23 anchor)
- [ ] FINDINGS_environmental_trigger_analysis.md patched for C1 (retrospective framing), C2 (hypothesis-generating thresholds), C3 (Feb 12 sleep-deprivation reframe)
- [ ] README.md reflects current app state and feature set
- [ ] No code changes to index.html

## Agent Context

- Documentation-only ticket. No `index.html` changes. No SW cache bump needed.
- FINDINGS corrections C4 and C5 are explicitly deferred (per PLAN_trigger_surface_expansion.md critique section).
- Arizona reframe rationale is in project_baseline_reframe.md (memory file).

## Implementation Notes

Low-risk, low-priority. Can be done in a single session after Wave 7 ships.

## Ship Notes

_(pending)_
