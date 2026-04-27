# Isobar — Plan Review Checklist

Run this **before** sending a PLAN to implementation (ticket creation). Each question maps to a principle in [`PRINCIPLES.md`](PRINCIPLES.md). If a question trips a "flag if", stop and either fix the plan or document why the exception holds.

This is the product-level analogue of the architecture grep in `ARCHITECTURE.md` — a mechanical pass over a proposed design before it becomes code.

Every PLAN must, at the top, cite the principles it **honors** and the ones it **tensions against**. A plan with no citations hasn't been reviewed.

---

## Cognitive accessibility

### 1. Is every prompt answerable without interoception?
**Flag if:** a prompt requires the user to rate a feeling on a numeric scale, or asks "how X do you feel" without a concrete behavioral or observational anchor.
**See:** Principle 1 (no numeric scales), Principle 3 (concrete, not interoceptive).

### 2. Can the interaction be completed on a bad brain-fog day?
**Flag if:** small tap targets, multi-step forms with required fields, reliance on recall from earlier in the flow, save blocked on optional input.
**See:** Principle 2 (works at worst), Principle 9 (fields optional).

### 3. Are labels literal and unambiguous?
**Flag if:** copy uses jargon, metaphor, or subjective nouns ("mood", "anxiety") where an observable proxy ("snapped at someone", "withdrew from planned contact") would do.
**See:** Principle 3.

### 3a. Does every new section match the surface's established structural pattern?
**Flag if:** the new section uses a different markup element for its header than peer sections on the same form; the new section introduces an active-state mechanism (marker element, opacity, glyph) not present on any peer widget; any structural element appears on this surface for the first time without being named and ratified in the plan.  
**How to apply:** for every structural choice, name one peer section on the same surface that makes the same choice. If you can't name one, ratify or remove.  
**Why:** ISO-73 shipped an `<h3>`, a detached circle marker, and opacity dimming — none had a peer on the form; all three caught in QA, none in review.

### 3b. Do labels read as recognisable states, not category names requiring interpretation?
**Flag if:** a label names a category rather than a state the user recognises in herself; a label requires estimating a duration, recalling a threshold, or categorising an experience before answering; two adjacent options have overlapping criteria with no tie-breaker; any label contains an unexplained acronym or clinical term; a mathematical symbol (≥, >, <) appears in a label or prompt.  
**How to apply:** read each label cold, in order, as an exhausted first-time user. If you need the description to understand what the label is asking, the label has failed. Description can add context; label must land alone.  
**See:** Principle 2 (works at worst), Principle 3 (concrete anchors).  
**Why:** ISO-73 shipped 8 labels requiring clinical vocabulary and threshold estimation; none would have passed this check.

### 4. What does this cost the bad-day path, in seconds?
**Flag if:** the feature adds to the morning check-in or resting flow without a time estimate, or if the total bad-day check-in path exceeds ~45 seconds. Every field costs ~5s; 10 features = skipped check-in on the days that matter most.
**See:** Principle 2.

### 5. Can this be logged retrospectively?
**Flag if:** the feature assumes real-time entry only. Most entries aren't real-time. Backdating must be supported without penalty, and time-of-event must be distinguishable from time-of-log.
**See:** Principle 2, Principle 12 (record integrity).

---

## Clinical framing

### 6. Does the plan call logged factors "exposures" not "triggers"?
**Flag if:** new UI copy, field names, or export sections use "trigger" for observational data. "Trigger" is reserved for patterns established as causal.
**See:** Principle 4.

### 7. Does severity assessment go through communication capacity AND irritability?
**Flag if:** a severity assessment captures only one of the two co-primary proxies, or relies on a felt-sense irritability rating without behavioral anchors. Both must appear, neither subordinated to a numeric scale.
**See:** Principle 5.

### 8. Does the plan respect the clinical timeline, not a single baseline?
**Flag if:** the plan refers to "the baseline" in the singular, conflates Summer 2022 with Arizona, uses "compared to Arizona" as a daily prompt, or lets Arizona live anywhere other than a dedicated trigger/mechanism evidence section.
**See:** Principle 6.

---

## Measurement

### 9. What construct does this field actually measure?
**Flag if:** the field name is vague (e.g. "irritability 1–5" conflates sensory overload, anger, impatience, and hangriness). Name the construct explicitly. Also flag if the user could unconsciously shape her answer to make the trend look "better" without actually feeling better (gaming risk).
**See:** Principle 1 (subjective state), Principle 5 (severity proxies).

### 10. What recall window does the prompt assume?
**Flag if:** a question like "how was your sleep?" has no defined window (last night? this week? today?). Undefined windows make entries incomparable across dates.
**See:** Principle 3 (concrete).

### 11. How do blanks render in later analysis?
**Flag if:** missing-data semantics aren't specified. Blank ≠ zero ≠ N/A ≠ "didn't ask." Analysis that treats "field not shown" as "user reported zero" produces garbage trends.
**See:** Principle 9 (optional by default) — optionality is free only if downstream reads handle blanks correctly.

---

## User autonomy

### 12. Does the plan avoid gating work based on inferred state?
**Flag if:** any UI withholds features, redirects the user to "rest", or capability-locks based on a logged symptom level.
**See:** Principle 8.

### 13. Are fields optional by default?
**Flag if:** a form blocks save on missing input unless the missing input makes the record meaningless (e.g. timestamp on an episode).
**See:** Principle 9.

---

## Patient invariants

### 14. Does the plan avoid assuming menstrual bleeding as a cycle anchor?
**Flag if:** calendar-day-of-cycle counters, period-start chips, "days until next period" predictions. Use symptom-based phase proxies.
**See:** Principle 14.

### 15. Does the plan avoid daily caffeine prompts?
**Flag if:** a daily check-in adds a caffeine intake field. Decaf only → uniformly zero.
**See:** Principle 15.

