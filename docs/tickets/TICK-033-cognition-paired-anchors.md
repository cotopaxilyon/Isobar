---
id: TICK-033
title: Cognition behavioral Y/N anchors — morning + evening paired
status: pending
priority: high
wave: 2
created: 2026-04-23
updated: 2026-04-23
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-76
  test: ""
depends-on: [TICK-018]
supersedes: []
shipped: ""
---

# TICK-033: Cognition Behavioral Y/N Anchors — Paired Morning + Evening

## Summary

Adds the 3-item cognition behavioral Y/N anchor set to BOTH the morning check-in form AND the EOD form per plan §Item 3 + Item 6 (locked 2026-04-23). This set is the exception to the EOD-only rule for behavioral anchors because the composite `cognition` axis uses `peakOfPaired` aggregation (max of AM/PM counts), which requires a morning measurement window. Feeds the `cognition` composite axis at **weight 0.15 — the highest single weight in the composite** (tied with `pain` and `costActivities`). Shipping this ticket unblocks the cognition contribution to the Derived Interference Index.

Cross-form ticket: touches morning check-in section + EOD section + `exportReport` + log card chips.

## Acceptance Criteria

### Morning check-in form
- [ ] Morning form renders a new section titled "Cognition this morning" (insertion point: above the existing `functionalToday` block, below whatever currently precedes it) with 3 Y/N toggle rows using the `.load-anchor` row pattern from TICK-030 (if TICK-030 has shipped) or a local stub with the same visual shape. Items in order:
  1. `cogAnchorLostTrack` — *"Lost track mid-sentence this morning"* (no description line — item is self-explanatory)
  2. `cogAnchorHadToReread` — *"Had to re-read to understand this morning"*
  3. `cogAnchorCouldntFindWord` — *"Couldn't find a word this morning"*
- [ ] `ciData` (morning initializer) adds `cogAnchors: { lostTrack: false, hadToReread: false, couldntFindWord: false }`. Optional

### EOD form
- [ ] EOD form renders a mirror section titled "Cognition today" with 3 Y/N toggle rows using identical ids but evening copy:
  1. `cogAnchorLostTrack` — *"Lost track mid-sentence today"*
  2. `cogAnchorHadToReread` — *"Had to re-read to understand today"*
  3. `cogAnchorCouldntFindWord` — *"Couldn't find a word today"*
- [ ] EOD form section sits directly below the emotional load section (TICK-032) — or below cost block (TICK-020) if TICK-030/031/032 haven't shipped yet
- [ ] `eodData` adds `cogAnchors: { lostTrack: false, hadToReread: false, couldntFindWord: false }`. Optional

### Log card
- [ ] Log card emits a single summary chip *"cog-symptom"* colored `var(--mid)` on morning entries AND on EOD entries when ANY of the three items is true (not gated on "any core" — all three are equivalent-weight). Morning and evening entries emit the chip independently
- [ ] Omit the chip when all three are false

### Export
- [ ] Export writes a compact labeled line in the Morning block: *"Cognition (AM): [lost-track, couldnt-find-word]"* — comma-separated short keys of active items. Omit when all three are false
- [ ] Export writes a compact labeled line in the EVENING block (once TICK-022 ships, otherwise temporary home in Morning branch): *"Cognition (PM): [lost-track, had-to-reread, couldnt-find-word]"*

### Technical
- [ ] **Do NOT bump SW cache version** (no shell asset changes)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty
- [ ] Morning-entry round-trip works: saving a pre-ticket morning check-in still renders (backward-compatible — `cogAnchors` defaults to absent = treated as all-false)

## Agent Context

