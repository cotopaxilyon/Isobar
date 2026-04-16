# Isobar — Environmental & Behavioral Trigger Analysis (Findings)

Compiled 2026-04-15. Twelve events analyzed with Open-Meteo historical weather data against patient-reported event logs. Supports `PLAN_environmental_risk.md`.

---

## Medication timeline

| Period | Medication | Notes |
|---|---|---|
| 2025 (pre–Oct 18 onward) | Gabapentin 600mg doses | Taken for cervical nerve pain (neck), not for episode control. Incidental GABAergic coverage during Oct 18–Nov 1 events. |
| 2026-02-06 → 2026-02-15 | Benzodiazepine trial (10 days) | Therapeutic for SPS-spectrum. Partial response: reduced frequency/severity but breakthrough on specific triggers. |
| 2026-02-16 → 2026-03-12 | Gap (medication unclear) | — |
| 2026-03-13 → present | Zonisamide 200mg | Anticonvulsant with anti-myoclonic properties (Na+ channel + carbonic anhydrase; minor GABAergic). Active during Apr 6 Flagstaff event and Apr 15 cluster. |

---

## Full event scoreboard

### Axis definitions

The thresholds below (−5 hPa pressure offset, ≥10°F over 5h for thermal axes) are **hypothesis-generating cutoffs derived from this same set of 14 events**, not prospectively validated. They are the smallest-unit descriptions that cleanly separate the analyzed events; prospective confirmation on new events is still needed before treating them as clinical decision thresholds.

- **Axis A — Pressure dwell:** hours in past 48 below (72h rolling peak − 5 hPa)
- **Axis B — Rapid thermal drop:** max 5h temperature drop in past 8h
- **Axis C — Rapid thermal rise:** max 5h temperature rise in past 8h

### Scoreboard

| # | Event | Location | Medication | Axis A | Axis B | Axis C | Non-env triggers | Verdict |
|---|---|---|---|---|---|---|---|---|
| 1 | April 2026 "976.5 hPa" compound | Marquette | ? | **red** | — | — | 7h fasted, dog exposure, driving through front | Environmental + compound |
| 2 | 2026-04-06 Flagstaff | Flagstaff AZ | Zonisamide | **red** (~40h dwell) | green | green | — | Environmental (pressure) |
| 3 | Arizona 98→45°F crash | AZ desert | ? | green | **red** (~53°F / 1.5h) | green | — | Environmental (thermal drop) |
| 4 | Arizona 75→95°F climb | AZ desert | ? | green | green | **red** (~20°F / 1h) | — | Environmental (thermal rise) |
| 5 | 2026-03-09 Traverse | Traverse City | Pre-zonisamide | green | **red** (14.7°F / 3h) | green | — | Environmental (thermal drop) |
| 6 | 2026-03-11 Traverse | Traverse City | Pre-zonisamide | **red** (sustained post-drop) | green | green | — | Environmental (pressure) |
| 7 | 2026-04-15 cluster (7 episodes) | Marquette | Zonisamide | **red** (~48h dwell) | green | green | — | Environmental (pressure) — **breakthrough on zonisamide** |
| 8 | 2025-10-18 | Marquette | Gabapentin 600mg | **red** (~20 hPa below peak, 24+h) | green | **red** (+14.8°F / 5h) | Airport AM shift | Compound environmental + exertion |
| 9 | 2025-10-20 | Marquette → Escanaba | Gabapentin 600mg | amber (late) | green | amber (+12.1°F / 5h) | Airport AM shift + acupuncture + chiropractor | Exertion-dominant with partial environmental |
| 10 | 2025-10-26 | Marquette area | Gabapentin | green | green | amber (+12.1°F / 5h) | 1-mile hike pre-event | Exertion-dominant |
| 11 | 2025-11-01 (02:30am) | Marquette | Gabapentin | green | green | green | Overnight airport shift ending 01:30 → event 02:30 (1h later) | **Pure exertion** (no env signal) |
| 12 | 2026-02-09 Marquette→Traverse drive | Traverse (arriving) | Benzo | **red** (20h dwell + 16.8 hPa drop through day) | green | green | 5h car ride (episode 4h in) | Environmental + car ride |
| 13 | 2026-02-12 Traverse (8pm) | Traverse City | Benzo | green | green | green | 5h sleep the prior night; psilocybin at 17:15 | **Sleep-deprivation–dominant** (no env signal). Psilocybin has since been used repeatedly without an episode, so it is at most a modifier, not the primary driver. |
| 14 | 2026-02-15 Eben ice caves + drive | Marquette area | Benzo | **red** (22h of day below peak−5) | green | green | Cold exposure + 5h car ride | Environmental + cold + car ride |

