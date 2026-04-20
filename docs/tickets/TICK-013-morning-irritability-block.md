---
id: TICK-013
title: Morning irritability block (Part A1)
status: pending
priority: high
wave: 1
created: 2026-04-19
updated: 2026-04-19
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-47
  test: ""
depends-on: [TICK-009, TICK-010, TICK-011, TICK-012]
supersedes: []
shipped: ""
---

# TICK-013: Morning Irritability Block (Part A1)

## Summary

Add the edginess polarity to the morning check-in. Today the only irritability surface is the cycle-phase `moodShift` toggle — trapped under a hormonal frame and missing from severity entirely. This ticket adds a 4-level "fuse / sensory tolerance" block plus an external-observation prompt below the existing communication step. New fields only; no schema migration. Stage 1 of the irritability/severity plan; first ticket after the Stage 0 persistence floor closed (ISO-39/40/41/42).

## Acceptance Criteria

- [ ] New 4-button block "Right now — fuse / sensory tolerance" renders in the Communication step, immediately after the existing externalObservation Y/N/No-one-around section (below it, not between it and the communication buttons)
- [ ] Options are `Normal — usual patience` / `Edgy — quicker to react than usual` / `Sensory overload — sounds / light / touch grating` / `Snap-line — anything extra is too much`
- [ ] Color ramp is `var(--good)` → `var(--accent)` → `#f97316` → `var(--danger)` — parallel to `communicationLevel` in shape but distinct in mid-range (accent vs. warn) to mark irritability as its own polarity
- [ ] New 3-button toggle "Has anyone noticed you snapping or seeming on edge?" with options `Yes` / `No` / `No one around`
- [ ] Both blocks are optional — saving the check-in does not require either
- [ ] Stored on the check-in record as `irritabilityLevel` (`normal | edgy | overload | snap_line`) and `morningIrritabilityExternalObservation` (`Yes | No | No one around` — label-string storage to match the existing `ciData.externalObservation` convention at `index.html:1489`)
- [ ] `ciData` defaults expose `irritabilityLevel: null` and `morningIrritabilityExternalObservation: null` so partial check-ins serialize cleanly
- [ ] Log card and export render irritability when present, omit silently when null
- [ ] Existing morning check-ins without the new fields render in log and export without error
- [ ] SW cache version bumped

## Agent Context

- Single-file PWA; all code lives in `index.html`.
- Insertion point: Communication step renders at `index.html:1474-1492` (`case 2` of `renderCiStep`). Add the new block after the existing `<div class="section">` that holds the external-observation prompt.
- `ciData` initial shape defined at `index.html:1328-1333`. Add the two new keys alongside `communicationLevel` and `externalObservation`.
- Reuse the existing `comm-btn` button pattern for the 4-level row and the existing `toggle-btn` / `toggle-pair` pattern for the Y/N/No-one-around row — both already styled and tap-target-correct.
- Export write paths to update: `generateReport()` morning check-in branch (around `index.html:1708-1729`). Render `irritabilityLevel` next to `communicationLevel` and `morningIrritabilityExternalObservation` next to `externalObservation`. Use the same null-guard pattern as the existing fields.
- Log card render path (`index.html:1577`) — add an irritability chip mirroring the communication chip when `irritabilityLevel` is set. Color ramp per AC#3 (`var(--good)` → `var(--accent)` → `#f97316` → `var(--danger)`). Do NOT edit the `recent-ep` stats block at `index.html:1621-1628`; it iterates episodes only and `irritabilityLevel` is a check-in field, so an edit there would be unreachable.
- **Do NOT touch the cycle-phase `moodShift` toggle in this ticket.** That rename is TICK-014 — splitting them keeps each ticket independently revertable.
- Run the architecture check after changes: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

Mechanically small (one new render block, two new keys, two render-site updates), but it's the first new irritability surface in the app. Test sequence:

1. Open morning check-in on a fresh day. New block appears, all 4 buttons untoggled. Save without tapping anything — record stores `null` for both new fields, no console errors, log card renders with no irritability chip.
2. Tap each of the 4 levels in turn — selection visually swaps with the right color tint, single-select behavior matches `communicationLevel`.
3. Tap each Y/No/No-one-around — same single-select behavior as the existing externalObservation row.
4. Save with `irritabilityLevel: 'edgy'` + `morningIrritabilityExternalObservation: 'Yes'`. Log card shows the irritability chip in accent color. Export run shows both new fields under the morning check-in entry.
5. Open a check-in saved before this ticket — log card and export both render without throwing.

Per the plan, this ticket is a follow-up modification to the already-shipped morning check-in restructure (TICK-005) — not a redesign. One block, two fields, no migration. Stage 1 → Stage 2 versioning is a MINOR bump per `PLAN_irritability_and_severity_mapping.md` §"Schema migration boundaries"; bump composite version when Stage 4 ships, not here.

## Ship Notes

_(pending)_
