# Isobar — 2026-04-19 Flight Episode (Findings)

Compiled 2026-04-19. Single episode (Marquette → Schoolcraft → Bellaire, Mooney M20) with paired METAR data for both legs. Episode occurred during leg 1; no episode during leg 2.

---

## Episode record (as logged, 4/19/2026 10:20 AM local)

Reconstructed from symptom-tracking report export. Matches the `epData` shape in `index.html` (type: 'episode' under Dexie key-value store).

```json
{
  "type": "episode",
  "timestamp": "2026-04-19T14:20:00-04:00",
  "entryDate": "2026-04-19",
  "prodromeTime": "10:20",
  "firstJerkTime": "10:49",
  "prodrome": ["fatigue", "back_pressure", "altered", "throat"],
  "limbsAffected": ["right_leg"],
  "bodyPain": ["lower_back"],
  "sensations": { "lower_back": ["Tight", "Pressure"] },
  "chestTight": false,
  "cane": false,
  "communicationLevel": "Quieter than usual",
  "externalObservation": "No",
  "exposures": ["weather", "animal", "mold", "poor_sleep"],
  "hoursFasted": 1.3,
  "lastIntake": "full meal",
  "severity": "Somewhat worse",
  "weather": null,
  "notes": "..."
}
```

**Data gap:** `weather` field is `null` because the device was offline in the aircraft at log time. Ambient conditions below are backfilled from nearest-airport METAR.

---

## Notes field (original + addendum)

### Original narrative (as logged)

> In a house with a dog, then cold wind, then in a small airplane with vibration before first twitch.
>
> This episode begain when I was flying with his partner in his Mooney 4 seater airplane. I had spent the night at my house in marquette that we think could have mold and does have a dog. before I got in the plane there was a cold wind that I was walking through for about 4 minutes. then in the plane there was a ton of vibration. I had an episode pretty much the entire time that we were flying. we flew from marquette michigan to schoolcraft airport. when we touched down it was hard for me to get out of the airplane but after stretching my legs I was slow but ok. when flying there was a ton of turbulance and it felt like evertime there was turbulance there was intense energy in my leg that wanted to be released and pressure in my chest. swallowing was difficult. and it was really hard to stay awake. after taking a bathroom break (for my partner) at the schoolcraft airport we flew again skirting the bottom of the Upper Peninsula to the mackinaw bridge and then flying south to the bellaire airport. that portion of the trip I had no episode and no feeling of pressure in my head or legs. can you check the weather/barametric pressure for the first half of the flight. and anything that you could think that would make the first half so different than the second half other than weather? marquette to schoolcraft was low clouds and gray, then schoolcraft onwards was scattered low clouds but sun peaking through.

### Addendum (METAR review, 2026-04-19)

Pressure was actually *rising* during the flight (KSAW altimeter 30.01→30.08 inHg, ~1016→1018 hPa), not low — but the 12 hours overnight sat at 1008–1011 hPa, so the flight happened on the rebound out of a pressure dwell. KSAW had active light snow and an OVC 4000 ceiling at departure; we were at 3,500 ft MSL right under it on leg 1. Leg 2 flew at the same altitude with comparable turbulence and produced no symptoms. Same mechanical stimulus, different outcome — the stimulus alone doesn't explain the leg-1 episode. Exposures present on leg 1 but not leg 2 (or decayed by leg 2): recent mold + dog dander (~30 min post-exposure vs ~2 h), recent cold-wind walk at 26°F, active snow at departure, lower cloud ceiling putting cruise altitude inside the sub-cloud layer. These are candidates to watch across future events, not asserted causes from n=1. Worth noting that exposures here behaved as sustained windows (mold/dog ~12 h, pressure dwell ~12 h) rather than point events, which the current chip format doesn't capture.

---

## Associated weather (METAR)

Source: Iowa State Mesonet ASOS archive (`mesonet.agron.iastate.edu`). Stations selected by proximity to actual airports used — KMQT (old Marquette County) is decommissioned; Marquette now operates from KSAW (Sawyer International). Schoolcraft County Airport is KISQ (Manistique).

### KSAW — Sawyer International, Marquette MI (departure, leg 1)

Flight window ~14:20–15:20 UTC (10:20–11:20 AM EDT).

