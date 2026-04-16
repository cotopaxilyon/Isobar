# Isobar — Morning Check-in Restructure (Plan)

---

## Session Status (2026-04-15)

**Phase:** Design / open-question review. Not yet implemented.

**Resolved open questions:**
- **Q1** — "Slept through — nothing noticed" chip: keep, pin to bottom, mutually exclusive with other overnight-event selections.
- **Q2** — Stiffness labels: **"Morning stiffness"** with prompt *"How long until you loosened up?"* for the inflammatory/rheumatology signal; separate SPS chip relabeled **"Woke up locked / couldn't move"** to distinguish the two phenomena.
- **Q3** — `hormonalSymptoms` field: remove now. Data gap accepted until the Hormonal Cycle Tracker (ROADMAP §3) ships.

**Open / in progress:**
- **Q4** — **Resolved:** drop the First Stand (Orthostatic) step entirely. User confirmed she notices nothing on first stand in the morning. A daily checklist of symptoms she doesn't experience would produce misleading negative data (inflating "no orthostatic symptoms" counts in the export) and violates the personalization principle in PROM design. If orthostatic symptoms emerge later in the day they can be captured reactively in episode/muscle event logs, or a dedicated orthostatic log can be added if the pattern changes.
- **Q5** — Step count now resolves to **5** (Sleep, Overnight Events, Communication, Body, Arizona + Notes) since dropping Q4's step removes one. No further decision needed.

**After all open questions resolve:** update the step-structure section, then move to implementation in `index.html`.

**Related roadmap items added this session:** ROADMAP §3 (Hormonal Cycle Tracker) and §4 (Reminders & Notifications).

---

## Purpose

Convert the current "Daily Check-in" into a **Morning Check-in** optimized for capturing baseline / pre-episode state rather than end-of-day accumulated burden.

## Why this change

The current check-in mixes three kinds of questions:

1. **Morning-natural** (sleep, current pain, current communication, Arizona comparison)
2. **Evening-natural** (exhaustion functional anchors, work capacity, cancelled plans, heat therapy used today)
3. **Prospective/impossible-at-either-time** (predicting today's exhaustion in the morning, or remembering last night's sleep quality accurately in the evening)

This forces a compromise that produces worse data regardless of when the user fills it out.

Per MEDICAL_PURPOSE.md, the primary clinical purpose is documenting **prodromal / pre-episode baseline state** for specialist evaluation (SPS workup in particular). A morning-anchored check-in captures this baseline uncontaminated by the day's exertion, fasting, weather exposure, and accumulated load.

Evening-relevant data (what actually happened today, what broke down) is already captured by episode logs and muscle event logs in real time, so there is no data loss from removing those fields from a scheduled daily check-in.

## Research basis

