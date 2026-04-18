# Isobar — Product Principles & Patient Invariants

> Architectural rules live in [`ARCHITECTURE.md`](ARCHITECTURE.md). Workflow lives in [`PROCESS.md`](PROCESS.md). This file is the **product-level** reference: the tenets and patient invariants every design decision must respect. Patient background is in [`../README.md`](../README.md).

Consult this file when:
- scoping a new feature or writing a PLAN
- reviewing a PLAN before implementation (use [`PLAN_REVIEW.md`](PLAN_REVIEW.md))
- choosing between two design options and the tradeoff isn't obvious
- evaluating a chip, prompt, label, or metric for fit with this patient

If you are about to violate one of these, stop and update the principle first — either the principle has an exception that needs recording, or the decision is wrong.

---

## When principles conflict

Priority order. Earlier wins later.

1. **Patient invariants** (14–16: cycle, caffeine, dietary) — facts, not opinions; can't be traded away.
2. **Data privacy** (10) — medical data; non-negotiable.
3. **Cognitive accessibility** (1–3) — the patient must be able to use the app.
4. **Clinical framing** (4–7) — what the data means.
5. **User autonomy** (8–9) — how decisions are made.
6. **Data infrastructure** (11–12) — where and how data lives.
7. **Product scope** (13) — the framing around everything else.

Use this only when two principles actually conflict on a specific decision. Most decisions don't need a tiebreaker.

## Citing principles in plans

Every PLAN doc cites the principles it **honors** (the ones it explicitly serves) and the ones it **tensions against** (where it chose one principle over another, and why). A plan that cites no principles is either trivial or hasn't been reviewed — flag either.

This is what converts tenets from poster to process. A principle only works if someone has to look at it.

---

## Cognitive accessibility

### 1. No numeric scales for subjective state

**Rule.** Pain, severity, mood, anxiety, and other felt-sense variables are **never** captured as a 0–10 (or 1–5, or 1–7) numeric rating.

**Why.** The patient has alexithymia and high pain tolerance. Numeric scales systematically under-report her actual state and force interoceptive translation she can't reliably perform.

**How to apply.** Use functional anchors ("did you nap / cancel plans / use the cane?"), body-map taps ("where, not how much"), sensation descriptors ("tight / aching / burning / pressure"), behavioral Y/Ns ("snapped at someone / withdrew from planned contact"), external-observer questions, and comparative baselines.

### 2. Works when she is at her worst

**Rule.** Every interaction must be completable during active symptoms, brain fog, and post-episode weakness.

**Why.** Variable daily function is the norm. The app has to collect data on the bad days, not just the good ones — those are the days that matter clinically.

**How to apply.** Large tap targets. One question per step. No required fields that block saving. Partial saves are always valid. If she can only tap two things before an episode gets bad, those two taps should capture the most critical data.

### 3. Ask concretely, not interoceptively

**Rule.** Prompts should be answerable from observation or action, not from inward feeling.

**Why.** Alexithymia makes "how anxious did you feel?" noisy. "Did you cancel plans?" produces the same clinical signal without requiring interoception.

**How to apply.** Prefer behavioral anchors, external-observer questions ("has anyone around you noticed you seem quiet or flat?"), and observable outcomes. Felt-sense fields are allowed as *secondary* signal — never as the primary severity proxy.

---

## Clinical framing

### 4. Exposures, not triggers

**Rule.** Logged environmental/behavioral factors around an episode are **exposures**, not triggers. "Trigger" is reserved for items established as causal via pattern across many events.

**Why.** Demanding a causal attribution at log-time causes under-logging (event 1, the dog exposure wasn't logged because she wasn't sure it was causal). Causation is inferred later from correlation — that's how a specialist reads the data too.

**How to apply.** Use "exposure(s)" in UI copy, code identifiers, export section titles, and planning docs. On touch, rename `triggers` → `exposures` with a read-side fallback for old entries.

