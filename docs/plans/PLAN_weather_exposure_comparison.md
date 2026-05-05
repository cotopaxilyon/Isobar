# PLAN: Weather Exposure Comparison

**Goal:** Show how often high-risk weather conditions coincided with episodes vs. occurred without episodes — providing evidence for or against weather as a necessary vs. sufficient condition.

---

## Background

Weather is saved at two points per day:
- **Morning check-in:** `weather: currentWeather || null` snapshotted when the check-in form is opened.
- **Each episode:** `weather: currentWeather || null` (legacy `episode`) or `weather_at_prodrome` (current `episode_v2`) snapshotted when the episode form is opened.

A separate backfill (index.html:3278+) fills `weather_at_prodrome` from the Open-Meteo archive endpoint when the real-time fetch failed (offline, no signal, fetch error). Backfilled snapshots carry `captured_retrospectively: true` and `fetchedAt: 'retrospective'`. They are observed weather data, not estimation.

The physician report's ENVIRONMENTAL PATTERN section currently reports two episode-side stats: `≥18h` pressure dwell and `≥13°F` temp drop. This plan replaces those two paragraphs with a contingency-table analysis that compares episode-days to non-episode-days using a single threshold scheme, plus a separate descriptive episode-level line and an Arizona block.

This answers two questions:
- **Necessary?** Did any episode occur in green-weather conditions?
- **Sufficient?** Did elevated weather always produce an episode?

---

## Agreed decisions

| # | Decision |
|---|---|
| 1 | All episode-side weather reads use `weather_at_prodrome ?? weather` (matches the existing ENV section pattern). |
| 2 | The existing `≥18h` pressure and `≥13°F` thermal paragraphs are deleted; this section subsumes them. The "insufficient data" fallback preserves the floor. |
| 3 | Day-level analysis (no event-level dedup). Honors the user's `episode_v2`-grain logging. A descriptive episode-level line is preserved separately. |
| 4 | (Moot — no merging.) |
| 5 | Day classification uses **morning check-in `weather` only** for both sides (apples-to-apples). Days without a morning check-in `weather` snapshot drop from both sides. Multi-checkin days take the worst risk-level. |
| 6 | Arizona days are **excluded** from the contingency math by lat/lon filter. A separate Arizona block reports raw counts only. |
| 7 | Always show counts + percentages. Append `(n=X — small sample)` inline when relevant n < 10. |
| 8 | Per-axis rows use compact `pct (n/N) vs pct (n/N)` format. The headline 2×2 carries the rigorous version. |
| 9 | Per-component gating. Each subsection renders or prints a specific "insufficient data" line; one thin side does not hide the others. |
| 10 | Headline output is a 4-cell day-level contingency + three derived rates + necessary/sufficient sentences keyed off `c > 0` and `b > 0`. |
| 11 | Aborted episodes (`type==='episode_v2' && spasm_count===0 && !prodrome_absent`) count toward "episode-day" — they are exposure events. Footnoted. |
| 12 | Backfilled snapshots are included in episode-level counts. Footnote: "archive-filled where the real-time fetch failed", not "retrospectively reconstructed". |
| 13 | `buildWeatherExposureTable` is a top-level helper near `environmentalRisk` (index.html ~985). `exportReport` calls it and formats the result. |
| 14 | Verification: synthetic fixture + one-week live-data hand-count, both as ACs, both verified before QA transition. |
| 15 | No schema changes. No home stat chip. |

---

## Data model

No schema changes. Existing data is sufficient.

**Episode side (descriptive line + episode-day classification):**
- All entries where `type === 'episode' || type === 'episode_v2'`. Each is one episode.
- Aborted episodes (`type==='episode_v2' && spasm_count===0 && !prodrome_absent`) are included.
- Each episode's weather snapshot is `(ep.weather_at_prodrome ?? ep.weather)`. Backfilled snapshots are included.

