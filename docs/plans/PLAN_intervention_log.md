# Isobar — Intervention Log (Plan)

---

## Session Status (2026-04-30)

**Phase:** Open questions resolved; design spec complete. Ready for ticket creation.

**Rev 2 (2026-04-30):** Worked through all 5 open questions. Key resolutions: window-match + manual override for episode attachment (Q1); per-category recall with quick-pick chips (Q2); wrap-up-only capture for time-to-effect plus opportunistic home-screen strip (Q3); keep both heat surfaces with documented semantic split (Q4); own cards with cross-reference badges, not fold-in (Q5). Resolutions detailed in "Resolved questions" section below.

**Origin:** Patient reports that 2-3mg sublingual THC, taken during an active episode, reliably aborts the episode and stops the pain. (See `project_thc_treatment_response.md` memory for the four-pathway mechanism research: glycine receptor potentiation, CB1/GABA modulation, mast cell stabilization, descending pain modulation via PAG.) The current data model captures the natural course of an episode (prodrome → spasms → resolution) but has no place to record what was *taken* in response, what dose, when, and what the perceived effect was. Without that, the dataset can't distinguish a naturally aborted episode from an intervention-aborted one, and can't surface "of N THC-treated episodes, M ended within X minutes."

This is not a THC-only feature. The same surface should capture every category of intervention the patient uses (heat, hydration, rest position, OTC analgesic, MCAS rescue meds, future prescriptions). THC is the prompting case; the design must generalize.

---

## Principles cited

**Honored:** P1 (no numeric scales — perceived effect is categorical); P2 (works at worst — single tap to log "took something"); P3 (concrete, observational descriptors); P4 (no causal attribution at log-time — perceived effect is "what I observed", not "what worked"); P9 (fields optional — only timestamp + category are required); P12 (record integrity — interventions are append-only, edits flagged); P13 (single user — categories and pre-filled options are tuned to her actual pharmacy/practice).

**Tensioned against:** P4 (exposures vs triggers framing). An intervention is an *action* the user took expecting a clinical effect; calling the perceived outcome "stopped the episode" comes close to a causal claim. Resolution: the field is labeled "what I observed after" and explicitly framed as observational ("can't know counterfactual"), with the export language carrying the same caveat.

---

## Purpose

Add a third event type — `intervention_event` — that records:
- **What** was taken (category + free-text specific)
- **When** it was taken (timestamp)
- **What was observed after** (categorical perceived effect, plus optional time-to-effect)
- **Episode link** (if taken during an open episode) or standalone (if taken during a prodrome that aborted, or as a daily preventive)

And surface that data:
- **Real-time:** during an open episode, alongside spasm logging — so a sublingual dose taken at minute 8 is timestamped within seconds, not reconstructed from memory two hours later
- **Retrospective:** in the postictal wrap-up, in case real-time logging was skipped
- **In exports:** chronologically interleaved with the spasm timeline so the specialist sees the dose-response sequence directly

## Why this change

The patient's reproducible THC-abort pattern is the highest-signal treatment-response observation in the dataset. It currently has no home in the schema. Logging it as a free-text note in the episode wrap-up loses:

- **Time-to-effect** — diagnostically meaningful (sublingual THC has ~10-30min onset; a 5min effect would suggest something else; a 60min effect would suggest something else again)
- **Dose-response across episodes** — does 2mg work the same as 3mg? Does a heavier prodrome need more?
- **Comparative effectiveness** — heating pad vs THC vs nothing; which actually correlates with shorter episodes?
- **MCAS rescue tier visibility** — if Benadryl/Pepcid abort episodes, that's evidence for the MCAS hypothesis the specialists are weighing

A structured log makes all four legible at export time and queryable for pattern surfacing later.

---

## Current code state (verified 2026-04-30)

