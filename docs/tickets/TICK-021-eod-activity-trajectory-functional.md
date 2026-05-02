---
id: TICK-021
title: EOD activity + single-shift trajectory + functionalToday
status: shipped
priority: high
wave: 2
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-55
  test: ""
depends-on: [TICK-018]
supersedes: []
shipped: ""
---

# TICK-021: EOD Activity + Single-Shift Trajectory + functionalToday

## Summary

Adds the remaining non-anchor scalar fields to the evening form: physical activity (level + optional type/when/minutes), the single-shift day-trajectory descriptor (`better / same / worse / up_down` with an optional shift-time selector for better/worse), and `functionalToday` — the daily self-awareness / validation-signal rating that plan §Item 6 explicitly moves to the EOD form. Multi-shift expansion for `up_down` is intentionally deferred to its own ticket (post-1-5 queue item) so this ticket stays scoped; the `up_down` option here simply stores the categorical without shift-time capture.

## Acceptance Criteria

- [ ] **Activity section** renders a 4-button row bound to `activityLevel` (`none / light / moderate / strenuous` — labels *None / mostly resting*, *Light — short walks*, *Moderate — sustained*, *Strenuous — pushed harder*). Below it: multi-select chip row "Type (optional)" bound to `activityType[]` with values `[walk, bike, workout, yoga, housework, other]`; multi-select chip row "When (optional)" bound to `activityWhen[]` with values `[morning, midday, afternoon, evening]`; single number input "Minutes (optional)" bound to `activityMinutes`
- [ ] **Trajectory section** renders a 4-button row bound to `dayTrajectory` (`better / same / worse / up_down` — labels per plan §"Part C — Form structure" Q1). When `better` or `worse` is selected, a conditional 3-button row appears bound to `trajectoryShiftTime` with values `[midday, afternoon, evening]`. Selecting `same` or `up_down` hides the shift-time row and clears `trajectoryShiftTime` to null. Section includes a small `<div class="setting-sub">` note: *"Multi-shift logging arrives in a later update"* beneath the `up_down` option
- [ ] **functionalToday section** renders a 4-button row bound to `functionalToday` on the `evening_checkin` record (NOT on the morning `checkin` record — morning's existing `functionalToday` field at `index.html:1530` stays untouched). Options and labels match the morning implementation exactly: `good / ok / scaled_back / bad` → *Good day / OK day / Scaled back / Bad day*; color ramp `good/accent/warn/danger`
- [ ] `eodData` initializer adds: `activityLevel: null, activityType: [], activityWhen: [], activityMinutes: null, dayTrajectory: null, trajectoryShiftTime: null, functionalToday: null`. All fields optional; partial saves round-trip
- [ ] Log card adds chips for set `activityLevel`, `dayTrajectory`, and `functionalToday` on `evening_checkin` entries (omitted otherwise). Export writes labeled lines for all seven set fields. Render within existing Morning section for this ticket — dedicated Evening section lands in TICK-022

## Agent Context

- Insertion point: after the cost section from TICK-020, above Save.
- Activity multi-select chips — reuse the existing `overnightEvents` multi-select pattern from morning check-in at `index.html:1437-1450`. The same toggle-in-array logic applies directly.
- Conditional UI for `trajectoryShiftTime` — render the shift-time row conditionally in the form JSX. When the user switches from `better` to `same`, clear `eodData.trajectoryShiftTime = null` in the click handler before re-rendering. Consistent with how morning handles its conditional `alcohol24h.lastDrinkTime` row at `:1405-1407`.
- `functionalToday` on EOD is **a separate field from the morning field**, even though they share the same name on different entry types. Reason: plan §Item 6 (`PLAN_irritability_and_severity_mapping.md:1027-1032`) moves `functionalToday` *conceptually* to EOD but the morning form ships with its own `functionalToday` already (`index.html:1527-1533`). Schema migration — removing from morning — is a Stage 4 concern; do not touch the morning field here. Per plan §"Schema migration boundaries" (`:958-961`), Stage 1→2 is a MINOR bump (new fields, no removals).
- Log card chip styling for new fields: reuse `functionalColors` / `functionalLabels` at `index.html:1587-1588`. For `activityLevel` introduce a new local map at the top of the render callback: `const activityColors = { none:'var(--mid)', light:'var(--good)', moderate:'var(--accent)', strenuous:'var(--warn)' }`. For `dayTrajectory` similarly — `const trajectoryLabels = { better:'got better', same:'same', worse:'got worse', up_down:'up & down' }`.
- Export: reuse `functionalLabels` already defined at `index.html:1728`. Add local activity-level and trajectory label maps in the EOD branch (TICK-022 will migrate this to a dedicated section).
- **Do NOT bump SW cache version** (no shell asset changes).
- Run architecture check: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

- **Why activity fields are scoped here:** plan §"Part C — Form structure" Q2 groups them as one section. `activityLevel` is the required-ish anchor; the optional sub-fields (`activityType`, `activityWhen`, `activityMinutes`) add resolution for PEM correlation analysis later.
- **Why single-shift trajectory here, multi-shift separately:** plan §Item 11 (`:1248-1269`) specs a conditional multi-shift expansion *when `up_down` is selected*, with up to 3 timestamped shifts. That's a distinct UI surface (list of shift rows, add/remove buttons, weather-fetch hooks per Item 14) and warrants its own ticket. Shipping `up_down` here without the expansion is safe because the data fallback is clearly documented in the plan: *"`up_down` is still valid with zero shift details (fallback behavior = current v1 spec)."*
- **Why `functionalToday` duplicates the morning field name:** the plan's long-term design (Stage 4) makes morning's `functionalToday` redundant once EOD captures it more reliably — retrospective end-of-day assessment is more accurate than morning prediction. But migrating the field now would be a schema change, which Stage 2 is explicitly not doing. They coexist for this stage; Stage 4 cleans up.
- **Field count check:** seven new fields, three log chips, seven export lines, one conditional UI. ~120-170 LOC. At the soft cap — split further only if LOC balloons past 200 during build.
- **Test sequence (user, during QA):**
  1. Open EOD form — three new sections appear below cost section.
  2. Tap `activityLevel` options one at a time — single-select; try setting + unsetting multi-select chips for type and when; type a number in minutes; save.
  3. Tap `dayTrajectory: better` — shift-time row appears. Tap `midday`. Switch to `dayTrajectory: same` — shift-time row hides and the stored `trajectoryShiftTime` should become null (verify in export).
  4. Tap `dayTrajectory: up_down` — no shift-time row; small note visible; `trajectoryShiftTime` null.
  5. Tap `functionalToday` options — chip appears in log with correct color; export prints "Today: …".
  6. Save with none of these fields set — log and export render cleanly.
  7. Open a morning check-in saved before this ticket — its `functionalToday` still renders (morning field untouched).

## Ship Notes

_(pending)_
