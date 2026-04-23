---
id: TICK-034
title: EOD symptom-axis behavioral Y/N anchors — fatigue + pain + social/irritability
status: pending
priority: high
wave: 2
created: 2026-04-23
updated: 2026-04-23
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-77
  test: ""
depends-on: [TICK-018]
supersedes: []
shipped: ""
---

# TICK-034: EOD Symptom-Axis Behavioral Y/N Anchors

## Summary

Adds three symptom-axis behavioral Y/N anchor sections to the EOD form per plan §Item 3 + Item 6 (locked 2026-04-23): **fatigue** (3 items), **pain** (3 items), **social/irritability** (4 items). All equal-weight count-based scoring within each axis. Fatigue feeds the `fatigue` composite axis (trajectory aggregation alongside Likerts); pain feeds the `pain` composite axis as a supplementing behavioral signal alongside the Likert and episode-peak; social/irritability feeds a distinct axis that contributes to both the composite and PEM correlation.

Bundled ticket — same UI pattern applied three times. Splittable if LOC balloons past 250.

## Acceptance Criteria

### Fatigue section (3 items)
- [ ] EOD form renders section titled "Fatigue today" with 3 Y/N toggle rows:
  1. `fatigueAnchorNapped` — *"Napped today"*
  2. `fatigueAnchorBedEarly` — *"Went to bed earlier than planned"*
  3. `fatigueAnchorRestedNotNap` — *"Rested / lay down during the day (not a nap)"*
- [ ] `eodData` adds `fatigueAnchors: { napped: false, bedEarly: false, restedNotNap: false }`

### Pain section (3 items)
- [ ] EOD form renders section titled "Pain today" with 3 Y/N toggle rows:
  1. `painAnchorAvoidedMovement` — *"Avoided a specific movement"*
  2. `painAnchorUnscheduledMed` — *"Took unscheduled pain medication"*
  3. `painAnchorAtRest` — *"Pain at rest (not just during movement)"*
- [ ] `eodData` adds `painAnchors: { avoidedMovement: false, unscheduledMed: false, atRest: false }`

### Social / irritability section (4 items)
- [ ] EOD form renders section titled "Social / irritability today" with 4 Y/N toggle rows:
  1. `socIrritAnchorSnapped` — *"Snapped at someone today"*
  2. `socIrritAnchorWithdrew` — *"Withdrew from planned contact"*
  3. `socIrritAnchorShortenedCancelled` — *"Cancelled or shortened a planned interaction"*
  4. `socIrritAnchorSharper` — *"Responded more sharply than the moment warranted"*
- [ ] `eodData` adds `socIrritAnchors: { snapped: false, withdrew: false, shortenedCancelled: false, sharper: false }`