- **Why paired (exception to EOD-only rule):** the composite `cognition` axis uses `peakOfPaired` = max(morning count, evening count). Max-aggregation requires two separate observations. Per plan §Item 3 rationale — "behavioral questions are end-of-day questions by nature" — the cognition exception stands because the symptoms (lost track, re-read, word-find) are *observable acute events*, not day-summary retrospectives. A morning stumble happens at a known time; a morning Y/N question is answerable.
- **Shared row pattern:** reuse `.load-anchor` CSS introduced by TICK-030. If TICK-030 hasn't shipped, add a local class stub with the same visual signature (bold label, optional grey description, tap-to-toggle active state). Dedupe on whichever load-anchor ticket ships last.
- **Cross-form consistency:** the same three keys (`lostTrack`, `hadToReread`, `couldntFindWord`) are used in both `ciData.cogAnchors` and `eodData.cogAnchors`. This lets Stage 4 composite engine read both with one key path.
- **Insertion points (morning):** the morning form's current flow lives around the `functionalToday` block. Insert above the `functionalToday` buttons but below whatever precedes it (probably the notes textarea or communication block). Prioritize a location that does not disrupt the morning flow's current muscle memory — above `functionalToday` keeps `functionalToday` as the last-before-save anchor.
- **Insertion points (EOD):** immediately below the emotional load section (TICK-032) if that's shipped; otherwise below cost block (TICK-020, shipped). When TICK-021/022 ship, activity and notes land below this section.
- **Log card:** extend the existing chips array once — gate is `hasAnyCogAnchor(e)` where the predicate reads `e.cogAnchors?.lostTrack || e.cogAnchors?.hadToReread || e.cogAnchors?.couldntFindWord`. Same predicate works for both entry types.
- **Export:** separate branches emit (AM) vs (PM) since they live in different sections (MORNING vs EVENING blocks). Label format matches `Cognitive load:` line from TICK-030 for visual consistency.
- **Morning form is NOT getting its own broader restructure here.** TICK-005 (morning restructure) is a separately-drafted ticket whose bundle status is ambiguous — do not conflate. This ticket adds a single section above `functionalToday` and leaves everything else untouched.

## Implementation Notes

- **Composite dependency:** without this ticket, the `cognition` axis at `axisConfig` weight 0.15 has no inputs — the composite can't compute a cognition contribution. Stage 4 composite engine (TICK-007) will need this before it can produce a valid Derived Interference Index. Shipping order: this ticket before TICK-007.
- **Why equal-weight, not tiered:** plan §Item 6 Change 2 locked "count-based scoring within each axis." Weighted scoring is for load sets (TICK-030/031/032) where items represent meaningfully different cost tiers; symptom-axis behavioral anchors are equivalent-severity observations — a lost-track incident isn't "lower tier" than a word-finding failure, they're parallel observations of the same underlying axis.
- **Why no description text on morning/evening phrasings:** the three items are short and familiar. Description paragraphs (as in TICK-030/031/032) would bloat the morning form — already a tight surface. Keep labels compact.
- **Cuts from candidate lists (plan §Item 6 Change 2):** "mixed up words" (collapses with #3 word-finding), "mind went blank" (subset of #1 lost-track), "had to check calendar repeatedly" (introspective EF/anxiety confound), "took notes for something normally remembered" (requires memory comparison → introspective).
- **LOC estimate:** ~200-240 LOC — two form surfaces, two export branches, one log chip, two initializers. Larger than the load-set tickets because of the cross-form work.
- **Test sequence (user, during QA):**
  1. Open morning check-in form — "Cognition this morning" section appears above `functionalToday` with 3 Y/N rows.
  2. Tap each item — tint appears; save — morning entry in log shows "cog-symptom" chip if any fired.
  3. Export — MORNING CHECK-INS section has a *"Cognition (AM): [...]"* line when any morning item fired.
  4. Open EOD form — "Cognition today" section present with same 3 items.
  5. Tap items on EOD — save — EOD entry shows "cog-symptom" chip if any fired; export has *"Cognition (PM): [...]"* line.
  6. Fire different items AM vs PM on the same day (e.g., lost-track in AM, word-finding in PM). Both entries log independently.
  7. Save morning with empty cog — no chip, no export line. Backward-compat: open a saved morning from before this ticket shipped — renders cleanly.
  8. Save EOD with empty cog — no chip, no export line.

## Ship Notes

_(pending)_