### 5. Communication capacity and irritability are co-primary severity proxies

**Rule.** Communication capacity ("can you hold a normal conversation right now?") **and** irritability are the primary severity indicators — equal weight, both captured. Neither is subordinate to a numeric scale.

**Why.** Both are clinically validated for this patient and both bypass interoceptive translation. Communication capacity reflects acute neurological state; irritability reflects dysregulation load that can diverge from communication on bad days. Capturing only one loses signal.

**How to apply.**
- Both appear in episode logging and daily check-in. Do not remove, bury, or simplify.
- Communication capacity is answered *during* episodes (she does not lose consciousness).
- Irritability is captured primarily via **behavioral anchors** (e.g. "snapped at someone", "withdrew from planned contact") — a felt-sense field may exist but is secondary signal, per Principle 3.
- Do not double-count: per the irritability plan, episode-level irritability anchors are deferred to avoid composite bias; EOD behavioral anchors are the primary capture point.

### 6. Clinical timeline, not single baseline

**Rule.** Severity is anchored to a **clinical timeline**, not a single "baseline period." The daily check-in scale is *functional-today*, not comparative.

**Why.** Summer 2022/23 is a pre-reactive active baseline (mountain biking, racing, no PEM). Arizona (spring 2026) is best-managed current state with 3 breakthrough events. Fusing them into one "baseline" erases the decline story and over-claims the cleanness of Arizona. Reframe locked 2026-04-15.

**How to apply.**
- Daily scale: 4-level functional-today — Good / OK / Scaled back / Bad. Level 1 ("physically active") is tied to the 2022-era ceiling, not Arizona.
- Exports carry the full timeline as the baseline section. Arizona gets a *separate* section framed as trigger/mechanism evidence, not as a baseline.
- Do not write "compared to Arizona" as a daily prompt.

### 7. Correlation is not causation in analysis language

**Rule.** When the app surfaces patterns across logged data, the language is strictly correlational. Causal claims require explicit human review and evidence beyond statistical co-occurrence.

**Why.** The app is heading toward pattern surfacing (README Phase 3). Premature causal framing ("pressure drops cause your episodes") is wrong *and* misleads the specialist, who needs to weigh mechanism against correlation independently. Principle 4 is the log-time version of this rule; this is the analysis-time version.

**How to apply.**
- Pattern-surfacing copy uses "coincides with," "appears alongside," "correlates with" — not "causes," "triggers," or "leads to."
- Auto-generated insights show evidence (N, effect size, time window) alongside the claim, so the user can judge weight.
- Exports distinguish established triggers (specialist-confirmed) from correlations (observational).

---

## User autonomy

### 8. Don't gate work based on inferred state

**Rule.** The app never tells the user to rest, pause, stop, "come back tomorrow," or similar — and never withholds features based on inferred impairment.

**Why.** She is the one who decides her capacity. Inferring "you're too impaired to continue" from logged symptoms is paternalistic and slows her down when she is explicitly choosing to work through it. Violates Principle 2 — the app exists *because* it must not gate her out.

**How to apply.** No capability-locking UI that hides features when severity is high. No modal suggestions to defer logging. Acknowledge state briefly if relevant; proceed with the requested action.

### 9. Fields optional by default

**Rule.** A form blocks save only when the missing input would make the record meaningless (e.g. timestamp on an episode).

**Why.** Required-field walls defeat Principle 2. A half-logged episode is clinically useful; no episode logged is not.

**How to apply.** Save button always active. Validation surfaces as hints, not blocks.

---

## Data & infrastructure

### 10. Data privacy is non-negotiable

**Rule.** Patient data is never exposed to third parties, never used for analytics or telemetry, and any remote storage is end-to-end encrypted or zero-knowledge.

**Why.** This contains medical data. The PIN exists because of that. Privacy is the invariant — *where* the data lives is a downstream choice, as long as the privacy guarantee holds.

