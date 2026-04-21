# Isobar — Trigger-Trap Correction (Plan)

Compiled 2026-04-19, rewritten 2026-04-20 after resolution of all six open questions. Modern migraine-trigger literature finds that most self-reported "triggers" are actually prodromal symptoms of an attack that has already started centrally. This plan specifies the app-design changes needed to avoid encoding that bias into Isobar's data model and future analyses.

---

## Session Status

**Phase:** Specced, ready for implementation. Blocks no in-flight work. Intersects Wave 6 (episode phase restructure) and Wave 7 (export consolidation) in the consolidated plan, and adds a new Wave 9 (Places) that did not previously exist.

All six open questions resolved — see "Resolutions" section below. Concrete constants pinned. Change 2 rewritten to an opportunistic-ping model that keeps stays out of the persisted schema entirely.

---

## Purpose

Retrofit the Isobar data model and export so that episode-context data cannot be silently interpreted as causal. Three coordinated changes:

1. **Primer window vs prodrome window** — split pre-episode time into a passive, objective primer window (up to 72h before prodrome onset) and a user-observed prodrome window (last 6h before ictal onset). The prodrome window contains likely *symptoms*, not causes; analyses keep the two separated so prodromal contamination doesn't masquerade as a trigger.
2. **Places schema = name + coords only; stays reconstructed from pings at query time.** No exposure chips on place. No persisted `stays` collection. Exposure attribution is a post-hoc analysis layer, not a stored fact, and stay boundaries are reconstructed on demand from an opportunistic location-ping log.
3. **Default correlation view = counter-examples, with a three-way split.** When the export or UI summarizes place–episode association, the framing leads with base rates ("18 stays, 4 with episode, 2 aborted, 12 clean"), never episode-conditioned framing. When the sample is too small, the export says so explicitly rather than printing a ratio.

## Why this change

The trigger-trap finding is the dominant finding in modern migraine and headache-phase research:

- Many perceived triggers are actually early prodromal symptoms. Chocolate "craving" is the prodrome, not the cause. "Bright light triggered it" reflects premonitory photophobia — normal light becoming intolerable because the attack has already begun.
- Placebo-controlled provocation trials fail to confirm most self-reported food triggers. Trigger-avoidance studies show no benefit vs. controls. Prodrome *recognition* is what actually helps patients.
- Passive signals (location, weather, sleep timing, accelerometer) consistently outperform active self-report in EMA/passive-sensing literature because they avoid recall bias and prodromal contamination.

Applied to Isobar: the Feb/March event data — and the 2026-04-19 flight episode — already show sustained exposure windows (mold/dog ~12h, pressure dwell ~12h) that the current "24h-prior chip" format flattens into a single causal-ish attribution. Without the window split, the primer-window signal (the stuff that actually varies between episode and non-episode days) and the prodrome-window signal (what she noticed as the attack started) get regressed together and mutually contaminate.

Without the Places correction: auto-geofence would be valuable *if* the place is stored as name + coords. Storing `exposures: ["dog","mold"]` on the place means every later correlation query is checking a pre-labelled hypothesis against itself.

Without the counter-example default: the export will read as "look at how many episodes happened at Marquette," which is the exact framing that produces false causal certainty and which the literature specifically warns against.

---

## Research basis

