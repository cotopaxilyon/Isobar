# Isobar — Environmental Risk Surface (Plan)

---

## Session Status (2026-04-15)

**Phase:** Shipped 2026-04-15. UAT 30/30 PASS (see `docs/archive/ENV-RISK-environmental-risk-surface.md`).

**Trigger for this plan:** Live event cluster 2026-04-15 afternoon (7 episodes between 15:57–18:27) with pressure reading 1006–1008 hPa and 6h trend +0.7 to +1.7 — the current app displayed **green** for the entire cluster. Review of weather history for Marquette (4/12–4/15), Flagstaff (around the documented 4/6 Arizona breakthrough), and Traverse City (around events of 3/9 and 3/11) confirmed that the current single-axis 6h-pressure-trend metric misses the actual trigger pattern.

**Additional validation data (Traverse City, MI):**
- **Mon 2026-03-09 event:** 14.7°F temp drop over 3h (65.2°F → 50.5°F between 13:00–16:00). Pressure calm (daily mean 1009 hPa). Fires **Axis B (thermal drop)** only.
- **Wed 2026-03-11 event:** Temperature stable (28–41°F). Pressure peaked at 1018.3 and slid continuously to a 987.5 hPa low by 3/12 06:00. Patient was in sustained post-drop dwell at event time. Fires **Axis A (pressure dwell)** only.

**Additional validation data (Marquette, MI):**
- **2025-10-18 event:** Pressure 999.6–1001.5 hPa all day, 72h peak was 1025.8 hPa (Oct 16) — patient was ~20 hPa below peak for 24+ hours, the largest dwell signal in the dataset. Fires **Axis A (pressure dwell)** red.
- **2025-11-01 event (~1pm):** Pressure calm and rising (1016→1021). Temperature stable 39–41°F. All environmental axes green. Trigger was non-environmental — patient had worked an overnight shift at the airport, and the event fits the PEM (post-exertional malaise) lag pattern documented in patient history. **This is a correct non-fire** — environmental axes should not flag exertional-trigger events. See "Trigger classes outside this plan" below.

Across 9 events with confirmed weather data, the three-axis model fires correctly on all 8 environmentally-triggered events and correctly does NOT fire on the 1 exertional-trigger event. This is stronger validation than a model that fires on everything.

**Related findings this session:**
- Arizona baseline description in `MEDICAL_PURPOSE.md` is inaccurate — "4 weeks complete symptom resolution" should read "4 weeks dramatically reduced symptom burden with 3 breakthrough events, each with identifiable environmental trigger."
- The n=3 Arizona breakthroughs + n=2 confirmed pressure-dwell events (Flagstaff 4/6, Marquette 4/15) + the April 976.5 hPa compound event form the data basis for the three-axis model below.

---

## Purpose

Replace the single-axis "6-hour pressure trend" risk metric with a **three-axis environmental risk surface** that reflects the actual triggers documented in patient data: sustained low-pressure dwell, rapid temperature drop, and rapid temperature rise.

## Why this change

The current model encodes the hypothesis that **rate of pressure change** triggers events. Patient data contradicts this in two distinct directions:

1. **Pressure events happen during sustained low-pressure dwell, not during the drop itself.** The Marquette 4/15 cluster (7 episodes) occurred ~48 hours into continuous sub-1010 hPa pressure with a flat/positive 6h trend. The Flagstaff 4/6 event occurred ~40 hours after pressure fell below local baseline, with a flat day-of trend. The April 976.5 hPa compound event occurred at absolute low after the fall was complete. In all three, the 6h-trend metric would have displayed green or mild at event time.

2. **Two of three Arizona breakthroughs were thermal, not barometric.** A 98→45°F crash over 1.5 hours (≈ −35°F/hr) and a 75→95°F climb over 1 hour (+20°F/hr) both triggered episodes during an otherwise relief-state baseline. Normal diurnal change is 1–2°F/hr. These rates are 10–20× baseline. The current app tracks a 6h temperature trend with a ±10°F warn threshold — this would catch a 10°F change spread over 6 hours (normal dusk cooling) with the same severity as a 10°F change in 30 minutes (atmospheric event). Rate information is being discarded.

A single scalar cannot represent three mechanistically distinct triggers.

## Research basis

