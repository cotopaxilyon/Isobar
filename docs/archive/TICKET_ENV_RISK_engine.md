# Ticket ENV-RISK — Environmental Risk Surface (replaces pressure status)

## What changed

The single-axis "6-hour pressure trend" risk metric has been replaced with a **three-axis environmental risk surface** computed from 72 hours of hourly weather data.

### Old model
- One metric: 6h pressure trend
- Green/amber/red based on rate of pressure change
- Weather card showed: Pressure (absolute), 6hr Trend (hPa change), Temp (current)
- Header showed: absolute pressure value + status label (e.g. "1013 hPa / ↓ Falling")
- Compound meal alert fired when: pressure trend < −1.5 AND fasting ≥ 4h

### New model

**Axis A — Low-pressure dwell**
- Counts how many of the past 48 hours pressure was below (72h peak − 5 hPa)
- Green: < 12h | Amber: 12–24h | Red: ≥ 24h

**Axis B — Rapid temp drop**
- Largest temperature drop over any 5h window in the past 8h
- Green: < 10°F | Amber: 10–14°F | Red: ≥ 14°F

**Axis C — Rapid temp rise**
- Largest temperature rise over any 5h window in the past 8h
- Green: < 10°F | Amber: 10–14°F | Red: ≥ 14°F

**Overall risk** = worst of any axis. **Concerning window** = any axis amber or red.

### UI changes
- Weather card: three risk cells (dwell full-width, temp drop + rise side by side), reference row, meta row
- Header top-right: dwell-hours number instead of absolute pressure
- Red-axis banner: static (no flashing), reads "CONCERNING WINDOW — [axis]. Recommend [actions]."
- Compound meal alert: fires when any axis is amber or red (not just pressure trend)

### Data changes
- `currentWeather` now includes: `pressureRecentPeak`, `pressureDwellHours`, `tempMaxDrop5h`, `tempMaxRise5h`
- These persist on logged entries via the existing `weather: currentWeather` save
- Export includes new fields for entries that have them; old entries render without them

## Files changed

- `index.html` — Open-Meteo URL, three-axis computation, `environmentalRisk()` function, `renderWeather()` rewrite, compound risk logic, export format

## What to test

### 1. Weather card layout

1. Open the app in incognito → set PIN → allow location.
2. Confirm the weather card shows **three risk cells**:
   - **Low-pressure dwell** — full width, shows `Xh / 48h` with a sub-line like "Below 1012.3 hPa (peak − 5)"
   - **Temp drop** and **Temp rise** — side by side on one row, each showing `±X°F` with "/ 5h window" sub-line
3. Each cell has a **colored left border** (green, amber, or red) matching its risk level.
4. Below the cells: a **reference row** showing current pressure/temp and 6h trends.
5. Below that: location coordinates, fetch time, and refresh button.

### 2. Header summary

1. Confirm the top-right of the home screen shows a number followed by "low-pressure dwell" — not an absolute pressure value.
2. The number and label should be colored to match the overall risk level (green/amber/red = worst of the three axes).

### 3. Concerning window banner

1. If any axis is **red**, confirm a banner appears at the top of the weather card:
   - Text starts with "⚠ CONCERNING WINDOW —"
   - Includes the axis name and "episode likely"
   - Includes "Recommend" before the action list
   - Banner does **not** flash or pulse — it is static
2. If no axis is red, confirm no banner appears.
3. To force-test, open DevTools console:
   ```js
   currentWeather.pressureDwellHours = 30;
   renderWeather();
   ```
   Confirm red dwell cell + banner: "Sustained low pressure — episode likely. Recommend heat therapy, stable meals, and minimizing exertion."
   ```js
   currentWeather.pressureDwellHours = 5;
   currentWeather.tempMaxDrop5h = 16;
   renderWeather();
   ```
   Confirm red temp drop cell + banner: "Rapid temperature drop — episode likely. Recommend staying warm, heat therapy, and avoiding cold exposure."
   ```js
   currentWeather.tempMaxRise5h = 15;
   renderWeather();
   ```
   Confirm both temp axes red, both messages in the banner.

### 4. Axis color thresholds

Use DevTools to test each axis at boundary values, calling `renderWeather()` after each change:

**Axis A (dwell):**
| `pressureDwellHours` | Expected |
|---|---|
| 5 | Green border |
| 12 | Amber border |
| 24 | Red border + banner |

**Axis B (temp drop):**
| `tempMaxDrop5h` | Expected |
|---|---|
| 6 | Green border |
| 10 | Amber border |
| 14 | Red border + banner |

**Axis C (temp rise):**
| `tempMaxRise5h` | Expected |
|---|---|
| 3 | Green border |
| 10 | Amber border |
| 14 | Red border + banner |

### 5. Compound meal alert

1. Log a meal, then wait (or set `meal:last` timestamp to 5h ago in DevTools).
2. Set an axis to amber or red (e.g. `currentWeather.pressureDwellHours = 15; renderWeather();`).
3. Confirm the meal card shows the compound alert: "Eat now — multiple risk factors active" with "Environmental risk elevated" in the sub-text.
4. Set all axes to green (`pressureDwellHours = 0, tempMaxDrop5h = 0, tempMaxRise5h = 0; renderWeather()`). Confirm the compound alert disappears (standard fasting alert may remain).

### 6. Logged entry data

1. With weather loaded, log an episode.
2. Open DevTools → Application → Local Storage. Find the entry.
3. Confirm the `weather` object contains: `pressureRecentPeak`, `pressureDwellHours`, `tempMaxDrop5h`, `tempMaxRise5h` alongside the existing fields.

### 7. Export

1. Tap **Export**.
2. Find the episode logged in test 6. Confirm it includes:
   - `Barometric pressure: X hPa (6hr trend: +/-X)`
   - `Pressure dwell: Xh of 48 below X hPa (peak − 5)`
   - `Max 5h temp drop: X°F · Max 5h temp rise: X°F`
   - `Temperature: X°F (6hr trend: +/-X°F)`
3. If any pre-change entries exist (from Wave 1 testing), confirm they still render with just the barometric pressure and temperature lines — no crash, no missing data.

### 8. Layout

1. On a narrow screen (375px width), confirm:
   - The dwell cell does not overflow.
   - The two temp cells sit side by side without clipping.
   - The reference row text does not wrap awkwardly.
   - The banner text wraps cleanly if long.
2. Confirm no JavaScript errors in the console throughout.

### 9. No old artifacts

1. Confirm the weather card does **not** show the old layout (three equal columns: Pressure / 6hr Trend / Temp).
2. Confirm the header does **not** show an absolute pressure value or status label like "↓ Falling".
3. Confirm the old "RAPID PRESSURE DROP" banner text does not appear anywhere.

## Pass criteria

- Three-axis weather card renders with correct layout and colored borders.
- Header shows dwell-hours, not absolute pressure.
- Banner appears only when an axis is red, does not flash, says "Recommend" before actions.
- Axis colors match threshold tables at boundary values.
- Compound meal alert fires on any axis amber/red + fasting ≥ 4h.
- New weather fields persist on logged entries and appear in export.
- Old entries export without error.
- No layout overflow on 375px. No console errors.
