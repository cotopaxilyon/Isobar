---
id: TICK-014
title: Cycle-phase moodShift → cycleRelatedDay rename (Item 12)
status: pending
priority: medium
wave: 1
created: 2026-04-19
updated: 2026-04-19
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-48
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-014: Cycle-Phase moodShift → cycleRelatedDay Rename (Item 12)

## Summary

Rename the cycle-phase `moodShift` toggle to `cycleRelatedDay` and broaden the label to *"Overall: today feels cycle-related"*. The current label conflates a meta-attribution toggle ("is today cycle-related?") with the peer-positioned specific symptom toggles next to it (breast tenderness, bloating, libido). The "Overall:" prefix makes the meta-status explicit. No structural UI restructure; if peer-positioning still confuses after ship, Option B (visual restructure) is a follow-up. Backward-compatible read of legacy `moodShift` values preserves all existing entries. Stage 1 of the irritability/severity plan; pairs with TICK-013 to clear Stage 1.

## Acceptance Criteria

- [ ] `cyclePhaseProxy.moodShift` field renamed to `cyclePhaseProxy.cycleRelatedDay` everywhere it is written
- [ ] Toggle label reads `Overall: today feels cycle-related` (not `Mood / irritability shift`)
- [ ] `cyclePhaseProxy` defaults shape exposes `cycleRelatedDay: false` (not `moodShift: false`)
- [ ] Reads of stored entries treat legacy `moodShift: true` as `cycleRelatedDay: true` — old entries continue to surface in log and export
- [ ] Export label reads `cycle-related day` (or comparable broadened wording — final wording in implementation), not `mood/irritability shift`
- [ ] No reorder, no sub-heading, no separation from peer phase-proxy toggles in the UI
- [ ] SW cache version bumped

## Agent Context

- Single-file PWA; all code lives in `index.html`.
- Field declared in `cyclePhaseProxy` defaults at `index.html:1333`.
- UI toggle button rendered at `index.html:1459` inside the cycle-phase section.
- Export read at `index.html:1722` (in the morning check-in branch of `generateReport()`).
- Backward-compat strategy: in every read site, coalesce `cp.cycleRelatedDay ?? cp.moodShift`. Do not migrate stored records — leave the legacy key in place on old entries. Per the plan, the data model is unchanged; this is a label/key rename with a coalesced read.
- **Do NOT add a separate "irritability" feeling toggle in this ticket** — that's TICK-013 (the standalone `irritabilityLevel` block). The Item 12 lock is *pure label rename*, no scope expansion.
- Confirm no other call sites reference `moodShift` after the rename: `grep -n 'moodShift' index.html` should return only the legacy-coalesce read sites.
- Run the architecture check after changes: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

Trivial rename in scope, but the backward-compat read is the load-bearing piece — the user has months of `moodShift: true` entries that must keep rendering. Test sequence:

1. Save a fresh check-in with the toggle ON. Stored record has `cyclePhaseProxy.cycleRelatedDay: true`, no `moodShift` key. Export and log show "cycle-related day."
2. Manually inspect (or seed via console) an entry with legacy `moodShift: true` and no `cycleRelatedDay` key. Export and log render the new label — old data surfaces under the new name without rewriting it.
3. Save a fresh check-in with the toggle OFF. Both keys stay falsy / absent; export omits the line.
4. Confirm `irritabilityLevel` (TICK-013, when shipped) and `cycleRelatedDay` are independent — toggling one does not affect the other.

Per the plan, the rename is a deliberate minimal-change-first decision. Visual restructure (Option B) is the documented fallback if peer-positioning remains confusing after ship — *do not pre-empt it here.*

## Ship Notes

_(pending)_