### Retrospective classification performance

**This is retrospective classification, not validated prediction.** The axis thresholds were chosen after inspecting these same 14 events, so the separation below is in-sample fit — it tells us the three axes are a coherent way to describe what happened, not that they will predict future events at the same rate. Prospective validation on events logged *after* the thresholds were fixed is required before making predictive claims.

| | Events with a documented environmental signature | Events explained by non-environmental mechanisms |
|---|---|---|
| At least one axis fires (in-sample) | 12 / 12 | 0 / 2 |
| All axes green (in-sample) | 0 / 12 | 2 / 2 (Nov 1 post-shift exertion; Feb 12 sleep deprivation ± psilocybin) |

Read as: across the analyzed set, the three axes cleanly separate environmentally-signatured events from non-environmental events. This is promising but not yet a validated predictive model.

---

## Trigger classes identified

### Class 1 — Environmental (captured by three-axis model)
- Sustained low-pressure dwell (hours below 72h peak − 5 hPa)
- Rapid thermal drop (≥10°F over 5h)
- Rapid thermal rise (≥10°F over 5h)

### Class 2 — Exertional / sleep disruption (NOT captured by current app)
- Overnight work shifts (Oct 18, Oct 20, Nov 1)
- Extended physical work (Oct 26 hike)
- Sleep <6h (Feb 12)
- Compound effect with environmental multiplies severity (Oct 18)

### Class 3 — Prolonged stillness / car travel (NOT captured by current app)
- Documented triggering events at 4–5h mark of car rides: Feb 9, Feb 15
- Distinct from "exertion" — happens during passive sitting, not during activity
- Active movement (skiing Feb 8, Feb 14) was tolerated on same drug regimen
- Mechanism likely orthostatic + autonomic (POTS-consistent)

### Class 4 — Sleep deprivation, with serotonergic drugs as a possible modifier (NOT captured by current app)
- Feb 12 was originally attributed to psilocybin; repeated psilocybin exposures since Feb 12 have **not** produced episodes, which reframes that event as **sleep-deprivation–dominant** (5h sleep the prior night) with psilocybin at most a modifier on top of a lowered threshold.
- Prior documented SNRI exacerbation in patient history keeps serotonergic agents on the monitor list as a potential modifier, but they are not supported as a standalone trigger by the current data.
- Clinical takeaway: quantified sleep hours is the single highest-value missing variable; daily psychoactive-substance logging captures the pattern without presuming causation (see `PLAN_trigger_surface_expansion.md`).

### Class 5 — Compound triggers (most severe events)
- Oct 18: airport shift + Axis A red + Axis C red → 2-hour twitch episode
- Feb 15: cold exposure + car ride + Axis A red
- April 976.5: low pressure + fasting + dog exposure + driving through front
- **Pattern: the worst events always combine ≥2 trigger classes.**

---

## Medication response patterns

### Gabapentin 600mg (Oct 2025 events)
- Taken for cervical nerve pain, not for episode control
- Present in bloodstream during Oct 18, 20, 26, Nov 1 events
- Events still occurred — expected, since dose/indication was not episode-targeted

### Benzodiazepine trial (Feb 6–15 2026)
- **Partial response pattern**, not the "dramatic SPS relief" typical of full SPS
- Asymptomatic on active-movement days with calm weather (Feb 8 skiing, Feb 14 skiing)
- Breakthrough on specific triggers: long drives (2/9, 2/15), serotonergic drug interaction (2/12), cold + car compound (2/15)
- Events that did occur resolved faster after re-dosing
- **Interpretation: drug provides meaningful background tone but insufficient to override high-magnitude compound triggers**