| Axis | Patient data | Published support |
|---|---|---|
| **A. Pressure dwell below local baseline** | Marquette 4/15 cluster (sub-1010 for ~48h); Flagstaff 4/6 (sub-local-peak−5 for ~40h); April episode at 976.5 hPa absolute after front passage complete | Rakers 2017 (seizures): OR 1.14 per 10.7 hPa lower absolute pressure — absolute matters more than rate. Okuma 2015: 6–10 hPa below standard induces migraine onset most frequently. No published literature specifies dwell-time; this axis is patient-data-driven with literature-consistent absolute-pressure framing. |
| **B. Rapid temperature drop** | Arizona breakthrough: 98°F → 45°F in 1.5h | Autonomic and MCAS literature document thermoregulatory failure with rapid thermal change. Funakubo 2021 documented acute sensory/autonomic effects from rapid environmental transitions over minutes. No published per-hour threshold. |
| **C. Rapid temperature rise** | Arizona breakthrough: 75°F → 95°F in 1h | Same as B. MCAS mast cell degranulation thresholds are known to be temperature-rate-sensitive in clinical reports, though no quantitative per-hour threshold is published. |

All three axes are supported by patient-specific events with clear environmental signatures. The quantitative thresholds below are initial best-guess values derived from her documented events, to be refined once the backfill analysis runs against her full event log.

## The three-axis model

At any moment, an environmental risk state is produced by three independent metrics computed from the past 48–72 hours of hourly weather data:

### Axis A — Pressure Dwell
```
pressureRecentPeak = max(pressure_msl[-72h...now])
pressureDwellHours = count(h in past 48h where pressure_msl[h] < pressureRecentPeak - 5)
```

| State | Threshold | Rationale |
|---|---|---|
| Green | dwell < 12h | Early or recovered |
| Amber | dwell 12–24h | Sustained exposure developing |
| Red | dwell ≥ 24h | Sustained exposure past the documented trigger threshold (Flagstaff 40h, Marquette 48h) |

Self-adjusting to location. Handles Marquette (~1007 at red) and Flagstaff (~1017 at red) with the same rule.

### Axis B — Rapid Thermal Drop
```
tempMaxDrop5h = max over all 5h windows in past 8h of (temp[start] - temp[end])
```

| State | Threshold | Rationale |
|---|---|---|
| Green | < 10°F over 5h | Within normal spring diurnal range (observed 3/7–3/13 non-event days: 5h swings of 5–10°F) |
| Amber | 10–14°F over 5h | Unusual, monitor |
| Red | ≥ 14°F over 5h | Atmospheric event / matches the documented 3/9 Traverse City event (14.7°F / 3h) and Arizona 98→45 breakthrough (~53°F / 1.5h) |

**Window width rationale:** The 2h window in the initial draft would have missed the documented 3/9 event (14.7°F drop spread across 3 hours). A 5h scanning window captures the 3/9 event cleanly and still fires on the shorter Arizona events (which show large deltas even when bracketed by a wider window).

### Axis C — Rapid Thermal Rise
```
tempMaxRise5h = max over all 5h windows in past 8h of (temp[end] - temp[start])
```

| State | Threshold | Rationale |
|---|---|---|
| Green | < 10°F over 5h | Normal diurnal warm-up |
| Amber | 10–14°F over 5h | Unusual, monitor |
| Red | ≥ 14°F over 5h | Matches documented 75→95 breakthrough rate (~20°F / 1h) with margin |

### Composite

Overall risk = highest severity of any axis. **Concerning window** = any axis amber or red. Home page displays all three axes simultaneously (cannot collapse without losing mechanism information).

---

## Implementation steps

### Step 1 — Extend `fetchWeather()` to pull 48h history

**Location:** `index.html` lines ~669–716

**Change:** Add `past_days=2` and extend `hourly=` list. Store the full hourly arrays on `currentWeather` so derivative metrics can be recomputed without a refetch.

