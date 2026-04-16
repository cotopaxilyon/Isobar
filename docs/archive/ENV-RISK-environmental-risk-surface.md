# UAT Write-Up — ENV-RISK: Environmental Risk Surface

**Date:** 2026-04-15
**Environment:** http://localhost:8000
**Execution:** Automated (Playwright spec uat-env-risk.spec.ts)
**Scenarios tested:** 30 (22 feature + 6 smoke + 1 live pipeline + 1 animation check) | **Pass:** 30 | **Fail:** 0 | **Blocked:** 0

## Result: ALL PASS

---

### Weather Card Layout (S1–S4)

#### Scenario 1: PASS
As a user on the home screen, when I view the weather card then I see three risk cells: Low-pressure dwell (full width), Temp drop and Temp rise (side by side on one row).

**Evidence:** Assertion passed — verified .weather-grid layout, dwell cell as first direct child, sub-grid with two columns for temp drop/rise, correct labels on all three cells.

#### Scenario 2: PASS
As a user on the home screen, when I view risk cells at green, amber, and red values then I see colored left borders matching the axis risk level.

**Evidence:** Assertion passed — verified border-left style contains `var(--good)` for green, `var(--warn)` for amber, `var(--danger)` for red across all states.

#### Scenario 3: PASS
As a user on the home screen, when I view the weather card then I see a reference row showing current pressure (hPa), temperature (°F), and 6h trends for both.

**Evidence:** Assertion passed — .weather-reference contains "1013.5 hPa", "72°F", "-1.2 hPa", "+3°F".

#### Scenario 4: PASS
As a user on the home screen, when I view the weather card then I see a meta row with location coordinates, fetch time, and a refresh button.

**Evidence:** Assertion passed — .weather-meta contains coordinates (33.45, -112.07), fetch time (10:30 AM), and .refresh-btn is visible.

---

### Header Summary (S5)

#### Scenario 5: PASS
As a user on the home screen, when I view the header then I see a dwell-hours number followed by "low-pressure dwell" — not an absolute pressure value — colored by overall risk level.

**Evidence:** Assertion passed — #pressure-summary contains "5h" and "low-pressure dwell", does NOT contain "hPa" or "Falling". Red state confirmed with `var(--danger)` color.

---

### Concerning Window Banner (S6–S10b)

#### Scenario 6: PASS
As a user on the home screen, when the dwell axis is red (30h) then I see a banner reading "CONCERNING WINDOW" with "Sustained low pressure — episode likely. Recommend heat therapy, stable meals, and minimizing exertion."

**Evidence:** Assertion passed — .alert-banner visible with expected text including "CONCERNING WINDOW", "Sustained low pressure", "episode likely", and "Recommend".

#### Scenario 7: PASS
As a user on the home screen, when the temp drop axis is red (16°F) then I see a banner with "Rapid temperature drop — episode likely. Recommend staying warm, heat therapy, and avoiding cold exposure."

**Evidence:** Assertion passed — .alert-banner visible with expected text.

#### Scenario 8: PASS
As a user on the home screen, when the temp rise axis is red (15°F) then I see a banner with "Rapid temperature rise — episode likely. Recommend staying cool, staying hydrated, and minimizing exertion."

**Evidence:** Assertion passed — .alert-banner visible with expected text.

#### Scenario 9: PASS
As a user on the home screen, when multiple axes are red then I see a single banner containing all applicable messages.

**Evidence:** Assertion passed — banner contains "Sustained low pressure", "Rapid temperature drop", and "Rapid temperature rise" simultaneously.

#### Scenario 10: PASS
As a user on the home screen, when all axes are green then I see no banner.

**Evidence:** Assertion passed — .alert-banner has count 0 when all values are green.

#### Scenario 10b: PASS
As a user on the home screen, when a red-axis banner appears then it is static with no pulse or flash animation.

**Evidence:** Assertion passed — computed animation and animationName do not contain "pulse" or "flash".

---

### Axis Color Thresholds (S11–S13)

#### Scenario 11: PASS
As a user on the home screen, when I test Axis A (dwell) at boundary values then I see correct color thresholds: green < 12h, amber 12–23h, red >= 24h.

**Evidence:** Assertion passed — tested values 5 (green), 11 (green), 12 (amber), 23 (amber), 24 (red), 48 (red). All border colors matched expected thresholds.

#### Scenario 12: PASS
As a user on the home screen, when I test Axis B (temp drop) at boundary values then I see correct color thresholds: green < 10°F, amber 10–13°F, red >= 14°F.

**Evidence:** Assertion passed — tested values 6 (green), 9 (green), 10 (amber), 13 (amber), 14 (red), 20 (red). All border colors matched.

#### Scenario 13: PASS
As a user on the home screen, when I test Axis C (temp rise) at boundary values then I see correct color thresholds: green < 10°F, amber 10–13°F, red >= 14°F.

**Evidence:** Assertion passed — tested values 3 (green), 9 (green), 10 (amber), 13 (amber), 14 (red), 20 (red). All border colors matched.

---

### Compound Meal Alert (S14–S15)

