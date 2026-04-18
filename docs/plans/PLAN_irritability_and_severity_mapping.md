# Isobar — Irritability Capture + Severity Mapping Framework (Plan)

---

## Session Status (2026-04-17)

**Phase:** Design / open-question review. Not yet implemented.

This plan has five parts:

- **Part A — Frontend (irritability capture):** add irritability as a parallel-polarity capacity axis (currently absent except as a cycle-phase-proxy toggle).
- **Part B — Backend (severity mapping framework):** make the severity model the export is implicitly using *explicit*, with per-axis cross-walk to standard clinical scales.
- **Part C — Evening check-in:** new ~1-minute optional check-in that captures within-day trajectory, physical activity, evening snapshots of communication and irritability, and per-domain interference cost.
- **Part D — PROMIS-comparable composite (Derived Functional Interference Index):** weighted multi-axis composite scaled to PROMIS Pain Interference T-units, derived from morning + evening data, no additional self-rating required.
- **Part E — Final export format & methodology header:** the assembled output that incorporates all of the above.

Parts A and B are independently shippable. Parts C, D, E build on each other — C provides the data, D computes the score, E presents both. Part D requires Part C to differentiate composite items beyond `functionalToday`.

**Decisions captured this session (all locked):**

*First round:*
- Irritability axis values: `normal | edgy | overload | snap_line` (user-confirmed wording)
- Evening check-in: include, scoped (~10–15 taps, ~1 minute, optional, soft prompt only)
- Activity chips: `walk / bike / workout / yoga / housework / other`
- Evening external-observation prompt: included ("Did anyone today comment on you seeming quiet, snappy, or off?")
- Composites: ship robust v1 with a priori weights + sensitivity analysis (not single-axis quick version)
- Naming: conservative ("Derived Functional Interference Index, PROMIS-comparable T-units") — no claim of being the PROMIS instrument
- Episode handling in composite: report alongside the score, not baked into items
- Aggregation for morning+evening pairs in composite: worse-of (peak interference, matches PROMIS construct)
- Window: 7-day primary; 14-day and 30-day trend windows when data available

*Second round (open-questions walk-through):*
- Morning irritability external-observation prompt: **included** ("Has anyone noticed you snapping or seeming on edge?") — new field `morningIrritabilityExternalObservation`
- Per-spasm external-trigger field: **restructured** from single bit to 4-option (`none | emotional | startle | unsure`, default `none`). Reason: distinguishes external-emotion trigger (causal) from prodrome-irritability (downstream of same autonomic shift as the spasm). Conflating the two would produce false-positive SPS-trigger data.
- Framework anchor language: **"behavioral pain assessment family (DisDAT, NCAPC) adapted for autistic alexithymic adults"** — explicit adaptation language to prevent specialist misreading the population framing.
- Cycle-phase `moodShift` toggle: **renamed** to `cycleRelatedDay`, broadened label *"Today feels cycle-related"* — covers all cycle-attributable symptoms in one toggle. Backward-compatible read of legacy `moodShift` values.
- Personal-baseline T source: **user-specified only.** Settings configures 4-tier values per axis × 2 baseline periods (Arizona spring 2026 + summers 2022/23). Until configured, export shows *"personal-baseline T pending — configure in settings."* Auto-derive path rejected.
- PROMIS calibration administration: **yes** — schedule two administrations ~2 weeks after Stage 4 ships, on different state-days (one moderate, one bad). Agreement statistic published in `MEDICAL_PURPOSE.md §Derived Indices`.
- Soft-prompt timing for evening check-in: **8pm default**, configurable in settings.

**Status:** All initial open questions resolved. **Critical-review walkthrough COMPLETE 2026-04-17** (all 16 items locked). See §"Critical Review Walkthrough" at the bottom of this file for the full decision record. Next step: refold locked decisions into the main plan body, then begin ticket creation starting with data persistence hardening.

---

## Part A — Irritability Capture

### Problem

Irritability currently appears in exactly one place in the app: a single toggle labeled *"Mood / irritability shift"* inside the cycle-phase-proxy section of the morning check-in (`index.html:1274`, written into `cyclePhaseProxy.moodShift`).

Three things are wrong with this:

1. **It is trapped under a hormonal frame.** The toggle is only meaningful as "is this cycle-related?" The user cannot log irritability as a standalone signal, as a prodromal symptom, or as a daily capacity indicator.
2. **There is no edginess polarity in the severity model.** The app's severity proxy is `communicationLevel` (normal → quieter → shortened → brief). This is the *withdrawal* polarity — she gets quieter when she is worse. But flares do not always shut her down; sometimes they wind her up. A day where she is snappy, sensory-overloaded, and intolerant of normal requests but still talking in full sentences currently logs as a normal communication day.
3. **It is missing from the episode log entirely.** The prodrome literature (migraine, seizure) and the SPS literature (emotion-triggered spasms) both make irritability/edginess a clinically load-bearing prodromal signal. The current prodrome chips capture only physical sensations.

### Research basis

| Direction | Source | Why it matters for this user |
|---|---|---|
| Irritability as prodrome (migraine) | Giffin et al. 2003; Schoonman et al. 2006 | Top-reported prodromal symptom 2–48h pre-headache; 20–40% of patients |
| Mood change as prodrome (seizure) | Petitmengin et al. 2007; Maiwald et al. 2011 | Reported in 25–50% of patients 1–3 days before events |
| Emotion-triggered spasms (SPS) | SPS clinical literature; GAD65 / GABAergic dysfunction | Spasms are documented to be triggered by emotional stimuli (frustration, startle); same GABAergic mechanism produces emotional dysregulation |
| Sympathetic load → shared irritability + pain threshold | POTS / dysautonomia literature | Sympathetic over-activation lowers the threshold for both pain perception and irritability simultaneously |
| Mast-cell mediator irritability | MCAS literature | Histamine/tryptase produce agitation/irritability alongside flares |
| Behavioral-anchor PROMs for irritability | PROMIS Anger Short Form; Brief Irritability Test (BITe-5); Sensory Profile | Validated short-form scales use behavioral/situational anchors, not feeling-introspection — same design pattern Isobar already uses |
| Alexithymia / interoceptive transduction | Bird, Cook 2013 et al.; autism interoception literature | For autistic + alexithymic adults, externally-observable behavioral irritability is often a more reliable pain-state proxy than self-rated pain. Same logic the app already applies to communication withdrawal. |

The unifying point: irritability is the **opposite polarity** of communication-withdrawal. Both are externally-observable behavioral proxies for the same underlying construct (autonomic / nociceptive load exceeding regulatory capacity). The app already validates this proxy approach for the withdrawal pole; extending it to the edginess pole is the same model, not a new one.

### Frontend changes

Three insertion points. Behavioral anchors only, no numeric scales, no required fields, large tap targets.

**A1 — Morning check-in Step 2 (Right Now: Communication) — add a second block below communication level:**

```
"Right now — fuse / sensory tolerance"
[ Normal — usual patience ]
[ Edgy — quicker to react than usual ]
[ Sensory overload — sounds / light / touch grating ]
[ Snap-line — anything extra is too much ]

"Has anyone noticed you snapping or seeming on edge?"
[ Yes ]  [ No ]  [ No one around ]
```

- Same 4-level structure and color ramp as `communicationLevel` (good → accent → orange → danger).
- Optional. No required-field block on save.
- Data keys:
  - `irritabilityLevel` — values `normal | edgy | overload | snap_line`
  - `morningIrritabilityExternalObservation` — values `yes | no | no_one_around`

The external-observation prompt parallels the existing communication prompt ("Has anyone noticed you seem quiet or flat?"). Recall reliability is lower in the morning than the evening version (less observation time accumulated since waking) but still produces useful signal when answered, particularly for partner observations from yesterday-evening / pre-sleep state that carry forward.

**A2 — Episode log prodrome sensations — add a chip:**

`edgy / overstimulated`

Sits alongside the existing prodromal sensation chips. Captures the prodromal-irritability literature. Maps into the same `prodrome[]` array — no schema change beyond the new value. Label and storage value are intentionally short to fit the existing chip layout.

**A3 — Per-spasm log (per `PLAN_episode_phases.md`) — add a 4-option external-trigger field:**

```
"External trigger right before this spasm?"
[ none ]                  ← default, no tap needed if there was no trigger
[ emotional event ]       ← argument, frustrating event, distress
[ startle / sensory ]     ← loud noise, sudden touch, jump-scare
[ unsure ]
```

Data key: `externalTrigger`, values `none | emotional | startle | unsure`. Default is `none` — she only taps if there was a trigger, no forced attribution.

**Critical conceptual distinction (resolved 2026-04-17):** This field captures *external triggers* only — events that originated outside her body and immediately preceded a spasm. It does **not** capture pre-episode irritability that surfaces because the autonomic shift producing the spasm is also producing irritability (the "snappy at partner before realizing an episode was starting" pattern from 2026-04-13).

The two directions:
- **Pain/autonomic → irritability (prodrome).** Captured at episode level via `irritabilityLevel` (morning + evening), the A2 prodrome chip "edgy / overstimulated", and the existing prodrome timing fields. Episode-scoped because prodrome state doesn't oscillate between spasms within one episode.
- **External event → spasm (true trigger).** Captured per-spasm via `externalTrigger`. SPS literature treats emotional and startle/sensory triggers as distinct mechanisms (the "stimulus-sensitive" feature), so they're split.

Conflating these two directions would produce false-positive SPS-trigger data — a spasm logged as `externalTrigger: emotional` when in fact the irritability and the spasm were both downstream of the same underlying autonomic state would mislead the specialist about the role of external emotional triggering in her presentation. The four-option structure with `none` as default makes this conflation hard to commit by accident.

### What stays as-is — and what gets renamed

**Rename `cyclePhaseProxy.moodShift` → `cyclePhaseProxy.cycleRelatedDay`** with broadened label *"Overall: today feels cycle-related"* (Item 12 lock — the "Overall:" prefix disambiguates the meta-attribution toggle from the peer-positioned specific symptom toggles in the same section). Single toggle now covers all cycle-attributable symptoms (mood, fatigue, food cravings, etc.) rather than only mood/irritability. No structural UI restructure — if peer-positioning turns out to remain confusing after ship, Option B (visual restructure) is the fallback. The toggle still serves a different purpose from `irritabilityLevel`:

- `irritabilityLevel` — *"how irritable am I right now?"* — state snapshot
- `cycleRelatedDay` — *"do today's symptoms feel cycle-related?"* — attribution

Both feed the export. Backward-compatible read: legacy `moodShift: true` values are read as `cycleRelatedDay: true` for entries logged before the rename.

---

## Part B — Severity Mapping Framework

### Problem

The current export (`index.html:1447`–`1562`) writes a flat list of categorical values per axis. It declares no methodology. A specialist opening `isobar-report-2026-04-17.txt` sees:

```
EPISODES
─────────────
4/12/2026 14:32
  Communication: Brief only / yes-no or less
  Severity vs Arizona: Severe (Arizona far away)
  ...
MORNING CHECK-INS
─────────────
4/12/2026
  Communication: Quieter than usual
  Today: Scaled back
  ...
```

There is no header explaining:

- **What framework this is.** A multi-axis behavioral assessment? Patient-reported outcome? Free-form journal?
- **Why no 0–10 numeric pain scale appears.** A specialist trained on NRS will assume the omission is an oversight, not a deliberate methodology choice.
- **How the categorical axes map to scales they recognize.** "Brief only" means what — DisDAT 3? PROMIS T-score ~70? They have no way to compare this to a patient population.
- **Which axis is load-bearing.** The morning-check-in question text labels communication as the *"Primary severity indicator"* (`index.html:893`), but the export does not. A specialist scanning the report has no way to know `communicationLevel` is the lead severity signal and `severity` (vs Arizona) is a separate relative comparison.

The app currently has **five severity-shaped axes** all emitted side-by-side with no declared relationship between them:

| Axis | Where logged | Range | Currently declared as |
|---|---|---|---|
| `communicationLevel` | episode + check-in | normal / quieter / shortened / brief | "Primary severity indicator" (UI only, not export) |
| `severity` (vs Arizona) | episode | similar / somewhat / much_worse / far_away | "Severity vs Arizona" |
| `functionalToday` | check-in | good / ok / scaled_back / bad | "Today: …" |
| Per-spasm intensity | per-spasm log (planned, `PLAN_episode_phases.md`) | TWITCH / MILD / MODERATE / STRONG / SEVERE | Plan says "maps to clinical 3-tier + Penn PSFS in export" — not yet implemented |
| Body map + sensations | episode + check-in | locations + McGill-style descriptors | Free list |