**Day classification (both sides of the contingency):**
- Source: morning check-in `weather` only. Episode-time snapshots are *not* used for day classification (they would create source asymmetry — episode days would have more chances to cross threshold than non-episode days, biasing the comparison).
- A "day" is a calendar date (`entryDate`).
- A day is **observed** if it has at least one `checkin` entry with `weather.pressureDwellHours != null`.
- An observed day's risk-level is the worst (`red > amber > green`) across all check-in snapshots taken that day.
- A day is an **episode-day** if it is observed AND has at least one episode (`episode` or `episode_v2`) on that `entryDate`.
- A day is a **non-episode-day** if it is observed AND has zero episodes on that `entryDate`.
- Days with no morning check-in `weather` snapshot are dropped from both sides.

**Arizona exclusion:**
- A day is an **Arizona day** if its check-in `weather.lat`/`weather.lon` falls inside the Arizona bounding box. The bounding box is pinned as a top-level constant in code at implementation time, after inspecting the lat/lon distribution in current data.
- Arizona days are excluded from the headline contingency, the per-axis breakdown, and the episode-level descriptive line.
- Arizona days are reported separately in the Arizona block with raw counts only.

---

## Thresholds

Use the existing `environmentalRisk()` thresholds (index.html:985):

| Axis | Amber | Red |
|------|-------|-----|
| Pressure dwell | ≥ 12h | ≥ 24h |
| Temp drop / 5h | ≥ 10°F | ≥ 14°F |
| Temp rise / 5h | ≥ 10°F | ≥ 14°F |

The contingency table's "amber+ vs green" split uses any-axis-amber+ as the "amber+" classification (i.e., a day is amber+ if `environmentalRisk(w).overall.level !== 'green'`). The per-axis breakdown reports each axis at the amber+ level.

---

## Implementation

### 1. Helper: `buildWeatherExposureTable(entries)`

Lives at top-level near `environmentalRisk` (index.html ~985). Returns a structured object; no formatting.

```js
{
  // Headline 2x2 (Marquette, day-level, morning checkin only)
  contingency: {
    a: Number,              // amber+ days with ≥1 episode
    b: Number,              // amber+ days with no episode
    c: Number,              // green days with ≥1 episode
    d: Number,              // green days with no episode
    episodeDays: Number,    // a + c
    nonEpisodeDays: Number, // b + d
    amberDays: Number,      // a + b
    greenDays: Number,      // c + d
    totalDays: Number,      // a + b + c + d
  },

  // Per-axis day-level breakdown (Marquette only, amber+ on each axis)
  axes: {
    dwell: { episodeDays, nonEpisodeDays, episodeDaysAmber, nonEpisodeDaysAmber },
    drop:  { episodeDays, nonEpisodeDays, episodeDaysAmber, nonEpisodeDaysAmber },
    rise:  { episodeDays, nonEpisodeDays, episodeDaysAmber, nonEpisodeDaysAmber },
  },

  // Descriptive episode-level (Marquette only, includes aborted + backfilled)
  episodeLevel: {
    totalEpisodes: Number,
    episodesWithWeather: Number,
    episodesAmber: Number,    // any axis amber+
    episodesRed: Number,      // any axis red
    backfilledCount: Number,  // count of weather snapshots from archive backfill
    abortedCount: Number,     // count of aborted episodes included
  },

  // Arizona block (separate; raw counts only)
  arizona: {
    observedDays: Number,
    episodeDays: Number,
    daysAmber: Number,
    daysRed: Number,
    episodes: Number,
  } | null, // null if no Arizona days in dataset
}
```

**Risk classification helper (per snapshot):** reuse `environmentalRisk(w)` directly. A snapshot is "amber+" if `environmentalRisk(w).overall.level !== 'green'`.

**Day's worst-risk rule:** for each observed day, take all check-in snapshots, classify each, keep the worst (`red > amber > green`).

**Arizona bounding box:** pinned as a top-level constant at implementation time. Verify by inspecting the lat/lon distribution in current data before pinning the box.

### 2. Physician report — ENVIRONMENTAL PATTERN section

**Delete the existing two paragraphs:**
- index.html:2086 — `Barometric pressure: ${dwellHigh.length}/${epsWithDwell.length} episodes occurred during sustained low-pressure periods (≥18h below threshold).`
- index.html:2091 — `Thermal exposure: ${dropHigh.length}/${epsWithDrop.length} episodes coincided with a ≥13°F temperature drop within the prior 5 hours.`

