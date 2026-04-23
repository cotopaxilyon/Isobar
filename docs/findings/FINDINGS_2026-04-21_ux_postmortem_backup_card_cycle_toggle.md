---
finding-type: observed-defect
tracked-in: [ISO-65, ISO-66]
---

# UX Postmortem: Two Design Failures, and the Standards That Would Have Caught Them

A writeup for an agent with no context on the project. The goal is not to report what broke — it's to show which established UX/accessibility standards would have caught each failure in review, and what process gap let them through.

---

## Project context (minimum viable)

A health-tracking PWA for one patient with brain fog, impaired interoception, and cognitive load limits during flares. The "bad-day path" is the core invariant: every prompt must be answerable without introspection, labels must describe observables, and the Home surface is scarce real estate because the app is opened daily, often under cognitive impairment.

This context matters because the stakes of a bad label or a misplaced card are higher than in a general-purpose consumer app. The relevant external standards apply broadly but bite harder here.

---

## Failure 1: A weekly admin task was given warning-level visual priority on the daily surface

**What shipped.** A "Back up your data" card on the Home screen, positioned between the primary daily actions (Log Episode, Morning Check-in, Evening Check-in prompt) and the meal-tracking card. It fires weekly. Home is opened daily. Crucially, the card is styled with an **amber warning border and amber tint** (`border-color:rgba(245,158,11,0.4);background:rgba(245,158,11,0.06)`) — the same colour family reserved elsewhere in the product for urgent/caution states. A routine, low-stakes, weekly admin task was given warning-level visual weight.

**What standards it violates.**

- **Material Design — button emphasis hierarchy.** "A layout should contain a single high-emphasis button that makes it clear that other buttons have less importance in the hierarchy." The backup card's warning colour competes with — and on a quiet day, *outranks* — the primary daily actions. The layout effectively has two high-emphasis regions fighting for attention, with the one that matters less winning on colour prominence.
- **Apple HIG — button hierarchy.** "Use size, color, and spacing intentionally, with larger, bolder elements and distinct colors reserved for primary actions, while secondary controls should recede." Warning amber is a "distinct colour" — it should be reserved for something that warrants alarm. A weekly backup does not.
- **Progressive disclosure (NN/G).** "Disclose everything that users frequently need up front so they have to progress to the secondary display only on rare occasions." A weekly backup is by definition rare. Its natural home is a secondary surface (Settings) or the tail of the scroll, not the primary action region.
- **Visual hierarchy (NN/G).** Users pay more attention to distinctively-styled things. Using a warning palette sets the expectation that something is wrong; using it for a reminder about a routine admin task trains the user to dismiss warning colours as noise — a knock-on accessibility cost that degrades the signal of actual warnings elsewhere in the product.

**How it got through.** The card was specified inside a "durability strategy" work item. Review focused on whether backup reliability improved. Nobody re-opened Home with fresh eyes and asked "does this belong here, at this position, in *this colour*?" The change was evaluated inside its own scope.

---

## Failure 2: An ambiguous meta-attribution was placed inside a specific-symptom group

**What shipped.** Inside a section headed **"Cycle phase symptoms today,"** three toggles sit peer-positioned:
- Breast tenderness
- Overall: today feels cycle-related
- Bloating / fluid retention

Two things fail at once, and they stack.

**Failure 2a — the section header promises observables, this toggle isn't one.** The word "symptoms" primes the reader to expect concrete bodily states. Breast tenderness and bloating are symptoms. "Today feels cycle-related" is not a symptom — it is a classification of the day as a whole. Even if the toggle were unambiguously labeled, it would still mismatch the promise the section header makes. This is a coherence-with-the-group-header violation, not a label issue in isolation.

**Failure 2b — the label itself is ambiguous and interoceptive.** "Today feels cycle-related" has no object — related to *what*? The phrase relies on the header for reference, and on the reader to infer that "cycle" means the menstrual/hormonal cycle. It also uses a felt-sense verb ("feels") in a population with impaired interoception.

**What standards it violates.**

