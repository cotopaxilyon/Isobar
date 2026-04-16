# Isobar — Exposure Surface Expansion (Plan)

Compiled 2026-04-15, after critical review of `FINDINGS_environmental_trigger_analysis.md` against current SPS / MCAS / POTS / hEDS literature.

---

## Session Status

**Phase:** Planning. Not yet implemented. No open questions blocking — user decisions needed on Tier 1 scope before build.

**Terminology change (2026-04-15, user-directed):** rename "trigger" → "exposure" throughout the app and this plan. Rationale: user does not always know which exposure caused an event (the dog-exposure event 1 case — she didn't log it at the time because she wasn't sure it was causal). "Exposure logging" captures environmental/behavioral context *without demanding a causal attribution from the user*. Causation is inferred later from correlation across many logged events, not asserted at log-time. This aligns with how a specialist would read the data anyway.

**Implication:** UI labels change ("Triggers" → "Exposures"), internal field names change (`triggers` → `exposures`, `trigOpts` → `exposureOpts`), export section titles change. Data-model migration: existing entries' `triggers` arrays rename to `exposures` on read (backward-compatible).

**Parent context:**
- `FINDINGS_environmental_trigger_analysis.md` identified five trigger classes; only Class 1 (environmental) is currently captured by the app.
- Literature review confirmed several well-documented trigger categories for the tracked hypotheses (MCAS, SPS-spectrum, POTS, autoimmune CTD) that the app does not log at all.
- User disclosed post-Findings data point: psilocybin has been used many times since Feb 12 2026 without an episode, which reframes the Feb 12 event as sleep-deprivation-dominant rather than serotonergic-dominant.

---

## Purpose

Expand the app's **exposure** logging surface so that the data sent to specialists covers the full documented exposure space for the active diagnostic hypotheses — not just the three environmental axes — and retire fields that produce low-signal or duplicative data. The data the specialist cares about is "what was she exposed to in the hours/days before the event," not "what does she think caused the event." Shifting from trigger-language to exposure-language removes the attribution burden that was causing under-logging.

## Why this change

The current episode-log trigger chip list (`weather`, `fasting`, `animal`, `chemical`, `new_env`, `poor_sleep`, `stress`, `exertion`, `hormonal`, `mold`) predates both:

1. The three-axis environmental model, which now computes environmental risk automatically from weather data. User-selected `weather` is redundant with computed axes.
2. The FINDINGS trigger-class analysis, which identified **Class 2 (exertion / sleep disruption)**, **Class 3 (prolonged stillness / car travel)**, and **Class 4 (serotonergic / pharmacological)** as distinct, documented trigger classes not represented in the chip list.

Separately, literature standard-of-care for MCAS/POTS tracking includes fields the app does not capture at all (alcohol, hydration, menstrual cycle day, hours slept as a number, high-histamine food exposure, recent illness, new medication).

This plan specifies what to add, what to retire, and what to restructure — so that after 4–6 weeks of post-change logging, the specialist export has the trigger breadth a neurologist, rheumatologist, or autonomic specialist would expect to see.

---

## Critique of current FINDINGS file (to be addressed in a separate patch)

Not part of this app-change plan, but noted so it's not lost:

- **C1.** "12/12 model performance" is retrospective classification, not validated prediction. Reframe language.
- **C2.** Axis thresholds (−5 hPa, ≥10°F/5h) are post-hoc. Label as hypothesis-generating, not validated cutoffs.
- **C3.** Feb 12 verdict needs update: psilocybin has been used repeatedly since without episode → sleep deprivation is the likely dominant driver; psilocybin is at most a modifier. Update Class 4 language accordingly.
- **C4.** Right-sided dominance claim deserves its own lateralization column in the scoreboard if it will be used in a spine-surgery conversation.
- **C5.** Dog exposure (event 1) is mentioned once and never revisited. Either it matters (MCAS class) or it doesn't — decide and document.

These are documentation edits, tracked separately from the app code work below.