The "Time of onset" and "Fasting" lines (index.html:2094–2098) are unchanged.

**Append in their place** (template; substitute helper output):

```
Weather exposure: episode-days vs. non-episode-days (Marquette only)
─────────────────────────────────────────────────────────────────────
Day-level analysis based on morning check-in weather snapshots. Days without
a morning check-in are excluded from both sides. Arizona reference period is
excluded from this comparison and reported separately below.

                      episode-day    no-episode-day    total
  amber+ weather day      [a]            [b]           [a+b]
  green  weather day      [c]            [d]           [c+d]
  total                  [a+c]          [b+d]            [N]

  Necessary?  [c] of [a+c] episode-days occurred in green weather
              → weather is [not] necessary for episodes [(n=X — small sample)]
  Sufficient? [b] of [a+b] amber-weather days had no episode
              → weather is [not] sufficient to produce episodes [(n=X — small sample)]
  Episode rate on amber-weather days: [pct]% ([a]/[a+b]) [(n=X — small sample)]
  Episode rate on green-weather days: [pct]% ([c]/[c+d]) [(n=X — small sample)]

Per-axis breakdown (episode-days vs non-episode-days, amber+):
  Pressure dwell ≥12h:  [pct]% ([n]/[N])  vs  [pct]% ([n]/[N])
  Temp drop ≥10°F:      [pct]% ([n]/[N])  vs  [pct]% ([n]/[N])
  Temp rise ≥10°F:      [pct]% ([n]/[N])  vs  [pct]% ([n]/[N])

Episode-level snapshot summary:
  [episodesWithWeather] of [totalEpisodes] episodes had a weather snapshot.
  Episodes in elevated-risk weather (amber+): [episodesAmber] / [episodesWithWeather] ([pct]%)
  Episodes in high-risk weather (red):        [episodesRed]   / [episodesWithWeather] ([pct]%)

  Footnotes:
  - Episode-days include both motor episodes and prodrome-aborted events
    (the body crossed the threshold in both cases). Aborted episodes: [abortedCount].
  - Episode-level weather counts include archive-filled snapshots for episodes
    where the real-time fetch failed: [backfilledCount].

Arizona reference period (separate)
─────────────────────────────────────
[observedDays] days observed; [episodeDays] episode-days; [daysAmber]/[observedDays] days had amber+ weather.
[episodes] episodes total.
```

**Per-component gating:**

- **Headline 2×2 + per-axis breakdown:** require `episodeDays >= 3 && nonEpisodeDays >= 5`. Below either, replace both blocks with: `Insufficient days for episode-vs-non-episode comparison ([episodeDays] episode-days, [nonEpisodeDays] non-episode-days observed).`
- **Episode-level snapshot summary:** require `episodesWithWeather >= 3`. Below, replace with: `Insufficient weather snapshots on logged episodes ([episodesWithWeather] of [totalEpisodes] episodes have weather data).`
- **Arizona block:** no gate. If `arizona` is null, omit the block entirely. If non-null, print whatever counts exist.

**Small-sample tags:** when a percentage is shown and its underlying n < 10, append `(n=X — small sample)` inline immediately after the percentage.

**`is/is not` resolution:**
- "is not necessary" if `c > 0`; "is necessary" if `c === 0`.
- "is not sufficient" if `b > 0`; "is sufficient" if `b === 0`.

---

## What this does NOT do

- Does not retroactively fetch weather for past days with no check-in (existing backfill is episode-only).
- Does not add weather logging to evening check-ins.
- Does not add any new form fields or user-facing prompts.
- Does not attempt to control for co-occurring exposures (THC, sleep, alcohol, social/cognitive load).
- Does not add a home stat chip.

---

## Acceptance criteria

**Code-verifiable (agent checks before transitioning to QA):**