**Current URL (line 681):**
```js
const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=pressure_msl,temperature_2m,precipitation&current_weather=true&temperature_unit=fahrenheit&timezone=auto&forecast_days=1`;
```

**New URL:**
```js
const url = `https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lon}&hourly=pressure_msl,temperature_2m,precipitation&current_weather=true&temperature_unit=fahrenheit&timezone=auto&forecast_days=1&past_days=3`;
```

`past_days=3` gives 72h of history (needed for Axis A's recentPeak window) plus 24h of forecast. Total payload remains small.

### Step 2 — Compute three-axis metrics

After the existing `idx` / `pressure` / `trend` / `temp` / `tempTrend` computation, add:

```js
// --- Axis A: pressure dwell below local recent peak ---
const pArr = d.hourly.pressure_msl;
const peak72Start = Math.max(0, idx - 72);
const pressureRecentPeak = Math.max(...pArr.slice(peak72Start, idx + 1));
const dwellThreshold = pressureRecentPeak - 5;
const dwell48Start = Math.max(0, idx - 48);
const pressureDwellHours = pArr
  .slice(dwell48Start, idx + 1)
  .filter(p => p < dwellThreshold).length;

// --- Axes B & C: rapid thermal transitions over 5h window, scanned across past 8h ---
const tArr = d.hourly.temperature_2m;
const scanStart = Math.max(0, idx - 8);
let tempMaxDrop5h = 0;
let tempMaxRise5h = 0;
for (let i = scanStart; i <= idx - 5; i++) {
  const delta = tArr[i + 5] - tArr[i];  // temp change over that 5h window
  if (delta < -tempMaxDrop5h) tempMaxDrop5h = -delta;   // store drop magnitude (positive)
  if (delta > tempMaxRise5h) tempMaxRise5h = delta;
}
```

Add these to the `currentWeather` object:
```js
currentWeather = {
  // ... existing fields ...
  pressureRecentPeak: Math.round(pressureRecentPeak * 10) / 10,
  pressureDwellHours,
  tempMaxDrop5h: Math.round(tempMaxDrop5h * 10) / 10,
  tempMaxRise5h: Math.round(tempMaxRise5h * 10) / 10,
};
```

### Step 3 — Replace `pressureStatus()` with `environmentalRisk()`

**Location:** lines 719–725

Retire the current `pressureStatus(hpa, trend)` function in favor of a richer status function that returns per-axis state plus an overall severity:

```js
function axisState(metric, amber, red) {
  if (metric >= red) return { level: 'red', color: 'var(--danger)' };
  if (metric >= amber) return { level: 'amber', color: 'var(--warn)' };
  return { level: 'green', color: 'var(--good)' };
}

function environmentalRisk(w) {
  const dwell = axisState(w.pressureDwellHours, 12, 24);
  const drop  = axisState(w.tempMaxDrop5h,      10, 14);
  const rise  = axisState(w.tempMaxRise5h,      10, 14);
  const worst = [dwell, drop, rise].reduce((acc, s) =>
    ({green:0, amber:1, red:2}[s.level] > {green:0, amber:1, red:2}[acc.level] ? s : acc));
  return { dwell, drop, rise, overall: worst };
}
```

### Step 4 — Update `renderWeather()` to display the three-axis surface

**Location:** lines 727–770

Replace the single "Pressure / 6hr Trend / Temp" three-cell grid with a three-axis risk surface plus a secondary reference row. The top-of-card banner triggers when any axis is red:

```html
<div class="weather-grid">
  <div class="weather-cell" style="border-left:4px solid ${risk.dwell.color}">
    <div class="weather-label">Low-pressure dwell</div>
    <div class="weather-val mono" style="color:${risk.dwell.color}">${w.pressureDwellHours}h <span style="font-size:12px">/ 48h</span></div>
    <div class="weather-sub">Below ${w.pressureRecentPeak - 5} hPa (peak − 5)</div>
  </div>
  <div class="weather-cell" style="border-left:4px solid ${risk.drop.color}">
    <div class="weather-label">Rapid temp drop</div>
    <div class="weather-val mono" style="color:${risk.drop.color}">−${w.tempMaxDrop5h}°F <span style="font-size:12px">/ 5h</span></div>
    <div class="weather-sub">Max drop in past 8h</div>
  </div>
  <div class="weather-cell" style="border-left:4px solid ${risk.rise.color}">
    <div class="weather-label">Rapid temp rise</div>
    <div class="weather-val mono" style="color:${risk.rise.color}">+${w.tempMaxRise5h}°F <span style="font-size:12px">/ 5h</span></div>
    <div class="weather-sub">Max rise in past 8h</div>
  </div>