### Zonisamide 200mg (Mar 13 2026 – present)
- Anti-myoclonic mechanism (sodium channel + carbonic anhydrase; minor GABAergic)
- Apr 6 Flagstaff event: Axis A red breakthrough
- Apr 15 cluster (today): Axis A red breakthrough, 7 episodes in ~2.5h
- **Breaking through zonisamide during sustained low-pressure dwell** — environmental trigger magnitude exceeding anti-myoclonic drug coverage

---

## Clinical summary draft (for specialist compilation)

> **Longitudinal environmental and behavioral trigger analysis (n=14 events, Oct 2025 – Apr 2026):**
>
> The patient's episodic neurological events have been analyzed against hourly historical weather data and contemporaneous behavioral/medication logs. Twelve events had a clear environmental signature on at least one of three independent axes (sustained low-pressure dwell of ≥24h below local 72h peak minus 5 hPa; rapid thermal drop ≥10°F over 5h; rapid thermal rise ≥10°F over 5h). Two events had no environmental signature and were explained by non-environmental mechanisms (post-overnight-shift exertion; sleep deprivation, ~5h the prior night). The axis thresholds above are hypothesis-generating cutoffs derived from this retrospective set and have not yet been prospectively validated.
>
> Identified trigger classes:
> 1. **Sustained low-pressure dwell after front passage** — most common, accounts for majority of recent clustered events.
> 2. **Rapid acute thermal transitions** — demonstrated by Arizona-baseline breakthroughs (98→45°F in 1.5h; 75→95°F in 1h) and Traverse City 3/9 event (14.7°F drop in 3h).
> 3. **Prolonged passive sitting / car travel ≥4h** — distinct from active exertion; active movement (skiing) was tolerated on same drug regimen on adjacent days. POTS/autonomic-consistent.
> 4. **Overnight physical work shifts** — events occur within 1–15h of shift end; short lag suggests direct exertional decompensation rather than delayed PEM.
> 5. **Sleep deprivation** — Feb 12 event occurred on ~5h sleep the prior night. Initially attributed to psilocybin co-exposure, but repeated psilocybin use since Feb 12 has not produced episodes, so sleep deprivation is the more likely primary driver. Documented SNRI exacerbation in the patient's history keeps serotonergic agents on the monitor list as a possible modifier, but the current data does not support them as standalone triggers.
>
> Compound triggers (≥2 classes co-occurring) consistently produce the most severe events.
>
> Medication response: benzodiazepine trial produced partial but incomplete response — breakthrough on high-magnitude compound triggers despite asymptomatic days on single-trigger or calm-environment days. Active zonisamide 200mg monotherapy has not prevented environmentally-triggered clusters (today's event cluster is active during sustained low-pressure dwell). Partial-but-incomplete benzo response is clinically suggestive of SPS-spectrum rather than generalized movement disorder or pure anticonvulsant-responsive myoclonus.
>
> Right-sided dominance (right leg first, progressing to right arm, occasional left facial involvement) observed across all events with limb distribution data.

---

## Remaining data gaps

- April "976.5 hPa compound event" — exact date/time not reconfirmed; would be worth nailing down to validate the Axis A analysis precisely.
- Arizona thermal breakthrough dates unknown — approximate dates would allow retroactive weather verification.
- Medication status during Oct 19, Oct 20 detailed hour-by-hour (gabapentin dose timing noted but full day's dose pattern not captured).
- Feb 16 – Mar 12 medication status (transition period between benzo and zonisamide).

---

## Next recommended work

1. Implement `PLAN_environmental_risk.md` (three-axis model) in `index.html`.
2. Add logging fields for non-environmental trigger classes (airport shift / long car ride / serotonergic drug) to the episode log.
3. Update `MEDICAL_PURPOSE.md` Arizona-baseline description per PLAN Step 8.
4. Consider paste-ready specialist-compilation document drawing from this findings file + existing event logs.
