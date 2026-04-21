---
id: TICK-020
title: EOD cost block — activities / connection / fun / sleep readiness
status: pending
priority: high
wave: 2
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-54
  test: ""
depends-on: [TICK-018]
supersedes: []
shipped: ""
---

# TICK-020: EOD Cost Block

## Summary

Captures "what did today cost" across four domains — activities planned, connection with people, things for fun, sleep readiness now. Each is a 4-tier retrospective rating per plan §"Part C — Form structure" Q5 and §"Likert conversion table". These four fields are the largest single weight cluster in the composite (0.15 for `costActivities` alone plus 0.05 each for the others — see `PLAN_irritability_and_severity_mapping.md:493-499`), so they anchor the evening form's clinical value.

## Acceptance Criteria

- [ ] EOD form renders a section titled "What did today cost across…" containing four sub-rows, each a 4-button single-select. Fields and option values: `costActivities` (`all / most / some / almost_none`, labels *all / most / some / almost none*), `costConnection` (`easy / muted / withdrew / couldnt`, labels *easy / muted / withdrew / couldn't*), `costFun` (`had_energy / a_little / none / avoided`, labels *had energy / a little / none / avoided*), `costSleepReadiness` (`tired_good / wiped / wired / overwhelmed`, labels *tired-good / wiped / wired / overwhelmed*). Section sits directly below the snapshot section from TICK-019 and above Save
- [ ] Color ramp for all four rows follows the Likert 1→2→4→5 ordinal mapping from plan §"Likert conversion table" (`PLAN_irritability_and_severity_mapping.md:419-428`): `var(--good)` → `var(--accent)` → `#f97316` → `var(--danger)`. Options must map monotonically to the ramp (tier 1 = good, tier 5 = danger)
- [ ] `eodData` initial shape includes `costActivities: null, costConnection: null, costFun: null, costSleepReadiness: null`; fields are optional, never block save
- [ ] Log card emits up to four small chips for set cost fields (chip pattern `<span class="entry-chip" style="color:${ramp}">${label}</span>`), omits silently when null. Export prints one line per set field with human-readable label
- [ ] Partial saves round-trip — any subset of the four nulled out renders in log and exports without error

## Agent Context

- Form insertion point: after the snapshot-block section from TICK-019, before the Save button in `#eod-actions`.
- Reuse the `.comm-btn` / `.comm-options` button pattern (example usage at `index.html:1483-1490`) for each of the four 4-button rows. Stacking four rows of four buttons each is fine — morning check-in already stacks comparable density.
- `eodData` initializer was established in TICK-018's `startEvening()`. Add the four new keys alongside (or after) the snapshot keys from TICK-019.
- Color ramp: reuse the same inline color values used in the morning communication block — do not introduce a new shared palette object unless one already exists. The morning block at `index.html:1483-1490` uses the `comm-btn-*` classes; alternately the irritability block at `:1498-1508` uses inline ramp. Either pattern is fine; pick one and apply consistently across all four cost rows.
- Export (`exportReport` at `index.html:1670-1792`): emit four labeled lines when present. Labels: *"Activities cost"*, *"Connection cost"*, *"Fun cost"*, *"Sleep readiness"*. Reuse the null-guard pattern (`if (e.costActivities) r += ...`). Rendering within the Morning section is acceptable for now; TICK-022 adds the dedicated Evening section.
- Log card: extend the existing chips array at `index.html:1600-1616` with four new entries conditional on field presence AND `e.type === 'evening_checkin'`. Do NOT show cost chips on morning check-ins (they don't carry these fields).
- Values use snake_case (`almost_none`, `had_energy`, `tired_good`) — match the plan's Likert table storage convention so the downstream Stage 4 composite can reference them directly without re-mapping.
- **Do NOT bump SW cache version** (no shell asset changes).
- Run architecture check: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

- **Why four rows instead of one grouped grid:** plan §"Part C — Form structure" Q5 shows a per-domain prompt so the user rates each separately. A 4×4 matrix UI would be denser but the plan's "works when she is at her worst" principle favors simple sequential rows.
- **Option label vs value:** store snake_case values (`almost_none`), render human-readable labels (*almost none*). Keep a small labels object per field at the render site, same pattern as `sevLabels` / `commLabels` in `exportReport` at `:1689-1690`.
- **Why `costActivities` carries the largest weight (0.15):** plan §"Weight rationale" (`PLAN_irritability_and_severity_mapping.md:493-499`) — *"retrospective behavioral evidence of interference. Along with pain and cognition it forms the composite's primary backbone."* Not this ticket's concern (composite math lands in Stage 4), but worth understanding the scope of the field being added.
- **Test sequence (user, during QA):**
  1. Open EOD form — four new rows appear below the snapshot section, all untoggled.
  2. Tap across each row — single-select per row, color tint matches ramp.
  3. Save with all four set — log card shows four chips; export has four labeled lines.
  4. Save with only `costActivities` set — log shows one chip; other three omit.
  5. Save completely empty — no chips, no export cost lines, no errors.
  6. Saved EOD from TICK-018 or TICK-019 (pre-cost) — renders cleanly with no cost chips.

## Ship Notes

_(pending)_