</div>
<div class="weather-reference">
  <span>Current: ${w.pressure} hPa · ${w.currentTemp}°F</span>
  <span>6h trend: ${w.trend>0?'+':''}${w.trend} hPa · ${w.tempTrend>0?'+':''}${w.tempTrend}°F</span>
</div>
```

Banner at top of card when `risk.overall.level === 'red'`:

> ⚠ CONCERNING WINDOW — [axis name]. [Axis-specific guidance: e.g. "Sustained low pressure. Heat therapy, stable meals, minimize exertion."]

### Step 5 — Update the header summary

**Location:** lines 736–738 (`pressure-summary`)

Change from pressure number to dwell-hours number — that is what is most diagnostic in the data:

```js
document.getElementById('pressure-summary').innerHTML =
  `<div class="mono" style="font-size:18px;font-weight:600;color:${risk.overall.color}">${w.pressureDwellHours}h</div>
   <div style="font-size:11px;color:${risk.overall.color}">low-pressure dwell</div>`;
```

### Step 6 — Persist new metrics on logged events

Events save `weather: currentWeather` at creation (line 861, 1074). No code change needed — the new fields will be captured automatically. But add a migration note for the export:

**Location:** export function, lines 1320–1330

```
Barometric pressure: 1008.3 hPa (6hr trend: +1.7)
Pressure dwell: 28h of 48 below 1010.4 hPa (peak − 5)
Max 5h temp drop: 3.2°F · Max 5h temp rise: 1.1°F
Temperature: 60°F (6hr trend: +4°F)
```

Keep the existing "6hr trend" line — specialists reading the report may look for rate of change specifically. Dwell and 2h rates are new information, not replacement.

### Step 7 — Update compound risk logic

**Location:** lines 1417–1419

Current:
```js
const pressureFalling = currentWeather && currentWeather.trend < -1.5;
const isCompound = pressureFalling && hoursElapsed >= 4;
```

New:
```js
const inConcerningWindow = currentWeather && environmentalRisk(currentWeather).overall.level !== 'green';
const isCompound = inConcerningWindow && hoursElapsed >= 4;
```

Any axis amber/red + fasting ≥4h triggers the compound food alert. Broader catchment, same clinical rationale.

### Step 8 — Revise MEDICAL_PURPOSE.md Arizona paragraphs

**Location:** `MEDICAL_PURPOSE.md` — Arizona baseline references throughout (multiple)

Replace any phrasing of "4 weeks of complete symptom resolution" with:

> **Arizona baseline (spring 2026):** 4 weeks of dramatically reduced symptom burden with 3 breakthrough episodes, each triggered by a specific acute environmental transition:
> 1. Pressure-associated breakthrough in Flagstaff (sustained sub-local-baseline pressure; documented in app logs 4/6/2026)
> 2. Rapid temperature drop: 98°F → 45°F in 1.5 hours
> 3. Rapid temperature rise: 75°F → 95°F in 1 hour
>
> This is not a failure of the baseline claim — it is the inverse. The Arizona period demonstrates that in the absence of these specific environmental transitions the patient can achieve a near-symptom-free state, and that her reactivity is quantifiably linked to identifiable acute environmental triggers rather than a diffuse generalized weather sensitivity. The three breakthroughs are the most diagnostically valuable data points in the entire tracked period.

### Step 9 — Log the 3 Arizona breakthroughs retroactively (user action)

Approximate dates and locations should be logged as events in the app so the dwell/rate metrics can be backfilled against them. Minimum data needed per event:
- Date (approximate OK)
- Location (to fetch weather archive)
- Trigger class (pressure / thermal-drop / thermal-rise)
- Anything remembered about prodrome, limbs, duration

This step is blocked on patient memory, not on code.

### Step 10 — Backfill analysis (follow-up, not this session)

Once Steps 1–9 are complete, a one-off script replays every event in the log against Open-Meteo archive for the location, and reports:
- Distribution of each axis value at event-time vs 100 random non-event times
- Which axis (or composite) best separates events from non-events
- Refined thresholds based on that separation

This converts the "best-guess initial thresholds" in this plan into data-calibrated values. Output goes into an UPDATES.md spec for threshold tuning.

---

## Verification

After Steps 1–7 are implemented:

1. Load the app. Confirm the weather card shows three risk cells (dwell / drop / rise) plus a current-reading reference line.
2. Open devtools, inspect `currentWeather`. Confirm new fields present: `pressureRecentPeak`, `pressureDwellHours`, `tempMaxDrop2h`, `tempMaxRise2h`.
3. On 2026-04-15 Marquette data, expect `pressureDwellHours` to be high (≥24 — red). Confirm the card shows red border on Axis A and the "Concerning Window" banner.
4. In devtools, force `currentWeather.tempMaxDrop5h = 14` and call `renderWeather()`. Confirm Axis B goes red, banner updates, Axis A remains whatever it was.
5. Log a new episode. Open the entry in the log list — confirm the saved `weather` object contains all three new fields.
6. Export report. Confirm the Pressure dwell, Max 2h drop, and Max 2h rise lines appear for new events. Old events (pre-change) should render the old format without error.
7. Let `meal:last` be 5h ago. Confirm the compound meal card reflects `inConcerningWindow` rather than the old `pressureFalling` scalar.

---

## Known limitations

- **Forecast lag.** Open-Meteo hourly data near "now" is a short-term model interpolation, not a direct station reading. Acute transitions in the last 1–2 hours may be smoothed. Mitigation: the rapid-transition axes scan the full past 6h, not just the last hour — a sharp event 3–6h ago will still surface.
- **Temperature scan at 5h window.** Hourly data means the finest detectable ΔT window is 1h→1h (adjacent steps). A sub-hour spike that reverses before the next stamp will not be seen. Acceptable: the documented Arizona events were 60–90 min and the Traverse City event was 3h, all within resolution. The 5h scanning window was widened from an initial 2h draft after Traverse City 3/9 data showed the event drop happened over 3h — a 2h window would have missed it.
- **Initial thresholds are best-guess.** The Axis A amber/red cutoffs (12h / 24h) are derived from two events. Axes B/C thresholds (10°F / 14°F over 5h) are derived from the Traverse 3/9 event, the two Arizona thermal breakthroughs, and the 3/7–3/13 Traverse non-event distribution. Step 10 (backfill analysis) is required to validate or revise these.
- **Backwards-compatibility at the data layer.** Events logged before this change have `weather.trend` but not the new fields. The export must render both formats. Handled by null-checks in the export code, not by backfilling old records.

---

## Out of scope for this plan

- **Baseline personalization beyond recentPeak.** A proper local rolling baseline (e.g. 30-day mean and σ) is stronger than 72h recentPeak but requires more data storage and is not justified by current evidence. Defer until Step 10 shows it matters.
- **Additional environmental axes** (humidity rate, wind shift at frontal passage, precipitation onset) — physiologically plausible but no patient-data support yet. Defer.
- **Forecast-based preemptive alerts.** A "pressure forecast to drop 8 hPa over next 12h" alert would give actionable lead time but is a separate feature. Add to ROADMAP.md as a new item after this lands.
- **Notification of axis transitions.** No push / scheduled notifications in this plan — Reminders & Notifications (ROADMAP §4) will handle the delivery layer; this plan handles the metric layer.

## Trigger classes outside this plan

This plan covers **environmental triggers** (pressure, temperature rate) that can be derived from Open-Meteo data. The 2025-11-01 event (overnight airport shift → event ~13h later) is a reminder that the app is not capturing other important trigger classes:

- **Physical-exertion load** — hours worked, type of work (sedentary vs physical), shifts that disrupt circadian rhythm. PEM lag is 24–48h per CFS/ME literature (sometimes shorter).
- **Sleep disruption** — total hours, timing relative to circadian baseline. Morning check-in captures sleep quality but not the exertional context leading into it.
- **Chemical / sensory exposure load** — jet fuel, solvents, perfume environments, sustained noise — relevant for MCAS.
- **Social/cognitive load** — prolonged masking, extended interactions. Autistic burnout is a documented trigger in her patient profile.

These are **not** environmental-surveillance metrics — they are self-reported context the app needs to collect from the patient. Recommended next-step roadmap item (after this plan ships):

> **Exertion & Load Tracker** — a brief evening entry (yes/no + hours for each of: physical work, sensory-intensive environment, social masking). Joins against event logs in the export so specialists can see whether an unexplained event (no environmental axis firing) was preceded by an exertional signal. This is what would have made the Nov 1 event explicable from app data alone.