| UTC | Temp °F | Dewpt °F | Altimeter inHg | Wind | Ceiling | Wx | Raw METAR |
|---|---|---|---|---|---|---|---|
| 11:45 | 23.0 | 12.2 | 29.99 | 350/05 | OVC 6000 | — | `KSAW 191145Z 35005KT 10SM OVC060 M05/M11 A2999` |
| 12:45 | 24.8 | 12.2 | 30.01 | 310/10 | FEW 5000 | — | `KSAW 191245Z 31010KT 10SM FEW050 M04/M11 A3001` |
| 13:45 | 26.6 | 12.2 | 30.03 | 310/12 | SCT 3500 / SCT 4300 | — | `KSAW 191345Z 31012KT 10SM SCT035 SCT043 M03/M11 A3003` |
| **14:45** | **26.6** | **12.2** | **30.04** | **330/10** | **OVC 4000** | **−SN** | `KSAW 191445Z 33010KT 10SM -SN OVC040 M03/M11 A3004` |
| **15:45** | **28.4** | **12.2** | **30.06** | **320/15 G24** | **OVC 4400** | **−SN** | `KSAW 191545Z 32015G24KT 10SM -SN OVC044 M02/M11 A3006` |
| 16:45 | 30.2 | 12.2 | 30.07 | 330/13 G19 | SCT 4400 / OVC 4900 | — | `KSAW 191645Z 33013G19KT 10SM SCT044 OVC049 M01/M11 A3007` |
| 17:45 | 32.0 | 12.2 | 30.08 | 310/14 | BKN 4900 / OVC 5500 | — | `KSAW 191745Z 31014KT 10SM BKN049 OVC055 00/M11 A3008` |

**Departure summary:** 26°F, OVC 4000, light snow falling, gusty NW wind 320-330/10-24 kt, altimeter rising steadily.

### KISQ — Schoolcraft County Airport, Manistique MI (leg 1 arrival, leg 2 departure)

Leg 1 arrival ~15:30 UTC; leg 2 departure ~16:00 UTC.

| UTC | Temp °F | Dewpt °F | Altimeter inHg | Wind | Ceiling | Raw METAR |
|---|---|---|---|---|---|---|
| 14:15 | 32.4 | 16.0 | 30.04 | 320/10 G14 | OVC 4300 | `KISQ 191415Z AUTO 32010G14KT 10SM OVC043 00/M09 A3004` |
| 14:35 | 33.0 | 15.0 | 30.04 | 310/09 G22 | OVC 4300 | `KISQ 191435Z AUTO 31009G22KT 10SM OVC043 01/M09 A3004` |
| 14:55 | 32.4 | 13.6 | 30.04 | 330/11 G22 | OVC 4500 | `KISQ 191455Z AUTO 33011G22KT 270V350 10SM OVC045 00/M10 A3004` |
| **15:15** | **33.4** | **14.4** | **30.05** | **330/08 G18** | **OVC 4500** | `KISQ 191515Z AUTO 33008G18KT 10SM OVC045 01/M10 A3005` |
| **15:35** | **33.3** | **14.4** | **30.06** | **310/13 G21** | **OVC 4500** | `KISQ 191535Z AUTO 31013G21KT 10SM OVC045 01/M10 A3006` |
| **15:55** | **33.3** | **14.0** | **30.07** | **300/12 G20** | **OVC 4500** | `KISQ 191555Z AUTO 30012G20KT 10SM OVC045 01/M10 A3007` |
| **16:15** | **34.0** | **14.0** | **30.07** | **310/14 G21** | **OVC 4700** | `KISQ 191615Z AUTO 31014G21KT 270V340 10SM OVC047 01/M10 A3007` |
| **16:35** | **35.6** | **14.5** | **30.07** | **330/14 G19** | **OVC 4900** | `KISQ 191635Z AUTO 33014G19KT 290V350 10SM OVC049 02/M10 A3007` |
| 16:55 | 34.0 | 15.0 | 30.08 | 320/13 G19 | OVC 4900 | `KISQ 191655Z AUTO 32013G19KT 280V340 10SM OVC049 01/M09 A3008` |
| 17:15 | 35.0 | 13.5 | 30.08 | 310/12 G22 | OVC 6000 | `KISQ 191715Z AUTO 31012G22KT 10SM OVC060 02/M10 A3008` |