| Item | Source | Why it belongs in the morning |
|---|---|---|
| Sleep parameters (bedtime, latency, wake time, quality) | Consensus Sleep Diary (Carney, Buysse et al. 2012) | Overnight recall is freshest on waking; evening recall is unreliable |
| Morning stiffness | Rheumatology literature (RA, PMR, Sjögren's, UCTD) | Validated inflammatory vs mechanical pain discriminator — only measurable in the morning |
| Orthostatic symptoms on first stand | POTS / dysautonomia literature, COMPASS-31 | Getting out of bed is the day's largest orthostatic challenge; strongest signal |
| Wake-state alertness | Morningness-Eveningness Questionnaire (MEQ) | Defined as a first-30-minutes-after-waking construct |
| Overnight neurological events | SPS literature (nocturnal spasms, sleep-onset stiffening) | Lost if logged 14+ hours later |
| Starting communication level | This project's existing severity proxy | Captures baseline before daily load compresses it |
| Starting pain body map | This project's existing structure | Body map at wake is the cleanest comparison point day-to-day |
| Arizona baseline comparison | This project's existing severity anchor | Morning-to-morning is the least biased comparison (Arizona was a stable whole-day state) |

## Design Principles

1. **Baseline, not summary.** Every question is about overnight or right-now, not about "today."
2. **No prospective questions.** We do not ask her to predict the day.
3. **Retrospective PEM is not scheduled.** PEM lags 24–72 hours (up to 3–5 days per CFS literature), so daily retrospective PEM questions produce noise. Omit.
4. **Evening-appropriate questions move out of the daily flow**, not into an evening check-in. Episode logs and muscle event logs already capture real-time degradation. Adding a second scheduled daily form contradicts the "works when she is at her worst" constraint.
5. **Same design constraints as the rest of the app** — no numeric pain scales, functional anchors only, large tap targets, no required fields.

---

## New Step Structure

Current: 6 steps (Communication → Body Map → Exhaustion & Function → Sleep & Hormones → Arizona → Notes)

Proposed: **5 steps**, different content.

```
Step 0 — Overnight Sleep
Step 1 — Overnight Events
Step 2 — Right Now: Communication
Step 3 — Right Now: Body
Step 4 — Arizona Comparison + Notes
```

### Step 0 — Overnight Sleep

Replaces existing Step 3 (Sleep & Hormones) sleep portion, expanded per Consensus Sleep Diary core items. Kept minimal — not a full CSD, just the items that matter for her trend data.

**Fields:**
- **Date** (defaults to today, editable — same control as now)
- **What time did you get into bed?** — time input, optional
- **What time did you get out of bed for the day?** — time input, optional
- **How many times did you wake up during the night?** — number, optional
- **Sleep quality** — existing 4-choice control: `Restorative / Somewhat / Poor / RLS bad`

**Data keys:**
- `sleep` (existing) — keep as-is
- `sleepBedTime` (new, nullable string `"HH:MM"`)
- `sleepWakeTime` (new, nullable string `"HH:MM"`)
- `sleepAwakenings` (new, nullable number)

Nothing is required. Skipping sleep times is fine — the sleep quality rating alone is still useful.

### Step 1 — Overnight Events

New step. Captures nocturnal neurological activity that sub-threshold muscle event logging misses because she was asleep.

**Fields:**
- **Did anything happen overnight?** — multi-select chips:
  - Muscle twitching
  - Jaw spasming / clenching
  - Intercostal / rib spasms
  - Woke up locked / couldn't move *(captures SPS-style rigidity — sustained co-contraction, distinct from inflammatory morning stiffness)*
  - Night sweats
  - Breathing trouble / choking sensation
  - Woke in pain
  - Slept through — nothing noticed *(pinned to bottom; mutually exclusive — selecting this clears other selections, selecting any other clears this)*
- **Morning stiffness** — prompt: *"How long until you loosened up?"* — single-select: `None / <15 min / 15–60 min / 1+ hours / Still stiff`. The "loosen up" framing anchors this as the inflammatory/rheumatologic pattern, distinct from the SPS-style "locked" chip above.

Morning stiffness is a validated rheumatology indicator (longer duration = more likely inflammatory). This is not currently captured anywhere in the app.

**Data keys:**
- `overnightEvents` (new, array of strings)
- `morningStiffness` (new, string — one of `none / under_15 / 15_to_60 / over_60 / ongoing`)

### Step 2 — Right Now: Communication

Keeps the existing Step 0 content unchanged. Communication capacity at wake is the cleanest baseline severity reading.

**No changes.** `communicationLevel` and `externalObservation` unchanged.

(Note: the current sub-label "Right now" already reads correctly for a morning context.)

### Step 3 — Right Now: Body

Keeps the existing Step 1 body map unchanged. Labeled "right now" semantics reinforced in the step subtitle.

**No changes** to `bodyPain` structure or `bodyMap()` function.

Step subtitle changes from `"Tap anywhere that hurts"` to `"Tap anywhere that hurts right now"` — small wording change to anchor temporally.

### Step 4 — Arizona Comparison + Notes

Merges the existing Arizona severity chooser and notes textarea into one screen.

**Fields:**
- Existing Arizona severity chooser (`severity` key) — **no changes**
- Existing notes textarea (`notes` key) — **no changes**

---

## Fields Removed from Daily Check-in

The following fields are removed from the check-in form and its underlying `ciData` object. This is intentional — they were either prospective guesses or belong in different entry types.

| Removed field | Reason | Where to capture instead |
|---|---|---|
| `nap`, `napHours` | Can't be known in the morning | Add to end-of-day optional "quick nap log" later if needed; not a diagnostic priority |
| `workCapacity` | Prospective in morning | Captured implicitly by cancelled plans / activity patterns over time |
| `cancelledPlans` | Prospective in morning | Could be an optional evening reflection later if useful |
| `heatTherapy` | Prospective in morning | Better as a real-time log when used |
| `hormonalSymptoms` | Daily yes/no produces noise; cycle phase is what matters | Move to a separate weekly/cycle tracker later (out of scope for this plan) |
| `episodesSinceLast` | Redundant — episodes are logged individually with timestamps | Derivable from episode entries; remove |

Removing these fields is a **one-way data change**. Historical check-ins already saved with these keys are unaffected — the code that reads them for the export report can continue to do so (guard for presence). The new form simply stops collecting them.

---

## Files to Change

Only one file: `index.html`

Specific locations:

| Change | Location |
|---|---|
| `CI_STEPS` array | lines ~1056–1063 |
| `startCheckin()` `ciData` init | lines ~1065–1079 |
| `renderCiStep()` case statements | lines ~1099–1198 |
| Step subtitle for body map | within case 3 (new) / via CI_STEPS |
| Home screen "Daily Check-in" button label | line ~418 — change to **"Morning Check-in"** |
| `exportReport()` check-in section | lines ~1339+ — add new fields to the printed report |
| Stats label | `stat-checkins` label if needed; currently reads "Check-ins" — fine as-is |

No CSS changes required. No changes to `bodyMap()`. No changes to storage schema (additive only — new keys, no renames).

---

## Implementation Steps

### Step 1 — Update `CI_STEPS` and `ciData` init

Replace the 6-step array and the `ciData` default object in `startCheckin()`. Remove removed keys, add new keys (all null/empty defaults).

### Step 2 — Rewrite `renderCiStep()` switch

Five cases total, in chronological order:

```
0 — Overnight Sleep       (new — expanded per Consensus Sleep Diary)
1 — Overnight Events      (new — chips + morning-stiffness duration)
2 — Right Now: Communication  (existing content, reordered)
3 — Right Now: Body           (existing body map, updated subtitle)
4 — Arizona + Notes           (merges existing Arizona + Notes into one screen)
```

Update `CI_STEPS` titles/subs accordingly.

### Step 3 — Home screen label

Change the action-card title from `"Daily Check-in"` to `"Morning Check-in"` (line 418). Subtitle/description updated if one exists.

### Step 4 — Export report

In `exportReport()`, the check-in section should print the new fields when present. Use optional chaining / presence checks so historical entries without these fields render cleanly. Specifically include:

- Sleep times and awakenings if present
- Overnight events array if non-empty
- Morning stiffness duration if present

### Step 5 — Legacy-entry tolerance

No schema migration needed. Old entries have the removed keys; new entries won't. The log view and export already iterate keys defensively. Spot-check the log-card chip rendering still works for both shapes.

---

## Testing Steps

1. Open app → **Morning Check-in** (home screen label).
2. Confirm progress bar shows 5 segments.
3. Step through each of the 5 screens. All optional — confirm "Next" works with nothing entered.
4. On Step 0 (Sleep), enter bed time + wake time + awakenings + quality. Confirm values persist across Back/Next.
5. On Step 1 (Overnight Events): multi-select a few chips; then tap **"Slept through — nothing noticed"** and confirm it clears the others; then tap any other chip and confirm it clears the "Slept through" selection. Also verify the morning-stiffness single-select persists.
6. Step 2 (Communication) and Step 3 (Body) behave as today; body-map subtitle reads "Tap anywhere that hurts right now".
7. Step 4 — Arizona choice + notes persist on one screen.
9. Save. Confirm entry appears in log with the existing card format (existing chips still render; new fields visible only in export).
10. Run **Export Report**. Confirm new fields appear in the DAILY CHECK-INS section, historical entries render without errors.
11. Open Ongoing stats — `stat-checkins` increments correctly.
12. Load an existing (pre-update) saved check-in via log view — confirm it still opens / displays without errors.

---

## Open Questions

1. ~~**"Nothing noticed" chip behavior**~~ — **Resolved:** keep the chip, rename to **"Slept through — nothing noticed,"** pin to bottom, mutually exclusive with other selections. Per multi-select / PRO design research: affirmative "nothing" distinguishes assessed-quiet from skipped, and mutual exclusivity prevents ambiguous both-states entries.
2. ~~**Morning stiffness wording**~~ — **Resolved:** use **"Morning stiffness"** with prompt *"How long until you loosened up?"*. The related SPS-pattern chip in Overnight Events is relabeled **"Woke up locked / couldn't move"** to sharpen the distinction between inflammatory stiffness (rheumatology signal) and sustained rigidity (neurology/SPS signal).
3. ~~**Keep `hormonalSymptoms` field**~~ — **Resolved:** remove now. Historical entries retain the field; the morning check-in no longer collects it. Hormonal data will be picked up by the cycle tracker (see ROADMAP.md §3).
4. ~~**First Stand (Orthostatic) step**~~ — **Resolved:** drop the step entirely. User does not experience orthostatic symptoms on first stand in the morning. A checklist of symptoms she doesn't have would inflate negative data and violate PROM personalization principles. Any future orthostatic signal can be captured reactively in episode/muscle logs.
5. ~~**Step count**~~ — **Resolved:** 5 steps (Sleep, Overnight Events, Communication, Body, Arizona + Notes), as a consequence of Q4.

---

## Out of Scope for This Plan

- Adding an evening check-in (explicitly rejected above — episode/muscle logs cover this ground in real time)
- Hormonal cycle tracker (tracked in ROADMAP §3)
- Nap logging (separate, minor)
- Schema migration for old entries (not needed — additive-only change)
- Reminders / notifications to prompt morning logging (tracked in ROADMAP §4)
