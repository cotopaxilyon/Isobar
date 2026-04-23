---
id: TICK-031
title: EOD social load anchor set — 7 items, 4 core + 3 extended, weighted
status: pending
priority: high
wave: 2
created: 2026-04-23
updated: 2026-04-23
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-74
  test: ""
depends-on: [TICK-018, TICK-020, TICK-030]
supersedes: []
shipped: ""
---

# TICK-031: EOD Social Load Anchor Set

## Summary

Adds the 7-item social-load anchor section to the EOD form per plan §Item 10 (locked 2026-04-23 in anchor-walkthrough). Behavioral Y/N anchors only, fenced against the cognitive-masking anchors from TICK-030 (masking = concealing self during fitting-in; social = handling the interaction itself — advocacy, conflict, multi-party, responsive availability). Feeds `eodSocialBehavioralCount` — a weighted-count input to the composite at weight 0.05 (per `axisConfig` at `PLAN_irritability_and_severity_mapping.md:461`) — and simultaneously the PEM correlation engine.

## Acceptance Criteria

- [ ] EOD form renders a section titled "Social load today" containing 7 Y/N toggle rows in this order, each using the same `<div class="load-anchor">` pattern introduced by TICK-030:
  - **Core:**
    1. `socialLoadAdvocacy` — *"Medical / bureaucratic self-advocacy"* / *"Appointment, pharmacy call, insurance call, specialist triage — you ran the advocacy yourself"* (weight 3)
    2. `socialLoadDifficultInteraction` — *"Difficult interpersonal interaction"* / *"Conflict, holding a limit, receiving directed frustration, navigating someone's hard feelings toward you"* (weight 3)
    3. `socialLoadGroupSetting` — *"Group setting ≥3 people ≥1h"* / *"Tracked multiple conversation threads simultaneously"* (weight 2)
    4. `socialLoadResponsiveAvailability` — *"Sustained responsive availability"* / *"Were 'on' for someone else's needs — partner, family, dependent — for a meaningful stretch today"* (weight 2)
  - **Extended (under "Additional" subheading):**
    5. `socialLoadPostHocProcessing` — *"Post-hoc social processing"* / *"Spent meaningful time after an interaction decoding it — 'what did they mean,' 'did I handle that right'"* (weight 2)
    6. `socialLoadNewContext` — *"New social context"* / *"Met a new person, or was in an unfamiliar social setting (novelty cost beyond masking baseline)"* (weight 1)
    7. `socialLoadObligationKept` — *"Scheduled social obligation kept"* / *"Attended a commitment you'd been dreading or low-capacity for"* (weight 2)
- [ ] Section sits directly below the cognitive load section (TICK-030) under the heading "Social load today"; "Additional" subheading separates core (items 1-4) from extended (items 5-7)
- [ ] Row interaction matches TICK-030: single-tap toggle, tinted background when active, ≥44px tap target, no coupling between rows (each fires independently)
- [ ] `eodData` initializer adds `socialLoad: { advocacy: false, difficultInteraction: false, groupSetting: false, responsiveAvailability: false, postHocProcessing: false, newContext: false, obligationKept: false }`. Optional; partial logging never blocks save
- [ ] Log card emits a single summary chip *"social-load"* colored `var(--mid)` when any core item fires. Omit when all 7 are false. Same gate pattern as TICK-030
- [ ] Export writes a compact labeled line: *"Social load: [advocacy, difficult-interaction, group-setting]"* — comma-separated short keys of active items. Omit when all 7 are false
- [ ] **Do NOT bump SW cache version** (no shell asset changes)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty

## Agent Context

- **Depends on TICK-030** for the `.load-anchor` row styling and toggle-handler pattern. If TICK-030 has not shipped when this ticket starts, stub the styles locally and they'll dedupe on the next load-set ticket. Prefer shipping in order.
- Insertion point: immediately below the cognitive load section from TICK-030 in the EOD rendering path.
- Storage: individual per-item booleans under `eodData.socialLoad.*`. Do NOT pre-derive the weighted count at save time — that's a composite-engine concern (Stage 4 / TICK-007). The count derivation will read these 7 booleans and the weights from the plan.
- **Weight-3 rationale for medical-advocacy (#1)**: the user has no coordinating physician and manages multiple specialists independently. This is the defining recurring high-cost social anchor for her specific context. Documented in `PLAN_irritability_and_severity_mapping.md` Item 10 social section. The weight is stored in the plan, not in the UI code — UI is pure capture.
- Log card chip: extend the chips array, gate on `e.type === 'evening_checkin' && (e.socialLoad?.advocacy || e.socialLoad?.difficultInteraction || e.socialLoad?.groupSetting || e.socialLoad?.responsiveAvailability)` (any core).
- Export: emit the compact labeled line inside the per-entry EVENING block. Temporary home in Morning section if TICK-022 hasn't shipped; cleanup lands with TICK-022.

## Implementation Notes

- **Why this axis is fenced from cognitive:** cognitive-masking (TICK-030 items #2/#3) captures the cost of *concealing self to fit in*. Social-load captures the cost of *handling the interaction itself* — these are separable and non-overlapping for PEM analysis. A heavy-networking day fires both (`cogLoadMaskingHeavy` AND `socialLoadDifficultInteraction`/`socialLoadNewContext`) — that's correct and intended. No max-rule across axes.
- **Why no per-item chips:** same rationale as TICK-030 — 7-item density would flood the log card. Summary chip gives "did she log this section" at a glance; detail lives in export.
- **Cuts from earlier drafts (plan §Item 10):** "texted with someone difficult" (too frequent), "made a phone call" (covered by cognitive EF+logistics or advocacy #1), "felt lonely today" (introspective), "disappointed in someone" (no observable anchor). All rationale preserved in plan.
- **LOC estimate:** ~130-170 LOC, less than TICK-030 because the `.load-anchor` pattern is already defined.
- **Test sequence (user, during QA):**
  1. Open EOD form — "Social load today" section below cognitive load section; 4 core items, then "Additional" subheading, then 3 extended items.
  2. Tap each item — toggle works independently.
  3. Tap #1 (Advocacy) and #2 (Difficult interaction) — both fire; save — log chip "social-load" appears; export shows both short keys comma-separated.
  4. Save with only extended (#5-#7) on, no core — per AC, summary chip should NOT fire; export still lists the extended keys. **Verify this matches AC — adjust if user wants chip on extended-only days.**
  5. Save empty — no chip, no export line.
  6. Save cognitive core + social core — both chips appear; export has both labeled lines.

## Ship Notes

_(pending)_