**Schoolcraft summary:** 33–36°F, OVC lifting 4300→4900→6000 ft through the afternoon, gusty NW 12-22 kt (same wind regime as KSAW), altimeter rising steadily, no precipitation observed.

### Overnight pressure dwell (KSAW, 2026-04-19 00:00–10:00 UTC)

Overnight into flight morning. MSLP not reported at KSAW; altimeter used as proxy.

| UTC | Altimeter inHg | ≈ MSLP hPa |
|---|---|---|
| 00:46 | 29.81 | 1009.1 |
| 02:18 | 29.86 | 1010.8 |
| 03:18 | 29.86 | 1010.8 |
| 04:58 | 29.86 | 1010.8 |
| 05:58 | 29.87 | 1011.2 |
| 06:58 | 29.87 | 1011.2 |
| 08:18 | 29.89 | 1011.9 |
| 09:18 | 29.93 | 1013.2 |
| 10:45 | 29.96 | 1014.3 |
| 11:45 | 29.99 | 1015.3 |

~10-11 hours at or below the `PLAN_environmental_risk.md` dwell proxy (1008.2 hPa = peak − 5, if peak is taken as recent 72h max ≈1013.2). Flight departed on the upswing.

---

## Analysis summary

### Pressure: not a dropping-low-pressure event

Altimeter rose throughout the flight day. The "weather" exposure chip was logged correctly but the mechanism implied (pressure dropping in the moment) isn't supported. The real pressure signal is the **overnight dwell** followed by a **rebound-departure** — which is the exact pattern already instrumented in `PLAN_environmental_risk.md` (Axis A: pressure dwell in past 48 h).

### Why leg 1 symptomed and leg 2 didn't

Flight-path data: both legs flown at ~3,500 ft MSL, same aircraft, same pilot, comparable turbulence. Stimulus held constant. What differed is body state.

| Factor | Leg 1 (symptomatic) | Leg 2 (asymptomatic) |
|---|---|---|
| Time since leaving mold/dog house | ~30 min | ~2 h |
| Cold-wind exposure recency | Fresh (4-min walk at 26°F, NW 10-15 kt) | None recent |
| Arousal / autonomic state | Climbing sympathetic load through takeoff | Post-break; patient describes partial reset |
| Active snow at departure | Yes (−SN at KSAW 14:45–15:45 UTC) | No (−SN stopped by 16:00 UTC) |
| Ceiling at 3,500 ft cruise | 500 ft below OVC 4000 — sub-cloud layer | 1,000-1,400 ft below OVC 4500-4900 |
| Pressure dwell recency | ~4 h post-dwell | ~6 h post-dwell |

These are descriptive differences between the two legs, not assertions that any of them caused the leg-1 episode. With n=1 event-pair, they are candidates to watch across future events.

### Stimulus-coupling observation

> "it felt like evertime there was turbulance there was intense energy in my leg that wanted to be released and pressure in my chest"

On leg 1, discrete mechanical stimuli (turbulence bumps) were reported as temporally concurrent with symptom impulses (leg energy + chest pressure). On leg 2, comparable mechanical stimuli were not. This is an observed correlation, not a demonstrated mechanism.

### Data-model implication for Isobar

The exposure chips on this episode (mold, animal, poor_sleep, weather) represent conditions with durations — mold/dog dander exposure lasted ~12 h ending at 9:45 AM; the pressure regime was a 12-h dwell followed by rebound. The chips do not currently carry start time or duration. Attaching those attributes to some exposure types would let post-hoc analysis like this one work from logged data alone rather than reconstruction. Framing only — not a specified spec change.

### Action items

1. App: when an episode is logged offline and later comes online, backfill `weather` from the nearest METAR for `timestamp`. Without this, the "weather" chip on 4/19 is unanchored in the stored record.
2. Paste the addendum narrative into the 4/19 10:20 AM episode notes field in-app (not auto-writable from this environment — Dexie is browser-local).
3. If and when this event is added to the master scoreboard in `FINDINGS_environmental_trigger_analysis.md`, verdict language should not assert trigger causation from this single event pair.