1. `buildWeatherExposureTable` lives at top-level near `environmentalRisk` (index.html ~985).
2. All episode-side weather reads in the helper use `(ep.weather_at_prodrome ?? ep.weather)`.
3. Day-level classification uses morning check-in `weather` only. No episode-time or EOD snapshots feed the day classification.
4. Days without a morning check-in `weather` snapshot are dropped from both sides of the contingency.
5. Days with multiple morning check-ins are classified by the worst risk-level among them.
6. Arizona days (lat/lon outside the Marquette bounding box; box constant pinned in code) are excluded from the contingency, per-axis breakdown, and episode-level summary; counted only in the Arizona block.
7. Aborted episodes (`type==='episode_v2' && spasm_count===0 && !prodrome_absent`) count toward "episode-day".
8. Episode-level descriptive line includes backfilled snapshots; `backfilledCount` is reported in the footnote.
9. Existing `≥18h` pressure paragraph and `≥13°F` thermal paragraph are deleted; new section subsumes them.
10. Per-component gating fires per the rules above. Below-threshold components print a specific "insufficient data: X / Y" line.
11. Percentages are followed by `(n=X — small sample)` inline when the relevant n < 10.
12. Synthetic fixture (Verification artifacts § below) returns the pinned object (deep-equal).
13. Live-data hand-count for the implementation week matches `buildWeatherExposureTable` output for that week.
14. No new fields written to any check-in, episode, EOD, motor_event, or intervention_event entries.
15. No home stat chip added.

**Behavioral / user-verified during QA:**

16. Report renders without errors when run against the current DB.
17. Headline 2×2, per-axis breakdown, episode-level line, and Arizona block each appear or are replaced by their specific "insufficient" line as specified.
18. Necessary/sufficient sentences correctly resolve to "is/is not" based on cell counts (`c>0`, `b>0`).
19. The Arizona block reads sensibly given the user's clinical framing (raw counts, no inference).

---

## Verification artifacts

### Synthetic fixture (AC 12)

Pinned at implementation time, before QA. Should cover at minimum:
- 1 Marquette episode-day with amber+ morning check-in
- 1 Marquette episode-day with green morning check-in (proves "necessary?" path)
- 1 Marquette non-episode-day with amber+ morning check-in (proves "sufficient?" path)
- 1 Marquette non-episode-day with green morning check-in
- 1 day with no morning check-in (proves it drops from both sides)
- 1 Arizona day (proves it lands in the Arizona block, not the contingency)
- 1 aborted episode (proves it counts as episode-day)
- 1 backfilled episode snapshot (proves it counts in episode-level summary, contributes to `backfilledCount`)

**Fixture array literal** (paste into browser console alongside `buildWeatherExposureTable`):

```js
const fixture = [
  // Day 1: Marquette amber+, episode → cell a
  { type: 'checkin',    entryDate: '2026-01-01', weather: { lat: 46.54, lon: -87.4, pressureDwellHours: 15, tempMaxDrop5h: 5,  tempMaxRise5h: 3 } },
  { type: 'episode_v2', entryDate: '2026-01-01', spasm_count: 2, prodrome_absent: false, weather_at_prodrome: { pressureDwellHours: 15, tempMaxDrop5h: 5 } },

  // Day 2: Marquette green, episode → cell c ("necessary?" path)
  { type: 'checkin',    entryDate: '2026-01-02', weather: { lat: 46.54, lon: -87.4, pressureDwellHours: 3, tempMaxDrop5h: 2, tempMaxRise5h: 1 } },
  { type: 'episode_v2', entryDate: '2026-01-02', spasm_count: 1, prodrome_absent: false, weather_at_prodrome: { pressureDwellHours: 3, tempMaxDrop5h: 2 } },

  // Day 3: Marquette amber+, no episode → cell b ("sufficient?" path)
  { type: 'checkin',    entryDate: '2026-01-03', weather: { lat: 46.54, lon: -87.4, pressureDwellHours: 14, tempMaxDrop5h: 3, tempMaxRise5h: 2 } },

  // Day 4: Marquette green, no episode → cell d
  { type: 'checkin',    entryDate: '2026-01-04', weather: { lat: 46.54, lon: -87.4, pressureDwellHours: 2, tempMaxDrop5h: 1, tempMaxRise5h: 0 } },

  // Day 5: no morning check-in weather, episode present → drops from both sides entirely
  { type: 'episode_v2', entryDate: '2026-01-05', spasm_count: 3, prodrome_absent: false, weather_at_prodrome: null, weather: null },

  // Day 6: Arizona check-in, episode → goes to arizona block only
  { type: 'checkin',    entryDate: '2026-01-06', weather: { lat: 32.22, lon: -110.97, pressureDwellHours: 0, tempMaxDrop5h: 1, tempMaxRise5h: 1 } },
  { type: 'episode_v2', entryDate: '2026-01-06', spasm_count: 1, prodrome_absent: false, weather_at_prodrome: { pressureDwellHours: 0 } },

  // Day 7: Marquette green, aborted episode → cell c (aborted counts as episode-day)
  { type: 'checkin',    entryDate: '2026-01-07', weather: { lat: 46.54, lon: -87.4, pressureDwellHours: 5, tempMaxDrop5h: 2, tempMaxRise5h: 1 } },
  { type: 'episode_v2', entryDate: '2026-01-07', spasm_count: 0, prodrome_absent: false, weather_at_prodrome: { pressureDwellHours: 5, tempMaxDrop5h: 2 } },

  // Day 8: no morning check-in, backfilled episode snapshot → drops from contingency, counts in episode-level
  { type: 'episode_v2', entryDate: '2026-01-08', spasm_count: 2, prodrome_absent: false, weather_at_prodrome: { pressureDwellHours: 10, tempMaxDrop5h: 3, captured_retrospectively: true, fetchedAt: 'retrospective' } },
];
```