---

## Scope — three tiers

### Tier 1 — ship first (high clinical yield, low UI friction)

**1. Alcohol logging**
- **Where:** new quick-log entry point OR a field on the morning check-in ("alcohol in last 24h: none / 1 / 2 / 3+ units, time of last drink").
- **Why:** MCAS-mechanistic (direct mast cell degranulator, blocks DAO). Currently zero data. Even a null result (no correlation with episodes) is clinically meaningful.
- **Export impact:** new line in per-event context; trigger-frequency summary section gains `alcohol within 24h: N events`.

**2. Hours slept (numeric) + sleep-end time**
- **Where:** morning check-in sleep step. Replace / augment the current sleep-quality chips with a numeric hours field and a time-of-wake field.
- **Why:** The Feb 12 reframe (above) makes *quantified* sleep the single most important missing variable. Binary "poor sleep" chip is not enough — the hypothesis is "<6h lowers threshold."
- **Export impact:** enables correlation of episode days vs prior-night sleep hours.

**3. Cycle-phase proxy (post-ablation, no menstrual bleeding)**
- **Constraint added 2026-04-15:** user had an endometrial ablation — no bleeding to anchor cycle-day count. Standard "day of cycle" tracking is not available. The Feb 6–15 benzo-trial notes and perimenopausal context in `MEDICAL_PURPOSE.md` are consistent with irregular / anovulatory cycles anyway, so a calendar-day approach would be unreliable even without ablation.
- **Approach:** track **cycle-phase symptom proxies** instead of bleeding-anchored cycle-day:
  - breast tenderness (present / absent)
  - mood / irritability shift (present / absent)
  - bloating / fluid retention (present / absent)
  - libido shift (up / down / neutral) — optional
  - basal body temperature (optional, only if user wants to; a persistent ≥0.4°F rise is the ovulation signal)
- **Where:** morning check-in, one row of chips (~3s to complete on most days).
- **Why:** both estrogen and progesterone directly modulate mast cell degranulation; POTS symptoms cluster around luteal phase. Without cycle-day anchoring, the only way to retrospectively infer hormonal phase is via the symptom proxies themselves. Tracking them daily produces a time series that a rheumatologist / gyn can interpret *better than* a cycle-day number from an ablated patient.
- **Export impact:** new "Hormonal proxy symptoms" timeline section; correlation with episode frequency computable from flag co-occurrence.
- **Out of scope here:** basal temp integration with a thermometer / wearable — manual entry only if at all.
- **Defers to ROADMAP §3** Hormonal Cycle Tracker for anything more structured.

**4. Serotonergic / psychoactive substance flag on episode log**
- **Where:** new trigger chip **"Substance in last 24h"** with a short free-text note. Does not require listing substances by name in the UI.
- **Why:** Even though post-Findings data weakens psilocybin-as-trigger, the app should still capture the data going forward so the pattern (or non-pattern) is documented rather than re-argued from memory.
- **Export impact:** flagged in per-event context; specialist can see the non-correlation over time.

**5. Add exposure chips already identified in FINDINGS but missing from the chip list:**
- `prolonged_stillness` — "Long drive / prolonged sitting (≥4h continuous)" (Class 3).
- `sleep_disruption` — "Overnight shift / disrupted sleep" (Class 2, distinct from current `poor_sleep` which is a subjective quality judgment).
- These are one-line additions to the chip array in `index.html` around line 968.

**Note on daily desk work (2026-04-15):** user works at a computer all day — prolonged sitting is a *daily baseline*, not a discrete exposure. Treating every workday as `prolonged_stillness` would flood the data and mask the episode-relevant signal (which is the ≥4h *continuous, non-home* sitting seen in the Feb 9 and Feb 15 car-travel events). Resolution:
- `prolonged_stillness` chip semantics = **continuous sitting outside normal desk routine, ≥4h without a movement break** (car travel, plane travel, long meeting, etc.).
- Separately, consider a **daily sedentary baseline** field on morning check-in — "movement breaks yesterday: none / a few / regular" — to establish whether baseline sedentary load *modifies* event frequency over time. This is Tier 2, not Tier 1 — the Class 3 car-travel signal is already clean without it, and we don't want to over-engineer the morning check-in.