#### Scenario 14: PASS
As a user on the home screen, when any environmental axis is amber or red and I have been fasting for 4+ hours then I see the compound meal alert: "Eat now — multiple risk factors active" with "Environmental risk elevated" in the sub-text.

**Evidence:** Assertion passed — with dwell at 15h (amber) and meal logged 5h ago, #meal-card contains "Eat now", "multiple risk factors", and "Environmental risk elevated".

#### Scenario 15: PASS
As a user on the home screen, when all environmental axes are green and I have been fasting for 4+ hours then I see a standard fasting alert without the compound risk messaging.

**Evidence:** Assertion passed — #meal-card does NOT contain "multiple risk factors" or "Environmental risk elevated" when all axes are green.

---

### Logged Entry Data (S16)

#### Scenario 16: PASS
As a user, when I log an episode with weather data loaded then the saved entry in localStorage contains the new weather fields: pressureRecentPeak, pressureDwellHours, tempMaxDrop5h, tempMaxRise5h.

**Evidence:** Assertion passed — episode logged end-to-end, localStorage entry verified to contain all four new fields alongside existing weather data.

---

### Export (S17–S18)

#### Scenario 17: PASS
As a user, when I export a report containing an entry with new weather fields then I see "Pressure dwell: Xh of 48 below X hPa (peak − 5)" and "Max 5h temp drop: X°F · Max 5h temp rise: X°F" in the export.

**Evidence:** Assertion passed — export file contains "Barometric pressure: 1013.5 hPa", "Pressure dwell: 18h of 48 below", "peak − 5", "Max 5h temp drop: 8.5°F", "Max 5h temp rise: 4.2°F", "Temperature: 68°F".

#### Scenario 18: PASS
As a user, when I export a report containing an old-format entry (without new weather fields) then the export renders the barometric pressure and temperature lines without error.

**Evidence:** Assertion passed — export contains "Barometric pressure: 1010 hPa" and "Temperature: 65°F", does NOT contain "Pressure dwell" or "Max 5h temp drop", no JS errors.

---

### Layout (S19)

#### Scenario 19: PASS
As a user on a 375px-wide screen, when I view the weather card with all axes red (maximum content) then I see no horizontal overflow, the dwell cell fits within viewport, the two temp cells sit side by side without clipping, the reference row fits, and the banner wraps cleanly.

**Evidence:** Assertion passed — scrollWidth <= clientWidth, all element bounding boxes within 375px, sub-grid has 2 cells.

---

### No Old Artifacts (S20–S22)

#### Scenario 20: PASS
As a user on the home screen, when I view the weather card then I see the new flex-column layout — not the old three-equal-column layout.

**Evidence:** Assertion passed — .weather-grid has display: flex, weather content does not contain "6hr Trend" as a standalone label.

#### Scenario 21: PASS
As a user on the home screen, when I view the header then I see no old-style pressure display — no "hPa", "Falling", "Rising", "Stable", "↓", or "↑" in the header summary.

**Evidence:** Assertion passed — #pressure-summary text does not contain any legacy pressure indicators.

#### Scenario 22: PASS
As a user on the home screen, when any axis is red then the banner does not contain the old "RAPID PRESSURE DROP" text.

**Evidence:** Assertion passed — full body text does not contain "RAPID PRESSURE DROP" even with all axes red.

---

### Smoke Tests (S23–S28)

#### Scenario 23: PASS
PIN setup flow completes, #view-home visible.

#### Scenario 24: PASS
Daily check-in end-to-end completes, "Check-in saved" toast confirmed.

#### Scenario 25: PASS
Episode log end-to-end completes, "Episode saved" toast confirmed.

#### Scenario 26: PASS
Log view with seeded entries renders, #log-list .entry-card count is 1.

#### Scenario 27: PASS
Export generates file matching `/^isobar-report-.*\.txt$/`.

#### Scenario 28: PASS
Navigation through all views (home, log, settings) with weather rendered — zero JavaScript errors.

---

### Live Pipeline (S29)

#### Scenario 29: PASS
As a user with location permission granted, when the app loads then weather data is fetched from Open-Meteo and the three-axis layout renders with live data.

**Evidence:** Assertion passed — #weather-content visible within 15s, .weather-grid and .weather-cell (count 3) rendered, .weather-reference and .weather-meta visible, header contains "h" and "low-pressure dwell".

---

## Findings

No issues found. All 30 scenarios passed across 9 test groups plus smoke tests:

- **Weather card layout** (S1–S4): Three risk cells, colored borders, reference row, meta row
- **Header summary** (S5): Dwell-hours label, no absolute pressure
- **Concerning window banner** (S6–S10b): Per-axis and combined messages, absent when green, static (no animation)
- **Axis color thresholds** (S11–S13): All three axes match boundary values exactly
- **Compound meal alert** (S14–S15): Fires correctly on elevated env + fasting, absent when green
- **Logged entry data** (S16): Four new weather fields persist in localStorage
- **Export** (S17–S18): New fields render, old entries degrade gracefully
- **Layout** (S19): No overflow at 375px
- **No old artifacts** (S20–S22): Legacy layout, header display, and alert text all removed
- **Smoke tests** (S23–S28): Core flows unbroken, no JS errors
- **Live pipeline** (S29): Real API fetch renders correctly