**Expected return object** (deep-equal against `buildWeatherExposureTable(fixture)`):

```js
{
  contingency: { a: 1, b: 1, c: 2, d: 1, episodeDays: 3, nonEpisodeDays: 2, amberDays: 2, greenDays: 3, totalDays: 5 },
  axes: {
    dwell: { episodeDays: 3, nonEpisodeDays: 2, episodeDaysAmber: 1, nonEpisodeDaysAmber: 1 },
    drop:  { episodeDays: 3, nonEpisodeDays: 2, episodeDaysAmber: 0, nonEpisodeDaysAmber: 0 },
    rise:  { episodeDays: 3, nonEpisodeDays: 2, episodeDaysAmber: 0, nonEpisodeDaysAmber: 0 },
  },
  episodeLevel: { totalEpisodes: 5, episodesWithWeather: 4, episodesAmber: 1, episodesRed: 0, backfilledCount: 1, abortedCount: 1 },
  arizona: { observedDays: 1, episodeDays: 1, daysAmber: 0, daysRed: 0, episodes: 1 },
}
```

**Trace notes:**
- Day 5 episode has no weather snapshot → excluded from `epsWithWx` → `episodesWithWeather` = 4 (days 1, 2, 7, 8)
- Day 6 episode lands in `arizonaDates` → excluded from `marqEps` → `totalEpisodes` = 5 (days 1, 2, 5, 7, 8)
- Day 1 episode weather: dwell=15 ≥ 12 → amber → `episodesAmber` = 1; dwell=15 < 24 → not red → `episodesRed` = 0
- Day 7 episode: `spasm_count=0, !prodrome_absent` → `isAborted` → `abortedCount` = 1
- Day 8 episode: `captured_retrospectively=true` → `backfilledCount` = 1
- Arizona day 6: dwell=0 < 12 → green → `daysAmber` = 0
- `nonEpisodeDays = 2` (days 3 and 4) → contingency gate `nonEpisodeDays >= 5` is NOT met → formatting output shows "Insufficient days" line (correct behavior for this small fixture)

**To verify in browser console:**

```js
// After app loads, paste fixture above, then:
const result = buildWeatherExposureTable(fixture);
console.log(JSON.stringify(result, null, 2));
// Manually diff against expected object above
```

### Live-data hand-count (AC 13)

To be completed after deployment. Open the app, run:
```js
const entries = await DB.allEntries();
const result = buildWeatherExposureTable(entries);
console.log(JSON.stringify(result, null, 2));
```
Then hand-count one week of data from the current DB (episode-days, non-episode-days, amber/green per day) and verify the function's output matches. Mismatch blocks QA transition.
