# Process Remediation — Cognitive Load Audit

**Origin:** `FINDING_cogload_ux_audit.md`  
**Purpose:** Close the three process gaps that allowed the ISO-73 bugs to ship. Changes are additive — two new questions in `PLAN_REVIEW.md`, one new pre-QA gate in `PROCESS.md`.

---

## The three gaps

| Gap | Where it occurs | What was missing |
|-----|----------------|-----------------|
| Plan-time: structural pattern | PLAN_REVIEW.md | No question asks whether new sections match the surface's existing structural grammar |
| Plan-time: copy readability | PLAN_REVIEW.md | Q2 and Q3 exist but neither asks whether labels read as recognisable states under cognitive impairment |
| Implementation-time: pre-QA | PROCESS.md | No form-UI-specific gate before marking Ready for QA |

The existing PLAN_REVIEW.md Q2 ("Can the interaction be completed on a bad brain-fog day?") focuses on tap targets and required fields. It does not check whether the copy itself is parseable under impairment. Q3 ("Are labels literal and unambiguous?") focuses on clinical framing and avoidance of subjective nouns. Neither asks: "can an exhausted person recognise herself in this label without analysis?"

---

## Gate 1 — Add to PLAN_REVIEW.md

Add the following two questions to the **Cognitive accessibility** section, after Q3.

---

### 3a. Does every new section match the surface's established structural pattern?

**Flag if:**
- The new section uses a different markup element for its header than peer sections on the same form (e.g. `<h3>` when peers use `.label`)
- The new section introduces an active-state mechanism that doesn't exist elsewhere on the surface (e.g. a detached marker element when every other widget carries state on itself)
- The new section introduces any element that appears on this surface for the first time — subheading, opacity dimming, marker glyph, tooltip — without explicit ratification in the plan

**How to apply:** for every structural choice in the proposed section, name one peer section on the same surface that makes the same choice. If you can't name one, the choice needs to be ratified or removed.

**Why:** every structural divergence that isn't ratified becomes a QA bug. ISO-73 shipped with h3, circle marker, and opacity that had no peer on the form — all three caught in QA, none caught in review.

---

### 3b. Do labels read as recognisable states, not category names requiring interpretation?

**Flag if:**
- A label names a clinical or technical category ("Sustained critical thinking >2h," "Emotional regulation as cognitive work") rather than a state the user recognises in herself ("Talked through something upsetting for 30+ minutes")
- A label requires the user to estimate a duration, recall a threshold, or categorise their experience before they can answer
- Two adjacent options have overlapping criteria with no stated tie-breaker (e.g. "Masking >1h" adjacent to "Heavy masking >2h OR high-stakes")
- Any label contains an unexplained acronym or clinical term (EF, MCAS, prodrome, activating)
- A mathematical symbol (≥, >, <) appears in a label or prompt

**How to apply:** read each label cold, in order, as if you've never seen the form before and are exhausted. If you need to read the description to understand what the label is asking, the label has failed. The description can add context; the label must land alone.

**Why:** the target user fills this form at end of day, often in a symptomatic state. Category names that require analysis are skipped or answered arbitrarily. ISO-73 shipped 8 labels that required clinical vocabulary and threshold estimation; none would have passed this check.

---

## Gate 2 — Add to PROCESS.md

Add the following section to `PROCESS.md`, under **Checking off acceptance criteria**, as a new subsection titled "Pre-QA gate for form UI work."

---

### Pre-QA gate for form UI work

Before moving any ticket that modifies or adds a form section to `Ready for QA`, run this checklist. These checks cannot be made from the diff; they require reading the rendered output.

**Structural audit**  
For every new element in the section, identify the peer element on the same surface and confirm the markup matches:
- Section header: same element and class as all peer section headers on this form
- Active-state mechanism: same mechanism (class, style, data-attribute) as peer selection widgets
- No element appears for the first time on this surface without being named in the plan and ratified

**Fatigued-user read-through**  
Read every label, description, subheading, and instruction in the new section, in order, as a person who is exhausted and cannot critically evaluate category names. For each item, ask:
1. Is there an instruction telling me what to do? (question, call to action, or obvious affordance)
2. Can I recognise myself in this label without reading the description?
3. Is any term jargon I might not know?
4. If there are thresholds or overlapping options, do I know which to pick?

If any answer is no, stop — the copy or structure needs revision before QA.

**Data completeness**  
For every key the new section writes, grep it against: history card render, export block, stats render. Confirm each key either appears in a consumer or is explicitly documented as not displayed. A key with no named reader is invisible data — log it as a bug before marking Ready for QA.

**Export consistency**  
Confirm new export labels match the form's display labels, not internal key names or slugs. Read the export block alongside the form labels. They should tell the same story.

---

## Where else this applies

These checks are written for this app but the underlying principle applies to any form UI work:

- **Error messages:** written by a rested developer, read by a frustrated user with no system context. Same author/user state gap.
- **Onboarding flows:** built by someone with months of product context, read by someone encountering it for the first time.
- **Form validation copy:** composed before any error has occurred, read in the moment of failure.
- **API error responses:** precise to the author who knows the request schema, opaque to an integrator debugging at midnight.
- **Documentation:** the author cannot see their own implicit knowledge; the reader arrives with none of it.
- **Any technical vocabulary in user-facing copy:** the developer lives in it; the user sees it once.

The invariant: the author always has three things the user doesn't — knowledge of why it looks the way it does, knowledge of the domain vocabulary, and a calm cognitive state while writing. Any one of those gaps can make something that passes every technical check completely unusable.

**The check that was missing is: read it as someone who doesn't know what you know, in the state they'll actually be in.** It cannot happen as a side effect of implementation review. Schedule it explicitly, as a named step before QA, every time.
