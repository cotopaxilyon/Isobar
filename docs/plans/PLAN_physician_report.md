# Isobar — Physician Report Restructure Plan

**Status:** Shipped — ISO-93  
**Date:** 2026-04-28  
**Scope:** How the exported report should be restructured to be useful to a specialist at a glance

---

## The Problem With the Current Format

The current export is a **chronological data dump**: episodes in reverse time order, then morning check-ins, then evening check-ins, each in isolation. A physician reading it faces:

1. **Scale opacity** — "Quieter than usual," "Edgy," "Somewhat worse," "Much worse" are meaningless without a legend. There's no explanation of *why* these are the metrics, or what clinical construct they map to.
2. **No cross-day synthesis** — a "snapping" event in the evening check-in (4/24) and the 10-jerk episode that night are logically connected but presented in separate sections with no visible link.
3. **Raw environmental numbers with no interpretation** — pressure dwell in hPa, 5h temp swing in °F. The pattern (most episodes cluster in high-dwell / large-drop conditions) is real and striking, but invisible in the per-episode listing.
4. **Motor event granularity front-loaded** — the second thing a doctor sees after the summary table is a list of 10 timestamped jerks with sensation descriptors per body region. That belongs in an appendix.
5. **Data quality issue** — sleep hours are logged as 20, 20.5, 21 in several entries. These appear to be a computation bug (likely AM/PM confusion in the app). A clinician seeing "sleep hours: 20" will either question the patient's credibility or the data's integrity. Must be flagged prominently or corrected before the report goes to a doctor.

---

## Structural Redesign

The report has four jobs:

1. Orient the doctor to who this patient is and why the scales look unusual
2. Give a period summary at a glance (one table)
3. Show the functional timeline with episodes and state co-located by day
4. Surface the environmental and neurological patterns that the raw data implies

Everything else — full motor event logs, raw pressure numbers, per-sensation breakdowns — moves to an appendix.

---

## Section 1 — Clinical Context Header (< half page)

One short paragraph, not a list. Written to be readable by a neurologist, rheumatologist, or autonomic specialist who has not seen this patient before.

**Content:**
- Patient: Cotopaxi Lyon, 37F, Marquette MI
- Diagnostic context: suspected SPS spectrum / autonomic dysfunction / post-COVID dysautonomia; multiple specialists, no coordinator
- Why non-standard scales: autistic, alexithymia, high pain tolerance → numeric self-report systematically under-reports actual state. App uses behavioral anchors validated in behavioral pain assessment literature (DisDAT/NCAPC family, adapted for autistic alexithymic adults)
- Arizona reference: 4 continuous weeks spring 2026 (~85°F stable desert) = near-complete symptom resolution; this is her personal calibration zero

---

## Section 2 — Scale Translation Legend (compact table)

This is the most important addition. Without it, the rest of the report is uninterpretable.

| Isobar Metric | What It Measures | Clinical Framing |
|---|---|---|
| **Communication: Talking easily / Quieter / Shorter / Brief** | Verbal output capacity, post-ictal withdrawal | Behavioral severity proxy; observable by partner; never complete loss of consciousness |
| **Fuse: Normal / Edgy / Sensory overload / Snap-line** | Dysregulation severity, opposite polarity to withdrawal | Both withdrawal and edginess indicate autonomic load exceeding regulatory capacity; edginess = activation pole |
| **Observed snapping (Yes)** | Partner-confirmed behavioral dysregulation event | Externally validated; stronger signal than self-report for alexithymic patients |
| **Episode severity: Somewhat worse / Much worse** | vs. Arizona baseline (near-complete resolution) | "Much worse" = sustained multi-jerk episode with significant functional impact |
| **Functional day: Good / OK / Scaled back / Bad** | Daily function tier | Good = near-normal; OK = managed some limitations; Scaled back = reduced significant activities; Bad = minimal function |
| **Prodrome: fatigue → back pressure → leg energy → left face** | Pre-episode neurological sequence | Reproducible in 9/10 episodes; left face = final sign, episode onset typically within 15 min |

The behavioral anchor approach is specifically chosen because: (a) numeric scales systematically underreport in autistic/alexithymic adults, (b) external observation (partner noticing flat tone or snappiness) is more reliable than interoceptive self-rating for this population, and (c) functional impact ("did she cancel plans, use the cane, nap mid-day?") has high test-retest reliability regardless of alexithymia.

---

## Section 3 — Period Summary Table (one table)

| | |
|---|---|
| **Reporting period** | 4/13/2026 – 4/27/2026 (15 days) |
| **Clinical episodes** | 10 total — 8 with motor events, 2 aborted (prodrome only) |
| **Total motor events (jerks)** | 35 |
| **Episode days** | 8 days with motor activity |
| **Functional day distribution** | Good: 3 / OK: 8 / Scaled back: 3 / Bad: 0 |
| **Overnight sub-threshold activity** | 5 days with nocturnal muscle twitching reported (no daytime episodes) |
| **Partner-confirmed dysregulation** | 3 evenings (4/21, 4/22, 4/24) — edgy or sensory overload; 1 confirmed snapping event (4/24) |
| **Worst episode** | 4/24 — 10 jerks / 4h 55m / excruciating headache / sensory overload + snapping (EOD) |
| **Most notable single exposure** | 4/26 in-flight: altitude ~9,000ft / 22°F thermal drop over Lake Michigan cold air mass |
| **Data quality note** | Sleep hours logged as 20–21h in several entries — likely a computation artifact in the app (AM/PM bug). Actual sleep consistent with bed/wake times (~7–9h). Disregard the raw "sleep hours" figure pending correction. |

