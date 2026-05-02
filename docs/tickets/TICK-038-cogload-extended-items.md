---
id: TICK-038
title: EOD cognitive load — add 3 missing extended items to form
status: pending
priority: normal
wave: 2
created: 2026-05-01
updated: 2026-05-01
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-101
  test: ""
depends-on: [TICK-030]
supersedes: []
shipped: ""
---

# TICK-038: EOD Cognitive Load — Add Missing Extended Items

## Summary

TICK-030 (ISO-73) shipped only the 5 core cognitive-load items in the EOD form. The 3 extended items (`communicationProduction`, `efLogistics`, `anticipatory`) are already in the `eodData` initializer and in the APPENDIX C export map, but cannot be toggled — they're unreachable from the form. This ticket renders them under an "Additional" subheading, matching the pattern introduced by TICK-031 and TICK-032.

## Acceptance Criteria

- [ ] EOD form cognitive load section gains an "Additional" subheading (`<span class="setting-sub">Additional</span>`) below the 5 existing core buttons
- [ ] Below the subheading: 3 extended toggle buttons using the existing `<button class="comm-btn">` pattern:
  1. `communicationProduction` — *"Wrote or rehearsed an avoided message"*
  2. `efLogistics` — *"EF + logistics work — 1+ hour"*
  3. `anticipatory` — *"Tracking 3+ open background threads"*
- [ ] Toggle behavior identical to core items: single-tap, tinted background when active, no coupling
- [ ] No changes to the data model, log card chip, or export — all three are already wired for these keys
- [ ] **Do NOT bump SW cache version**
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty

## Agent Context

- Insertion point: after the last core item's closing tag in the cognitive load `<div class="comm-options">` at `index.html` (around the `emotionalRegulation` button), before the section's closing `</div></div>`.
- The `eodData.cogLoad` initializer already has `communicationProduction`, `efLogistics`, `anticipatory` (line ~2390). No schema change.
- The export block already maps all 8 keys including these three (APPENDIX C). No export change.
- The log card chip gates on all 8 keys including these three. No chip change.
- Pattern to copy: see TICK-031/032 "Additional" subheading blocks — `<div style="margin-top:10px;margin-bottom:4px"><span class="setting-sub">Additional</span></div>` followed by a `<div class="comm-options">` with the extended buttons.

## Implementation Notes

- **Why these were missing:** TICK-030 shipped only 5 core items during implementation; the 3 extended items survived in the data model and export but the form rendering was incomplete. Surfaced during TICK-031/032 implementation review 2026-05-01.
- **Why no data model change:** the initializer was correct from TICK-030. This is a form-only gap.
- **LOC estimate:** ~25-35 LOC — just a subheading + 3 buttons.

## Ship Notes

_(pending)_