**How to apply.**
- No analytics, no telemetry, no third-party data collection. Ever.
- Local-first is the default because it's the simplest way to guarantee privacy (current: `localStorage`; planned: Dexie/IndexedDB).
- A backend or sync layer is allowed **only** if it's E2EE or zero-knowledge, or the user holds the credentials (e.g. iCloud Drive via Web Share API). Dexie Cloud was rejected on this criterion — not E2EE by default.
- External services (weather, push) see only derived or anonymous signals — never identifiable data.

### 11. Offline-first

**Rule.** The app functions without network connectivity.

**Why.** She travels frequently and lives in the Upper Peninsula — cell coverage is inconsistent.

**How to apply.** Service worker caches the shell. Weather fetching degrades gracefully. Logging never requires a round-trip.

### 12. Record integrity — corrections are traceable

**Rule.** Entries are append-only at the record level. Corrections to a past entry must be distinguishable from the original — either as a new edit record linked to the original, or with a visible "edited" marker and timestamp. No silent overwrites.

**Why.** The specialist needs to trust the timeline. Silent overwrites make "was this always logged as 3 PM, or did I change it?" unanswerable. For clinical-grade records the answer must always be recoverable.

**How to apply.**
- Edit-time features (e.g. "edit time" on the resting card) preserve the original entry timestamp *and* record the edit time and old value.
- Deletions are soft (hidden from default view, recoverable) unless the user explicitly purges. A purge is confirmed, not default.
- Exports flag edited entries so the specialist sees corrections as corrections.

---

## Product scope

### 13. Single user, not a market

**Rule.** Isobar is a bespoke tool for one patient. Generalizability, multi-user support, tenancy, and market-fit concerns are explicitly not design goals.

**Why.** Design tradeoffs collapse when "what about other users?" stops being a live question. Features can be patient-specific without apology. Simplicity and fit-for-purpose beat flexibility. If the app ever ships to a second user, it's a rewrite, not a migration.

**How to apply.**
- When a design question reduces to "should we make this more general?", the answer is no unless it simplifies *this* user's path.
- Copy, defaults, chip sets, food suggestions, and severity scales are tuned to this patient. "What if the user is someone else?" is not a blocking question.
- Feature ideas driven by abstract product thinking ("users might want X") fail review unless grounded in a specific ask or observation from this user.

---

## Patient invariants

These are factual constraints about this specific patient. Not opinions — facts that rule out certain designs entirely.

### 14. No menstrual-bleeding cycle anchor

Post-endometrial-ablation: she does not bleed. Calendar-day-of-cycle counters, period-start chips, and "days until next period" predictions produce no data or wrong data. Use symptom-based phase proxies (breast tenderness, irritability shift, bloating, libido shift, BBT).

### 15. Caffeine ≈ 0

She drinks decaf coffee and decaf tea only. Daily caffeine-intake fields waste check-in real estate and produce uniformly-zero data. Trace caffeine from decaf (2–15 mg/cup) is below any plausible autonomic threshold. State the fact once in exports; do not prompt daily.

### 16. Dietary constraints

Vegetarian (no meat). Gluten-free (documented intolerance). Egg-free (documented allergy). Low-dairy (small amounts of hard cheese / yogurt tolerated). Low-histamine where feasible (MCAS suspected — red wine, aged cheese, fermented foods are triggers). All food suggestion logic must filter by these.

---

## How to add a new principle

1. State the rule in one imperative sentence at the top of its section.
2. Explain **Why** — usually a past incident, a clinical fact, or a constraint the agent can't infer from code.
3. Explain **How to apply** — when the principle kicks in, what the concrete design move is.
4. If the principle can be mechanically verified, also add a check to `ARCHITECTURE.md`. A principle without verification is a guideline, not an invariant.
5. Add or update a question in [`PLAN_REVIEW.md`](PLAN_REVIEW.md) that maps to the new principle.
6. Update the priority order in "When principles conflict" if the new principle introduces a new category.
