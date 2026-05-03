---
id: TICK-040
title: Weather exposure comparison — episode-day vs non-episode-day contingency
status: backlog
priority: normal
wave: emergent
created: 2026-05-03
updated: 2026-05-03
plan: docs/plans/PLAN_weather_exposure_comparison.md
test: null
linear:
  id: ISO-109
  parent: null
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-040: Weather exposure comparison — episode-day vs non-episode-day contingency

## Summary

Replaces the two episode-side stats in the physician report's ENVIRONMENTAL PATTERN section (`≥18h` pressure dwell at index.html:2086 and `≥13°F` temp drop at index.html:2091) with a contingency-table analysis that answers two questions explicitly:
- **Necessary?** Did any episode occur in green-weather conditions?
- **Sufficient?** Did elevated weather always produce an episode?

Output is a 4-cell day-level contingency + three derived rates + necessary/sufficient sentences keyed off cell counts, plus a per-axis breakdown, an episode-level descriptive line, and a separate Arizona block.

Touches `exportReport()` only. No schema changes; no new form fields; no home stat chip.

Origin: critical review of `PLAN_weather_exposure_comparison.md` on 2026-05-03 surfaced 15 issues with the original draft (schema fallback, Arizona handling, statistical framing, source asymmetry, dedup rule, gating, AC tightness). All 15 resolved and the plan rewritten in place.

## Acceptance Criteria

See `docs/plans/PLAN_weather_exposure_comparison.md` § Acceptance criteria for the full 19-item set (15 code-verifiable + 4 behavioral). Summary by surface:

### Helper

- [ ] `buildWeatherExposureTable` lives at top-level near `environmentalRisk` (index.html ~985)
- [ ] All episode-side weather reads use `(ep.weather_at_prodrome ?? ep.weather)`
- [ ] Day-level classification uses morning check-in `weather` only (no episode-time or EOD snapshots)
- [ ] Days without a morning check-in `weather` snapshot drop from both sides of the contingency
- [ ] Days with multiple morning check-ins are classified by the worst risk-level among them
- [ ] Arizona days (lat/lon outside the Marquette bounding box) excluded from contingency, per-axis breakdown, and episode-level summary; counted only in the Arizona block
- [ ] Aborted episodes (`type==='episode_v2' && spasm_count===0 && !prodrome_absent`) count toward "episode-day"
- [ ] Episode-level descriptive line includes backfilled snapshots; `backfilledCount` reported in footnote

### Report formatting

- [ ] Existing `≥18h` pressure paragraph and `≥13°F` thermal paragraph deleted; new section subsumes them
- [ ] Per-component gating fires per the plan's rules (3/5 thresholds split per subsection); below-threshold components print specific "insufficient data: X / Y" lines
- [ ] Percentages followed by `(n=X — small sample)` inline when relevant n < 10
- [ ] Necessary/sufficient sentences resolve to "is/is not" based on `c>0` / `b>0`

### Verification (before QA transition)

- [ ] Synthetic fixture (pinned in plan's Verification artifacts §) returns the pinned object (deep-equal)
- [ ] Live-data hand-count for the implementation week matches `buildWeatherExposureTable` output

### Cache / no-regression

- [ ] No new fields written to any check-in, episode, EOD, motor_event, or intervention_event entries
- [ ] No home stat chip added
- [ ] SW cache version bumped (report-shape change is a shell behavior change)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty

## Agent Context

- **Pre-implementation lat/lon check.** Before pinning the Arizona bounding box constant, grep current check-in data for the lat/lon distribution (Marquette ~46.5N, -87.4W; Arizona ~32-37N, -109 to -114W). Pin a constant `ARIZONA_BOUNDING_BOX = { latMin, latMax, lonMin, lonMax }` and a helper `isArizonaDay(checkin)` that returns true when the check-in's `weather.lat`/`weather.lon` falls inside.
- **Day's worst-risk rule.** For each observed day, take all check-in snapshots (currently always one in practice; defensive against future multi-checkin days), classify each via `environmentalRisk()`, keep the worst (`red > amber > green`).
- **`is/is not` resolution.** "is not necessary" if `c > 0`; "is necessary" if `c === 0`. "is not sufficient" if `b > 0`; "is sufficient" if `b === 0`.
- **Footnote phrasing.** Backfilled snapshots are "archive-filled where the real-time fetch failed", *not* "retrospectively reconstructed" — they are observed weather data from Open-Meteo's archive endpoint, not estimation.
- **Per-component gating, not whole-block gating.** Thin episode-side data must not hide the non-episode side or vice versa. Each subsection independently gates and prints its own "insufficient data" line.

## Implementation Notes

- **Why not 6h dedup of episodes:** the user's `episode_v2`-grain logging is the chosen unit (per `project_data_review_apr27`). Two `episode_v2` rows on the same day = the user explicitly tapped "Warning starting" twice = two distinct events. Day-level analysis (one episode-day = ≥1 episode that day) sidesteps the unit-mismatch problem without re-litigating logging grain.
- **Why morning-checkin-only for day classification:** episode-time snapshots create source asymmetry — episode days would have more chances to cross threshold than non-episode days, biasing the comparison by construction.
- **Why exclude Arizona from math:** per `project_baseline_reframe`, Arizona is treated as separate trigger evidence (near-complete symptom resolution regardless of weather, attributable to environmental change as a whole, not weather alone). Including those days dilutes the Marquette contingency.
- **Why include aborted episodes as episode-days:** per `project_thc_treatment_response`, aborted episodes are evidence the prodrome was real and the body crossed the threshold. Excluding them would actively mis-state the exposure data.
- **LOC estimate:** ~120-180 LOC — one helper, one structured object, formatting changes in `exportReport()`, two-paragraph deletion.

## Test Sequence (user, during QA)

1. Open the report. The old `≥18h` pressure and `≥13°F` thermal paragraphs are gone.
2. New section heading: "Weather exposure: episode-days vs. non-episode-days (Marquette only)".
3. 4-cell contingency table renders with cell counts and totals.
4. Necessary/sufficient sentences read correctly given the cell counts.
5. Per-axis breakdown shows three rows (dwell / drop / rise) in the compact `pct (n/N) vs pct (n/N)` format.
6. Episode-level snapshot summary reads correctly; footnotes name aborted-episode and backfill counts.
7. If Arizona data exists, separate Arizona block follows with raw counts only.
8. If any subsection lacks data, it shows a specific "insufficient data: X / Y" line, not silence.
9. Small-sample tags `(n=X — small sample)` appear inline next to percentages with n<10.
10. Report renders without errors; no fields added to any entry types (verify via JSON export inspection).

## Ship Notes

_(pending)_