- Home screen has **two** action cards: `Log Episode` (`index.html:410`) and `Morning Check-in` (`:415`). The three-button phase design from `PLAN_episode_phases.md` is **not yet implemented**.
- Live episode form is `startEpisode()` at `:1125`, single-form 9-step wizard, writes `type: 'episode'`.
- Migrated historical data carries `type: 'episode_v2'` + `type: 'motor_event'` records (per `project_data_review_apr27` memory). Export at `:1789` reads both.
- Existing `substance24h` field at episode form step 4 (`:1271`) captures retrospective substance use in the prior 24h — adjacent but distinct concept (passive intake vs active intervention).
- `heatTherapy` field exists on check-in entries — overlaps with future "intervention category = heat". Out-of-scope to consolidate now; flagged for follow-up.

This plan does **not** depend on `PLAN_episode_phases.md` shipping first. It works against the legacy single-form flow today, and the data shape carries forward when phase logging lands.

---

## Data shape

New entry type `intervention_event`, modeled after `motor_event`:

```json
{
  "type": "intervention_event",
  "timestamp": "ISO string",
  "episode_id": "ep_<id>" | null,
  "category": "cannabinoid",
  "specific": "THC 2-3mg sublingual",
  "perceived_effect": "stopped_episode" | "reduced_pain" | "no_change" | "made_worse" | "unsure" | null,
  "time_to_effect_min": 15 | null,
  "notes": "string",
  "_promptDismissed": false
}
```

`_promptDismissed` is set to `true` when the user taps "Not now" on the opportunistic home-screen effect-capture strip (Q3); it suppresses re-prompting for that specific intervention. Default false.

### Field details

- **`timestamp`** — required. Real-time logging stamps `now()`; retrospective logging exposes a time picker.
- **`episode_id`** — null for standalone events (preventive, prodrome-aborted, daily). When taken during an open episode (post-`PLAN_episode_phases.md`), auto-attached. In the legacy flow, attached at episode-save time if the intervention timestamp falls within the episode window.
- **`category`** — closed list, picked from chips:
  - `cannabinoid` (THC, CBD)
  - `mcas_rescue` (antihistamines, mast cell stabilizers — Benadryl, Pepcid, cromolyn)
  - `gaba_agonist` (benzo, gabapentinoid — if prescribed)
  - `muscle_relaxant` (baclofen, etc.)
  - `otc_analgesic` (acetaminophen, ibuprofen)
  - `heat` (heating pad, hot shower — for symptom-response use; routine heat goes in morning check-in `heatTherapy`)
  - `hydration` (water, electrolytes)
  - `rest_position` (lying down, propping legs)
  - `supplement` (magnesium, B-complex)
  - `other` (free text in `specific`)
- **`specific`** — free text. Per-category recall (Q2): the input is prefilled with the most recent specific used in this category, and up to 3 most-recent distinct specifics are shown as quick-pick chips below the input. Storage key `intervention:recent:<category>` holds the recent list. New category = no prefill, no chips, plain input.
- **`perceived_effect`** — five categorical options + null. Framed as observation, not causation: *"What did you notice after?"* Options: stopped the episode / reduced pain only / no change / made it worse / not sure.
- **`time_to_effect_min`** — optional, captured retrospectively. Surfaced only when `perceived_effect` is `stopped_episode` or `reduced_pain`. Free-text minutes input or quick chips: `5`, `15`, `30`, `60+`.
- **`notes`** — free text, optional.

### Why `intervention_event` is its own type, not a field on the episode

- A single episode can have multiple interventions (e.g. heating pad → 30min later, THC → 20min later, hydration). Modeling as an array on the episode would work, but a separate event type:
  - Mirrors the `motor_event` pattern already in the schema (architectural symmetry, easier to read).
  - Captures **standalone** interventions: a microdose taken during a prodrome that aborts before any spasm, or a preventive evening dose, or a routine MCAS antihistamine. None of those have an episode to attach to, but all are worth logging for pattern surfacing.
  - Each event has its own timestamp, which is what time-to-effect calculations need.