- **Gestalt — Similarity (NN/G).** "When items share some visual characteristic, they are assumed to be related... elements that share similar characteristics are perceived as belonging to the same group and are processed as a whole by the brain." Three visually identical toggles are read as three items of the same kind. Two are symptoms; one is a meta-judgment. The layout forces the reader to reconcile an inconsistency the design created.
- **WCAG SC 2.4.6 Headings and Labels (AA).** "If headings or labels are provided, they be descriptive." The intent text names the affected populations explicitly: "users who have disabilities that make reading slow and... people with limited short-term memory." Both the section header ("symptoms" when one item isn't) and the toggle label ("feels cycle-related") fail the descriptiveness bar.
- **WCAG SC 3.3.2 Labels or Instructions (A).** Clear labels "particularly [help] those with cognitive, language, and learning disabilities to enter information correctly." A label the user cannot decode on a bad day is functionally absent.
- **Cognitive accessibility guidance (Section 508).** "Experimental, unusual, or innovative UI or UX elements should be avoided, as they can be confusing." Mixing a meta-attribution into a specific-symptom grid is exactly the kind of non-standard grouping this guidance warns against.

**How it got through.** There are two separate process failures here, and they must not be blurred:

1. **The structural problem was acknowledged in writing, then explicitly deferred with no trigger.** The commit message introducing the rename states: *"No UI restructure — visual reorg (Option B) is the documented fallback if peer-positioning still confuses after ship."* The reviewer knew. The reviewer named Option B. The reviewer set no event that would cause Option B to be revisited — no date, no threshold, no QA pass. This is not a case of oversight. It is a case of a documented punt with no retrieval mechanism. This is the severe failure.

2. **Separately, the rename itself was graded against its predecessor, not against the standard.** The new label was an improvement over "mood shift." It was not measured against WCAG 2.4.6 descriptiveness as a standalone string. This is the lesser failure, and it would have been caught if the process demanded a fresh-eyes label review on every copy change.

These are distinct failures with distinct fixes. They happened to co-occur on the same ticket.

---

## Shared root cause

Both failures stem from one pattern:

> **Changes were reviewed inside their own scope, not against the full user surface at the user's point of entry.**

- The backup card was reviewed as a durability feature. Durability got better. The Home surface got worse — including a colour-hierarchy regression no one owned.
- The cycle toggle was reviewed as a rename. The new label was better than the old one. The new label was still ambiguous in absolute terms, and the structural mismatch with the section header and its peers was written down and punted.

A corollary pattern, which is its own first-class failure mode: **deferred fixes without triggers are not deferred — they are abandoned.** Naming "Option B is the fallback if X persists" creates a false sense of safety. Without a specific re-check event, the fallback is forgotten the moment the ticket closes.

---

## Generalizable best practices (grounded in external standards)

These apply to any team doing design review on a constrained surface. They are specific instances of a single meta-rule — **review from the user's point of entry** — which is listed last because every item above it is a case of it.

### 1. Placement *and colour weight* must match cadence and urgency

Weekly or monthly admin tasks do not get peer-positioning, peer-size, or peer-colour with daily actions. Warning palettes (amber, red) are reserved for things that warrant alarm — not for reminders about routine maintenance. Using alarm colours for non-alarm states degrades the user's response to actual alarms. Anchored in Material Design's "single high-emphasis button per layout" and Apple HIG's "distinct colors reserved for primary actions."

### 2. In cognitive-accessibility-constrained contexts, prefer observable labels over felt-sense labels

Felt-sense language is sometimes the right answer — pain quality ("burning vs. aching") in pain-tracking, emotional granularity in therapy apps, creative self-description in journaling tools. The rule is therefore conditional, not a blanket ban:

> When (a) the product targets a cognitive-accessibility-constrained population, or (b) an observable proxy exists that carries the same signal, prefer the observable.

"Today feels cycle-related" fails both tests: the population can't reliably interocept the judgment, and an observable proxy exists (the specific symptom toggles it sits next to). "Feels" was the wrong verb here. It might be the right verb elsewhere.

### 3. Category coherence goes up to the group header, not just across the items

When presenting a group of choices, check coherence at two levels:
- **Across the items.** If one option is a meta-attribution and the rest are specific instances within the category, the group is incoherent — separate the meta control visually or remove it.
- **Against the header.** Every item in a group must match the promise the header makes. A section titled "X symptoms" must contain only items a reader would recognise as symptoms. A section titled "How you slept" must not contain items about daytime energy. The header is a contract with the reader.

### 4. Deferred fixes require explicit re-check triggers

Any plan, commit message, or ticket that names a conditional fallback ("Option B if X persists") must also name the trigger that causes the fallback to be revisited. Candidates: a specific date, a usage-pattern threshold, a named QA pass, a followup ticket filed in the same session. A fallback without a trigger is a comment, not a plan. Treat these as rejectable at review time.

### 5. Review labels against the standard, not against the predecessor

When copy changes, re-apply the full clarity checklist to the *new* string as if seeing it cold. "Better than what it replaced" is not the bar. The bar is WCAG 2.4.6 plus any product-specific label rules. This is a distinct discipline from #4 — #4 is about acknowledged-but-deferred problems; this is about letting incremental improvements mask absolute failures.

### 6. Review from the user's point of entry (the meta-rule)

Before approving a change, open the surface the user opens, scroll the way the user scrolls, and ask what the change does to the surface *as a whole* — not what it adds in isolation. Everything above is a specialised instance of this. A team that consistently does this will catch most of the specific failures above before they need named rules. A team that doesn't will keep rediscovering them.

---

## Process changes (operational mechanics)

The best practices above are the framing. These are the wire — the specific process changes this postmortem drives. Framing without mechanics decays; mechanics without framing become box-ticking. Both are needed.

### 1. QA verdict mechanic

Default posture is unchanged: **QA verifies that the ticket's ACs were met.** That is the operating baseline, not a limitation to be worked around. What changes is the handling of UX findings that surface during an AC-scoped run:

- **UX findings on an AC-met ticket → PASS + UX Caution block.** The ticket passes; the QA comment includes a UX Caution block naming the finding; a sibling bug is filed immediately with a priority recommendation. UX observations do not block the originating ticket.
- **FAIL is reserved for two cases, and only two:**
  - (a) AC not met.
  - (b) The implementation shipped an element, state, or control not named in the AC, and that element has a defect. The test is *shipped-new-and-broken*, not *pre-existing-and-noticed*. If the flaw is not in code introduced by this ticket, it is a separate bug — not grounds to FAIL the ticket that surfaced it.

This preserves the discipline of AC-bounded evaluation while giving UX findings a routed, priority-tagged destination instead of either silent dropping or scope-creep FAILs.

### 2. Full-surface re-review is trigger-fired, not default

Reviewing every ticket against the full user surface at the point of entry is the correct framing (Best Practice #6) but the wrong default operationalisation — it doesn't scale, and making it mandatory recreates the scope-creep problem in a new direction. Instead, name scope-bounded evaluation as a specific failure mode to check for, and engage full-surface re-review only when explicit triggers fire:

- Any change landing on the **Home surface** (primary daily-action region).
- Any change that **renames or re-labels a control** in a cognitive-accessibility-constrained section.
- Any change inside a group layout that **adds or reorders peer items** (Gestalt similarity risk).
- Any change touching **warning-palette colours** (amber/red) outside an explicit alarm state.

When any trigger fires, the reviewer opens the affected surface cold and applies Best Practice #6 before approving. Default reviews keep their current scope.

### 3. Deferred-fix trigger gate

A commit, plan, or ticket that names a conditional fallback ("Option B if X persists," "revisit if users report Y") is not accepted until the re-check trigger is also named. Acceptable triggers: a specific date, a usage-pattern threshold, a named QA pass, or a followup ticket filed in the same session. A fallback without a trigger is a comment, not a plan — reviewers are empowered to reject on that basis alone.

### 4. Section-heading coherence check

Added to the Isobar UX review checklist: for every group of controls presented together, does every item in the group match the promise the section header makes? If one item is a meta-attribution and the others are specific instances, the group is incoherent. Options: separate the meta control visually, rewrite the header to match, or remove the outlier. This check runs on any copy change inside a group layout.

---

## Sources

- [Visual Hierarchy in UX: Definition — Nielsen Norman Group](https://www.nngroup.com/articles/visual-hierarchy-ux-definition/)
- [Progressive Disclosure — Nielsen Norman Group](https://www.nngroup.com/articles/progressive-disclosure/)
- [Similarity Principle in Visual Design — Nielsen Norman Group](https://www.nngroup.com/articles/gestalt-similarity/)
- [The 3 I's of Microcopy: Inform, Influence, and Interact — Nielsen Norman Group](https://www.nngroup.com/articles/3-is-of-microcopy/)
- [All buttons — Material Design 3](https://m3.material.io/components/all-buttons)
- [Buttons — Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/buttons)
- [Understanding SC 2.4.6: Headings and Labels — W3C WAI](https://www.w3.org/WAI/WCAG21/Understanding/headings-and-labels.html)
- [Understanding SC 3.3.2: Labels or Instructions — W3C WAI](https://www.w3.org/WAI/WCAG21/Understanding/labels-or-instructions.html)
- [Web Content Accessibility Guidelines (WCAG) 2.2 — W3C](https://www.w3.org/TR/WCAG22/)
- [Designing Digital Content For Users With Cognitive Disabilities — Section508.gov](https://www.section508.gov/design/digital-content-users-with-cognitive-disabilities/)
- [Usability and UX of Cognitive Intervention Technologies — Frontiers in Psychology](https://www.frontiersin.org/journals/psychology/articles/10.3389/fpsyg.2021.636116/full)
