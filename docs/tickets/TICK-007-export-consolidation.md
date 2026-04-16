---
id: TICK-007
title: Export consolidation
status: pending
priority: medium
wave: 7
created: 2026-04-15
updated: 2026-04-15
plan: null
test: null
depends-on: [TICK-005, TICK-006]
supersedes: []
shipped: ""
---

# TICK-007: Export Consolidation

## Summary

Rewrite the plain-text export to reflect all changes from Waves 1–6. Adds clinical timeline header (summers 2022/23 through fall 2025 onset), Arizona as a separate trigger-evidence section, per-episode phase metrics, exposure summary, functional-today scale for check-ins, and motor activity breakdown (four buckets). Severity rendered as patient-language + clinical approximate (PGI-S, mRS, PSFS Part 2) with a one-time legend.

## Acceptance Criteria

- [ ] Export header includes clinical timeline (locked in project_baseline_reframe.md)
- [ ] Arizona section is separate from timeline — framed as trigger/mechanism evidence
- [ ] Episode entries include: prodrome duration, spasm count, episode duration, episodeImpact, postictal assessment
- [ ] Motor activity split into four buckets per consolidated plan Gap 2
- [ ] Check-in entries use functional-today labels (Good/OK/Scaled back/Bad)
- [ ] Exposure section uses "Exposures" title, lists all logged exposure chips
- [ ] Severity labels include clinical scale approximations with one-time legend
- [ ] Old entries (pre-wave-4) render correctly with fallback labels
- [ ] Report is readable by a neurologist, rheumatologist, or autonomic specialist without app context

## Agent Context

- Entire app is in `index.html`.
- Key function: `generateReport()` / `exportReport()`.
- This is a rewrite of the export function, not a patch. Read all entry types and render appropriately.
- Clinical timeline text is locked — do not edit the timeline content, copy verbatim from project_baseline_reframe.md.
- Bump SW cache version.

## Implementation Notes

This ticket has no plan doc — the export format is defined by the cumulative output of Waves 1–6. A plan doc may be written before implementation if the export layout needs user review.

## Ship Notes

_(pending)_