---

## Section 4 — Day-by-Day Timeline (1–2 pages)

This is the key structural change. Each day is a single row. Episodes and check-in state are co-located so the doctor can see that 4/24 EOD snapping corresponds directly to that night's 10-jerk episode, and that 4/22 morning stiffness + 4h awakenings follows 4/21's episode cluster.

**Columns:**
- **Date**
- **Morning state** (sleep quality / overnight events / pain / fuse level)
- **Episodes** (count, start time, duration, jerk count, severity tier)
- **Evening state** (fuse level, observed snapping, day trajectory, today overall)
- **Key note** (brief free text — travel, PT, conference, etc.)

**Example row for 4/24:**

| Date | Morning | Episodes | Evening | Note |
|---|---|---|---|---|
| 4/24 | OK sleep, night sweats + twitching, lower back pain | EP9: 9:24pm → 1:19am, 10 jerks, Much worse, chest tightness | Sensory overload, **snapping confirmed**, wiped, got worse (shift ~afternoon) | Last day of conference all week; goosebumps left side post-onset |

The current format buries this. A doctor looking at the 4/24 morning check-in sees "normal irritability, no snapping" — because that's the morning report from before the episode. The 10 jerks happened that evening. The EOD snapping was logged separately. Only the timeline view connects them.

---

## Section 5 — Environmental Pattern Summary (narrative + 2–3 bullet points)

Replace the per-episode raw weather block with an interpreted synthesis. Doctors don't need individual hPa readings — they need the pattern.

**Proposed content:**

> **Barometric pressure:** 9 of 10 episodes occurred during periods where barometric pressure had been sustained below patient threshold for ≥18 of the preceding 48 hours (pressure dwell). The most severe episodes (4/24, 4/21, 4/15) all showed dwell >29 hours. The two aborted episodes (4/17) occurred at 18–21h dwell — below the pattern threshold for full events.

> **Thermal exposure:** 7 of 10 episodes were preceded by a temperature drop ≥13°F within 5 hours. The in-flight 4/26 episode involved a 22°F thermal drop over Lake Michigan (60°F → 38°F) with nearly identical pressure at both waypoints — suggesting thermal exposure was the dominant mechanism, not pressure change, in that event.

> **Nocturnal predominance:** 7 of 8 episodes with motor events began between 9pm and 1am. The sole daytime exception was the in-flight episode (1:50pm), which had unique altitude/thermal exposure. Nocturnal pattern is consistent with circadian autonomic fluctuation (vagal dominance window).

> **Fasting:** Not a primary discriminator in this dataset — most episodes occurred within 1–2h of a meal. No compound fasting + pressure events captured. Does not rule out fasting as a threshold modulator; insufficient n to evaluate.

---

## Section 6 — Neurological Observations

Short synthesized bullets — not a wall of raw data.

**Prodrome reliability:**
- Fatigue + back pressure: present in 9 of 10 episodes (universal early signal)
- Leg energy: present in 7 of 10 (mid-stage)
- Left facial tingling: present in 3 of 10 (late sign; when present, episode onset within 8–15 min)
- Prodrome duration: range 0–139 min; median ~29 min; 2 episodes with no prodrome (5 and partially 1)

**Laterality:**
- Left-predominant sustained episodes: 4/21, 4/23, 4/24 (episodes 6, 7, 8, 9)
- Right-predominant: 4/15, 4/19, 4/26 (episodes 1, 4, 10)
- No clear bilateral-symmetric episodes; each episode has a dominant side

**Postictal communication:**
- "Quieter than usual" in 8 of 10 episodes with observable postictal state
- No loss of consciousness or complete verbal loss reported in any episode
- Partner-confirmed in all observed episodes

**Chest tightness:**
- Present in 4 of 8 motor episodes (episodes 1, 6, 9, 10)
- Consistently coincides with first jerk in severe episodes (not prodromal)

**Sub-threshold nocturnal activity:**
- Overnight muscle twitching reported 5 mornings independent of any logged episode
- Suggests ongoing low-level motor activity below the episode threshold on "quiet" nights

---

## Section 7 — Appendix: Full Episode Detail

Everything currently in the "Clinical Episodes" section moves here. Full motor event logs, sensation descriptors, raw weather readings, prodrome timestamps. Physicians who want to drill into a specific event can, but the body of the report doesn't require them to.

---

## What This Plan Does Not Change

- The underlying data or app logic — this is purely a **report format** change
- The per-episode data itself (still all present, in the appendix)
- The custom scale philosophy — we translate, not replace

---

## Open Questions Before Implementation

1. **Sleep hours bug** — confirm whether this is a display calculation error or a storage error. If storage, the raw data is corrupted and the report should note it explicitly. If display, fix the calculation before the report goes to a doctor.
2. **Appendix granularity** — does the physician want per-jerk sensation descriptors, or just jerk count + dominant body region per episode? The current detail level (4 jerks with "Tight, Aching, Pressure, Squeezing" per region per jerk) is very granular. One row per jerk (time, side, dominant region) is probably sufficient.
3. **Scale translation placement** — as a legend before the summary table, or as a footnote? Argument for front: doctor needs it before they can read anything else. Argument for footnote: interrupts flow. Recommendation: front, as a compact collapsible or boxed sidebar.
4. **Export format** — MD file works for now, but for a specialist visit a PDF or printed page is more appropriate. Out of scope for this plan but worth noting.
