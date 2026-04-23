---
status: shipped
ticket: ISO-73
title: TICK-030 EOD cognitive load anchor set — QA Fail
date: 2026-04-23
---

# ISO-73 QA Fail — Fix Plan

## Root cause

The spec prescribed a new `load-anchor` widget class that conflicts with the EOD form's established interaction language in four distinct ways. Implementation faithfully executed the spec — these are spec gaps, not implementation bugs. QA filed ISO-82, ISO-83, ISO-84, ISO-85 as separate tickets for each failure.

**Code trace (independent verification):**

1. **ISO-82 — heading hierarchy inversion** (confirmed)
   - All other EOD sections use `<span class="label">`: 11px, all-caps, grey, letter-spaced
   - Cognitive load section uses `<h3 style="font-size:15px;font-weight:600">`: 15px bold, full-contrast text
   - The `<h3>` reads as a page-level heading while every sibling section uses a visually subordinate label. Exact location: `index.html:2138`

2. **ISO-83 — "Additional" subheading is semantically empty** (confirmed)
   - `<h4 class="setting-sub" style="margin:14px 0 4px">Additional</h4>` at `index.html:2152`
   - `.setting-sub` renders at 12px / `var(--dim)` — barely distinguishable from description text beneath it
   - "Additional" provides no cue to a fatigued/alexithymic user about whether to engage: it doesn't signal lower priority, optional nature, or less-frequent scenarios

3. **ISO-84 — circular dot implies single-select** (confirmed)
   - `.anchor-check { border-radius:50%; ... }` at `index.html:349` — fully round = radio button affordance
   - All 8 items are independently multi-selectable, but the circular marker signals "pick one"
   - Standard checkbox affordance is square/rounded-rect; radio affordance is circular

4. **ISO-85 — four selection-widget patterns on one EOD form** (confirmed)
   Four distinct interaction widgets co-exist on the form:
   - `comm-btn` — full-width vertical stacked, single-select (used in 6+ sections)
   - `toggle-btn` / `toggle-pair` — horizontal pair, single-select (external observation)
   - `choice` chips — horizontal wrap, multi-select (activity type/when, shift time)
   - `load-anchor` card-with-dot — vertical stack, multi-select (cognitive load, new in ISO-73)
   
   The form now speaks four interaction dialects. This is both an ISO-73 consequence and a pre-existing condition (the first three patterns predate this ticket). ISO-85 exists as a separate ticket.

## Fix options

### Option A — Surgical (fixes ISO-82/83/84 in-place, ISO-85 stays as its own ticket)

Three targeted changes to the `load-anchor` implementation:

1. **ISO-82**: Replace `<h3 style="font-size:15px;font-weight:600">Cognitive load today</h3>` with `<span class="label">Cognitive load today</span>` — matches every other section heading on the form.

2. **ISO-83**: Replace "Additional" with a more meaningful divider. Options:
   - `<span class="label" style="margin-top:14px">Also, if it happened</span>` — signals these are supplemental, not required
   - `<span class="label" style="margin-top:14px">Less-frequent loads</span>` — signals these don't fire most days
   - Remove the subheading entirely and rely on visual spacing — the extended items are already at `opacity:0.9`

3. **ISO-84**: Change `.anchor-check` from `border-radius:50%` to `border-radius:4px` — square corners signal checkbox (multi-select) rather than radio (single-select). No other change needed; the rest of the toggle mechanic is correct.

**Scope**: ~5 LOC. No data impact, no export change, no structural change to the section. ISO-85 is deferred to its own ticket.

### Option B — Widget unification pass (fixes ISO-85 and absorbs 82/83/84)

Convert `load-anchor` cards to use the existing `choice` chip pattern (which already supports multi-select via `choices` + `choice.selected`). This makes the cognitive load section visually and interactively consistent with activity-type and trajectory-shift sections.

**Tradeoff**: The spec's description text (the verbose behavioral anchors) doesn't fit in a chip. It would need to be dropped or moved to a tooltip/expansion. The spec rationale for verbosity (learning curve for first use) would be sacrificed. This is a PM-level call about density vs. consistency.

**Scope**: ~50 LOC change. Requires spec sign-off before implementation.

### Option C — Defer ISO-85, ship Option A now

Option A unblocks ISO-73 → Done. ISO-85 (fragmentation) proceeds as its own design/spec conversation before TICK-031/032 ship, which is when fragmentation would compound. QA explicitly recommends addressing unification before TICK-031/032.

## Recommendation

**Option A** to clear the ticket. **Separately**, ISO-85 needs a PM decision before TICK-031/032 are implemented — if Option B (or a hybrid) is preferred, that work belongs in ISO-85, not here.

## Files to change (Option A)

- `index.html:2138` — `<h3>` → `<span class="label">`
- `index.html:2152` — `<h4 class="setting-sub">Additional</h4>` → `<span class="label" style="margin-top:14px">Also, if it happened</span>` (or PM-chosen alternative)
- `index.html:349` — `.anchor-check { border-radius:50%; ... }` → `border-radius:4px`

## Do not touch

- Data model (`cogLoad` initializer) — correct
- Toggle logic — correct
- Export line — correct
- Log chip — correct
- Masking independence — correct