---

## UI surfaces

### Surface 1 — Home screen "Took something" card

A third action card on the home grid (`index.html:409-420`), styled in a calmer color than the danger-red episode button (e.g. accent green), labeled **Took something**, sub-text *"Log meds, heat, anything"*. Tap → opens the intervention form.

The form is one screen, fits without scrolling on iPhone:

```
[Date / time picker — defaults to now]
[Category chip row — 10 options, scrollable horizontally]
[Specific — text input, prefilled from most recent in this category]
[Quick-pick chips — up to 3 most recent distinct specifics for this category]
[Perceived effect — 5 chips, optional]
[Time to effect — appears only if effect chip selected; quick chips + custom]
[Notes — single-line input]
[Save]
```

If an episode is currently open (post-`PLAN_episode_phases.md`), `episode_id` auto-attaches. In the legacy flow, the form has no awareness of an "open" episode — attachment happens at episode-save time by timestamp window matching (Q1).

### Surface 1a — Opportunistic effect-capture strip (home screen)

Above the action grid on home view, render a strip if there exists any `intervention_event` matching: `timestamp ∈ [now - 120min, now] && perceived_effect === null && _promptDismissed !== true`. The strip shows:

```
[💊 You logged THC 2-3mg sublingual at 14:51]
[Stopped] [Less pain] [No change] [Worse] [Not sure]   [Not now]
```

Tapping an effect chip writes `perceived_effect` (and prompts inline for `time_to_effect_min` via quick chips: 5 / 15 / 30 / 60+ / custom). Tapping "Not now" sets `_promptDismissed: true`. The strip dismisses on either action and won't reappear for that intervention. If multiple eligible interventions exist, only the most recent is shown at a time.

Rationale: Q3 — captures the freshness-window effect data without interrupting rest. Zero cost when no interventions are pending.

### Surface 2 — Episode form integration (legacy flow)

In the existing 9-step episode form, add a new step between current step 4 (`exposures` / `substance24h`) and step 5 (body map):

**Step 4.5: "Did you take anything during this episode?"**

The step always renders (no Yes/No gate — gating adds a tap and the answer is implied by whether the list is empty). Behavior:

- The step queries `intervention_event` records where `episode_id === null && timestamp ∈ [prodromeTime, min(now, prodromeTime + 12h)]` (Q1 window).
- Each match shows as a row with a checkbox (default checked): category + specific + time + perceived effect (if set).
- Above the list: an "Add another" button opens the intervention form pre-set to attach to this episode at save time. Newly-added interventions appear in the list with checkbox checked.
- If `perceived_effect === null` on any listed intervention, an inline 5-chip row offers a one-tap capture (same chips as the home-screen strip — final retrospective pass for effect data).
- If zero matches: the step shows *"No interventions logged in this episode's window — Add one?"* with the Add button. Skipping is one tap on Next.

