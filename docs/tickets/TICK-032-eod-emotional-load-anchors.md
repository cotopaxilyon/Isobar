---
id: TICK-032
title: EOD emotional load anchor set — 5 items, 4 core + 1 extended, weighted
status: pending
priority: high
wave: 2
created: 2026-04-23
updated: 2026-04-23
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-75
  test: ""
depends-on: [TICK-018, TICK-020, TICK-030]
supersedes: []
shipped: ""
---

# TICK-032: EOD Emotional Load Anchor Set

## Summary

Adds the 5-item emotional-load anchor section to the EOD form per plan §Item 10 (locked 2026-04-23 in anchor-walkthrough). Behavioral Y/N anchors capturing affective content (not regulation work, which is in TICK-030's cognitive anchor #4). Deliberately below the 6-item framework floor — the emotional axis has fewer clean observable anchors than cognitive/social for alexithymic populations; rationale preserved in plan §Item 10 emotional section. Feeds `eodEmotionalBehavioralCount` — a weighted-count input to the composite at weight 0.05 (per `axisConfig` at `PLAN_irritability_and_severity_mapping.md:462`) — and the PEM correlation engine.

## Acceptance Criteria

- [ ] EOD form renders a section titled "Emotional load today" containing 5 Y/N toggle rows in this order, each using the `<div class="load-anchor">` pattern from TICK-030:
  - **Core:**
    1. `emoLoadConflict` — *"Conflict or rupture event"* / *"Argument, meaningful misunderstanding, difficult conversation with someone that matters"* (weight 3)
    2. `emoLoadSignificantNews` — *"Significant news or awaited outcome"* / *"Medical result, test result, financial/legal outcome, or other real-stakes news received today"* (weight 3)
    3. `emoLoadDreadLoop` — *"Dread / anxiety loop ≥1h"* / *"Ran worry, catastrophizing, or avoidance loops about a specific concrete thing for a meaningful stretch today — observable as checking, rehearsing, avoidance behaviors"* (weight 3)
    4. `emoLoadWitnessedDistress` — *"Witnessed distress"* / *"Someone you care about was having a hard time today and you were present to it (vicarious affect load)"* (weight 2)
  - **Extended (under "Additional" subheading — single item):**
    5. `emoLoadFlashback` — *"Emotional flashback"* / *"A place, smell, song, or mention pulled you back into a past difficult experience today"* (weight 2)
- [ ] Section sits directly below the social load section (TICK-031) under the heading "Emotional load today"
- [ ] Row interaction identical to TICK-030 / TICK-031: single-tap toggle, tinted when active, ≥44px tap target
- [ ] `eodData` initializer adds `emoLoad: { conflict: false, significantNews: false, dreadLoop: false, witnessedDistress: false, flashback: false }`. Optional
- [ ] Log card emits a single summary chip *"emo-load"* colored `var(--mid)` when any core item fires. Omit when all 5 are false
- [ ] Export writes a compact labeled line: *"Emotional load: [conflict, significant-news, dread-loop]"* — comma-separated short keys of active items. Omit when all 5 are false
- [ ] **Do NOT bump SW cache version** (no shell asset changes)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty

## Agent Context

- **Depends on TICK-030** for the `.load-anchor` row pattern. Sibling to TICK-031 — ordering between TICK-031 and TICK-032 is flexible (neither blocks the other).
- Insertion point: immediately below the social load section from TICK-031 (or below cognitive if TICK-031 hasn't shipped yet).
- Storage: individual per-item booleans under `eodData.emoLoad.*`. No pre-derived count at save time.
- **Cross-axis firing is expected and correct.** A conflict day fires `emoLoadConflict` (this axis, the affective content) AND `socialLoadDifficultInteraction` (TICK-031, the interactional cost). Both are true data points; they are not duplicates. The composite and PEM correlation analyses treat them as separable signals.
- Log card chip: extend the chips array with `e.type === 'evening_checkin' && (e.emoLoad?.conflict || e.emoLoad?.significantNews || e.emoLoad?.dreadLoop || e.emoLoad?.witnessedDistress)` (any core).
- Export line lands in the EVENING block (TICK-022 cleanup if shipping before that).

## Implementation Notes

- **Why 5 items instead of the framework's 6-item floor:** walkthrough 2026-04-23 locked this as a deliberate deviation. User cut two proposed anchors — grief-pulse (observability concerns for alexithymic presentation) and high-activation-positive (user did not recognize this as a regular-enough cost). Witnessed Distress was promoted from extended to core to preserve the 4-core nested-PROMIS architecture. Post-launch reconsideration: if ≥14 paired days of data show emotional-axis signal underperforming cognitive/social for PEM correlation, revisit the anchor set. Candidates deferred for post-launch documented in the plan (shame/self-criticism with behavioral wrapper, "had to deliver hard news," "family/relationship tension active," grief-pulse retry with tighter observability).
- **Why observable-event anchors for emotional axis:** alexithymia-aware. The locked Framing A rule (absolute Y/N, observable events, no introspection) is hardest to satisfy for affect because felt-intensity IS the natural reporting modality. Every item in this set anchors to a concrete event or behavior (a conflict happened; news arrived; dread-loop shows as checking behavior; someone was present to distress; a trigger surfaced) — not to felt-intensity.
- **Why #3 (dread loop) is behavior-anchored, not feeling-anchored:** plan §Item 10 emotional rationale — "observable via behavior: checking, rehearsing, avoidance." If the user can't recall whether she was anxious but CAN recall whether she checked something repeatedly or avoided a specific task, the anchor fires honestly.
- **Cuts from earlier drafts (plan §Item 10 emotional):** "held back an emotional reaction" (covered by cognitive #4 emotional regulation composure), "felt overwhelmed today" (introspective), "had to regulate a reaction in public" (subset of cognitive emotional regulation).
- **LOC estimate:** ~100-130 LOC, smallest of the three load-set tickets.
- **Test sequence (user, during QA):**
  1. Open EOD form — "Emotional load today" section below social load; 4 core items then "Additional" subheading with 1 item.
  2. Tap each — toggle works. Confirm tap target is comfortable on a low-capacity day.
  3. Fire `emoLoadConflict` AND `socialLoadDifficultInteraction` on the same save — both record true; export shows entries in both "Social load" and "Emotional load" lines. Confirm this feels right (same event, two axes, not a duplicate).
  4. Fire only `emoLoadFlashback` (extended) — per AC, summary chip should NOT fire (gate is "any core"); export line lists `[flashback]`. **Verify this matches AC.**
  5. Save empty — no chip, no export line.
  6. Older pre-ticket EOD — renders cleanly with no emo-load section.

## Ship Notes

_(pending)_
