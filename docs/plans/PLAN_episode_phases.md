# Isobar — Episode Phase Restructure (Plan)

---

## Session Status (2026-04-15)

**Phase:** **Ready for implementation.** All 8 open questions resolved. Design spec complete. Next step: build in `index.html`.

**Origin:** User raised the question of whether the current single "Log Episode" button (which collects prodrome + first jerk + wrap-up in one form) should be split into separate phase buttons. Web research confirmed standard neurological terminology (prodrome → ictal → postictal) and best-practice guidance (epilepsy.com, Epilepsy Foundation) that each phase should be logged as it happens to avoid recall bias.

**Rev 2 change:** "Jerking started" was a single ictal_onset timestamp. User flagged that a typical 6-hour episode includes 6–12 individual spasms across varying locations (legs, legs+arms, arms+neck, etc.) and that per-spasm logging would capture vastly more clinical signal — spasm count, location distribution, intensity trajectory across the episode. Replaced with a per-spasm button. The Muscle Event button and the in-episode spasm button now share one data shape; ictal_onset is derived as the first spasm's timestamp.

**Rev 3 change:** Terminology — UI uses "spasm" (clinically aligned with SPS literature, dignified, diagnosis-appropriate). Internal data tag remains `motor_event` (diagnosis-neutral, survives whichever hypothesis is eventually confirmed).

---

## Purpose

Replace the single "Log Episode" button with **phase-based logging** that mirrors the standard prodrome → ictal → postictal model used in neurology, and integrates cleanly with the planned standalone Muscle Event button (UPDATES.md).

## Why this change

The current single-button flow forces the user to reconstruct the prodromal sequence and timing **after** the event — i.e., during the postictal window when cognition, communication, and motor control are most impaired. This is the worst possible time to capture the most diagnostically valuable data.

Per MEDICAL_PURPOSE.md, the prodromal sequence (right leg → bilateral → left arm → left facial tingling) is *the* signature finding for the SPS hypothesis — it reflects spinal interneuron disinhibition propagating rostrally before motor release. Individual symptom timestamps within the prodrome, and the prodrome→ictal latency, are clinically load-bearing data points that the current flow cannot capture.

Splitting into phase-based buttons:
- Captures each phase **as it happens** (epilepsy.com observation guidance: write down what happens as soon as you can — details are lost otherwise)
- Makes prodrome→ictal latency a real measurement instead of a guess
- Makes postictal duration a real measurement (resolution becomes an explicit user action)
- Matches the terminology specialists use, so exports speak the clinical language

## Research basis