**6. Localized / directional cold-airflow exposure (new class, user-reported 2026-04-15)**
- **Evidence:** user reports at least one incident of feeling an episode beginning while driving with AC airflow pointed directly at her; turning off the fan aborted the prodrome. This is distinct from the Class 1 Axis B rapid thermal drop (which is *ambient* temperature change over hours). This is localized skin-level cold airflow on a short time-scale aborting on removal.
- **Why this matters clinically:**
  - SPS-spectrum: startle/touch/cold-stimulus triggering is literature-documented; directional cold airflow is a plausible cutaneous-stimulus variant.
  - MCAS: cold urticaria is already in the patient's history (`MEDICAL_PURPOSE.md` §Hypothesis 2). Localized cold → skin mast cell degranulation → systemic cascade is a coherent mechanism.
  - POTS/autonomic: thermoregulatory challenge from directional cooling on a subset of skin surface.
  - Whichever mechanism dominates, the pattern is **under-documented** because the app currently has no way to log it.
- **New exposure chip:** `directional_cold_airflow` — "Cold airflow on skin (AC vent, fan, open window)".
- **Complementary:** add an **"aborted episode / prodrome resolved"** outcome to the episode log (see item 7 below). The AC case is the canonical example of a near-miss where the intervention (turning off the fan) is itself clinical data.

**7. Aborted-episode / near-miss logging (new concept, enabled by item 6)**
- **Where:** at the top of the episode-log flow, offer a branch: "Full episode" / "Prodrome that resolved without progressing."
- **Fields for the aborted-episode branch:** timestamp, prodromal symptoms present (same chips as full-episode prodrome), exposures at time of onset, **what changed / intervention taken when it subsided** (free-text + common-intervention chips: moved to warmer area, removed airflow, ate food, lay down, left environment, etc.), time-to-resolution.
- **Why:** aborted episodes are diagnostically valuable precisely because they isolate the *minimum-sufficient* exposure (the thing that was about to trigger a full event) and the *counter-exposure* (what stopped it). Current app only captures full episodes — aborted ones are invisible.
- **Export impact:** separate "Prodromal events / aborted episodes" section; intervention-efficacy summary ("cold airflow removed: N/N aborted").

### Tier 2 — ship after Tier 1 proves the pattern

**8. ~~Caffeine intake~~** — **dropped 2026-04-15**: user drinks only decaf coffee and tea, so dietary caffeine is effectively zero and a daily caffeine field would produce uniformly-null data. State "decaf only" once in the specialist export static context instead of tracking daily.
**9. Hydration quick-tap (low / fair / good)** — morning check-in.
**10. Recent illness flag (7-day persistence)** — one tap on morning check-in, auto-clears after 7 days.
**11. New medication / dose change (72h persistence)** — same pattern.
**12. High-histamine meal flag** — single checkbox added to existing meal-log entry ("aged / fermented / leftover / shellfish").
**13. Daily sedentary baseline** — morning check-in, "movement breaks yesterday: none / a few / regular" (see §5 note). Only useful once ≥4 weeks of Tier 1 data exists to test whether baseline sedentary load modifies event frequency.

### Tier 3 — evaluate after Tier 1+2 data accumulates

- Startle / loud-noise environment marker (SPS-specific; logging fidelity likely poor).
- Hot shower/bath as a discrete timed event.
- Vibration exposure (largely covered by Class 3 `prolonged_stillness`).

---

## What to retire or restructure

**Retire:**
- `weather` exposure chip on the episode log. The three-axis model computes this from weather data; the chip invites duplicate / contradictory user attribution. Keep the computed axes in the export; drop the user-selected chip.
- `new_env` exposure chip. Low specificity; the real hypothesis it was proxying (mold) has its own `mold` chip already.