### 16. Do food suggestions filter by dietary constraints?
**Flag if:** suggestions include meat, gluten, eggs, or heavy dairy, or ignore low-histamine (MCAS) where feasible.
**See:** Principle 16.

---

## Data & infrastructure

### 17. Does the feature preserve data privacy?
**Flag if:** the plan introduces analytics, telemetry, or a third-party service that sees identifiable data. Any remote storage or sync layer must be E2EE, zero-knowledge, or user-credentialed (e.g. iCloud Drive).
**See:** Principle 10.

### 18. Does the feature work offline?
**Flag if:** a new feature fails closed without network. Network-dependent features (weather) must degrade gracefully.
**See:** Principle 11.

### 19. Is backward-compat handled for reads of existing entries?
**Flag if:** a rename or schema change would break rendering of old entries. Readers should fall back (e.g. `entry.exposures ?? entry.triggers ?? []`).
**See:** `PROCESS.md` — acceptance-criteria convention.

### 20. What's the historical data migration story?
**Flag if:** the plan adds a new field without specifying how existing entries represent it. "Field wasn't asked yet" must be distinguishable from "user answered zero" (see Q11). Code compat (Q19) is not the same as data migration — one keeps old entries rendering, the other keeps them analyzable.
**See:** Principle 12 (record integrity).

---

## Export & handoff

### 21. What does the export look like after this ships?
**Flag if:** the plan doesn't describe its export footprint. Every feature eventually gets read cold by a specialist who wasn't in the room. Show the before/after of the relevant export section, or confirm there is none.
**See:** Principle 7 (correlation ≠ causation in analysis language), Principle 12 (record integrity — edits flagged in exports).

---

## Lifecycle

### 22. What alternatives were considered and rejected?
**Flag if:** the plan presents one approach with no alternatives. Forces the author to articulate rejected options — a year later this is the only defense against "why do we have two overlapping fields?"

### 23. What's the rollback plan if this ships wrong?
**Flag if:** no documented path back. Solo-dev context means the user is also the QA team — a feature that can't be removed cleanly is a liability. At minimum: can the field be hidden without breaking existing entries?

### 24. What would trigger retiring this?
**Flag if:** no retire criteria. You already killed `weather` and `new_env` chips when they stopped paying off — codify that move. Name the signal: "if I stop using this within X weeks, remove it"; "if specialist feedback doesn't engage with this section, remove it."

---

## Meta

### 25. Is the plan testable end-to-end?
**Flag if:** acceptance criteria can only be checked from the diff. Every behavioral claim needs a functional path (manual walkthrough or Playwright spec).
**See:** `feedback_test_before_qa` — QA is verification, not discovery.

### 26. Does the plan name what it is *not* doing?
**Flag if:** scope boundaries are implicit. Plans should explicitly call out what's out of scope and what's deferred — this is where half-finished implementations come from.

### 27. Does every claim about existing code resolve to real, reachable code?
**Flag if:** the plan cites a `file:line` that wasn't grep-verified in the same session, or asserts that a recovery path / existing flow "handles" a case without naming (a) the function, (b) its call site, and (c) the state preconditions to reach it. Existence ≠ reachability — a symbol can exist in the codebase and still be unreachable from the state the plan claims it covers.
**See:** `PROCESS.md` — Verification discipline for authored claims. Real incident: ISO-42 Implementation Notes cited a fictional `DB.remove('pin')` recovery path that shaped the risk framing before UAT caught it.

---

## Data-shape invariants

Two items from the meal state-coherence postmortem (`docs/findings/FINDINGS_2026-04-22_meal_state_coherence.md`). Scoped narrowly on purpose — the postmortem's first draft proposed a five-mechanic suite of data-shape gates; critique of that suite concluded most of the machinery was doing work the *derive-live* preference (`ARCHITECTURE.md` "Preference: derive live, don't cache") does for free. What remains is the write/read check (mechanical, cheap) and the absence-of-side-effect AC question (the sharpest standalone insight from the incident).

### 28. Will this plan introduce a new storage key with no reader yet on `main`?
**Flag if:** the plan writes to a new `DB.set('literal', ...)` key whose read site doesn't land in the same ticket. Either the reader lands in this ticket, or the write does not land yet. A persisted record with no consumer is a lie.
**See:** `docs/ARCHITECTURE.md` §4 (storage keys have named readers — mechanical grep). Origin: `meal:last_drink` shipped as an orphan write on 2026-04-15 and stayed invisible to every downstream surface until the 2026-04-22 audit caught it.

### 29. Does this plan include an AC describing the *absence* of a side-effect?
**Flag if:** the plan has an AC phrased as "X does not reset Y," "Z is not triggered," "logging W does not update V" without a paired AC for the *visibility / read-side* behavior. If a new storage key is introduced to satisfy the absence (writing to a separate key to avoid resetting the main one), the paired AC must cover what surface the new key shows up on. Narrow absence-of-side-effect ACs without paired visibility ACs are a rejection signal.
**See:** Origin: the TICKET-3 AC *"drink does not reset the fasting clock"* was satisfied by writing to `meal:last_drink`; nobody asked "who reads that key?" because the AC didn't require it. This is the single sharpest insight from the meal postmortem — the AC's shape determined what the review looked at, and the review stopped at what the AC required.

---

## How to use

- **Before sending a PLAN to implementation:** walk this checklist against the plan doc. Flag each trip. Resolve or document an exception before tickets get created.
- **After shipping, if a new kind of regression surfaces:** add a question here and link the principle it maps to. The checklist grows from real misses, not from speculation.
- **Ceiling, not a floor:** if a plan needs a question this list doesn't have, ask it. Add it if it's going to recur.
