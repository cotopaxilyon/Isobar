# Cognitive Load Section — Full Audit

**Surface:** Evening check-in — "Cognitive load today" block  
**Origin ticket:** ISO-73 / TICK-030  
**Discovered:** 2026-04-23, QA session + post-QA audit  
**Tracked in:** ISO-82, ISO-83, ISO-84, ISO-85 (structural bugs); data/copy bugs not yet tracked

---

## What was shipped

ISO-73 added 8 cog-load anchor rows to the evening check-in: 5 core rows and 3 extended rows separated by a subheading. The section shipped with the following problems, none caught during implementation.

---

## Bug inventory

### Structural (form-level)

**S1 — Section header used `<h3>` instead of `.label`**  
Every other section marker on the evening check-in uses `<span class="label">` (11px uppercase dim). The new section used `<h3 style="font-size:15px;font-weight:600">` — sentence-case, normal text colour, larger. Visually dominated the form; peer sections read as eyebrows.  
_Tracked: ISO-82_

**S2 — Circle marker implied single-select on multi-select data**  
`.anchor-check` had `border-radius:50%` — the universal affordance for radio buttons. All 8 rows are independent Y/N toggles. First-pass read: pick one. Actual behaviour: pick any subset.  
The fix changing `50%` to `4px` addresses the symptom but not the cause: no other widget on the form has a detached marker element at all. `.comm-btn`, `.toggle-btn`, `.choice` all carry active state on the widget itself. The `.anchor-check` element should be removed entirely; `.load-anchor[data-active="true"]` already applies background + border-color to the card.  
_Tracked: ISO-84_

**S3 — `opacity:0.9` on extended rows is imperceptible and incoherent when active**  
0.9 vs 1.0 is not a legible visual distinction. More critically: the opacity is applied to the entire card, including its active-state accent fill — so a selected extended item renders visually weaker than an unselected core item. The signal and the state fight each other.  
_Not yet tracked_

**S4 — Sub-header copy is wrong and skippability signal is absent**  
The shipped subheading is "Additional" (`<h4 class="setting-sub" style="margin:14px 0 4px">`, 12px dim mixed-case) — not `<span class="label">` as peer section headers use, and not the spec phrase "Also, if it happened." The design intent was a skippability cue: extended items can be skipped on hard symptom days. "Additional" conveys neither category membership ("still cognitive load") nor skippability. A first-time user mid-scroll cannot tell what the three rows are or whether they are optional. The `<h4>` renders at visual weight close to peer-section `.label` markers, so the boundary between the cog-load section and "PHYSICAL ACTIVITY TODAY" is ambiguous — a scanner reads them as two sibling micro-sections rather than section content followed by a new section.  
_Tracked: ISO-83_

**S5 — Four distinct selection-widget patterns on one form**  
The evening check-in now carries four distinct selection-widget patterns: `.toggle-btn` (snapshot), `.comm-btn` (cost block, activity level), `.choice` (activity chips), and `.load-anchor` (cognitive load). The cog-load widget is novel on every axis simultaneously — card layout, left-aligned marker element, and circular glyph. No other section on the form uses any of those three choices. Even if each per-section break (S1–S4) were corrected individually, the form-level fragmentation would remain: a user must relearn the tap affordance at each section. Neither the plan review nor the pre-QA gate that existed at ship time asked "how many distinct widget patterns does this form now carry?"  
_Tracked: ISO-85_

### Data layer

**D1 — History card chip checks 5 of 8 cog-load keys**  
Line 1698: the `.some()` check that determines whether to show the `cog-load` chip includes only the 5 core keys. The 3 extended keys (`communicationProduction`, `efLogistics`, `anticipatory`) are excluded. A user who logs only extended items gets no history chip — the data is invisible in card view.  
_Not yet tracked_

**D2 — Export uses machine slugs; rest of export uses display labels**  
The export's cogLoad block (line 1925) emits `thinking-sustained`, `masking-heavy`, `comm-production`, `ef-logistics`. Every other field in the same export block uses full display labels: "Communication: Talking easily — normal back and forth", "Fuse / sensory: Edgy — quicker to react than usual". Inconsistent register; cogLoad section reads as internal identifiers.  
_Not yet tracked_