**Restructure:**
- `fastedHours` free-text input on the episode log. Delete the input; compute from meal-log last-meal-time at episode-start timestamp. Removes cognitive burden during an active episode (core UX principle per MEDICAL_PURPOSE.md §3).
- `stress` chip is too broad to analyze. Split into `stress_acute` ("sudden emotional spike / startle") and `stress_chronic` ("ongoing elevated baseline"), OR drop chronic and keep only the acute SPS-relevant one. Recommend: **split**, because chronic stress may still matter for autoimmune correlation.

---

## Data-model changes (episode / meal / check-in objects)

Rename (with backward-compatible read):
- `episode.triggers` → `episode.exposures` (on load, if `triggers` present and `exposures` absent, copy across).

New fields (Tier 1):
- `episode.substance24h: { flag: bool, note: string }`
- `episode.computedFastedHours: number` (replaces `fastedHours` string input)
- `episode.exposures`: add `prolonged_stillness`, `sleep_disruption`, `directional_cold_airflow`; remove `weather`, `new_env`; split `stress` → `stress_acute`, `stress_chronic`.
- `episode.kind: 'full' | 'aborted'` — distinguishes full from prodrome-only events.
- `episode.intervention: { chips: string[], note: string, timeToResolve: minutes }` — populated only when `kind === 'aborted'`.
- `checkin.sleepHours: number`
- `checkin.sleepEndTime: string` (HH:MM)
- `checkin.cyclePhaseProxy: { breastTender: bool, moodShift: bool, bloating: bool, libido: 'up'|'down'|'neutral'|null, bbt: number|null }`
- `checkin.alcohol24h: { units: number, lastDrinkTime: string | null }`

New fields (Tier 2):
- `checkin.hydration: 'low' | 'fair' | 'good'`
- `checkin.recentIllness: { flag: bool, setAt: timestamp }` (7-day auto-expire in render)
- `checkin.medChange: { flag: bool, setAt: timestamp }` (72h auto-expire)
- `checkin.movementBreaks: 'none' | 'few' | 'regular'`
- `meal.highHistamine: bool`

Backward compatibility: existing stored entries don't have these fields. Render paths must treat missing as absent, not as `false`-meaning-logged-absent. This matters for the export — "no alcohol logged" is not the same as "alcohol confirmed zero."

---

## Export / report changes

- Rename "Triggers" section/headers → "Exposures" throughout the export.
- New **Exposures & Behaviors (last 30 days)** section, separate from per-event exposures. Summarizes: alcohol days, mean sleep hours, cycle-phase-proxy timeline, caffeine-heavy days, recent-illness flags, med-change events.
- Per-event context gains: cycle-phase-proxy snapshot, prior-night sleep hours, alcohol-within-24h, substance-24h flag, `kind` (full vs aborted), intervention data on aborted events.
- New **Prodromal events / aborted episodes** section with intervention-efficacy summary (e.g. "cold airflow removed: N/N aborted").
- Exposure-frequency summary excludes retired chips; includes new ones (including `directional_cold_airflow`).

---

## Open questions for user