| Concept | Source | Relevance |
|---|---|---|
| Prodrome / ictal / postictal phase model | [Epilepsy Foundation Australia — Seizure Phases](https://epilepsyfoundation.org.au/understanding-epilepsy/seizures/seizure-phases/) | Standard neurological terminology applies even though events are non-epileptic; specialists expect this framing |
| Phase-by-phase real-time logging | [Epilepsy.com — Seizure Observation](https://www.epilepsy.com/manage/tracking/observation) | "Note what happens in each phase – before, during, and after… write down what happens as soon as you can" |
| Prodromal symptom characterization (30 min – several hours, insidious onset) | [Prodromal symptoms in epileptic patients — ScienceDirect](https://www.sciencedirect.com/science/article/pii/S105913110800232X) | Validates that prodrome is a discrete, measurable phase with its own timing — not a single moment |
| SPS spasm episodes precipitated by external stimuli; "status spasticus" possible | [Stiff Person Syndrome — StatPearls/NCBI](https://www.ncbi.nlm.nih.gov/books/NBK573078/) | Confirms episode duration is highly variable and resolution timestamp is meaningful |
| SPS clinical phases and presentation | [Practical Neurology — Stiff-Person Syndrome](https://practicalneurology.com/diseases-diagnoses/movement-disorders/stiff-person-syndrome/31707/) | Background on rigidity progression and spasm characterization |

---

## Proposed structure

### Three buttons on the home screen

| Button (UI label) | Underlying tag | What it does |
|---|---|---|
| **Warning starting** | `prodrome_onset` | Timestamps prodrome onset; opens prodrome checklist screen |
| **Log a spasm** | `motor_event` | Per-event log: timestamp + location + intensity. Auto-derives `ictal_onset` from the first one in an open episode; standalone if no episode is open |
| **It's over** | `postictal_resolution` | Timestamps end; opens postictal wrap-up form |

The previously-planned standalone "Muscle event" button (UPDATES.md) collapses into the same button as in-episode jerk logging — same data shape, same form. The only difference is whether an `episode_id` is attached.

UI labels are plain language; underlying data is tagged with medical terms so exports/reports speak the specialist's language.

### Episode state model

An **episode** is an open record from the moment "Warning starting" is tapped until "It's over" is tapped. Only one episode can be open at a time. While an episode is open:

- The home screen shows a persistent "Episode in progress" banner with elapsed time and live spasm count
- "Warning starting" is hidden (already in prodrome)
- "Log a spasm" remains the primary action — tap once per spasm
- "It's over" appears as the resolution action

If the user logs a spasm without ever tapping "Warning starting" (event came on with no warning), that's a valid path — the episode opens automatically at the first spasm's timestamp with a null prodrome and a flag `prodrome_absent: true`. The user is prompted afterward (non-blocking): "Did this come on with no warning, or did you forget to log the warning phase?" with a one-tap option to backdate prodrome onset.

If the user forgets to tap "It's over" and the episode is still open after some threshold (e.g., 8 hours — well past her documented 30 min – 4 hour range), prompt on next app open: "Is your episode still active, or did you forget to close it?" with options to backdate the resolution to the last logged spasm.

### Per-phase forms

#### Prodrome screen (after "Warning starting")

Single-screen checklist of **prodromal sensations only** (no motor activity — twitches and jerks are spasms, logged via the spasm button). Each tap timestamps that sensation. User can tap as she feels them appear — does not need to fill in all at once.

**Why sensation-only:** Migraine and epilepsy prodrome literature is explicit that mixing sensory and motor entries produces unusable data. Twitches are low-intensity spasms (intensity = "light twitch" in the spasm log) and the first one transitions the episode from prodrome → ictal automatically. Keeping the boundary clean lets the export report **prodrome-to-first-spasm latency** — i.e., how long the sensory-only warning lasts — which is itself diagnostic data.

**Vocabulary:** Sensations are described as either "heightened sensation" (clinically: paresthesia) or "loss of sensation" (clinically: anesthesia/hypoesthesia), plus structural sensations like pressure, tightness, buzzing, heaviness, warmth, coldness. Plain language is used throughout the UI; clinical terms appear in exports only.

**Pre-composed chips (documented sequence from MEDICAL_PURPOSE.md):**
- Lower back pressure
- Buzzing / energy in legs
- Right leg — heightened sensation
- Left leg — heightened sensation
- Both legs — heightened sensation
- Right arm — heightened sensation
- Left arm — heightened sensation
- Left facial — heightened sensation
- Chest tightness (sensation)
- Throat tightness (sensation)

**Plus "Custom" entry** — opens a quick two-tap form: location chip (same regions as spasm log) + sensation type chip (pressure / heightened sensation / loss of sensation / buzzing / tightness / heaviness / warmth / coldness / other). For anything outside the documented pattern.

Each entry stored as `{location, sensation_type, timestamp}`. Order is preserved as-tapped, capturing the propagation sequence directly.

Big targets, no required fields, can be left and re-entered. Auto-captures weather/pressure on prodrome_onset.

#### Per-spasm log ("Log a spasm")

Tapped once per spasm during the episode (and standalone outside an episode). One screen, designed for 2–3 taps total:

- **Where** — tap one or more body regions. Multi-select. Final chip set:
  - right leg
  - left leg
  - right arm
  - left arm
  - neck
  - back
  - face
  - jaw
  - around the ribs (squeezing) — intercostal involvement
  - under the ribs (can't breathe in) — diaphragm involvement
  
  Hands roll into "right/left arm" and feet roll into "right/left leg" (patient does not experience hand- or foot-only spasms). No "both legs" / "both arms" shortcuts — bilateral is recorded by tapping each side, which preserves whether involvement was actually simultaneous vs. sequential.
- **Intensity** — 5-level functional scale anchored on the decision/action the spasm forces. Each chip shows label + one-line action descriptor (the descriptor is the anchor — UI only — not stored). Avoid 0–10 scales (per MEDICAL_PURPOSE.md — invalid for this patient).

  | Level (stored) | UI label | Action descriptor on chip |
  |---|---|---|
  | 1 | TWITCH | Barely register it |
  | 2 | MILD | Keep doing what I'm doing |
  | 3 | MODERATE | Pause or brace, then continue |
  | 4 | STRONG | Have to stop completely |
  | 5 | SEVERE | Worst I get — full-body lock or loss of control |

  **Clinical scale mapping (export):**
  - Per-spasm intensity → clinical 3-tier: twitch = sub-spasm activity (excluded from spasm count), mild = mild spasm, moderate = moderate spasm, strong + severe = severe spasm (severe additionally flagged with "functional incapacity / approaching status" language — relevant for status spasticus risk assessment).
  - Spasm count per hour → **Penn Spasm Frequency Scale (PSFS)** grade 0–4, computed from counted spasms (twitches excluded per Penn convention).
  - Intensity trajectory across episode → novel, not captured by any standard scale; reported as a per-episode timeline.
- **Save** — single big button. Auto-timestamps. Auto-attaches `episode_id` if an episode is open.

No required fields. If the user is overwhelmed and just taps Save, the entry is `{timestamp, episode_id, location: null, intensity: null}` — the timestamp alone is still useful for spasm frequency analysis.

The first `motor_event` with `episode_id` set automatically populates `episode.ictal_onset` on the parent episode. No separate "ictal start" action is needed.

Weather is captured on the episode's first spasm (cheap; same data as standalone muscle events).

#### Postictal wrap-up ("It's over")

Closes the episode. Auto-fills:
- Total duration (postictal_resolution − prodrome_onset OR ictal_onset)
- Prodrome duration (ictal_onset − prodrome_onset)
- Ictal duration (postictal_resolution − ictal_onset)
- Weather snapshot at resolution

Asks (revised postictal fields — observable anchors, no mechanism interpretation required):
- Communication capacity now (existing scale)
- **Standing up** — "What was standing up like?" — No trouble / Needed momentum or a push / Couldn't stand without help, had to sit
- **Legs after standing** — "Once up, how did your legs feel?" — Normal / Locked at first, loosened with steps / Weak, hard to hold my weight / Both locked and weak
- **Stiffness** — "Are any areas stiff?" — Yes/No → if yes, tap regions (lower back/trunk, R leg, L leg, R arm, L arm, neck, jaw)
- Cane required to walk? (yes/no)
- Myalgia / soreness present? (yes/no, location optional)
- **Did you consider seeking help during this episode?** (yes/no) — care-seeking signal, separated from per-spasm intensity scale
- **Functional impact** — "What did it cost you?" — Stayed active / Had to rest or sit / Needed to lie down / Still impaired hours later (stored as `episodeImpact`)
- Anything notable? (free text)

Note: "Weakness severity" field retired — replaced by the standing-up and legs-after-standing fields which distinguish rigidity (locked/loosened with steps) from true weakness (can't hold weight) without requiring the patient to interpret mechanism.

This is the only screen with structured questions — by the time it appears, the patient is postictal and stable enough to answer.

### Muscle event integration (unified)

In rev 1 of this plan, "Muscle Event" was a separate button that behaved differently inside vs. outside an episode. Rev 2 collapses it: **the per-spasm button and the muscle event button are the same button.** A spasm during an episode and a sub-threshold muscle twitch outside one are clinically the same kind of observation — discrete motor events with location and intensity. The only difference is whether they happen inside an open episode window.

This preserves the SPS-relevant signal flagged in MEDICAL_PURPOSE.md (continuous motor unit activity *between* full spasms is itself a diagnostic feature) without forcing the user to think about which button to use during an event. There's just one motor-event log; the data tells the rest of the story.

---

## Data model changes

### `episodes` collection

```
{
  id: <uuid>,
  prodrome_onset: <timestamp | null>,
  ictal_onset: <timestamp | null>,        // derived: timestamp of first motor_event with this episode_id
  postictal_resolution: <timestamp | null>,
  prodrome_absent: <bool>,
  prodrome_symptoms: [{ symptom, timestamp }],
  postictal: {
    communication_capacity, cane_required, weakness_severity,
    myalgia_present, myalgia_location, notes
  },
  weather_at_prodrome: {...},
  weather_at_resolution: {...},
  status: 'open' | 'closed' | 'auto_closed'
}
```

Note: `ictal_onset` is not stored independently — it's computed from the linked motor_events. This avoids drift between the two.

### `motor_events` collection (unifies jerks and standalone muscle events)

```
{
  id: <uuid>,
  timestamp: <timestamp>,
  episode_id: <uuid | null>,           // null = standalone muscle event
  location: [<region>, ...] | null,    // multi-select; null if user skipped
  intensity: 'light' | 'strong' | 'severe' | null,
  weather: {...}
}
```

Derived per-episode metrics computed at export time:
- `spasm_count` = `motor_events.where(episode_id == this).length`
- `spasm_locations_distribution` = aggregate of `location` arrays across in-episode events
- `spasm_intensity_distribution` = histogram of `intensity` across in-episode events
- `spasm_frequency_per_hour` = `spasm_count / ictal_duration_hours`

### Migration

Existing single-record episodes map to closed episodes with:
- `prodrome_onset` = old prodrome timestamp (if captured) else null
- `postictal_resolution` = old end time
- `prodrome_symptoms` = derived from old prodrome checkbox fields, all sharing the prodrome_onset timestamp (data limitation, flagged in export)
- A single derived `motor_event` is created per old episode using the old "first jerk" timestamp and any old jerk-location data from the legacy schema, so `ictal_onset` resolves correctly
- `status: 'closed'`

No data is lost. Old records are simply less granular than new ones.

---

## Export / report changes

Per-episode export gains:
- Prodrome duration (minutes)
- Prodrome symptom sequence with relative timing (e.g., "T+0: lower back pressure → T+8min: right leg → T+14min: bilateral → T+22min: left arm → T+27min: left facial → T+31min: first spasm")
- Ictal duration (minutes)
- **Spasm count** and **per-hour frequency** within the episode
- **Spasm location distribution** across the episode (e.g., "Legs only: 4 spasms, Legs+arms: 5 spasms, Arms+neck: 2 spasms, Trunk: 1 spasm")
- **Intensity distribution** (light / strong / severe counts)
- **Location drift over time** — useful for documenting whether spasms ascended rostrally during the episode (a propagation signature relevant to spinal myoclonus origin per MEDICAL_PURPOSE.md)

These are the clinically load-bearing additions per MEDICAL_PURPOSE.md §Hypothesis 1 (SPS) and §Hypothesis 5 (cervical myelopathy — right-sided initiation pattern).

---

## Tradeoffs

**Cost:** more taps during an active event, when cognition and motor control are impaired.

**Mitigations:**
- Each button leads to one big-target screen
- Prodrome screen is a tap-as-you-feel-it checklist with no required fields — user can ignore it entirely if she's overwhelmed
- "Jerking started" is a single tap with no follow-up
- "It's over" is the only structured form, and by then she's postictal but stable
- Persistent "episode in progress" indicator means she never has to remember which button to tap next — the UI tells her

**Net effect:** in the worst-case scenario (severe event, no capacity to interact), the data captured is no worse than the current single-button flow (just timestamps for prodrome_onset and postictal_resolution, no detail). In the best case (mild-to-moderate event, capacity to tap), the data captured is dramatically richer than what the current flow can ever produce.

---

## Open questions

- **Q1 — Resolved:** Hide "Warning starting" once an episode is open. The in-progress banner gets a "Cancel episode" affordance for accidental taps — cancellation deletes the open episode entirely (no record created), keeping the data clean.
- **Q2 — Resolved:** Flat list, ordered by typical propagation sequence. Restructured to **sensations only** — twitches/jerks belong in the spasm log (intensity = "light twitch") so the prodrome→ictal boundary stays clean and the prodrome-to-first-spasm latency becomes a measurable quantity. Vocabulary uses "heightened sensation" / "loss of sensation" instead of "tingling" / "numbness" — plain language, more reliable patient interpretation, maps cleanly to clinical paresthesia/anesthesia in exports.
- **Q3 — Resolved:** Final location chip set: right leg, left leg, right arm, left arm, neck, back, face, jaw, around the ribs (squeezing), under the ribs (can't breathe in). Hands roll into arms, feet roll into legs (no isolated distal spasms in patient history). "Trunk" replaced with "back" (patient experiences posterior-only torso spasms; abdomen chip can be added later if pattern changes). Intercostal vs. diaphragm split using anatomical-hint plain-language labels. No "both legs" / "both arms" shortcuts — bilateral involvement is logged by tapping each side, preserving whether involvement was simultaneous vs. sequential. No separate "throat / swallowing" chip — patient has not experienced pharyngeal spasms (would be PERM-relevant brainstem signal if it appears, add then).
- **Q4 — Resolved:** 5-level functional intensity scale (TWITCH / MILD / MODERATE / STRONG / SEVERE) anchored on decision/action per spasm, with one-line action descriptor on each chip. Clinical scale mapping in export: intensity → mild/moderate/severe 3-tier, count → Penn Spasm Frequency Scale. When "SEVERE" is tapped: (1) the parent episode is auto-flagged with `contained_severe_spasm: true` so it surfaces prominently in exports and (2) after saving the spasm, a non-blocking optional prompt offers a single text field for notes. No emergency-contact surfacing — patient prefers to own the escalation decision without app prompting.
- **Q5 — Resolved:** Two-threshold model, since the app is a PWA with no background service.
  - **Prompt threshold — 4 hours of inactivity inside an open episode.** On app open, if the active episode has had no spasm logs and no resolution tap for 4+ hours, prompt: "Your episode is still open but nothing's been logged in 4+ hours. Is it still active, or close it?" Options: `[Still active]` / `[Close — set resolution to last spasm]` / `[Close — let me pick a time]`.
  - **Auto-close threshold — 12 hours since last logged spasm.** If the user never opens the app to respond to the prompt, the episode auto-closes silently-but-flagged.
  - **Auto-close timestamp handling** — follows FHIR / ePRO / seizure-diary methodology: preserve observed data, flag uncertainty, provide context, leave imputation to the analyst. Fields: `postictal_resolution` = last logged spasm timestamp (no fabricated buffer), `resolution_uncertain: true`, `resolution_source: "auto_closed_inactivity_12h"`, `last_known_activity` = timestamp of last spasm, `status: "auto_closed"`. Export footnotes uncertain-resolution episodes with "Duration calculated from last observed spasm; true resolution may be later."
- **Q6 — Resolved:** Recent-episode card on home screen for 1 hour after close (no persistent list — history view handles older episodes). Full amendment model defined, aligned with ALCOA+ / ePRO evidence base / 21 CFR Part 11 where relevant (exports go to specialists, so integrity matters; GxP ceremony deliberately excluded).
  - **Amendment tiers by integrity risk:**
    - **Tier 1 — Freely editable:** notes, postictal wrap-up (communication, cane, weakness, myalgia). Retrospective by design. Audit trail only.
    - **Tier 2 — Editable with reason:** spasm location, spasm intensity, prodrome sensations. Required reason picker: *"tapped wrong chip" / "remembered more detail" / "clinician-requested correction" / "other"*. Original preserved + new value stored.
    - **Tier 3 — Append-only retrospective entry:** adding a missed spasm or missed prodrome sensation. Stored with `captured_retrospectively: true`, `time_since_original_capture` (minutes), required reason. Exports visibly separate real-time vs. retrospective entries — ePRO research shows backfill is the biggest diary data-quality failure, so friction is intentional.
    - **Tier 4 — Correction record (not overwrite):** `prodrome_onset` and `postictal_resolution` timestamps drive headline clinical metrics (prodrome→first-spasm latency, total duration). Original preserved as superseded entry; new value stored as correction with required reason. Export shows both so clinician sees the original real-time tap and the later correction.
  - **No "reopen closed episode" action** (state-machine anti-pattern in clinical docs). Instead:
    - Within 30 min of close: if a late spasm happens, one-time prompt "Was the episode actually still going?" — if yes, resolution timestamp becomes a Tier 4 correction record.
    - After 30 min: late activity is either a new episode (user taps "Warning starting") or a standalone motor event.
  - **Excluded by design:** electronic signatures, external-witness audit, immutable cryptographic log — overkill for single-patient personal-tool use case.
- **Q7 — Resolved:** Button label is **"It's over"**. Patient chose this over first-person alternatives ("I'm done") that more closely match existing app voice patterns ("I just ate") — user preference wins on voice/tone questions.
- **Q8 — Resolved:** Never prompt. Standalone motor events and episodes are fully separate categories; patient explicitly decides between them. Rationale: app-driven nudging biases patient categorization, and standalone muscle events are clinically valuable on their own (sub-threshold motor activity is diagnostically relevant for SPS per MEDICAL_PURPOSE.md). The jerk-without-prodrome path already exists (`prodrome_absent: true` when the user explicitly taps "Warning starting" retroactively or starts an episode directly).

---

## Implementation notes (deferred until open questions resolved)

- All changes live in `index.html` (single-file PWA, per project structure)
- Episode state lives in localStorage under a new `isobar_episodes` key; motor events under `isobar_motor_events`; old `isobar_episode_log` key is read once for migration then deprecated
- "Episode in progress" indicator: sticky banner at top of home screen showing elapsed time + live spasm count, updating every 30s
- Phase buttons: large, full-width, color-coded by phase (warning/active/resolution) using existing color scheme
- "Log a spasm" button is the primary persistent action (visible whether or not an episode is open) — minimizes friction for the most-frequent action during an event
- Prodrome checklist screen reuses the existing chip pattern (Morning Check-in overnight events)
- Per-spasm form reuses chip pattern for location multi-select and segmented control for intensity
- Postictal wrap-up reuses existing form components (communication scale, cane toggle, etc.)

## Related

- **UPDATES.md** — Muscle Event button (planned); this plan integrates with it
- **PLAN_morning_checkin.md** — Morning Check-in restructure (in progress); same design philosophy of capturing data at the natural time, not retrospectively
- **MEDICAL_PURPOSE.md** §Hypothesis 1 (SPS), §Muscle Event Log — clinical rationale for prodrome sequence capture
- **ROADMAP.md** — add a pointer to this plan once approved