| Claim | Source |
|---|---|
| Many perceived migraine triggers are prodromal symptoms | [American Migraine Foundation — Science behind migraine triggers](https://americanmigrainefoundation.org/resource-library/the-science-behind-migraine-triggers/); [PubMed 40980937](https://pubmed.ncbi.nlm.nih.gov/40980937/); [PubMed 39380339](https://pubmed.ncbi.nlm.nih.gov/39380339/) |
| Placebo-controlled provocation fails to confirm most self-reported food triggers | [PMC8068686](https://pmc.ncbi.nlm.nih.gov/articles/PMC8068686/); [Neurology Live — migraine trigger trap](https://www.neurologylive.com/view/helping-your-patients-avoid-the-migraine-trigger-trap) |
| Passive signals (location, sleep, accelerometer) outperform active self-report | [JMIR 2025 — passive EMA](https://www.jmir.org/2025/1/e70871); [PubMed 28637126](https://pubmed.ncbi.nlm.nih.gov/28637126/) |
| Location-auto-detect dwell-based model (prior art; 10K-user validation) | [Migraine Insight](https://migraineinsight.com/); [PMC12712558](https://pmc.ncbi.nlm.nih.gov/articles/PMC12712558/) |
| Correlation-engine benchmark (no location, strong factor correlation) | [Bearable](https://bearable.app/) |

---

## Constants

Pinned values for the first implementation. Revisit after ≥4–6 weeks of captured data (see "Dependencies / ordering").

| Constant | Value | Meaning |
|---|---|---|
| `PRIMER_WINDOW_HOURS` | `72` | Ceiling: primer window begins `prodrome_onset − 72h`. |
| `PRODROME_FLOOR_HOURS` | `6` | Floor: primer window ends `prodrome_onset − 6h`; the last 6h pre-prodrome is considered prodrome-adjacent and is rendered with that ambiguity flagged rather than as clean primer data. |
| `POST_STAY_EPISODE_WINDOW_HOURS` | `48` | A stay "counts" for episode-association when an episode's ictal_onset falls within the stay or within 48h after the stay closes. |
| `STAY_COUNT_MIN` | `5` | Minimum reconstructed stays at a place (in the query window) before any ratio is printed. Below this, the export prints "not enough data yet." |
| `PING_RADIUS_M_DEFAULT` | `75` | Default radius used when clustering pings into a place; adjustable per place at labeling time. |

---

## Design changes

### Change 1 — Primer window vs prodrome window

This is an **analysis and export change**, not a new data field. The boundary already exists in the planned schema: `episode.prodrome_onset` (from PLAN_episode_phases). All that's missing is using it as a window boundary in the export and any correlation view.

**Windows:**

- **Primer window** = `prodrome_onset − PRIMER_WINDOW_HOURS` to `prodrome_onset − PRODROME_FLOOR_HOURS` (i.e., 72h → 6h pre-prodrome). Passive/objective signals that vary independent of whether an attack is starting. Populated from:
  - Location / stay reconstruction (Change 2).
  - Weather axes (already computed).
  - Sleep hours and sleep-end time (Wave 5, shipped).
  - Alcohol units and last-drink time (Wave 5, shipped).
  - Meal log (already captured).
  - Cycle-phase proxies from morning check-ins (Wave 5, shipped).

- **Prodrome-adjacent band** = `prodrome_onset − PRODROME_FLOOR_HOURS` to `prodrome_onset` (last 6h pre-prodrome). Data here is rendered separately with a "prodrome-adjacent — interpret with caution" label. Not counted as clean primer exposure; not treated as prodrome symptom either. This band catches the "I went out for dinner 3 hours before the shift started" case where the attack was already under way centrally.

- **Prodrome window** = `prodrome_onset` to `ictal_onset` (first spasm). Contains what the patient *noticed* — mood shift, sensory sensitivity, cravings, fatigue, paresthesias. These are likely *symptoms of the attack*, not causes. Already modelled as `episode.prodrome_symptoms` in PLAN_episode_phases. The export renders prodrome symptoms as **prodromal (likely symptom)**, never as exposures, and never mixes them into a "24h prior" summary alongside primer-window data.

- **No-prodrome case:** when `prodrome_absent: true`, the primer window ends at `ictal_onset − PRODROME_FLOOR_HOURS` and the prodrome window is empty. Export notes "no prodrome captured — primer window extended to 6h before first spasm; last-6h band still rendered separately as prodrome-adjacent."

**Schema impact:** none. `prodrome_onset` + `prodrome_symptoms` already specced. Only the **export-generation path** and any future **correlation UI** read the window boundary.

**Two parallel prodrome timelines in the export.** Resolves Q5 (retrospective backfill). `prodrome_symptoms` entries split into two tracks rendered side by side:

- **Track A — real-time:** entries with `captured_retrospectively: false`. Treated as the primary prodrome record.
- **Track B — retrospective backfill:** entries with `captured_retrospectively: true`. Rendered in a parallel column with a visible "backfilled" marker. Not excluded from the export (they are real data) but never silently merged with Track A, because hindsight bias makes them mechanically different evidence.

Correlation/timing computations use Track A only; Track B is narrative context only. The clinician can still see both.

**Morning check-in treatment:** a morning check-in taken *before* an episode that day — if the episode's prodrome_onset is within 6h of the check-in timestamp — renders in the export under "prodrome window" not "primer window," even though the data lives on a check-in record. Boundary is temporal, not by data source.

### Change 2 — Places schema + opportunistic-ping stay reconstruction

New data surface. Rewritten from the original 15-minute-dwell threshold model to an opportunistic-ping model that keeps persisted data minimal and never commits a "stay" to storage.

**Places (persisted):**

```js
// places collection
{
  id: <uuid>,
  name: <string | null>,     // null = unnamed (coords-only default, see Q2 resolution)
  lat: <number>,
  lon: <number>,
  radiusM: <number>,         // default PING_RADIUS_M_DEFAULT (75m); adjustable per place
  createdAt: <timestamp>,
  // NOTHING ELSE. No exposures, no tags, no "what's at this place."
}
```

**Location pings (persisted):**

```js
// locationPings collection
{
  id: <uuid>,
  ts: <timestamp>,
  lat: <number>,
  lon: <number>,
  accuracyM: <number | null>,  // from the Geolocation API; used to discard low-quality samples
}
```

Pings are written opportunistically while the app is open: whenever any view samples location (morning check-in, episode log, Places view open, manual "where am I" tap). There is no background scheduler — Isobar is a PWA with no service-worker geolocation. A ping may also be written on navigation visibility-change events when permission is granted.

**Stays (reconstructed, not persisted):**

Stays are derived on demand from `locationPings` at export or query time. Algorithm (applied per place):

1. Filter pings inside `place.radiusM` of `(place.lat, place.lon)` within the query window.
2. Cluster consecutive in-radius pings. A gap > 2h between consecutive in-radius pings closes the cluster; the next in-radius ping opens a new stay.
3. For each cluster: `arrived ≈ first_ping.ts`, `left ≈ last_ping.ts`, `observed_dwell = left − arrived`.
4. Every reconstructed stay is rendered with an **"observed dwell (lower bound)"** label — the actual dwell is ≥ the observed span, because pings are foreground-only and gaps in the cluster mean the app was closed, not that the user left.

**Why opportunistic-ping, not a persisted stays collection:**

- No background service means any persisted "stay" record would be an inference dressed up as a fact. Reconstruction at query time makes the inference explicit and inspectable.
- Ping log is append-only and small (~dozens of rows per day even with heavy use). Stays can be re-derived with a better algorithm later without migrating data.
- If the user relabels a place or adjusts its radius, stay history automatically reflects the new shape on next query. No backfill step.
- Eliminates the "missed visit" bookkeeping problem — there is no truth-state that can be wrong, just pings and a derivation.

**What is explicitly not stored on a place:**

- `exposures: ["dog","mold","altitude"]` — a *hypothesis about what's at the place*. Saving it locks the schema into confirming that hypothesis. Exposure attribution is done at analysis time, as a query filter the user can toggle.
- Any "expected severity" / "safe place" / "known bad" flag.
- Weather or altitude lookup (computed from coords at query time).

**Place creation:** when a ping arrives more than `radiusM` from all known places, a new unnamed place is created with the ping's coords as center. The user is **not prompted to name it at creation time** (resolves Q2). Naming is an opt-in action from the Places view (see Change 3). An unnamed place displays as "Place near (lat, lon)" rounded to 3 decimals.

**Privacy floor:** pings and places stored in Dexie, same protection as every other record. Nothing leaves the device. No third-party geocoder; reverse-geocoding is opt-in.

### Change 3 — Counter-example default view + three-way split + Places view

**Three-way stay split** (resolves Q6). Any export section or Places-view row summarizing place–episode association uses this framing:

> Marquette house — 18 stays in the last 90 days.
> • 4 with episode (ictal_onset during stay or within 48h after)
> • 2 with aborted episode (same window)
> • 12 clean (no episode, no aborted event)

**Not:**

> Marquette house — 4 episodes occurred during or after a stay here.

The first framing makes the denominator visible and preserves the intervention-efficacy signal from aborted episodes. The second silently drops the 14 disconfirming cases and loses the aborted row entirely.

**"Not enough data yet" placeholder.** When `reconstructed_stay_count < STAY_COUNT_MIN` (5) for a place in the query window, the export prints:

> Marquette house — 3 stays in the last 90 days. Not enough data yet for a base-rate view (minimum 5).

No ratio, no episode count split. The goal is to prevent the reader from pattern-matching on three-event noise.

**Same rule for exposures** (when the export's correlation summary is built): "alcohol within 72h primer window — N primer-window hits on episode days, M primer-window hits on non-episode days" — never just the episode count. When the non-episode denominator is absent or below threshold, the export prints "(base rate unavailable)" rather than fabricating a ratio.

**Time windows** for the counter-example computation are the same as Change 1 — primer-window data for primer-style exposures, prodrome-window data rendered separately and never treated as an exposure. Prodrome-adjacent band data (last 6h pre-prodrome) is counted in a third sub-row flagged "ambiguous."

**Places view in-app** (resolves Q3). A dedicated Places view surfaces the reconstructed stay list and the three-way split per place, using counter-example framing by default. Patient seeing honest base rates is itself therapeutic — it's the cognitive mode the literature says reduces trigger-trap error. View actions:

- Label or rename a place.
- Adjust radius (default 75m).
- Merge two places (if the same physical location got two coord clusters).
- Delete a place (pings stay; place re-creates on next out-of-radius ping unless merged).

The Places view is the only UI entry point for place naming; naming never interrupts logging.

---

## Resolutions to the six open questions

1. **Primer-window length** — `PRIMER_WINDOW_HOURS = 72`, `PRODROME_FLOOR_HOURS = 6`. Last 6h rendered as a separate "prodrome-adjacent" band, not merged into clean primer data. Revisit after ≥4 weeks of captured data.

2. **Place-naming policy** — coords-only default; no prompt at place creation; naming is opt-in from the Places view. Unnamed places display as "Place near (lat, lon)."

3. **Stay visibility** — Places view surfaces the reconstructed stays with counter-example framing and three-way split. The patient sees the same honest base rates the specialist sees.

4. **Migraine Insight parallel** — tracked in ROADMAP only (new §4). Parallel trial 2026-04-19 → 2026-07-19; compare signals at the end. No in-app integration.

5. **Retrospective prodrome backfill** — included but rendered in a separate parallel timeline in the export. Correlation/timing math uses real-time-captured entries only; retrospective entries render as narrative context with an explicit backfill marker.

6. **Aborted-episode aggregation** — third bucket in all counter-example summaries (episodes / aborted / clean). Preserves the intervention-efficacy signal that the aborted-episode branch provides.

---

## Integration with existing plans

### PLAN_episode_phases.md (Wave 6 — not yet started)

- **No schema changes.** `prodrome_onset`, `ictal_onset`, `prodrome_symptoms`, `prodrome_absent`, and the `captured_retrospectively` flag already exist in the spec.
- **Export-generation path in Wave 7 must consume those boundaries** per Change 1. Add a line to the Wave 7 scope: "Exposures export respects primer-vs-prodrome window boundary; prodrome-adjacent 6h band renders separately; retrospective prodrome entries render in a parallel timeline."
- **Prodrome symptoms render as 'prodromal' in the export**, never under "exposures" or "triggers." The current PLAN_episode_phases export spec already renders them under a prodrome heading with relative timing, so this alignment is mostly labeling: the export section is titled "Prodrome (likely symptoms of attack — not causes)."

### PLAN_trigger_surface_expansion.md (Wave 4 + Wave 6 — not yet started)

- **Terminology fits.** "Exposure" already removes the log-time causal-attribution burden; this plan sharpens the point by keeping exposures strictly in the primer window in analysis.
- **No change to the exposure chip set.** Chips remain valid — they just render under the primer window in the export (when logged on an episode) or as standalone daily context (when logged on a morning check-in).
- **One watch-item:** the `directional_cold_airflow` chip on the episode log is logged *at episode time*, which means it may reflect an already-started attack's cold intolerance (premonitory thermal sensitivity is in the literature). Reported in the export as "reported at episode onset," not as a clean primer-window exposure. No schema change.
- **Aborted-episode branch** (Tier 1 item 7) is *highly* compatible: aborted episodes are the strongest possible evidence of a *real* trigger-response dynamic because intervention reversal is observable in the same session. They stay intact and become the third bucket in every counter-example view.

### Consolidated plan (`project_consolidated_plan.md`)

Proposed amendments to the wave map:

- **Wave 7 — export consolidation:** add one bullet — "respect primer-window (72h→6h pre-prodrome) vs prodrome-adjacent (6h→0h) vs prodrome-window boundary; prodrome symptoms render as 'likely attack symptoms,' never as exposures; retrospective prodrome entries render in a parallel timeline; correlation summaries lead with counter-example framing and three-way stay split; print 'not enough data yet' when `stay_count < 5`."
- **New Wave 9 — Places & stays (opportunistic-ping model):** ships after Wave 8. Name + coords only per Change 2. `locationPings` append-only; stays reconstructed at query time with observed-dwell-as-lower-bound framing. Feeds back into the Wave 7 export as an additional primer-window signal.
- **Waves 1–6 unaffected.**

No in-flight work is blocked. No shipped data needs migration.

---

## Out of scope for this plan

- Migraine Insight parallel use (tracked in ROADMAP §4; user-side validation, not a code change).
- Any change to the three-axis environmental model (`PLAN_environmental_risk.md`).
- Any change to the morning check-in (Wave 5 shipped; the window split is applied at export, not at log).
- Altitude and cabin-pressure capture on flights (surfaced by the 2026-04-19 flight finding; separate plan or ROADMAP item).
- Background-service geolocation for missed-visit coverage (out of scope by design — PWA doesn't support it, and the opportunistic-ping model makes it unnecessary).
- A correlation-engine UI inside the app. The counter-example default applies to exports and the Places view; broader in-app correlation is not in this plan.

---

## Dependencies / ordering

1. Wave 6 ships (PLAN_episode_phases) — required to have `prodrome_onset` available as a data boundary.
2. Wave 7 (export consolidation) implements the primer/prodrome-adjacent/prodrome window split, parallel prodrome timelines, counter-example default, three-way stay split, and the "not enough data yet" threshold.
3. Wave 9 (Places) implemented: `places` collection, `locationPings` collection, query-time stay reconstruction, Places view. Feeds into Wave 7 export.
4. After ≥4–6 weeks of data across primer-window exposures + reconstructed stays, revisit `PRIMER_WINDOW_HOURS`, `PRODROME_FLOOR_HOURS`, `STAY_COUNT_MIN`, and `POST_STAY_EPISODE_WINDOW_HOURS` against the actual data distribution.
5. At 2026-07-19 (Migraine Insight parallel trial end), compare Migraine Insight's signal output to Isobar's primer-window exports for the same period.

---

## Related

- `PLAN_episode_phases.md` — provides the `prodrome_onset` boundary that makes Change 1 possible. No conflict.
- `PLAN_trigger_surface_expansion.md` — renamed triggers → exposures; this plan extends the reasoning to window-aware analysis. No conflict.
- `FINDINGS_2026-04-19_flight_episode.md` — concrete case where sustained-window exposures (mold/dog ~12h, pressure dwell ~12h) reveal the inadequacy of 24h-chip causal framing.
- `FINDINGS_environmental_trigger_analysis.md` — Class 1–5 trigger-class model, to be re-read with window-awareness after Wave 7 ships.
- `project_consolidated_plan.md` (memory) — proposed Wave 7 bullet + new Wave 9.
- `ROADMAP.md` §4 — Migraine Insight parallel trial (2026-04-19 → 2026-07-19).