This is not a small problem. It is the difference between a specialist treating the export as data versus treating it as a diary.

### The mapping question, made explicit

The user's design constraints (memory + `MEDICAL_PURPOSE.md`) are clear: **no 0–10 numeric pain scales.** The clinical justification is documented — alexithymia and interoceptive differences make NRS systematically underreport her actual state. This is correct and well-supported.

But "no 0–10" does not mean "no scale at all." It means "use scales appropriate for the patient." There are validated alternatives that do not require interoceptive translation:

| Scale family | What it is | Fit for Isobar |
|---|---|---|
| **NRS / VAS (0–10)** | Self-rated numeric | Rejected — the documented reason |
| **Verbal Rating Scale (VRS, 4-tier)** | none / mild / moderate / severe | Still requires interoceptive self-rating — partial fit |
| **DisDAT (Disability Distress Assessment Tool)** | Multi-axis behavioral observation: facial, vocal, body language, comfort signals | Strong fit — explicitly designed for non-self-report contexts including communication-impaired adults |
| **NCAPC (Non-Communicating Adult Pain Checklist)** | Behavioral observation: vocal / social / facial / activity / body / physiological | Strong fit — same design pattern as Isobar |
| **PROMIS profile (Pain Interference, Pain Behavior, Anger, Sleep Disturbance, Fatigue)** | T-scored short forms (mean 50, SD 10) | Strong fit for cross-population comparison; can be derived from existing Isobar axes with declared mapping |
| **ECOG Performance Status (0–4)** | Functional capacity (0=fully active … 4=bedridden) | `functionalToday` is already an ECOG-equivalent and could be declared as such |
| **Penn Spasm Frequency Scale (PSFS, 0–4)** | Spasm count + severity tier | Already specced for the spasm intensity export per `PLAN_episode_phases.md` |
| **McGill Pain Questionnaire — descriptor families** | Sensory / affective / evaluative descriptors (no number) | Already what `sensations` per region is doing implicitly |

**The honest framing:** Isobar is already implementing a **DisDAT/NCAPC-style multi-axis behavioral pain assessment, anchored to functional capacity rather than self-rated intensity, given autistic + alexithymic presentation.** It just is not telling the clinician that.

### Proposed model

Declare the assessment framework explicitly in the export header, and add per-axis cross-walks so the categorical values land in scales the specialist recognizes. **No composite single number** — the absence is intentional and defensible (and would create false precision if added).

**B1 — Export header preamble.** Replace the current 3-line header with a one-paragraph methodology statement + axis legend, e.g.:

```
ISOBAR SYMPTOM REPORT
Generated: 2026-04-17 14:32
─────────────────────────────────────────────

ASSESSMENT METHODOLOGY
This report uses behavioral / functional anchors rather than self-rated
numeric pain scales (NRS / VAS). Numeric self-report is rejected here
on documented clinical grounds: the patient has autistic alexithymia
and high pain tolerance that systematically suppress NRS values
relative to functional reality (see MEDICAL_PURPOSE.md §"Symptom
reporting is unreliable in clinical settings").

Severity is captured across multiple externally-observable axes,
each anchored to a recognized clinical scale. No composite score is
computed — integration is left to the reviewing clinician.

AXIS LEGEND (severity-bearing axes, daily and per-event)
  Communication capacity → DisDAT verbal/communication subscale
    normal / quieter / shortened / brief-only
  Fuse / sensory tolerance → DisDAT emotional + Sensory Profile axis
    normal / edgy / sensory-overload / snap-line
  Functional capacity today → ECOG Performance Status equivalent
    good (ECOG 0) / ok (1) / scaled-back (2) / bad (3–4)
  Severity vs personal baseline (Arizona) → relative reference
    similar / somewhat-worse / much-worse / far-away
  Spasm intensity → Penn Spasm Frequency Scale (PSFS)
    TWITCH (excluded from PSFS) / MILD (1) / MODERATE (2) /
    STRONG (3) / SEVERE (4)
  Pain location + sensation → McGill Pain Questionnaire descriptor
    families (sensory / affective), no intensity number

PERSONAL BASELINE REFERENCES
  Pre-onset (athletic ceiling): summers 2022–2023
    [populated from clinical timeline]
  Best-managed post-onset: Arizona spring 2026
    [populated from existing Arizona section]

```

**B2 — Per-axis labels in the body of the export.** Each axis line gets the standard-scale name in parentheses on first appearance per entry, e.g.:

```
4/12/2026 14:32
  Communication (DisDAT verbal): Brief only / yes-no
  Fuse / sensory (DisDAT emotional): Snap-line
  Severity vs baseline (relative): Far away from Arizona
  Spasm intensity (PSFS): MODERATE × 4 = PSFS grade 2
  ...
```

This costs ~12 characters per line and saves the clinician opening a manual.

**B3 — A "primary severity indicator" callout** at the top of each entry, since the UI already designates communication as primary. One line, before the axis details:

```
  Primary severity indicator: Brief-only communication (DisDAT lower bound)
```

**B4 — Explicitly NO composite score.** Document this in the header as a deliberate methodology choice. A composite would be false precision — the axes do not have a validated weighting scheme for this patient population, and producing a single number would defeat the multi-axis design.

**B5 — Irritability gets first-class export treatment, parallel to communication.** Whenever `communicationLevel` is printed, `irritabilityLevel` is printed immediately after. They are paired axes representing two polarities of the same construct, and the export should reflect that.

### Why this is overdue regardless of irritability

`TICK-007 Export consolidation` is already in the backlog (Wave 7). The current export was built feature-by-feature without a declared assessment framework. Even before adding `irritabilityLevel`, the existing five severity-shaped axes need a header and a cross-walk, or the report cannot do the job MEDICAL_PURPOSE.md §"diagnostic gap" claims it does. Part B should be folded into TICK-007's scope, with this plan as the spec.

---

## Part C — Evening Check-in

### Problem

The morning check-in captures wake-state baseline. Episode and spasm logs capture event-time data. Neither captures three things that are clinically load-bearing:

1. **Within-day trajectory.** A day starting bad and ending OK (the user's 2026-04-16 example: felt awful all morning → pressure lifted in afternoon → went to bed feeling relatively OK) is currently invisible. No event was triggered and the morning check-in was already complete by the time the recovery happened.
2. **Recovery as a measurable phenomenon.** Episode logs only fire on degradation. Recovery — particularly recovery tied to environmental change — has no logging surface.
3. **Daily depletion of the primary severity axes.** Communication and irritability are sampled once at wake. Whether the day depleted them, and by how much, is not captured.

### Reconciliation with the prior "no evening check-in" design decision

`PLAN_morning_checkin.md` Design Principle 4 explicitly rejected an evening check-in. The version rejected there was a **second full check-in** that re-asked baseline questions (sleep, body map, etc.) and violated "works when she is at her worst." The version specced here is structurally different:

- Scoped to delta and cost only — no re-asking baseline questions
- ~10–15 taps total, ~1 minute, all optional fields
- Soft prompt only (in-app surface after a configurable hour); no push notifications until ROADMAP §4 ships
- Skipping a day produces clean missing data; the composite handles this by computing over whatever days have data

This is additive, not blocking. The rationale that rejected the original evening check-in still stands — and is consistent with shipping this version.

### Form structure

```
EVENING CHECK-IN

1. How did today go from morning to now?
   [ Got better as the day went on ]
   [ Stayed about the same ]
   [ Got worse as the day went on ]
   [ Up and down — no clear direction ]

   If "better" or "worse": when did it shift?
   [ midday ]  [ afternoon ]  [ evening ]
   (auto-captures weather snapshot at the shift time)

2. Physical activity today
   [ None / mostly resting ]
   [ Light — short walks, light movement ]
   [ Moderate — sustained activity, planned exercise ]
   [ Strenuous — pushed harder than usual ]

   (optional) Type:    [ walk ] [ bike ] [ workout ] [ yoga ] [ housework ] [ other ]
   (optional) When:    [ morning ] [ midday ] [ afternoon ] [ evening ]
   (optional) Minutes: ___

3. Right now — communication
   [ Talking easily ] [ Quieter than usual ] [ Shorter responses ] [ Brief only ]

4. Right now — fuse / sensory tolerance
   [ Normal patience ] [ Edgy ] [ Sensory overload ] [ Snap-line ]

5. What did today cost across...
   Activities I planned:    [ all ] [ most ] [ some ] [ almost none ]
   Connection with people:  [ easy ] [ muted ] [ withdrew ] [ couldn't ]
   Things for fun:          [ had energy ] [ a little ] [ none ] [ avoided ]
   Sleep readiness now:     [ tired-good ] [ wiped ] [ wired ] [ overwhelmed ]

6. Did anyone today comment on you seeming quiet, snappy, or off?
   [ Yes ] [ No ] [ No one around ]

7. Anything to note...
   [ text input, optional ]
```

Snapshot questions (3, 4) come before retrospective questions (5, 6) so current state is captured before the harder cognitive task of summarizing the day.

### Post-critical-review form additions (2026-04-17)

The form structure above is the **pre-refold v1 blueprint.** The critical-review walkthrough locked significant additions that will extend the form for the final Stage 1 ticket. Full specs live in the Critical Review Walkthrough section; this is a summary of what the final form will include:

**From Item 11 — multi-shift trajectory capture:**
- Question 1's `trajectoryShiftTime` becomes an expanded section when user selects `up_down`. Up to 3 shift timestamps with direction (better/worse), all optional. Single-trajectory days unchanged.

**From Item 6 + Item 10 — behavioral-anchor fields (new EOD fields):**
- **Social/irritability behavioral anchors** (locked in Item 3; expanded in Item 6): "snapped at someone today Y/N," "withdrew from planned contact Y/N," +1–2 TBD.
- **Cognition behavioral-anchor Y/N list** (morning + evening paired): ~3 candidates from ["lost track mid-sentence," "had to re-read to understand," "couldn't find a word"] — final list TBD at Stage 1 ticket design.
- **Fatigue behavioral anchors** (EOD): "napped today Y/N," "went to bed earlier than planned Y/N."
- **Pain behavioral anchors** (EOD, supplementing the Likert): "avoided a specific movement Y/N," "took unscheduled medication Y/N."

**From Item 10 — three load-type anchor sets (new EOD sections):**

- **Cognitive load — 8 items, 4 core, weighted** (fully specced, see walkthrough). Items include: sustained critical thinking >2h, masking hybrid >1h/>2h, high-sensory >4h, emotional regulation composure >30min, communication production, EF+logistics work, anticipatory/managerial load.
- **Social load** — framework locked (Framing A, 6–8 items, 4 core, weighted); items TBD during Stage 1 ticket design using same walkthrough method.
- **Emotional load** — framework locked; items TBD.

**From Item 7 — `painEpisodePeak` write-time denormalization:**
- When an episode is saved, its peak-pain value is also written to the day's EOD record field `painEpisodePeak`. No direct EOD form question; automatic on episode save.

**From Item 6 — `functionalToday` is now validation-only:**
- The `functionalToday` field retained on EOD form for daily self-awareness AND as the ground-truth validation signal, but is NOT a composite input.

**Cost impact on form time:**
- Base form ~1–2 min → extended form ~3–5 min with all additions (validated as acceptable during walkthrough Item 8 capacity discussion).
- Core/extended nesting (4 core items per load type always answered; extended items skippable on hard symptom days) preserves partial-completion utility.

### Schema

New entry type: `evening_checkin` (parallel to existing `checkin` and `episode` types — separate type chosen over a `period` field on `checkin` because nearly every analytical query needs to filter morning vs evening explicitly).

Fields:

| Field | Type | Values |
|---|---|---|
| `dayTrajectory` | string | `better \| same \| worse \| up_down` |
| `trajectoryShiftTime` | string \| null | `midday \| afternoon \| evening` (only when trajectory is better/worse) |
| `activityLevel` | string | `none \| light \| moderate \| strenuous` |
| `activityType` | string[] | subset of `[walk, bike, workout, yoga, housework, other]` |
| `activityWhen` | string[] | subset of `[morning, midday, afternoon, evening]` |
| `activityMinutes` | number \| null | optional duration |
| `eveningCommunicationLevel` | string | `normal \| quieter \| shortened \| brief` |
| `eveningIrritabilityLevel` | string | `normal \| edgy \| overload \| snap_line` |
| `costActivities` | string | `all \| most \| some \| almost_none` |
| `costConnection` | string | `easy \| muted \| withdrew \| couldnt` |
| `costFun` | string | `had_energy \| a_little \| none \| avoided` |
| `costSleepReadiness` | string | `tired_good \| wiped \| wired \| overwhelmed` |
| `eveningExternalObservation` | string | `yes \| no \| no_one_around` |
| `eveningNotes` | string | optional |
| `eveningWeather` | object | auto-captured snapshot: `{ pressure, trend, currentTemp, tempTrend }` |
| `timestamp` | string | ISO at submit |
| `type` | string | `'evening_checkin'` |

All fields optional (no required-field block on save). Day-trajectory has the highest skip cost analytically — flag in UI as "the most useful single answer here" but never block save.

### Soft prompt

Appears on the home screen as a card after the configured evening hour (default `8pm`, configurable in settings). Card text: "Evening check-in (optional, ~1 min)". Dismissible. Re-appears next evening regardless of dismissal status that day. No notification, no badge, no nag.

If she opens the app after the evening hour and has not logged today's evening check-in, the card sits above the existing home cards. If she has logged, the card disappears for the day.

### Recall-bias mitigation

The evening external-observation prompt has more recall ambiguity than the morning version (whole day vs. immediately-recent overnight). Phrasing is intentionally specific ("comment on you seeming quiet, snappy, or off?") rather than abstract ("how did social interactions go?") — concrete behavioral memories are more reliably retrieved than abstract impressions.

The activity-when chips are multi-select rather than single-select for the same reason: easier to recall "I walked in the morning and did housework in the afternoon" than to pick one bucket.

---

## Part D — Derived Interference Index

### What it is

A multi-axis composite derived from morning + evening Isobar data without requiring a PROMIS administration for scoring. It is **not** a PROMIS T-score — PROMIS population norming (thousands of calibration subjects) cannot be substituted by single-subject data regardless of administration count.

**Canonical name throughout UI, export, and methodology doc:** *"Derived Interference Index"* — NEVER "PROMIS-comparable T" or similar phrasing that implies population-normed equivalence (Item 9 lock).

**PROMIS administrations happen monthly** (Item 4 lock) accumulating toward N≥10 — these are a *single-subject reference point*, not a validation anchor. Export disclaimers describe what the N threshold does and does not prove.

### Likert conversion table per axis

Each Isobar axis (4-tier) → 5-point Likert. Direct ordinal mapping with the missing middle preserved (no "3 = Somewhat" — the 4-tier is built around functional thresholds, not a continuous scale):

| Axis | 1 | 2 | 4 | 5 |
|---|---|---|---|---|
| `functionalToday` | good | ok | scaled_back | bad |
| `communicationLevel` (morning + evening) | normal | quieter | shortened | brief |
| `irritabilityLevel` (morning + evening) | normal | edgy | overload | snap_line |
| `sleep` quality | restorative | somewhat | poor | RLS_bad |
| `costActivities` | all | most | some | almost_none |
| `costConnection` | easy | muted | withdrew | couldnt |
| `costFun` | had_energy | a_little | none | avoided |
| `costSleepReadiness` | tired_good | wiped | wired | overwhelmed |

Missing values for any axis on any day → that axis excluded from that day's item computation; remaining weights renormalized.

### Composite architecture (post-critical-review refold)

**Structural principles locked during the 2026-04-17 critical-review walkthrough (Items 6 + 7):**

- **`functionalToday` is NOT a composite input.** It is the **validation ground truth** — the composite is a multi-axis *prediction* of daily interference, validated by tracking how well it correlates with the user's own `functionalToday` self-rating over time.
- **All aggregation goes through a declarative `axisConfig` dispatcher** — no hardcoded per-axis formulas. Three aggregation strategies: `peakOfPaired` (4 axes), `trajectory` (fatigue), `single` (sleep + cost fields).
- **Write-time denormalization for episode-peak pain** — `painEpisodePeak` written to the day's EOD record at episode save time, so daily aggregation reads 3 sibling fields (morning, evening, episode peak) without cross-entity joins.
- **Alexithymia-aware substitutions (Items 3 + 6):** cognition axis uses behavioral-anchor Y/N counts (morning + evening) not self-rated Likerts; social/emotional get EOD behavioral anchors; `irritabilityLevel` demoted from primary driver to secondary contributor.

### `axisConfig` dispatcher

Single source of truth for composite structure. Each axis declares its aggregation strategy and inputs. Composite engine dispatches to one of three strategy functions.

```js
axisConfig = {
  version: "2.0.0",  // see Versioning section

  pain:       { agg: 'peakOfPaired', inputs: ['painMorning', 'painEvening', 'painEpisodePeak'], weight: 0.15 },
  cognition:  { agg: 'peakOfPaired', inputs: ['cogAnchorMorning', 'cogAnchorEvening'],          weight: 0.15 },
  comm:       { agg: 'peakOfPaired', inputs: ['commMorning', 'commEvening'],                    weight: 0.10 },
  irrit:      { agg: 'peakOfPaired', inputs: ['irritMorning', 'irritEvening'],                  weight: 0.05 },  // demoted per Item 3
  fatigue:    { agg: 'trajectory',   inputs: ['fatigueMorning', 'fatigueEvening', 'dayTrajectory'], weight: 0.10 },
  sleep:      { agg: 'single',       inputs: ['sleepLastNight'],                                weight: 0.05 },

  costActivities:      { agg: 'single', inputs: ['costActivities'],      weight: 0.15 },
  costConnection:      { agg: 'single', inputs: ['costConnection'],      weight: 0.05 },
  costFun:             { agg: 'single', inputs: ['costFun'],             weight: 0.05 },
  costSleepReadiness:  { agg: 'single', inputs: ['costSleepReadiness'],  weight: 0.05 },

  behavioralAnchorsSocial:    { agg: 'single', inputs: ['eodSocialBehavioralCount'],    weight: 0.05 },
  behavioralAnchorsEmotional: { agg: 'single', inputs: ['eodEmotionalBehavioralCount'], weight: 0.05 },

  // Validation signal (NOT in composite — ground truth only)
  _validation_functionalToday: { agg: 'none', role: 'validation_only', inputs: ['functionalToday'] },
}
// Weights sum to 1.00 across composite-contributing axes (all axes except _validation_*).
// Weights are v1 judgment values — refinable post-launch via variance-dominance analysis.
```

**Strategy functions:**

- **`peakOfPaired(inputs)` — returns `max(inputs)`** (after Likert-scale normalization or anchor-count normalization per axis). Matches PROMIS peak-interference construct; aligns with peak-severity recall bias (Item 7).
- **`trajectory(inputs)` — for fatigue only.** Combines morning/evening Likert with `dayTrajectory` descriptor to produce a trajectory-shape score (not a max). Aggregator TBD at Stage 1 implementation — max is a bad aggregator for fatigue (expected evening fatigue after a full day ≠ interference).
- **`single(inputs)` — returns the single input value** (after normalization). For sleep, cost fields, and EOD behavioral-anchor counts.

### Composite computation per day

1. For each axis in `axisConfig`, dispatch to the axis's `agg` function with its `inputs`. Result is a normalized [0, 1] per-axis score.
2. Weighted sum across axes → daily raw composite (range [0, 1]).
3. If any axis's inputs are all missing, drop that axis and renormalize remaining weights (same as pre-refold behavior).
4. The resulting daily raw composite converts to T per the Raw-to-T conversion section.

### Validation against `functionalToday` (new — Item 6)

- `functionalToday` is captured on EOD form but is NOT an input to the composite.
- Export includes a weekly **concordance metric**: rolling 7-day correlation between composite rank and `functionalToday` rank.
- Persistent divergence (correlation < 0.5 over 4+ weeks) flags a spec problem — either weights are miscalibrated, inputs are wrong, or the multi-axis model doesn't match how the user actually experiences her days.
- This validation framing is the primary interpretability story for the composite, not just "what's today's T."

### Weight rationale (v1 — refinable post-launch)

- **`costActivities` gets the largest single weight (0.15)** — retrospective behavioral evidence of interference. Along with `pain` and `cognition` it forms the composite's primary backbone.
- **`pain` and `cognition` get 0.15 each** — both have `peakOfPaired` aggregation including episode data (pain) or behavioral-anchor counts (cognition), so their axis score already incorporates the day's worst state.
- **`comm` and `fatigue` get 0.10 each** — meaningful contributors but not primary drivers.
- **`irritabilityLevel` demoted to 0.05** — Item 3 decision; self-rated emotion items have known reliability limits for this user profile.
- **Cost fields beyond `costActivities` get 0.05 each** — fine-grained domain impairment signals.
- **Sleep gets 0.05** — important context but not primary interference signal.
- **Behavioral-anchor social/emotional counts get 0.05 each** — contributions from Item 10 load tracking that belong in the composite (as opposed to PEM correlation inputs).

**All weights are v1.** Post-launch variance-dominance analysis (re-run during the fold-back from Item 6) confirms no single axis >40% of variance before Stage 1 ships.

### Aggregation across windows

Daily raw composite scores (computed per Part D "Composite computation per day" above) are aggregated across rolling windows:

1. For each day in the window with sufficient data, compute the daily raw composite via the axisConfig dispatcher.
2. Mean the daily raw scores across the window (skip days with no data).
3. Apply **cold-start thresholds (Item 15 lock):**
   - **UI display:** minimum 4 days in window to render a numeric value; below threshold, show *"Derived Interference Index pending — accumulating baseline data (X of 4 minimum days logged)"*.
   - **Clinical export:** minimum 7 days in window to publish a value; below threshold, export shows *"Derived Interference Index pending — accumulating baseline data (X of 7 minimum days logged)"* and omits the numeric score.

**Trend windows:** Compute the composite at 7-day, 14-day, and 30-day windows when data is available. Show in export as a small table:

```
   7-day:  0.68 [90% CI: 0.59–0.76]  (window: 2026-04-11 to 2026-04-17)
  14-day:  0.65 [90% CI: 0.57–0.73]  (window: 2026-04-04 to 2026-04-17)
  30-day:  0.64 [90% CI: 0.58–0.70]  (window: 2026-03-19 to 2026-04-17)
```

90% CI comes from the Monte Carlo sensitivity envelope (see Sensitivity analysis below). Direction of change across windows is the primary interpretability signal.

**Concordance with `functionalToday` (Item 6 validation signal):** every export window also reports the rolling correlation between the composite rank and `functionalToday` rank — see Part D "Validation against functionalToday" above.

### Raw-to-T conversion (preserved for reference contexts only, NOT the headline metric)

Because the composite is **not** population-normed, T-score conversion is published only as a **single-subject reference** when N≥10 PROMIS administrations have accumulated. Below that threshold, the composite is reported as a raw [0, 1] score with no T equivalent.

**N-threshold display rules (Item 4 + Item 9):**
- N < 4 PROMIS administrations: validation-status label is `preliminary`; T conversion is not shown.
- 4 ≤ N < 10: label is `accumulating`; T is not shown in export, but internal calibration diagnostics are maintained.
- N ≥ 10: label is `single-subject reference`; T conversion can be shown in export alongside the disclosure block from Item 9, and always accompanied by the explicit "NOT population-normed PROMIS T" label.

The PROMIS Pain Interference conversion table is retained in code as a reference for computing the single-subject T when the N threshold is met.

### Personal-baseline delta

Computed alongside the standard composite to give clinically actionable trend information. **Source: user-specified only.** Auto-derive rejected (2026-04-17) — early logging would misrepresent peak baseline state.

**Two baseline periods, DIFFERENT collection methods (Item 8 lock):**

1. **Arizona spring 2026 — direct self-rating.** Wizard asks the user to select the most-typical value per axis via Likert rating. Period is recent; recall is tractable. Export label: *"Arizona 2026 baseline — direct self-rating."*
2. **Summers 2022/23 — behavioral-anchor recall.** Wizard asks **observable event/capability questions** instead of Likert state ratings. Answers convert to approximate Likert values via a documented mapping table. Export label: *"Summers 2022/23 baseline — anchor-derived estimate (retrospective reconstruction)."*

**Rationale for split methodology:** The Items 3 + 6 alexithymia-aware principle extends to retrospective data collection — behavioral/capability recall over 3–4 years is reliable; emotional/cognitive state recall is not. User capacity is not the bottleneck (user confirmed 2026-04-17 she'll do extended work if it yields better data); reliability is.

**Computation:**
1. Baseline raw composite per period is computed using the same axisConfig dispatcher as daily scores.
2. Personal-baseline delta = current-window raw composite − baseline raw composite (per period).
3. Export defaults to the **Summers 2022/23 anchor-derived baseline** as the reference (more clinically meaningful — pre-onset comparison), with Arizona 2026 available as a toggle.
4. Output framing: *"+0.18 from Summers 2022/23 anchor-derived baseline"*.

**Pre-configuration state:** Until baseline wizards are completed, personal-baseline delta is not published. Main composite still publishes regardless.

### Settings — Personal Baseline Values wizards

Two separate wizards in a single settings section.

**Wizard 1 — Arizona spring 2026 (direct self-rating):**
- Per-axis Likert rating form. Axis list matches the current `axisConfig` contributing axes (excludes `_validation_functionalToday`), but includes behavioral-anchor Y/N counts as separate "typical-count" selections (e.g., "On a typical Arizona 2026 day, how many of these cognitive-anchor behaviors were active? 0/1/2/3/4+").
- Each axis defaults to "skip — don't have a baseline value here." Skipped axes drop from composite for that baseline period; weights renormalize.
- Wizard is resumable; partial configuration persists; revisable anytime.

**Wizard 2 — Summers 2022/23 (anchor-derived recall):**
- Does NOT ask state/emotion Likerts. Instead asks observable/capability recall questions. Candidates (final list + conversion table TBD during Stage 1 ticket design):
  - "Could you regularly walk 2 miles without planning around symptoms?" (yes / sometimes / rarely / no)
  - "Did you regularly cancel plans because of symptoms?" (never / sometimes / often / most weeks)
  - "Did you use medication daily / weekly / rarely / never?"
  - "Did people notice you were struggling?" (never / occasionally / often)
  - "Could you work a full day without mid-day collapse?" (routinely / often / rarely / never)
- Anchor answers convert to approximate Likert values per a documented mapping table (visible in `MEDICAL_PURPOSE.md`).

**Storage:**
```
settings.personalBaseline.arizona2026     = { axisKey: categoricalValue | null, ... }
settings.personalBaseline.summers2022_23  = { anchorKey: anchorAnswer | null, ... }
settings.personalBaseline.summers2022_23_derivedLikerts = { axisKey: derivedLikert | null, ... }  // computed cache
```

**`MEDICAL_PURPOSE.md` must document (Item 8):**
- Rationale for direct-vs-anchor split between periods.
- Full anchor→Likert conversion table (transparent; no hidden heuristics).
- Retrospective-reliability literature citations.
- That anchor-derived baseline has known lower precision than direct — treat as directional, not quantitative.

### Sensitivity analysis (Item 5 lock)

Two complementary analyses run per export window:

**1. One-at-a-time weight perturbation (interpretability view):**
- For each axis in `axisConfig`, nudge its weight ±10% with others held fixed; recompute daily composites across the window.
- Report the single-axis perturbation that moves the window composite most and by how much.
- Output example: *"Composite most sensitive to `costActivities` weight: ±10% weight → ±0.06 shift. Least sensitive to `sleep`: ±10% weight → ±0.004 shift."*
- Answers "which axis dominates this window."

**2. Monte Carlo joint perturbation (uncertainty envelope):**
- Define a plausible ±15% range around every weight simultaneously. (Per-axis ranges may be narrower/wider — TBD at Stage 1 ticket design; default ±15% for v1.)
- Sample ~10,000 whole weight-combinations from those ranges.
- Recompute the composite for every day under every sample.
- Report the **90% interval** for each day's composite, and for the window mean.
- Export format: `composite: 0.62 [90% CI: 0.54–0.71]`.
- Answers "how confident can we be in the ranking/magnitude of this score."

**Tier-ambiguous flagging:**
- If any day's 90% CI crosses a severity-tier boundary, that day is flagged `tier-ambiguous` in the export.
- Helps clinicians distinguish clearly-severe days from borderline-bad days.

**Likert-mapping perturbation DEFERRED (Item 5 locked as B, not D):**
- Mapping function choice (linear / stepped / sqrt) is treated as fixed for v1.
- Post-launch, if a clinician raises the linear-mapping assumption, Mapping perturbation can be added as a secondary analysis.

### Episode handling

Reported alongside the T-score, never baked into the composite. Episodes are too heterogeneous to slot into a single PROMIS item without distortion (one severe episode looks the same as one mild episode in the count, but they're very different functional events).

Export block:

```
Episodes in window:  2
  2026-04-13  duration 95min  intensity moderate  cane: yes
  2026-04-15  duration 35min  intensity mild      cane: no
```

### Versioning (Item 13 lock)

**Semver classification on `axisConfig.version`:**
- **MAJOR** — axis added/removed, aggregation strategy changed for an axis (`peakOfPaired` → `trajectory`), core/extended nesting restructured. Historical values not directly comparable to current values.
- **MINOR** — weight changes, Likert-to-normalized mapping shifts, PROMIS conversion updates, anchor threshold tweaks. Values shift in magnitude but schema stable.
- **PATCH** — bug fixes, calculation errors, typos, documentation-only changes. No intended change in composite values.

**Artifacts:**
- `axisConfig` object contains a `version: "MAJOR.MINOR.PATCH"` field.
- Config-object JSON hash = composite-version fingerprint.
- `docs/COMPOSITE_VERSIONS.md` maintains a changelog entry per bump, explaining what changed and why.

**Per-window dual-view export (Option D — new in critical-review refold):**

Every export window is renderable in two modes:

| Mode | What it shows | When to use |
|---|---|---|
| `original` | Composite values as computed at time of logging, using the `axisConfig` version in effect that day. | Provenance-preserving view; default. |
| `recomputed_to_current` | Stored raw inputs re-run through the *current* `axisConfig`. | Analytical view — what current math says about historical data. Useful for comparing periods across a version boundary. |

**Storage requirements:** raw inputs stored permanently (assured via Dexie.js from Items 1+2); historical `axisConfig` versions retained in app bundle or IndexedDB so any version can be replayed.

**Export labeling (non-negotiable):**
- Header includes `view_mode: original` OR `view_mode: recomputed_to_current`.
- When `recomputed_to_current`, header also lists original version range in window: `original_versions_in_window: [2.1.0, 2.2.0, 2.3.0]`.
- UI export preview offers a mode toggle; default is `original`.

**Stage provenance (Item 16 lock):**
- Header declares current stage: `stage: "Stage 3"` + human-readable `stage_description: "Part A + Part B composite + Part C evening check-in"`.
- Mixed-stage-window detection: if window spans a stage boundary, header adds `window_spans_stages: [2, 3]`, `composite_may_be_discontinuous: true`, `stage_boundary_dates_in_window: [...]`.
- UI banner when viewing historical data spanning a boundary: *"methodology updated on [date] — pre-update values computed differently; see details."*

### PROMIS calibration protocol (Item 4 lock)

Not a validation — a single-subject reference that accumulates over time. Never substitutes for PROMIS population norming.

**Launch protocol:**
- Administer PROMIS Pain Interference Short Form 6a **twice at Stage 1**: once at baseline, once at ~4 weeks. Serves as a preliminary sanity check — catches gross miscalibration before 6 months of data pile up.

**Ongoing protocol:**
- Monthly administrations thereafter, accumulating toward N≥10 over ~10 months.
- Each administration:
  1. Note the 7-day window ending on the administration date.
  2. Compare administered T to derived composite (mapped via single-subject reference table once N≥10).
  3. Log agreement delta in `docs/COMPOSITE_VERSIONS.md` calibration-diagnostics appendix.

**N-threshold rules (from Raw-to-T conversion section above):**
- N < 4: `preliminary` — T not shown in export.
- 4 ≤ N < 10: `accumulating` — T not shown, internal diagnostics only.
- N ≥ 10: `single-subject reference` — T can appear in export with the Item 9 disclosure block, always labeled "NOT population-normed PROMIS T."

**Not v1 blocking** — composite ships and is usable (as raw [0,1] + personal-baseline delta) without any PROMIS administrations. But the calibration diagnostics begin at Stage 1.

---

## Part E — Final Export Format & Methodology Header

### Header preamble (replaces current 3-line header)

```
ISOBAR SYMPTOM REPORT
Generated: 2026-04-17 14:32
Patient: [name]                          Composite version: v1.0
─────────────────────────────────────────────────────────────────

ASSESSMENT METHODOLOGY

This report uses behavioral / functional anchors rather than self-rated
numeric pain scales (NRS / VAS). Numeric self-report is rejected here
on documented clinical grounds: the patient has autistic alexithymia
and high pain tolerance that systematically suppress NRS values
relative to functional reality (see MEDICAL_PURPOSE.md
§"Symptom reporting is unreliable in clinical settings").

Severity is captured across multiple externally-observable axes,
each anchored to a recognized clinical scale from the behavioral
pain assessment family (DisDAT, NCAPC) adapted for autistic
alexithymic adults — patients who can self-report verbally but for
whom numeric self-rating is documented to systematically underreport
relative to functional reality. No single composite is treated as
definitive — a Derived Interference Index is provided for
multi-axis trend interpretation, paired with personal-baseline-relative
scoring. NOT a PROMIS T-score — population norming cannot be substituted
by single-subject data regardless of administration count.

AXIS LEGEND
  Communication capacity (morning + evening snapshot)
    → DisDAT verbal/communication subscale (adapted)
    normal / quieter / shortened / brief-only

  Fuse / sensory tolerance (morning + evening snapshot)
    → DisDAT emotional subscale + Sensory Profile axis (adapted)
    normal / edgy / sensory-overload / snap-line

  Functional capacity (today, daily)
    → ECOG Performance Status equivalent
    good (ECOG 0) / ok (1) / scaled-back (2) / bad (3–4)

  Severity vs personal baseline (per-episode)
    → relative reference, anchored to Arizona spring 2026 floor
    similar / somewhat-worse / much-worse / far-away

  Spasm intensity (per-spasm, episode log)
    → Penn Spasm Frequency Scale (PSFS) for count aggregation
    TWITCH (excluded from PSFS) / MILD (1) / MODERATE (2) /
    STRONG (3) / SEVERE (4)

  Pain location + sensation (per-region, descriptive)
    → McGill Pain Questionnaire descriptor families
    sensory + affective descriptors, no intensity number

  Within-day trajectory (evening check-in)
    → daily course indicator, pairs with environmental snapshots
    better / same / worse / up-and-down

  Physical activity (evening check-in)
    → exertion input variable, supports PEM correlation
    none / light / moderate / strenuous, with optional type/timing

  Daily interference cost (evening check-in)
    → per-domain retrospective, feeds Derived Interference Index
    activities / connection / fun / sleep-readiness

PERSONAL BASELINE REFERENCES
  Pre-onset (athletic ceiling): summers 2022–2023
    Mountain biking 1–2h daily, competitive racing, no PEM, no episodes
  Best-managed post-onset:      Arizona spring 2026
    4-week period of dramatically reduced symptom burden,
    3 breakthrough events with identifiable environmental triggers
    (NOT a clean baseline — see methodology for distinction)

DERIVED INTERFERENCE INDEX  (NOT PROMIS T)
  Multi-axis composite, single-subject calibration.
  PROMIS administrations to date:  N = 3   [accumulating]
  Validation status:  accumulating (4 ≤ N < 10 for single-subject reference)
  axisConfig version: 2.0.0   hash: 8f3a9c2e
  view_mode: original
  stage: Stage 3  ("Part A + Part B composite + Part C evening check-in")

  Window: 7 days ending 2026-04-17
    Composite (raw):         0.62    [90% CI: 0.54–0.71]
    Personal-baseline delta: +0.18   vs Summers 2022/23 baseline (anchor-derived)
    functionalToday concordance (validation): r = 0.73 (rolling 14-day)
    Trend (raw composite):   7-day 0.62   14-day 0.58   30-day 0.55
    Weight sensitivity (one-at-a-time ±10%): most sensitive to costActivities
    (±0.06 shift); least sensitive to sleep (±0.004 shift).

  Component data (this window):
    Functional today:          good 0  ok 1  scaled-back 4  bad 2
    Comm (morning):            normal 2  quieter 3  shortened 2  brief 0
    Comm (evening):            normal 1  quieter 2  shortened 3  brief 1
    Fuse (morning):            normal 1  edgy 4  overload 2  snap-line 0
    Fuse (evening):            normal 0  edgy 3  overload 3  snap-line 1
    Sleep quality:             restorative 1  somewhat 3  poor 2  RLS-bad 1
    Day trajectory:            better 1  same 2  worse 3  up-down 1
    Activity level:            none 2  light 3  moderate 2  strenuous 0
    Cost (activities):         all 0  most 2  some 4  almost-none 1
    Cost (connection):         easy 1  muted 2  withdrew 3  couldn't 1
    Cost (fun):                had-energy 0  a-little 2  none 4  avoided 1
    Cost (sleep readiness):    tired-good 0  wiped 3  wired 3  overwhelmed 1
    Episodes in window:        2

  Episodes (this window):
    2026-04-13  duration 95min   moderate  cane: yes  pressure: 1003 hPa
    2026-04-15  duration 35min   mild      cane: no   pressure: 1011 hPa
─────────────────────────────────────────────────────────────────
```

The header is verbose by design. A specialist scanning the export gets the methodology, the axis legend, the framework names, the baseline references, and the derived index — all in the first screen — without opening a second document.

### Per-entry export format

Each entry (episode, morning check-in, evening check-in) gets a per-axis label tagged with its standard scale on first appearance per entry:

**Episode entry:**

```
EPISODE — 2026-04-13 14:32
  Severity vs baseline (relative):       Far away from Arizona
  Communication (DisDAT verbal):         Brief only / yes-no
  Spasm count + intensity (PSFS):        4 spasms; PSFS grade 2
  Pain locations + sensations (McGill):  right leg (burning, electric),
                                         lower back (pressure, aching)
  Prodrome:                              right leg, energy in legs,
                                         left facial tingling
  Limbs affected:                        right leg, left arm
  Cane required:                         yes
  Weather:                               1003 hPa (Δ-3 over 6h),
                                         62°F (Δ-8°F over 5h)
  Pressure dwell:                        18h of 48 below peak-5
  Exposures:                             dog exposure, fasted 7h
  Notes:                                 …
```

**Morning check-in entry:**

```
MORNING CHECK-IN — 2026-04-13
  Sleep quality:                         Poor
  Sleep:                                 bed 23:45, woke 07:20, 3 awakenings
  Overnight:                             muscle twitching, woke in pain
  Morning stiffness:                     15–60 min
  Communication (DisDAT verbal):         Quieter than usual
  Fuse / sensory (DisDAT emotional):     Edgy
  Pain locations:                        right leg, lower back
  Functional today (ECOG-equiv):         Scaled back (ECOG 2)
  Cycle proxies:                         mood/irritability shift, breast tenderness
  Notes:                                 …
```

**Evening check-in entry:**

```
EVENING CHECK-IN — 2026-04-13
  Day trajectory:                        Got worse as the day went on
  Trajectory shift time:                 afternoon
  Activity:                              Moderate; bike + housework;
                                         60 min; morning + afternoon
  Communication (DisDAT verbal):         Brief only
    Δ from morning:                      −2 (quieter → brief)
  Fuse / sensory (DisDAT emotional):     Snap-line
    Δ from morning:                      −2 (edgy → snap-line)
  Cost (activities):                     some
  Cost (connection):                     withdrew
  Cost (fun):                            avoided
  Cost (sleep readiness):                overwhelmed
  External observation today:            Yes (commented as snappy / off)
  Weather (evening snapshot):            998 hPa (Δ-5 from morning 1003),
                                         58°F (Δ-4°F from morning 62°F)
  Notes:                                 …
```

### Daily summary block (new — appears once per day at the top of that day's entries)

```
═══ DAY: 2026-04-13 ═══
  Morning state:        Quieter, Edgy, Scaled-back day, Stiff <60min
  Evening state:        Brief-only, Snap-line, day trajectory: worse
  Daily depletion:      communication −2, irritability −2 (significant)
  Activity:             Moderate (bike + housework, 60 min)
  Episodes today:       1 (severe, 95 min, cane required)
  Pressure delta:       −5 hPa morning to evening
  External observation: Yes (snappy / off)
```

This block lets a specialist see the whole day in 7 lines before drilling into entries.

### Methodology doc cross-references

Export header points to:

- `MEDICAL_PURPOSE.md §"Severity Assessment Framework"` (new section to be added under TICK-008 or a new ticket — declares DisDAT/NCAPC/ECOG/PSFS/McGill cross-walk as the methodology)
- `MEDICAL_PURPOSE.md §Derived Indices` (new section — formula spec for the Derived Functional Interference Index, raw-to-T table source, sensitivity analysis methodology, calibration administration agreement statistics)
- `MEDICAL_PURPOSE.md §Personal Baseline References` (existing Arizona / summer 2022–23 framing — link from the header)

---

## Open questions — all resolved (2026-04-17)

**Round 1 (initial design):**

- ~~Wording of irritability options~~ → `normal / edgy / overload / snap_line`
- ~~Methodology header verbosity~~ → verbose, by design (see Part E)
- ~~Evening check-in — include or not~~ → include, scoped form (Part C)
- ~~Activity-type chip list~~ → `walk / bike / workout / yoga / housework / other`
- ~~Evening external-observation prompt~~ → include
- ~~Composite naming~~ → conservative ("Derived Functional Interference Index, PROMIS-comparable T-units")
- ~~Composite weights v1~~ → a priori weights per Part D, with sensitivity analysis published

**Round 2 (open-questions walk-through):**

- ~~Morning irritability external-observation prompt~~ → **include** ("Has anyone noticed you snapping or seeming on edge?"). Field: `morningIrritabilityExternalObservation`.
- ~~Per-spasm trigger field — single bit vs typed?~~ → **4-option restructure** (`none | emotional | startle | unsure`, default `none`). Resolved by user observation that prodrome irritability and external trigger are decidedly different things; conflating them would produce false-positive SPS-trigger data. Prodrome direction stays at episode level; external-trigger direction stays per-spasm with explicit options.
- ~~DisDAT/NCAPC framing~~ → cite as **"behavioral pain assessment family (DisDAT, NCAPC) adapted for autistic alexithymic adults"** with explicit adaptation language to prevent specialist misreading.
- ~~Cycle-phase `moodShift` toggle~~ → **rename** to `cycleRelatedDay`, broaden label to *"Today feels cycle-related"* covering all cycle-attributable symptoms. Backward-compatible read of legacy values.
- ~~Personal baseline T source~~ → **user-specified only.** One-time settings wizard configures 8 axes × 2 baseline periods. Auto-derive from logged data rejected (early logging too likely to misrepresent peak baseline state).
- ~~PROMIS calibration administration~~ → **yes**, schedule two administrations ~2 weeks after Stage 4 ships, on different state-days (one moderate, one bad). Agreement statistic published in `MEDICAL_PURPOSE.md §Derived Indices`.
- ~~Soft-prompt timing for evening check-in~~ → **8pm default**, configurable in settings.

No remaining open items. Plan is build-ready.

---

## Integration with existing plans

- **`PLAN_episode_phases.md`** — A2 (prodrome chip `edgy / overstimulated`) and A3 (per-spasm `emotionalTrigger` toggle) attach cleanly to the per-spasm and prodrome data structures already specced. Add to that plan's chip list and per-spasm record fields. Does not block the episode-phase ticket from shipping first; can be added as an amendment.
- **`PLAN_morning_checkin.md`** — A1 (morning irritability block) inserts into Step 2. The morning check-in restructure is already shipped (TICK-005), so this is a follow-up modification, not a redesign. One additional 4-button block in an existing step.
- **`PLAN_trigger_surface_expansion.md`** — Part C activity capture overlaps the `prolonged_stillness` exposure chip (negative-direction activity proxy) but does not conflict; activity logging is the positive-direction complement. No changes needed to that plan.
- **`PLAN_environmental_risk.md`** — Part C's morning + evening weather snapshots feed an enhanced within-day pressure correlation analysis (recovery-when-pressure-rises pattern). The environmental risk engine remains unchanged; new derived analytics build on top.
- **`TICK-007 Export consolidation`** — Parts B and E in full belong here. This plan is the spec; the ticket implements it.
- **`MEDICAL_PURPOSE.md`** — needs three new sections (under TICK-008 or a new ticket):
  - §"Severity Assessment Framework" — declares the DisDAT/NCAPC/ECOG/PSFS/McGill cross-walk as the methodology
  - §"Derived Indices" — formula spec for the Derived Functional Interference Index (Part D), raw-to-T table source, sensitivity analysis methodology, calibration agreement protocol
  - §"Within-day Trajectory and Recovery" — documents the evening-check-in rationale and how trajectory data supports the environmental hypothesis

---

## Build order (post-refold — 2026-04-17)

The plan ships in **six stages** (five original + one precursor added by Items 1+2), each individually reversible and individually useful:

0. **Stage 0 — Data persistence hardening (PRECURSOR, from Items 1+2).** Dexie.js migration from localStorage + `navigator.storage.persist()` for eviction-resistance + weekly Web Share API → iCloud backup + JSON import for recovery. Must ship before any stage that accumulates data (i.e., before Stage 1). Reason: localStorage cap (~5 MB) and iOS PWA storage eviction would eventually destroy the dataset. This is its own ticket, independent of the rest of the plan. **Precondition for every other stage.**

1. **Stage 1 — Part A1 (morning irritability block) + cycle-phase label rename (Item 12).** Smallest scope, no schema migration, lowest risk. Ships after Stage 0.

2. **Stage 2 — Part C (evening check-in) + behavioral anchors + load tracking (Items 6, 10, 11).** New entry type, new home-screen card, all new fields including:
   - Cognitive load 8-item anchor set (4 core + 3 extended, weighted).
   - Social load + emotional load anchor sets (framework locked; items TBD during Stage 2 ticket design via walkthrough).
   - Behavioral-anchor Y/N fields for cognition/fatigue/pain (supplementing existing axes).
   - Multi-shift trajectory expansion (up to 3 shift timestamps when `up_down` selected).
   - Weather re-fetch at shift timestamps with interpolation fallback (Item 14).
   - `painEpisodePeak` write-time denormalization hook on episode save.
   - Independently useful the day it ships — within-day trajectory data starts accumulating immediately, even before the composite is computed.

3. **Stage 3 — `MEDICAL_PURPOSE.md` full documentation update.** Refolded composite spec + all 16 locked decisions + weighting rationales + anchor-to-Likert conversion tables + retrospective-reliability citations + PROMIS labeling rules + sensitivity methodology + versioning semver + cold-start thresholds + stage provenance. Could ship before or in parallel with Stage 4.

4. **Stage 4 — Parts B + D + E (composite engine, baseline wizard, export consolidation).** Largest scope. Includes:
   - Declarative `axisConfig` dispatcher + three strategy functions (Item 7).
   - `functionalToday` validation-signal concordance export (Item 6).
   - Monte Carlo sensitivity + one-at-a-time (Item 5).
   - Dual-period baseline wizard: direct for Arizona 2026, anchor-derived for Summers 2022/23 (Item 8).
   - Split UI (4-day) vs. clinical-export (7-day) cold-start thresholds (Item 15).
   - Export-header versioning + dual-view + stage provenance + PROMIS labeling + disclaimer block (Items 9, 13, 15, 16).
   - **Requires Stage 2 to have ≥7 days of evening data** before the composite produces a publishable clinical export value; UI shows raw composite earlier at 4 days per Item 15.

5. **Stage 5 — Parts A2 + A3 (episode prodrome chip + per-spasm emotional-trigger toggle).** Attaches to TICK-006 (episode phases plan) when that ships, or amends after.

**Optional follow-up (post-launch analytics):**
- **PROMIS calibration protocol (Item 4):** 2 admins at Stage 4 ship + monthly thereafter accumulating toward N≥10. Single-subject reference only — never population-normed validation.
- **PEM correlation across four load types** (Item 10): physical + cognitive + social + emotional, cross-day regression. Emerges from Stage 2 data once ≥14 paired days accumulate.
- **Variance-dominance re-check:** run after ~3 months of data to confirm no axis >40% of composite variance (Item 6 acceptance criterion).
- **Axis consolidation refactor (Item 6 Change 3 deferred):** post-launch, after ≥3 months of data, identify co-varying axes (fatigue↔cognition, social↔irritability) and consolidate. MAJOR version bump.

**Schema migration boundaries (informs versioning — Item 13):**
- Stage 1 → Stage 2: MINOR bump (new fields, no schema change for existing data).
- Stage 2 → Stage 4: MAJOR bump (composite structure changes; `functionalToday` reclassified as validation-only).
- Stage 4 → Stage 5: MINOR bump (prodrome chip additions don't change composite).

The composite gracefully handles missing data (skip axes, renormalize weights), so partial rollout still produces valid output. Every export through the transition period will carry the stage-provenance header from Item 16.

---

## Critical Review Walkthrough (COMPLETE 2026-04-17)

User requested a critical review of the plan; review surfaced 16 issues across architectural, methodological, UX, and scope categories. All 16 items resolved via structured walkthrough with lock decisions. Main plan body above has been refolded to reflect the locked decisions. This section preserves the decision record.

### Locked items

**Item 1 + 2 (combined) — Data persistence hardening (LOCKED)**
- Migrate from `localStorage` to **Dexie.js** (IndexedDB wrapper)
- Enable `navigator.storage.persist()` for eviction-resistance (esp. iOS Safari 7-day eviction risk)
- Add weekly auto-prompt to export full JSON via Web Share API → user saves to iCloud Drive
- Add "Import from JSON" button in settings for recovery
- Rationale: localStorage cap (~5 MB) and iOS PWA storage eviction would eventually destroy the dataset. Dexie + persist + manual-but-prompted iCloud Drive backup gives durability + Apple-grade E2EE without third-party trust.
- Considered Dexie Cloud — rejected: not E2EE by default, single-maintainer commercial venture, no HIPAA compliance.
- **This is a precursor ticket — must ship before Stage 1 of the main plan.**

**Item 3 — Alexithymia-aware composite: behavioral anchors on EOD (LOCKED, Option C + EOD-only)**
- Keep `irritabilityLevel` as a felt-sense daily field (user finds it useful for self-awareness) but **demote it in the composite** — it becomes a secondary input, not a primary driver of the social/emotional axes.
- Add **behavioral-anchor Y/N fields on the EOD form only** (not the episode log). Candidate anchors (final list TBD during Stage 1 ticket design):
  - "Snapped at someone today"
  - "Withdrew from planned contact today"
  - (1–2 more — to be confirmed when drafting the Stage 1 ticket; keep list short)
- **EOD-only rationale:**
  1. Double-counting risk if both episode-log and EOD capture the same behaviors → composite would weight same event twice.
  2. Behavioral questions are end-of-day questions by nature — "did X happen today" can't be answered mid-day.
  3. Derived Interference Index is daily-scoped, so its inputs should match that scope.
  4. Episode log already anchors incidents to real-world cost via `costActivities` and existing impairment fields — no need to duplicate at episode-time.
- **Composite rebalancing:** Social + emotional axes now weight EOD behavioral anchors alongside external-observation fields; `irritabilityLevel` weight reduced. Exact weight table to be specced when Parts B/C/D/E are refolded.
- **MEDICAL_PURPOSE.md** must document: self-rated emotion fields have known reliability limits for autistic/alexithymic adults; composite deliberately anchors to behavioral evidence for methodological integrity.
- **Deferred:** Episode-level behavioral anchors can be added post-launch if data shows a gap (e.g., severe episodes with no visible daily fallout).

**Item 4 — PROMIS calibration: sanity check + rolling accumulation (LOCKED, Option D)**
- **Launch protocol:** Two PROMIS Pain Interference short-form administrations at Stage 1 (baseline + ~4 weeks in) as a preliminary sanity check — catches gross miscalibration early before 6 months of data pile up.
- **Ongoing protocol:** Continue administering the PROMIS short form **monthly** thereafter, accumulating toward N≥10 over ~10 months for a defensible single-subject calibration reference.
- **Labeling rules (non-negotiable):**
  - Metric is always called **"Derived Interference Index"** in UI and export headers.
  - Never labeled "PROMIS T-score" or "PROMIS-comparable T" until N≥10 AND accompanying disclosure that this is single-subject self-anchored, not population-normed.
  - Export headers include current N of PROMIS administrations and an explicit "NOT population-normed PROMIS T" disclaimer.
- **`MEDICAL_PURPOSE.md` must document:**
  - Single-subject calibration cannot replicate PROMIS population norming (calibration sample in thousands).
  - Two administrations are a sanity check, not validation.
  - N≥10 threshold is a pragmatic single-subject floor drawn from ePRO daily-diary literature, not a statistical guarantee.
- **Composite versioning interaction:** Any change to the PROMIS↔composite conversion table bumps the MINOR version (see Item 13 when we get to it); historical windows are not retroactively recomputed.

**Item 5 — Sensitivity analysis: one-at-a-time + Monte Carlo joint perturbation (LOCKED, Option B)**
- **Keep one-at-a-time weight perturbation** (±10% per axis, others fixed) for interpretability — produces the "which axis dominates" table.
- **Add Monte Carlo joint perturbation:**
  - Define plausible range per weight (default ±15%; some axes may justify narrower/wider — to be specced when Parts B/C/D/E are refolded).
  - Sample ~10,000 whole weight-combinations; recompute composite for each day under each sample.
  - Report **90% interval** for each day's composite alongside the point estimate.
  - Export format: `composite: 0.62 [90% CI: 0.54–0.71]`.
- **Likert-mapping perturbation explicitly deferred** — academic for single-subject use; add post-launch only if a clinician raises the linear-mapping assumption.
- **`MEDICAL_PURPOSE.md` must document:**
  - Weights are judgment calls, not derived from empirical calibration.
  - Monte Carlo envelope reflects weight uncertainty only, not mapping-function uncertainty or Likert-scale quantization.
  - Days where the 90% interval crosses severity-tier boundaries should be flagged as "tier-ambiguous" in the export.

**Item 6 — Structural composite redesign: `functionalToday` becomes validation, not input + expand behavioral anchors (LOCKED, Option E = Change 1 + Change 2)**

*This is the largest change in the critical-review walkthrough and restructures Parts B/C/D/E when the plan is refolded.*

**Change 1 — Remove `functionalToday` from composite inputs; reframe as validation signal:**
- `functionalToday` (Good / OK / Scaled back / Bad) stays on the EOD form for daily self-awareness — **it is NOT an input to the Derived Interference Index**.
- Instead, `functionalToday` becomes the **ground-truth validation signal**: we test whether the multi-axis composite actually predicts the user's own sense of daily function.
- Validation export: weekly correlation between composite score and `functionalToday` ordinal rank. Persistent divergence flags a spec problem.
- This eliminates the circularity problem (the overall-interference self-rating was both input AND implicit target).

**Change 2 — Extend behavioral-anchor Y/N fields (Item 3 logic) to more axes on the EOD form:**
- **Social/irritability** (from Item 3): "snapped at someone," "withdrew from planned contact," +1–2 TBD.
- **Cognition:** candidates — "lost track mid-sentence Y/N," "had to re-read to understand Y/N," "couldn't find a word Y/N" (final list TBD at Stage 1 ticket design; keep short).
- **Fatigue:** candidates — "napped today Y/N," "went to bed earlier than planned Y/N."
- **Pain:** candidates — "avoided a specific movement Y/N," "took unscheduled medication Y/N."
- All EOD-only (same Item 3 rationale: avoid double-counting, answers require day-complete perspective).
- Count-based scoring within each axis (e.g., cognition Y/N count → [0,1] normalized).

**Change 3 — Axis consolidation (overlap collapse) DEFERRED to post-launch:**
- Likely co-varying pairs (fatigue↔cognition, social-withdrawal↔irritability) may warrant consolidation after ~3 months of real data.
- Cannot identify which axes actually co-vary without data — premature to spec pre-launch.
- Post-launch refactor bumps composite MAJOR version (see Item 13).

**Downstream implications to handle during refold:**
- Composite inputs now: domain Likerts (pain, cognition, social, sleep, fatigue, irritability) + `costActivities` + EOD behavioral-anchor Y/N counts. `functionalToday` explicitly excluded.
- Item 4 PROMIS calibration now compares PROMIS T to the multi-axis-only composite (cleaner test — PROMIS isn't measuring the user's own overall function self-rating).
- Item 5 Monte Carlo output reframed: "how well does multi-axis composite predict `functionalToday`" becomes the primary interpretability story, alongside the 90% CI on composite itself.
- Weight table (Parts B/C/D/E) will need full redesign — `functionalToday` weight goes to zero, other axes get the reclaimed weight mass, and behavioral-anchor Y/N axes are new slots.
- Variance-dominance analysis must be re-run during spec refold to confirm the restructured composite isn't now dominated by `costActivities` alone. If it is, that's a new Item 6 to re-address.

**`MEDICAL_PURPOSE.md` must document:**
- The composite is a multi-axis *prediction* of daily interference; `functionalToday` is the single-item *ground truth*.
- Validation rests on the composite tracking `functionalToday` over time — it is the user's overall self-rating that anchors "is the metric working."
- Behavioral anchors across axes are a deliberate alexithymia-aware design choice, not padding.

**Item 7 — Part A of 2: Aggregation structure redesign (LOCKED, Option C′ + cost-reductions)**

*Item 7 split into two sub-questions during walkthrough. Sub-question A (structural — which axes pair, how they aggregate) is locked here. Sub-question B (documentation prominence) is the current RESUME point below.*

**C′ structural design — per-axis aggregation strategies:**

| Axis | Aggregation strategy | Inputs |
|---|---|---|
| Pain | `peakOfPaired` | `painMorning`, `painEvening`, `painEpisodePeak` (denormalized) |
| Cognition | `peakOfPaired` | `cogAnchorMorning` (Y/N count), `cogAnchorEvening` (Y/N count) |
| Communication | `peakOfPaired` | `commMorning`, `commEvening` |
| Irritability | `peakOfPaired` | `irritMorning`, `irritEvening` |
| Fatigue | `trajectory` | `fatigueMorning`, `fatigueEvening`, `dayTrajectory` descriptor |
| Sleep | `single` | `sleepLastNight` |
| costActivities, costConnection, costFun, costSleepReadiness | `single` | (retrospective roll-up by user) |

- **Three aggregation strategies total:** `peakOfPaired` (4 axes), `trajectory` (1 axis — fatigue), `single` (rest).
- **Rationale per strategy:**
  - `peakOfPaired` matches PROMIS peak-interference construct; consistent with well-documented ePRO peak-severity recall bias — the user naturally encodes the day by its worst moment.
  - `trajectory` for fatigue because `max` is a bad aggregator there (expected evening fatigue after a full day ≠ interference); trajectory descriptor captures pacing/crash patterns better.
  - `single` for sleep (can't pair) and retrospective cost fields (user already mentally aggregates).

**Cost-reduction 1 — Declarative axis-config dispatcher:**
- Replace hardcoded `commWorse` / `irritWorse` named formulas with a single `axisConfig` object and one dispatch function.
- Three strategy functions (`peakOfPaired`, `trajectory`, `single`), each <10 lines.
- Adding new axes post-launch is a one-line config edit, not a code change.
- Config-object hash becomes the Item 13 composite-version artifact — printed in export headers.

**Cost-reduction 2 — Write-time denormalization for episode-peak pain:**
- When an episode is saved, write its peak-pain value to a day-level field `painEpisodePeak` on the EOD record for that day.
- Daily aggregation reads three sibling fields (morningPain, eveningPain, episodePeak) — no cross-entity join.
- Eliminates the blind-spot-2 problem where `worseOf(morning, evening)` would systematically miss the day's actual peak when an episode occurred.

**Alexithymia-aware consistency (ties to Items 3 + 6):**
- Cognition's "paired" inputs are **behavioral-anchor Y/N counts**, not self-rated Likerts. This preserves the Item 6 principle (behavioral evidence preferred over introspective self-rating) and still gets peak-aggregation via `peakOfPaired` on the counts.
- Pain Likerts kept as Likerts (physical sensation, not emotion — alexithymia-vulnerable reliability concern doesn't apply).

**`MEDICAL_PURPOSE.md` documentation requirements (explicit — cost-reduction doesn't extend to docs):**
- Explain **all three aggregation strategies**, not just `worse-of`:
  - `peakOfPaired` — why max, what it aligns with (peak-severity recall bias, PROMIS construct), what it systematically excludes (within-day averaging, mean-state).
  - `trajectory` — why fatigue is aggregated by shape rather than magnitude, cite PEM/pacing literature.
  - `single` — for sleep and retrospective costs, trivially correct but stated for completeness.
- Document the **episode-peak denormalization** for pain — that `painEpisodePeak` is pulled into daily aggregation so the peak during an episode isn't lost.
- Document the **alexithymia-aware cognition path** — that cognition aggregation runs on Y/N behavioral-anchor counts, not on self-rated cognitive-state Likerts, and why.
- Document what the `axisConfig` object represents and that its hash identifies the composite version.

**Item 7 — Part B of 2: Documentation prominence (LOCKED, Option A — single composite, documented rigorously)**
- **One composite only** — no dual-reporting with a mean-based alternate. The `peakOfPaired` design choice is deliberate and aligned with how the user encodes days (peak-defined, episodic condition); publishing a mean alternate would contradict the Q2 design intent.
- **Export header must declare:**
  - `axisConfig` hash (Item 13 composite-version artifact)
  - One-line aggregation summary per axis (e.g., `pain: peakOfPaired over morning/evening/episodePeak`)
  - Explicit note: "Peak-aggregation reflects user-experienced worst state, not averaged-day state."
- **Detailed rationale lives in `MEDICAL_PURPOSE.md`** per the Part A documentation requirements.
- **Rejected options:**
  - B (dual-report mean + peak) — two metrics to validate, clinicians pick one anyway, project should own the choice.
  - C (switch to mean) — invalid given Q2 lock on `peakOfPaired`.
  - D (per-day user choice) — UX overhead for marginal analytical gain.

**Item 8 — Baseline wizard: both periods, alexithymia-aware retrospective (LOCKED, Option F)**

User clarified capacity is not the bottleneck for one-time setup tasks; she'll do extended work if it yields better data. So the wizard redesign addresses **reliability**, not burden.

**Structure:**

- **Arizona spring 2026 baseline — direct self-rating.**
  - Full wizard as originally specced — Likert ratings per axis (period is recent, recall is tractable).
  - Axis list must be updated per Item 6 restructure: remove `functionalToday` (no longer a composite input), add the new behavioral-anchor Y/N axes for cognition/fatigue/pain that we'll spec during refold.
  - Export label: "Arizona 2026 baseline — direct self-rating."

- **Summers 2022/23 baseline — behavioral-anchor recall.**
  - Restructured entirely as **behavioral/capability recall questions**, NOT state/emotion Likert ratings.
  - Example anchor questions (final list TBD during Stage 1 ticket design):
    - "Did you regularly cancel plans because of symptoms? (never / sometimes / often / most weeks)"
    - "Could you walk 2 miles without planning around symptoms? (yes / sometimes / rarely / no)"
    - "Did you use medication daily / weekly / rarely / never?"
    - "Did people notice you were struggling? (never / occasionally / often)"
    - "Could you work a full day without mid-day collapse? (routinely / often / rarely / never)"
  - Anchor answers convert to approximate Likert values via a documented mapping table.
  - Export label: "Summers 2022/23 baseline — anchor-derived estimate (retrospective reconstruction)."

**Rationale:**
- Extends Items 3 + 6 alexithymia-aware design principle to retrospective data collection — behavioral/capability recall over 3–4 years is much more reliable than state/emotion recall.
- Preserves the "vs. healthy-me" pre-onset comparison (analytical feature would have been lost in Option D).
- Labels differentiate direct vs. anchor-derived baselines so clinicians interpret them correctly.
- User can complete both periods in one sitting or across multiple — no forced spacing (respects user capacity feedback).

**`MEDICAL_PURPOSE.md` must document:**
- Rationale for direct self-rating vs. anchor-derived-estimate split between the two baseline periods.
- The anchor-to-Likert conversion mapping table (fully transparent — no hidden heuristics).
- Retrospective-reliability literature citations.
- That the anchor-derived baseline has a known lower precision than the direct baseline and should be treated as directional, not quantitative.

**Item 9 — PROMIS labeling enforcement across UI + export (LOCKED, Option D)**

- **Global rename:** Drop the phrase **"PROMIS-comparable T"** from all plan, code, UI, and export references. Use **"Derived Interference Index"** everywhere.
- **Structured disclaimer block** included in every export:
  ```
  Metric: Derived Interference Index (NOT PROMIS T)
  Method: Multi-axis composite, single-subject calibration
  PROMIS administrations to date: N = X
  Validation status: [preliminary (<4 admins) | accumulating (4–9 admins) | single-subject reference (≥10 admins)]
  axisConfig hash: [Item 13 composite-version artifact]
  ```
- **UI-side enforcement:** The app itself never shows a T-score-like number without the disclaimer visible alongside. When any derived composite value is rendered (settings, export preview, any visualization), the disclaimer string accompanies it within the same view.
- **Covered surfaces:** Export JSON/CSV/PDF, export preview, settings debug view, any future in-app dashboard that surfaces the composite numerically.
- **Rejected E (block word "PROMIS" adjacent to T-score via static check):** paranoid for a single-user tool where both surfaces are directly controlled.

**`MEDICAL_PURPOSE.md` must document:**
- Why "Derived Interference Index" is the canonical name (single-subject self-anchored, not population-normed).
- The N threshold rationale for each validation-status tier.
- That "PROMIS-comparable" is explicitly never used because of systematic misreading risk.

**Item 10 — Behavioral-anchor load tracking for cognitive / social / emotional exertion (LOCKED)**

Extends the Item 3/6 behavioral-anchor pattern to three new load types (cognitive, social, emotional). All fields on the EOD form, count-based **weighted** scoring per load type, feeds the PEM correlation engine.

**Design framework (applies to all three load types):**

- **Framing A — all absolute Y/N, observable events.** No relative/introspective comparisons ("heavier than usual") — would violate Item 3/6 alexithymia-aware principle per research red flags.
- **Weighted scoring, not equal-weight count.** Different anchors represent different cost levels; count-as-equal would be noise. Weights are rough v1 values; refinable post-launch based on which anchors actually correlate with next-day symptom shifts.
- **6–8 items per load type, 4 core + rest extended.** Nested PROMIS-29-style architecture per research. Core items always answered; extended items skippable on hard symptom days. Longitudinal data stays comparable across "full" and "core-only" days.
- **Max across all three load types: ~20 items total.** Per EMA daily-compliance literature.
- **Max rule for overlapping tiered anchors.** Where one anchor is a subset of another (e.g., heavy masking is a subset of masking), `max(weights)` on the day both fire — no double counting.

**Research foundation:** NASA-TLX, Neuro-QoL Cognitive Function, Raymaker autistic burnout model, AASPIRE, monotropism literature, Gross emotion regulation + ego-depletion, Invisible Family Load Scale, Sweller cognitive-load theory, DSQ-PEM, CDC ME/CFS PEM management, EMA compliance meta-analyses.

---

**COGNITIVE load — 8 items, 4 core (LOCKED during walkthrough)**

Covers the evidence-backed domains: effortful cognition, executive function, learning, social-cognitive (masking), sensory processing, emotional regulation as cognitive work, communication production, anticipatory/managerial load.

**CORE (4 items, always answered):**

| # | Item | Weight |
|---|---|---|
| 1 | **Sustained critical thinking / complex problem-solving** >2h (debugging hard bugs, analyzing complex situations, weighing decisions with multiple factors) | **3** |
| 2 | **Masking tier** (hybrid — both Y/Ns can fire, score is `max`): | |
| 2a | &nbsp;&nbsp;Masking / social-cue translation / script-building >1h | 2 |
| 2b | &nbsp;&nbsp;Heavy masking event >2h OR high-stakes (networking, conference social, major family gathering) | 3 |
| 3 | **Extended high-sensory environment** >4h (conference centers, airports, crowded venues, sustained noise + visual complexity) | **3** |
| 4 | **Emotional regulation as cognitive work** — held composure through >30 min of an upsetting / activating situation (kept reaction internal) | **3** |

**EXTENDED (3 items, skippable on hard symptom days):**

| # | Item | Weight |
|---|---|---|
| 5 | **Communication production** — composed or rehearsed a communication you'd been dreading (hard email, difficult message, script for a phone call) | **2** |
| 6 | **EF + logistics work** >1h (planning, scheduling, coordinating multiple moving pieces, managing paperwork, making phone calls, navigating healthcare / insurance / bureaucratic systems, tracking multiple threads) | **2** |
| 7 | **Anticipatory / managerial load** — ran significant background logistics today (≥3 open threads to actively track: appointments, bills, follow-ups, coordinating others) | **2** |

**Explicitly cut from earlier drafts (reasoning documented for future reference):**
- "Reading dense material" — user confirmed reading is low-cost; not worth an anchor slot.
- "Did math without aids" — niche; when it fires in a meaningful way it's captured by #1 problem-solving.
- "Made a decision you'd been putting off" — too close to #1 or #6 depending on the decision type; use decision fatigue only if data shows a gap.
- "Had to recall something you hadn't thought about" — too vague to be observable cleanly.
- "Learning something new" — originally core; cut because when it fires in a cognitively meaningful way it's usually captured by #1 or #5.
- "Context switching >5x" — originally extended; cut as overlapping with #6 EF (same executive-function substrate).

**Scoring:**
- Max full-log day: 3 + 3(masking max) + 3 + 3 + 2 + 2 + 2 = **18**
- Max core-only day: 3 + 3(masking max) + 3 + 3 = **12**
- Raw score normalized to [0, 1] by dividing by max-for-logged-mode.

**SOCIAL load — parallel structure TBD**
- Apply same framework (Framing A, 6–8 items, 4 core, weighted, observable events).
- Known anchors likely to include: extended difficult interactions, group settings, non-masking social cognition (decoding charged interactions after the fact), advocacy/translation work.
- Full spec DEFERRED to Stage 1 ticket design with user walkthrough.

**EMOTIONAL load — parallel structure TBD**
- Apply same framework.
- Known anchors likely to include: conflict events, high-stakes events (medical advocacy, healthcare decisions), grief/loss events, anxiety-driven rumination.
- Full spec DEFERRED to Stage 1 ticket design with user walkthrough.

**PEM correlation engine extension:**
- Physical exertion (existing) + cognitive load + social load + emotional load — four independent inputs.
- Each load type correlates against next-day symptom worsening independently.
- Output format: "Day-N load profile: physical=2 / cognitive=13 / social=X / emotional=Y (normalized) → Day-N+1 composite shift: +0.18."
- Any correlation above threshold flagged in export.

**`MEDICAL_PURPOSE.md` must document:**
- The 8 evidence-backed cognitive-load domains (NASA-TLX + Neuro-QoL + Raymaker + Invisible Family Load Scale + Gross + Sweller taxonomy).
- Why behavioral-anchor Y/Ns are used instead of load intensity Likerts (alexithymia-aware consistency with Items 3 + 6; research red flag against intensity self-rating).
- Weighting rationale per anchor (why emotional regulation is weight 3, not 2).
- Core vs. extended nesting architecture (mirrors PROMIS-29).
- That anchor weights and thresholds are v1 judgment calls, refinable post-launch if data shows mis-calibration.
- Cuts rationale (why context switching, learning, and reading are NOT in the final set).

**Cost flagged:** EOD form is becoming ~3–5 minutes with cognitive + social + emotional load anchors + the Item 3/6 behavioral anchors. User confirmed this is acceptable (capacity feedback from Item 8 discussion).

**Item 11 — Multi-shift trajectory capture (LOCKED, Option B)**

- Keep `dayTrajectory` categorical as the primary trajectory descriptor.
- **When user selects `up_down`, form expands to capture up to 3 shift timestamps** with direction:
  - Each shift: `time` (midday / afternoon / evening / late_evening) + `direction` (better / worse)
  - All shift entries optional — user can log as many or as few as she remembers; `up_down` is still valid with zero shift details (fallback behavior = current v1 spec).
- **Conditional UI** — single-shift days (`better` / `worse` / `same`) see no added fields; only `up_down` opens the multi-shift expansion.
- **Data structure:**
  ```
  dayTrajectory: 'up_down'
  trajectoryShifts: [
    { time: 'midday', direction: 'better' },
    { time: 'afternoon', direction: 'worse' },
    { time: 'evening', direction: 'better' }
  ]
  ```
  Single-shift spec preserved: `{ time: 'afternoon', direction: 'worse' }` stored as single-element array.
- **Weather snapshot captured per shift timestamp** — extends existing plan's trajectory-weather integration.
- **Rejected options documented:**
  - C (per-shift Likerts) — overkill; 4 Likerts/day adds burden on single-trajectory days that outweighs multi-shift-day gain.
  - D (optional free-form timeline) — free-form text isn't analyzable.
  - E (per-shift cause attribution) — violates "exposures not triggers" principle; forces causation assertion at log-time.
- **`MEDICAL_PURPOSE.md` must document:**
  - Multi-shift capture resolution limit (3 shifts) and why it's sufficient for most recovery+re-trigger patterns.
  - That missing shift details on `up_down` days is acceptable and doesn't invalidate the trajectory classification.

**Item 12 — Cycle-phase section: pure label rename (LOCKED, Option F)**

- **Rename the `cycleRelatedDay` toggle label** to something that makes its meta-attribution status explicit — e.g., *"Overall: today feels cycle-related"* (final wording TBD during Stage 1 ticket design; keep it short).
- **No visual restructure, no reorder, no sub-heading.** Keep specific phase-proxy toggles (breast tenderness, etc.) as peer toggles in the same section.
- **Fallback upgrade path:** If seeing it in the UI confirms peer-positioning is still confusing, upgrade to Option B (structural separation) in a follow-up ticket. Not pre-committed.
- **Data model unchanged.** Backward-compatible read of legacy `moodShift` values still applies (already locked in current plan).
- **Rejected options:**
  - B (structural restructure) — deferred as fallback; minimal-change-first is the right default.
  - C (conditional on cycleRelatedDay = true) — hides symptom data on days attribution is unclear.
  - D (invert hierarchy) — asks for two judgments when often the symptoms ARE the attribution.
  - E (remove specific toggles) — loses structured phase-proxy data she uses to infer cycle phase.

**Item 13 — Composite versioning + per-window dual-view exports (LOCKED, Option D)**

**Semver classification (locked):**
- **MAJOR** — axis schema change: axis added/removed, aggregation strategy changed for an axis (`peakOfPaired` → `trajectory`), core/extended nesting restructured. Composite fundamentally changes what it's measuring.
- **MINOR** — weight changes on existing axes, Likert-to-normalized mapping shifts, PROMIS conversion table updates, anchor threshold tweaks. Magnitude shifts but axis schema stable.
- **PATCH** — bug fixes, calculation errors, typos, documentation-only changes. No intended change in composite values.

**`axisConfig` object (locked):**
- Contains `version: "MAJOR.MINOR.PATCH"` field.
- Full config-object JSON hash becomes the composite-version artifact.
- Hash printed in every export header alongside the semver string (first 8 chars).
- Version history maintained in `docs/COMPOSITE_VERSIONS.md` with a changelog entry per bump explaining the change.

**Historical-data handling — per-window dual view (Option D):**

Every export window can be rendered in two modes:
- **Original mode:** composite values as computed at the time of logging, using the `axisConfig` version in effect that day.
- **Recomputed-to-current mode:** stored raw inputs re-run through the *current* `axisConfig` — shows what the current math would say about historical data.

**Storage requirements:**
- Raw input data stored permanently (already assured via Dexie.js migration from Items 1+2).
- Historical `axisConfig` versions retained in app bundle or IndexedDB so any version can be replayed.
- Day records tag the `axisConfig` version that produced their original composite value.

**Export labeling (non-negotiable to prevent misreading):**
- Export header must declare which mode is active: `view_mode: original` OR `view_mode: recomputed_to_current`.
- When `recomputed_to_current`, header also lists the original version range spanned by the window (e.g., `original_versions_in_window: [2.1.0, 2.2.0, 2.3.0]`) so readers know which days were re-computed.
- Clinicians reading a PDF should never be uncertain which view they're seeing.

**UX:**
- Export preview UI offers a mode toggle before download.
- Default is `original` (preserves provenance).
- Switching to `recomputed_to_current` shows a visible "showing recomputed view" banner in the preview and in the exported file header.

**Rejected options:**
- A (never recompute) — leaves known-wrong PATCH bugs in historical record forever.
- B (recompute MINOR+PATCH) — retroactively rewrites history based on current weight judgments.
- C (recompute PATCH only) — cleaner than D but loses the analytical power of comparing "current-math-applied-retroactively" for meta-analysis.

**`MEDICAL_PURPOSE.md` must document:**
- The semver classification and what changes warrant MAJOR/MINOR/PATCH.
- The dual-view export system and how to read the `view_mode` header.
- That `original` is the provenance-preserving default; `recomputed_to_current` is an analytical view.
- That PATCH bugs are preserved in `original` mode (for auditability) and corrected in `recomputed_to_current`.

**Item 14 — Weather snapshot at shift timestamp: belt-and-suspenders (LOCKED, Option D)**

- **Primary path:** re-fetch weather from API at each trajectory shift timestamp when online.
- **Always store morning + evening snapshots** regardless of shift timestamps (used for offline/API-failure fallback).
- **Fallback path:** when offline OR API fails OR API times out (default 3s), linearly interpolate from that day's stored morning + evening snapshots.
- **Retry behavior:** failed re-fetches queued for background retry when connectivity/API restored; cache per timestamp prevents duplicate fetches.
- **Form save is non-blocking** — user can save the evening check-in immediately; weather fetches happen asynchronously.
- **Data tagging:** each captured weather snapshot stores `source: 'api' | 'interpolated'` so analysis can distinguish direct readings from estimates.
- **Rejected options:**
  - A (skip when offline) — loses offline-day environmental data permanently.
  - C (always interpolate) — consistent but wastes API fidelity when online.
  - E (defer weather to v2) — can't backfill lost shift-timestamp data.

**`MEDICAL_PURPOSE.md` must document:**
- Weather data source tagging and that interpolated values are approximations.
- Linear interpolation assumption (weather typically monotonic across 8–12 hours) and when it breaks down (e.g., fast-moving fronts).

**Item 15 — Cold-start composite handling: split thresholds for UI vs. clinical export (LOCKED, Option D)**

**Threshold policy:**
- **UI display:** Minimum **4 days** of evening data before the Derived Interference Index renders numerically. Below 4 days, UI shows `"Derived Interference Index pending — accumulating baseline data (X of 4 minimum days logged)"`.
- **Clinical export:** Minimum **7 days** of evening data before the composite appears in any export. Below 7 days, export shows the same pending message (`X of 7 minimum days logged`) and omits the numeric score.
- **Rationale for split:** self-monitoring tolerates noisy-but-directional data (pattern-tracking); clinical export must be defensible (no sparse-data misreading).

**Cold-start thresholds for other derived metrics (locked — extends the same pattern):**
- **Personal-baseline T (Arizona 2026):** requires baseline wizard completion **AND** ≥4 days of in-app evening data (matches UI threshold for the main composite).
- **Personal-baseline T (Summers 2022/23):** requires anchor-derived baseline wizard completion only (no in-app data threshold — the retrospective baseline is self-contained).
- **PEM correlation:** requires ≥14 days of paired load-data + next-day composite (2 weeks minimum for any correlation signal to be meaningful at single-subject scale).
- **Monte Carlo envelope:** requires ≥7 days of composite data to be meaningful; computed per-window after threshold met.
- **Trajectory analysis (multi-shift days):** no minimum — published as soon as any `up_down` day is logged.

**Pending-state message format (canonical):**
- `"<Metric name> pending — accumulating baseline data (X of <threshold> minimum days logged)"`
- Appears anywhere the metric would otherwise render (UI card, export header, visualization placeholder).

**Rejected options:**
- A (single 4-day threshold) — can produce misleading clinical exports on sparse weeks.
- B (single 7-day threshold) — loses a week of self-monitoring utility for no gain.
- C (preliminary tag) — ambiguous; clinician might still use the number inappropriately.
- E (no minimum) — single-day composite is meaningless.

**`MEDICAL_PURPOSE.md` must document:**
- All cold-start thresholds and which metric uses which.
- That UI and export thresholds differ by design (not a bug).
- The split rationale — "self-monitoring tolerates noise; clinical export requires defensible data."

**Item 16 — Stage provenance in exports + mixed-stage-window warning (LOCKED, Option C — final walkthrough item)**

- **Every export header declares current stage provenance:**
  - `stage: "Stage 3"` (or whatever stage is current at time of export).
  - `stage_description: "Part A + Part B composite + Part C evening check-in"` (human-readable list of shipped components).
- **Mixed-stage window detection:**
  - When an export window spans a stage boundary (e.g., a rolling 7-day window that crosses a Stage 2 → Stage 3 ship date), header flags:
    - `window_spans_stages: [2, 3]`
    - `composite_may_be_discontinuous: true`
    - `stage_boundary_dates_in_window: ["2026-05-15"]`
- **Source of truth for stage metadata:** `docs/COMPOSITE_VERSIONS.md` changelog (already required per Item 13). Each stage ship date is a new entry.
- **Interaction with Item 13 dual-view export:**
  - In `original` mode: stage info is as-of-the-day for each day in the window; mixed-stage warning fires if multiple stages in window.
  - In `recomputed_to_current` mode: all days re-run through current stage's axisConfig; no mixed-stage warning (by definition, all days now use current math) but header notes "recomputed from original stages: [2, 3]" for provenance.
- **UI equivalent:** When viewing historical data spanning a stage boundary in-app, show a thin banner `"methodology updated on [date] — pre-update values computed differently; see details"`.

**Rejected options:**
- A (version-only declaration) — technically correct but not legible to clinicians not watching for version strings.
- B (stage declaration without mixed-window warning) — misses the specific case where comparison breaks.
- D (force-split at boundaries) — breaks self-monitoring feedback loop for 7 days at every transition; too disruptive.
- E (full methodology history in every export) — too verbose for routine exports.

**`MEDICAL_PURPOSE.md` must document:**
- The 5-stage rollout and what each stage ships.
- How to read stage provenance headers.
- When to trust direct cross-export comparisons (same stage on both) vs. when mixed-stage warnings apply.

---

## ✅ Critical-Review Walkthrough Complete (2026-04-17)

All 16 items resolved. The plan's locked decisions are now:

| # | Topic | Decision |
|---|---|---|
| 1+2 | Data persistence | Dexie.js + `navigator.storage.persist()` + weekly iCloud backup + JSON import |
| 3 | Alexithymia-aware composite | Option C + EOD-only — demote `irritabilityLevel`, add behavioral-anchor Y/Ns |
| 4 | PROMIS calibration | Option D — 2 at launch + monthly to N≥10, never mislabel as PROMIS T |
| 5 | Sensitivity analysis | Option B — one-at-a-time + Monte Carlo 90% CI |
| 6 | Composite restructure | Option E — `functionalToday` → validation signal; behavioral anchors expanded to cognition/fatigue/pain |
| 7 | Aggregation structure | Option C′ + cost-reductions — declarative axisConfig + write-time denormalization; 3 aggregation strategies |
| 7B | Documentation | Option A — single composite, documented rigorously (no dual-report) |
| 8 | Baseline wizard | Option F — both periods, alexithymia-aware retrospective (anchor-derived for 2022/23) |
| 9 | PROMIS labeling | Option D — UI + export both carry disclaimer |
| 10 | Load tracking | Behavioral-anchor cognitive load: 8 items, 4 core, weighted, research-backed domain coverage. Social + emotional framework locked, specifics deferred to Stage 1. |
| 11 | Multi-shift trajectory | Option B — conditional expansion up to 3 shifts on `up_down` |
| 12 | Cycle-phase section | Option F — pure label rename, no structural change |
| 13 | Composite versioning | Option D — semver + per-window dual-view exports (original + recomputed_to_current) |
| 14 | Weather at shift timestamps | Option D — re-fetch when online + always interpolate fallback |
| 15 | Cold-start thresholds | Option D — 4 days UI, 7 days clinical export |
| 16 | Stage provenance | Option C — stage info + mixed-window warning in every export |

### Next step: fold locked decisions back into the main plan body

Decisions above modify Parts B / C / D / E + `MEDICAL_PURPOSE.md` requirements. The walkthrough state preserved here is the source of truth; main-plan-body sections need to be rewritten to reflect:
- Item 6's `functionalToday` → validation-only restructure (biggest change; touches weights, inputs, validation framing).
- Item 7's axisConfig declarative structure replaces the hardcoded `commWorse`/`irritWorse` named formulas in plan lines 401–416.
- Item 10's 8-item cognitive-load anchor set (new EOD fields).
- Items 13/16's versioning + stage provenance spec in the export-header section.
- Item 8's behavioral-anchor retrospective for Summers 2022/23 (replaces the Likert-style retrospective in lines 466–479).

### After refold: ticket creation begins

First ticket should be **data persistence hardening (Items 1+2)** — precursor to Stage 1. Dexie.js migration + `navigator.storage.persist()` + Web Share API → iCloud + JSON import.

### Pending items (4–16)

| # | Issue | One-line summary |
|---|---|---|

### After walkthrough completes

Once all 16 are resolved, fold the locked decisions back into the main plan body (most modify Parts B / C / D / E or `MEDICAL_PURPOSE.md` requirements). Then plan is fully build-ready.

### Research sources used in critical review

- ePRO recall bias: [PROMs bias literature review (MDPI)](https://www.mdpi.com/1660-4601/18/23/12445), [ePRO daily diaries in RA (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6431038/)
- Alexithymia in autism: [Meta-analysis (PMC)](https://pmc.ncbi.nlm.nih.gov/articles/PMC6331035/), [TAS-20 psychometric in autistic adults](https://link.springer.com/article/10.1186/s13229-021-00463-5)
- Storage / PWA persistence: [Storage quotas and eviction (MDN)](https://developer.mozilla.org/en-US/docs/Web/API/Storage_API/Storage_quotas_and_eviction_criteria), [WebKit storage policy update](https://webkit.org/blog/14403/updates-to-storage-policy/)
- Dexie Cloud security model: [Authentication docs](https://dexie.org/cloud/docs/authentication), [Database encryption discussion](https://github.com/dexie/Dexie.js/discussions/1538)
- PROMIS Pain Interference: [Scoring manual (HealthMeasures)](http://www.healthmeasures.net/images/PROMIS/manuals/PROMIS_Pain_Interference_Scoring_Manual.pdf)