On episode save:
- All checked interventions get `episode_id` written (set to the episode's stable identifier — the `entry:<timestamp>` key derived from prodromeTime + entryDate).
- Unchecked interventions stay with `episode_id: null`.
- Single-attachment is enforced (Q1) — the wrap-up step's query excludes interventions with non-null `episode_id`, so they can't appear in a second episode's wrap-up.

This is the **retrospective safety net** — even if the user never opened the home screen during the episode, she gets one prompt in the wrap-up flow.

### Surface 3 — During-episode banner (post-`PLAN_episode_phases.md`)

When `PLAN_episode_phases.md` ships and the home screen has the "Episode in progress" banner, that banner gains a **"Took something"** button alongside "Log a spasm" and "It's over". This is the primary real-time logging path — single tap, opens the form, `episode_id` auto-attached.

This surface is **deferred** to land alongside or after the phase restructure. The home-screen card (Surface 1) and the wrap-up step (Surface 2) cover the use case in the meantime.

### Surface 4 — Export integration

In the per-episode block of the physician export (`exportReport()` at `index.html:1789`), interventions appear in the chronological event list alongside motor events:

```
[Episode block]
  Prodrome onset: 14:32
  Spasm 1: 14:48 (right leg, moderate)
  Intervention: 14:51 — THC 2-3mg sublingual
    Effect noted: stopped episode (~15 min)
  Spasm 2: 14:55 (right leg, light)  [pre-effect, expected]
  Last activity: 15:06
  Total span: 34 min
```

Standalone interventions (no `episode_id`) are not rendered inside any episode block; they appear in the daily timeline section as `Intervention: HH:MM — <category> <specific>`.

The export's narrative paragraph adds a one-line summary if the intervention pattern is strong: *"THC 2-3mg sublingual was taken during 7 of 12 episodes; perceived effect was stop-episode in 6 of 7."* Language is strictly observational per Principle 7.

---

## Acceptance criteria (per ticket)

This plan decomposes into 3 dependent tickets. ACs are specified per ticket below.

### TICK-035: Intervention event schema + standalone home-screen logging + opportunistic strip

- [ ] New `intervention_event` data type writes to `entry:<timestamp>` keys with all fields per data shape (incl. `_promptDismissed: false` default)
- [ ] Home screen has a third action card "Took something" (alongside Log Episode + Morning Check-in)
- [ ] Form captures: timestamp, category (10 chip options), specific with per-category recall (prefill + up to 3 quick-pick chips backed by `intervention:recent:<category>` storage key), perceived effect (5 chips, optional), time-to-effect (chips + custom, optional), notes
- [ ] Home-screen opportunistic strip (Surface 1a) renders above the action grid when any intervention in past 120min has `perceived_effect === null && !_promptDismissed`; tapping an effect chip writes the field, "Not now" sets `_promptDismissed: true`
- [ ] Existing readers (`exportReport`, log view) tolerate the new type without error (backwards compat — old code paths skip unknown types)
- [ ] Cache version bumped if `sw.js` precaches affected files

### TICK-036: Episode wrap-up intervention review (legacy flow)

- [ ] Episode form (legacy `startEpisode` flow) gains a step "Did you take anything during this episode?" between current steps 4 and 5
- [ ] Step queries `intervention_event` records where `episode_id === null && timestamp ∈ [prodromeTime, min(now, prodromeTime + 12h)]`
- [ ] Each match renders as a row with default-checked toggle showing category, specific, time, perceived effect
- [ ] "Add another" button opens the intervention form configured to attach to this episode on episode-save
- [ ] Inline 5-chip effect capture appears for any listed intervention with `perceived_effect === null`
- [ ] On episode save, all checked interventions get `episode_id` set (single-attachment — already-attached interventions are excluded from the query and cannot appear in a second wrap-up)
- [ ] Step does not block episode save when skipped (P9)

### TICK-037: Log view cards + export intervention timeline

- [ ] New `renderInterventionCard(entry)` function renders intervention entries in the log view as their own cards
- [ ] Episode card render gains a `💊 N interventions` chip near the duration line, where N counts interventions where `episode_id === <this episode's id>`; chip click scrolls to and highlights the first matching intervention card
- [ ] Intervention card shows a "During episode HH:MM–HH:MM" sub-line if `episode_id` is set; sub-line click scrolls to the parent episode card
- [ ] Per-episode block in `exportReport()` interleaves interventions with motor events chronologically
- [ ] Each intervention line shows: timestamp, category, specific, perceived effect, time-to-effect (if recorded)
- [ ] Standalone interventions appear in the daily timeline section, not inside any episode block
- [ ] If ≥3 interventions of the same category exist with perceived effect data, append a one-line observational summary to the narrative paragraph
- [ ] Export language is strictly observational ("noted after", "perceived"), no causal verbs

---

## Resolved questions

### Q1 — Episode-id attachment in the legacy flow

**Resolution:** Auto-attach by `[prodromeTime, min(saveTime, prodromeTime + 12h)]` window. The wrap-up step always renders, showing all unattached interventions in that window with checkboxes (default checked). On episode save, checked interventions get `episode_id` set. An intervention can only be attached to one episode (single-attachment constraint).

**Why:** real-time logging during an open episode hits the window cleanly; retrospective episode logging falls back to manual add via the wrap-up step's "Add another" button. The 12h cap protects against pathological retro logging from sweeping in unrelated recent interventions. Single-attachment prevents double-counting across overlapping/backdated episodes.

**Concrete rule:** at episode save, query `intervention_event` records where `episode_id === null && timestamp ∈ [prodromeTime, min(saveTime, prodromeTime + 12h)]`. The wrap-up step lists them with default-checked toggles. On confirm, checked records get `episode_id` written and persisted.

### Q2 — Specific recall

**Resolution:** Per-category recall, with the input pre-filled by the most recent specific *and* up to 3 most recent distinct values shown as quick-pick chips below.

**Why:** dose variation across episodes (2mg vs 3mg vs 5mg) is real signal worth preserving. Pre-filling alone forces a re-edit; chips let her pick from her own dosing history with one tap. Cap at 3 to keep the chip row from cluttering on small screens. Cross-category contamination is avoided by keying recall to category.

**Concrete rule:** maintain `intervention:recent:<category>` storage key holding the 3 most recent distinct `specific` strings used. On category selection, prefill input with `[0]` and render `[0..2]` as chips.

### Q3 — Time-to-effect capture

**Resolution:** Capture at episode wrap-up. No real-time push/modal prompts. Add an opportunistic home-screen strip: if any `intervention_event` in the past 120min has `perceived_effect === null && !_promptDismissed`, render a one-line inline strip with the 5 effect chips. Dismissible.

**Why:** post-dose is exactly when the user is most likely lying down resting; interruptive prompts are anti-Principle 2. But waiting only for episode wrap-up loses the case where no episode is open (standalone preventive dose, or a prodrome that aborts). The opportunistic strip threads the needle — zero interrupt cost (shown only if she opens the app anyway), captures the effect in the freshness window, dismissible. Editing from the log view remains the always-available retrospective path.

**Concrete rule:** on home-screen render, query for interventions in past 120 minutes with `perceived_effect === null && !_promptDismissed`. If any, render an inline strip above the action grid: *"You logged \[specific\] at \[HH:MM\] — notice anything?"* with the 5 effect chips and a "Not now" button (sets `_promptDismissed: true`).

### Q4 — Heat consolidation with check-in `heatTherapy`

**Resolution:** Keep both fields. They measure different things. Document the semantic split in the intervention form copy. No deprecation or migration.

**Why:**
- `heatTherapy` on the morning check-in = habitual/comfort heat use during the period (heating pad while reading, hot shower in the morning).
- `intervention_event: heat` = a timestamped, symptom-response action with perceived effect.
- Consolidating would either downgrade the intervention log (lose timing) or upgrade the check-in (force per-event entry that the user won't fill out for habitual use). Both lose signal.
- Small overlap when heat is used symptomatically is acceptable. Export language disambiguates: check-in section says "heat used during the period," intervention block says "heat applied at HH:MM, effect noted: ___." Specialist sees both framings, redundancy is visible rather than misleading.

**Concrete rule:** add disambiguating sub-text under the `heat` category in the intervention form: *"For heat used in response to symptoms. Routine heating pad use belongs in the morning check-in."* No other code change.

### Q5 — Episode card vs intervention card in the log view

**Resolution:** Each intervention gets its own card. Cross-reference via badges and sub-lines, not fold-in.

**Why:** folding intervention render into the episode card couples two entry types and complicates editing (attached interventions need edit affordances through a parent render). Own-card preserves schema symmetry — every type renders its own card. Standalone interventions need own-card anyway; keeping attached interventions as own-card maintains uniformity.

**Concrete rule:**
- New `renderInterventionCard(entry)` function for the log view.
- Episode card render gets a chip near the duration line: count of interventions where `episode_id === <this episode>`, rendered as `💊 N interventions`. Chip click handler scrolls to and briefly highlights the first matching intervention card.
- Intervention card render shows a sub-line if attached: *"During episode \[HH:MM–HH:MM\]"* (clickable to scroll to the parent episode card).

---

## No remaining open questions.

---

## Out of scope

- Pattern surfacing across interventions ("THC stopped 6/7 episodes") beyond the one-line export summary. Full statistical surface is Phase 3 of the README roadmap.
- Reminders / dose timing alerts ("you took THC 4 hours ago, can re-dose"). Cleanly addressed by a future ticket if the use case emerges.
- Drug-interaction warnings. Out of scope and outside the app's clinical role.
- Auto-deduplication with check-in `heatTherapy`. See open question 4.
- Export integration with the daily timeline (separate from per-episode block) — deferred to TICK-037 or follow-up if scope grows.

---

## Backwards compatibility & migration

- Old episode entries (`type: 'episode'` and `type: 'episode_v2'`) have no intervention links — the export renders them with no intervention block, identical to current behavior.
- No data migration needed. Existing data is unaffected.
- The new `intervention_event` type is additive. Any readers that filter `entries.filter(e => e.type === 'episode' || ...)` continue to work; intervention events are simply not picked up by those filters.
- Cache version bump in `sw.js` per architecture invariants.

---

## Rollback

If this ships and the patient finds the third action card cluttering, or the wrap-up step adds friction:
- Hide the home-screen card via a setting toggle (lighter touch than removal)
- Skip the episode wrap-up step if no interventions are window-matched (already the default behavior)
- Existing `intervention_event` records remain queryable from exports; only the input surfaces are hidden

If the entire feature is retired:
- Stop showing the action card and wrap-up step (one-line UI hide)
- Existing intervention records continue to render in exports until explicitly removed
- No data destruction

---

## Retire criteria

- After 6 weeks of having the surface, if fewer than 5 `intervention_event` records have been logged, retire the home-screen card. The wrap-up step alone is enough.
- If the patient stops using THC (or whatever the active intervention is) and no other intervention category fills the volume, retire entirely — at that point the intervention log is dead weight.
- If the specialist export reader doesn't engage with the intervention block in any of the next 3 appointments, simplify it (collapse to a one-line "interventions used: …" instead of the chronological interleave).

---

## Alternatives considered

| Alternative | Rejected because |
|---|---|
| Free-text "what did you take" field on the episode wrap-up | Loses time-to-effect, loses category, loses standalone interventions, can't be queried |
| Boolean "took THC?" on the episode form | THC-specific; doesn't generalize to MCAS rescue, heat, OTC; doesn't capture dose or timing |
| Reuse `substance24h` field | Different semantic (passive 24h intake vs active intervention with intent and observation); conflating loses both signals |
| Add as fields on `episode_v2` instead of new type | Doesn't capture standalone preventive doses or prodrome-aborted micro-interventions; can't represent multiple interventions per episode without becoming an array (at which point a separate type is cleaner) |
| Push to a dedicated medications log (separate from episode tracking) | Loses the episode linkage that makes the data clinically useful; the whole point is dose ↔ event correlation |

---

## Build order

1. **TICK-035** — schema + home-screen logging surface. Self-contained; can ship and be used immediately.
2. **TICK-036** — episode wrap-up integration. Depends on 035.
3. **TICK-037** — export integration. Depends on 035 (data must exist before it can render).

Sizing: each is ≤ 1 day of work, ≤ 200 LOC, ≤ 5 ACs (per `PROCESS.md` ticket sizing).