### Copy layer

**C1 — No task instruction in the section**  
Every other section on the form either asks a direct question ("Did you connect with people today?") or presents states to recognise oneself in ("Talking easily — normal back and forth"). The cog-load section presents a section title and cards, with no instruction. A fatigued first-time user doesn't know whether to pick one, pick all, or what tapping does.

**C2 — Labels are category names, not recognisable states**  
"Sustained critical thinking >2h," "Emotional regulation as cognitive work," "Anticipatory / managerial load" are clinical category names. To answer them, the user must: recall the day, categorise what happened, compare against the threshold, and decide if it qualifies. The form's other labels are states the user recognises immediately in herself without analysis.

**C3 — "EF" is unexplained jargon**  
"EF + logistics work >1h" — EF is shorthand for executive function. A user who doesn't know that term cannot parse the label. The description clarifies, but a fatigued user reads the label first and may not reach the description.

**C4 — "Emotional regulation as cognitive work" requires four cognitive operations**  
The user must: (1) recall whether something upsetting happened, (2) assess whether she held composure, (3) estimate whether it lasted >30 minutes, (4) determine whether the situation was "activating." That's the highest cognitive demand of any item on the form, on a surface designed for low-demand end-of-day logging.

**C5 — Masking / heavy masking boundary has no tie-breaker**  
"Masking >1h" and "Heavy masking >2h OR high-stakes" are adjacent sibling items with overlapping criteria. A user who masked for 90 minutes at a moderately high-stakes appointment doesn't know which to tap. No guidance is provided. A fatigued user freezes or picks arbitrarily.

**C6 — Anticipatory row description missing its lead-in**  
Spec: "Ran significant background logistics (≥3 open threads actively tracked: appointments, bills, follow-ups, coordinating others)." Shipped: "≥3 open threads actively tracked (appointments, bills, follow-ups, coordinating others)." The "Ran significant background logistics" phrase that categorises the type of load is absent.  
_Tracked: ISO-83_

**C7 — Dense multi-clause descriptions across 8 items**  
Each of the 8 rows requires reading a label plus a multi-clause description sentence before the user can decide. Total reading load at end of a symptomatic day is high. The descriptions are doing work the labels should be doing.

---

## Root cause

Three distinct failure modes, all present simultaneously.

**1. Spec compliance treated as UX correctness.**  
The spec described 8 rows with these labels and descriptions. Implementation built them faithfully. No step asked: are these labels usable by someone who is exhausted and hurting at 8pm? The spec is a hypothesis, not a guarantee.

**2. New section compared against the spec, not against the form.**  
The structural divergences (h3, circle marker, opacity) were only visible by looking at the new section beside the other sections in `renderEvening()`. The comparison made during implementation was against the TICK-030 spec. Those are different comparisons.  
> *This audit committed the same mistake: S4 originally described "Also, if it happened" (spec copy) and `<span class="label">` (spec assumption) without verifying against the shipped code. The actual shipped copy was "Additional"; the actual markup was `<h4 class="setting-sub">`. An audit of an implementation defect must verify against the implementation, not the spec it was supposed to follow.*

**3. No fatigued-user read-through.**  
Technical review confirmed the toggle fires, the key exists, the class matches. None of those checks simulate a person at 8pm who can't analytically evaluate clinical category names or estimate durations. That check was never performed.

---

## Generalisation

The failure is not specific to this surface. It applies anywhere:

- A spec is written by a rested author for a fatigued target user
- A new section is added to a form with an established pattern
- Copy uses category names or clinical vocabulary the user may not share
- A new structural element (first marker, first subheading, first opacity dimming) is introduced without auditing peers
- A new selection widget is introduced without counting how many distinct widget patterns the surface already carries — individual-section review misses form-level interaction grammar fragmentation
- Keys are written by a feature but their presence in downstream surfaces (history, export, stats) is assumed rather than verified

The check that was missing — read it as someone who doesn't know what you know, in the state they'll actually be in — cannot happen as a side effect of implementation review. It has to be scheduled.
