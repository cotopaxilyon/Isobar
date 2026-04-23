---
id: TICK-030
title: EOD cognitive load anchor set — 8 items, 4 core + 3 extended, weighted
status: pending
priority: high
wave: 2
created: 2026-04-23
updated: 2026-04-23
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-73
  test: ""
depends-on: [TICK-018, TICK-020]
supersedes: []
shipped: ""
---

# TICK-030: EOD Cognitive Load Anchor Set

## Summary

Adds the 8-item cognitive-load anchor section to the EOD form per plan §Item 10 (locked 2026-04-17). Behavioral Y/N anchors only, no intensity Likerts — alexithymia-aware per the Items 3 + 6 principle. Four core items (always answered) + three extended items (skippable on hard symptom days) + a tiered masking hybrid (2a/2b with within-axis max-rule). Feeds the PEM correlation engine directly (cognitive-load composite input is the cognition axis's paired morning/evening Y/N anchors, specced separately — this set is PEM-only).

## Acceptance Criteria

- [ ] EOD form renders a section titled "Cognitive load today" containing 8 Y/N toggle rows in this order, each a full-width tappable card with bold short label and grey description text beneath:
  - **Core:**
    1. `cogLoadThinkingSustained` — *"Sustained critical thinking >2h"* / *"Debugging hard bugs, analyzing complex situations, weighing decisions with multiple factors"* (weight 3)
    2. `cogLoadMasking` — *"Masking >1h"* / *"Social-cue translation, script-building, concealing self to fit in"* (weight 2)
    3. `cogLoadMaskingHeavy` — *"Heavy masking >2h OR high-stakes"* / *"Networking event, conference social, major family gathering"* (weight 3, may fire alongside #2 — max-rule applies at composite)
    4. `cogLoadHighSensory` — *"Extended high-sensory environment >4h"* / *"Conference centers, airports, crowded venues, sustained noise + visual complexity"* (weight 3)
    5. `cogLoadEmotionalRegulation` — *"Emotional regulation as cognitive work"* / *"Held composure through >30 min of an upsetting or activating situation (kept reaction internal)"* (weight 3)
  - **Extended (visually subdued under a small "Additional" subheading):**
    6. `cogLoadCommunicationProduction` — *"Communication production"* / *"Composed or rehearsed a communication you'd been dreading (hard email, difficult message, phone script)"* (weight 2)
    7. `cogLoadEfLogistics` — *"EF + logistics work >1h"* / *"Scheduling, coordinating multiple threads, managing paperwork, healthcare/insurance/bureaucracy"* (weight 2)
    8. `cogLoadAnticipatory` — *"Anticipatory / managerial load"* / *"Ran significant background logistics (≥3 open threads actively tracked: appointments, bills, follow-ups, coordinating others)"* (weight 2)
- [ ] Section sits below the cost block (from TICK-020) and above the activity section (from TICK-021, when that ships). Ordering among load sections: cognitive (this ticket) → social (TICK-031) → emotional (TICK-032)
- [ ] Each row is a single-tap toggle; tapped state tints background (`var(--accent)`-adjacent) and shows a filled check or dot marker. Untapped state is bordered grey. Tap target ≥44px vertical
- [ ] `eodData` initializer adds `cogLoad: { thinkingSustained: false, masking: false, maskingHeavy: false, highSensory: false, emotionalRegulation: false, communicationProduction: false, efLogistics: false, anticipatory: false }`. Entire object optional; save never blocked on it
- [ ] Masking hybrid (#2 / #3) — both toggles fire independently in storage. No coupled UI logic (don't auto-enable #2 when #3 is tapped). Max-rule is a composite-time concern, not a UI-time concern
- [ ] Log card omits per-item chips for this section — it's dense data. If any core item fires, emit a single summary chip *"cog-load"* colored by `var(--mid)` (neutral marker that the section was logged). Omit entirely when all 8 fields are false
- [ ] Export writes a compact labeled line under the evening block: *"Cognitive load: [thinking-sustained, masking, high-sensory]"* — comma-separated short keys of active items. Omit the line when all 8 are false
- [ ] Partial logging round-trips — any subset of the 8 set, any combination across core and extended, renders in log and export without error
- [ ] **Do NOT bump SW cache version** (no shell asset changes)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty

## Agent Context

- Insertion point: after the cost block section in the EOD form rendering path, above wherever TICK-021's activity section will land.
- Toggle-row pattern: there is no existing "full-width bold-label + grey-description tap row" pattern in `index.html`. Closest analogues are the multi-select chip rows (morning `overnightEvents` at `index.html:~1437-1450`) and the cycle-proxy chips from ISO-51. Introduce a small shared component-style pattern for these load-anchor rows — a `<div class="load-anchor" data-active="false">` with a `<strong>` label and a `<small>` description, tap handler toggles the `data-active` attribute and updates `eodData.cogLoad[key]`. Apply this same pattern in TICK-031 and TICK-032 for consistency. Styles should be introduced once in the existing `<style>` block.
- Description text is intentionally verbose for first-use learning curve. Acceptable visual density — the plan's capacity discussion (Item 8) confirmed a 3-5 min EOD form is acceptable, and this is the densest section of it.
- Section heading: plain text `<h3>Cognitive load today</h3>`; subheading for extended items: `<h4 class="setting-sub">Additional</h4>` reusing the existing `.setting-sub` styling.
- Log card chip: extend the existing chips array at `index.html:~1600-1616`, conditional on `e.type === 'evening_checkin' && hasAnyCogLoad(e)`.
- Export: emit the compact labeled line inside the per-entry EVENING block (which lands in TICK-022). If TICK-022 hasn't shipped when this ticket ships, emit into the Morning section branch as a temporary home — TICK-022's cleanup pass will move it.
- **`cogLoadMaskingHeavy` value independence:** because #2 (`cogLoadMasking`) can be true while #3 (`cogLoadMaskingHeavy`) is also true — or either alone — the UI must not couple them. A user who did >1h of moderate masking AND a separate 2h+ heavy-masking event records both as true. The max-rule at composite time means both-true scores as 3, not 2+3=5.

## Implementation Notes

- **Why Y/N and not intensity:** Item 10 lock rationale — NASA-TLX-style intensity self-rating is research-red-flagged for alexithymic populations. Behavioral anchors (observable events) preserve signal without requiring introspection about felt-load.
- **Why "extended" items aren't collapsed by default:** one-tap access on all 8 items is simpler than a show/hide toggle that adds cognitive overhead when the user is already tired. Visual subduing (smaller heading, same row size) communicates the hierarchy without hiding.
- **Why no composite math in this ticket:** the cognitive load set feeds the PEM correlation engine post-hoc, not the daily composite. Cognitive contribution to the composite comes from the `cognition` axis (cogAnchorMorning/Evening paired Y/Ns — specced separately in the symptom-axis behavioral-anchor ticket cluster, still TBD). This ticket is pure data capture.
- **Why no per-item chips in the log card:** dense data (8 items) would overwhelm the log card's scan pattern. A single *"cog-load"* marker chip on days where any core item fires gives a visual cue that the section was filled in. Detailed review happens in export.
- **Cuts from earlier drafts (plan §Item 10):** reading, math-without-aids, decision-deferred, recall-effort, learning-new, context-switching ≥5x — all rationale documented in the plan under "Explicitly cut from earlier drafts."
- **LOC estimate:** ~180-220 LOC for form markup + toggle handler + initializer + log chip + export line. At the soft cap. Split further only if build balloons past 250.
- **Test sequence (user, during QA):**
  1. Open EOD form — "Cognitive load today" section appears below cost block with 5 core items, then "Additional" subheading, then 3 extended items.
  2. Tap each item — tint appears; tap again — tint removes. Tap target is large enough to hit with a sore wrist.
  3. Tap #2 (Masking) and #3 (Heavy masking) separately — both fire independently; saving shows both as true.
  4. Save with 3 core items on — log card shows the "cog-load" summary chip; export line lists the 3 short keys.
  5. Save with only extended items on (no core) — per AC, log chip should NOT fire (gate is "any core"); export still lists the extended keys. **Verify this behavior matches the AC spec; if the user wants the chip to also fire on extended-only days, adjust.**
  6. Save with nothing set — no chip, no export line.
  7. Reopen a pre-ticket saved EOD — renders cleanly with no cog-load section.

## Ship Notes

_(pending)_