### Placement, interaction, storage
- [ ] All three sections use the `.load-anchor` row pattern from TICK-030 (or local stub if TICK-030 hasn't shipped — dedupe on whichever ships last). Single-tap toggle, ≥44px tap target, no coupling between rows.
- [ ] Section order: fatigue → pain → social/irritability. Insertion point: below the cognition EOD section (TICK-033) if shipped; otherwise below the emotional load section (TICK-032) or cost block (TICK-020, shipped).
- [ ] No "core vs extended" split for any of these three sections — the counts are equal-weight per plan §Item 6 Change 2, so a hierarchy would not reflect any scoring difference.
- [ ] All fields optional; partial logging never blocks save.

### Log card
- [ ] Log card emits up to three summary chips on `evening_checkin` entries:
  - *"fatigue"* colored `var(--mid)` when any fatigue-anchor item fires
  - *"pain"* colored `var(--mid)` when any pain-anchor item fires
  - *"irrit"* colored `var(--mid)` when any social/irritability-anchor item fires
- [ ] Omit each chip when its axis has all items false

### Export
- [ ] EVENING block (once TICK-022 ships; temporary home in Morning branch otherwise) renders three compact labeled lines:
  - *"Fatigue: [napped, bed-early]"*
  - *"Pain: [avoided-movement, at-rest]"*
  - *"Social/irrit: [withdrew, shortened]"*
- [ ] Each line omitted when its axis is all false

### Technical
- [ ] **Do NOT bump SW cache version** (no shell asset changes)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty
- [ ] Backward-compatibility: older EOD entries render cleanly with no symptom-axis sections (defaults to all-absent = treated as all-false)

## Agent Context

- **Three sections, same pattern.** Extract a small render helper if it reduces repetition meaningfully — e.g. `renderAnchorSection(title, anchors, storageKey)` called three times. Do not over-abstract — if the three sections fit cleanly without a helper, inline is fine.
- **Storage keys use camelCase under per-axis object** (matches TICK-030/031/032 convention):
  - `eodData.fatigueAnchors.napped | bedEarly | restedNotNap`
  - `eodData.painAnchors.avoidedMovement | unscheduledMed | atRest`
  - `eodData.socIrritAnchors.snapped | withdrew | shortenedCancelled | sharper`
- **Equal-weight count semantics** — composite engine (Stage 4 / TICK-007) will read each section's booleans, count active, divide by section max. No weight table to store here.
- **Why no description text for these items:** the item labels are short and self-explanatory (unlike the load anchors where thresholds and context needed description). Keep the EOD form tight — this ticket adds 10 rows; terse labels are a kindness.
- **Log card gating:** follow the TICK-030/031/032 pattern — emit a section-summary chip, not per-item chips. Three chips (fatigue / pain / irrit) is the ceiling added by this ticket; combined with load-set chips that will mean up to 6 load+symptom summary chips on a heavy day. Still tighter than per-item.

## Implementation Notes

- **Why bundled, not split:** the three sections share the same row pattern, same interaction model, same storage shape. Splitting adds ~3× ticket overhead (three sets of ACs, three code reviews) for no design clarity gain. If LOC balloons past 250 during build, split into TICK-034 (fatigue + pain) and TICK-035 (social/irritability).
- **Composite integration (not this ticket's concern, for reference):**
  - `fatigueAnchors` count → feeds `fatigue` axis alongside morning/evening Likerts and `dayTrajectory` via `trajectory` aggregator (Stage 4).
  - `painAnchors` count → supplements `pain` axis (Likert + episode peak + anchor count).
  - `socIrritAnchors` count → contributes to a distinct axis in the composite. Plan §Item 3 "composite rebalancing" locks that social + emotional axes weight EOD behavioral anchors alongside external-observation fields.
- **Cuts rationale** (preserved from walkthrough 2026-04-23):
  - Fatigue: "skipped activity too tired" (overlaps `costActivities`), "woke unrefreshed" (overlaps sleep quality), "pushed through depleted" (introspective).
  - Pain: "used heat/cold/device" (routine-use risk, no signal), "modified activity because of pain" (overlaps `costActivities` + #1 avoidance), "adjusted posture repeatedly" (baseline-behavior noise).
  - Social/irritability: "thinner-skinned than usual" (introspective), "avoided eye contact" (autistic-baseline misfire risk), "didn't initiate contact" (vague baseline).
- **LOC estimate:** ~220-280 LOC — 10 rows + 3 initializers + 3 log chips + 3 export lines + possibly one render helper. At the soft cap. Split point: 250 LOC during build → move social/irritability to TICK-035.
- **Test sequence (user, during QA):**
  1. Open EOD form — three new sections appear after cognition (or after emotional load if cognition hasn't shipped): "Fatigue today" (3 items), "Pain today" (3 items), "Social / irritability today" (4 items).
  2. Tap each item across all three sections — independent toggles; no coupling.
  3. Save with 1 fatigue item + 2 pain items + 3 social items — log card shows three chips (fatigue, pain, irrit); export writes three labeled lines with correct short-key lists.
  4. Save with only one axis firing — only that axis's chip and export line; others silent.
  5. Save empty — no new chips, no new export lines.
  6. Older pre-ticket EOD from TICK-018/019/020 — renders cleanly, no new sections.
  7. Combined test with TICK-030/031/032/033 if those have shipped — EOD form scrollable and all sections render in the spec'd order without overlap. Confirm form is still usable at 3-5 minute completion time on a normal day.

## Ship Notes

_(pending)_