1. ~~**Alcohol entry point**~~ — **resolved 2026-04-15:** morning check-in, fields = units yesterday (none / 1 / 2 / 3+) + **time of last drink** (HH:MM, optional). Rationale: mast-cell/acetaldehyde effects span minutes–12h, POTS/histamine-bucket tail extends 24–48h; time-of-last-drink lets the episode log compute hours-since-last-drink for any later event (including next-day flares) from one daily entry. Episode export should surface "last alcohol: Xh ago" rather than a bucketed 24h flag. Data-model `checkin.alcohol24h = { units, lastDrinkTime }` already matches.
2. ~~**Cycle-phase proxy set**~~ — **resolved 2026-04-15:** ship with breast tenderness + mood shift + bloating + libido. BBT dropped — thermometer habit too high-friction for the marginal phase-identification value on top of the symptom trio. Libido UI must use explicit labels — **"higher than usual" / "lower than usual" / "about the same"** — not "up / down / neutral" (ambiguous about baseline). Data-model: `checkin.cyclePhaseProxy = { breastTender: bool, moodShift: bool, bloating: bool, libido: 'higher' | 'lower' | 'same' | null }` (drop `bbt` field).
3. ~~**Tier 1 vs Tier 1+2 scope for first ship**~~ — **resolved 2026-04-15:** Tier 1 only. Revisit Tier 2 after ≥4 weeks of Tier 1 data.
4. ~~**`stress` chip**~~ — **resolved 2026-04-15:** split into two chips with explicit helper text.
   - `stress_acute` — chip label **"Acute stress event"**, helper: *A discrete spike in the last few hours — argument, bad news, startle, near-miss, confrontation. Something that happened, not something ongoing.*
   - `stress_chronic` — chip label **"Elevated baseline stress"**, helper: *Ongoing elevated load over days or longer — deadline week, caregiving strain, unresolved conflict, financial/medical worry. The background level, not a specific event.*
   - Disambiguation line under both (info-icon or inline): *If you could name a time it happened → acute. If it's been the general state for days → chronic. Both can apply.*
5. ~~**Aborted-episode UI placement**~~ — **resolved 2026-04-15:** branch at top of episode-log flow. User confirmed the behavioral path: she only recognizes a near-miss *because* she already opened the episode log when the prodrome started, then it resolved. A separate home-screen "log a near-miss" button would have no traffic. First screen of the episode log asks **"Full episode" / "Prodrome that resolved"**; if the latter, the flow swaps in intervention fields (what changed, time-to-resolve) instead of severity/duration.
6. ~~**`directional_cold_airflow` granularity**~~ — **resolved 2026-04-15:** single chip, no source picker. Source detail goes in the existing episode-log free-text note when relevant; mechanism is the same across sources at current data volume.
7. ~~**FINDINGS patch**~~ — **resolved 2026-04-15:** patch **now, narrow** before next specialist appointment. Scope of the now-patch (critique items C1–C3 only):
   - C1: reframe "12/12 model performance" as retrospective classification, not validated prediction.
   - C2: label axis thresholds (−5 hPa, ≥10°F/5h) as hypothesis-generating cutoffs, not validated.
   - C3: update Feb 12 verdict — sleep deprivation is the likely dominant driver; psilocybin at most a modifier (post-Feb 12 repeated-use-without-episode data).
   - **Deferred to a later batched FINDINGS revision (after ≥4–6 weeks of Tier 1 data):**
     - C4: right-sided dominance — add a lateralization column to the event scoreboard if it will be used in a spine-surgery conversation.
     - C5: dog-exposure (event 1) — decide whether it's an MCAS-class exposure worth keeping as an example, or drop it from the narrative.
     - Re-evaluation of axis thresholds against a larger event count.
     - Incorporation of exposures newly captured by Tier 1 (alcohol, sleep-hours, cycle proxies, directional cold airflow, aborted episodes).

---

## Dependencies / ordering

1. Resolve open questions above.
2. Apply FINDINGS file patches (documentation only — not blocking).
3. Implement Tier 1 data-model and UI changes in `index.html`.
4. Implement Tier 1 export changes in the report-generation path.
5. Verify backward compatibility against existing stored entries (load old log, confirm render path).
6. Ship; collect ≥4 weeks of data before Tier 2 scoping.

---

## Out of scope for this plan

- Full Hormonal Cycle Tracker (ROADMAP §3) — the minimum-viable cycle-day field here is a placeholder.
- Reminders / notifications (ROADMAP §4).
- Changes to the three-axis environmental model itself (covered by `PLAN_environmental_risk.md`).
- Episode-phase work (`PLAN_episode_phases.md`).
- Changes to episode body-map, sensations, or communication-level fields — those were scoped elsewhere and are working.
