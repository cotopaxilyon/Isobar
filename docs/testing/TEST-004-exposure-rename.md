---
id: TEST-004
ticket: TICK-004
status: pending
last-run: ""
---

# TEST-004: Exposure Rename + Auto-Fasting

## What changed

The episode form step previously titled "Triggers" has been renamed to "What was going on today?" with the subtitle "Select anything that was present." All internal field names changed from `triggers` to `exposures`. The fasting hours field is now auto-populated from the last logged meal. The export uses "Exposures" throughout. Existing entries with `triggers` arrays are read via backward-compat fallback.

### Key behaviors

- **Framing:** Step title uses neutral "what was going on" language instead of causal "triggers" framing.
- **Field rename:** `epData.triggers` → `epData.exposures`, `trigOpts` → `exposureOpts`, `_lastArr` → `'exposures'`.
- **Auto-fasting:** If `meal:last` exists in storage, the fasting field is pre-populated with the calculated elapsed hours and displayed as read-only with an "Edit" link. If no meal is logged, the manual input appears with "No meal logged — enter manually."
- **Manual override:** Tapping "Edit" on the auto-calculated value clears it and shows the number input with a "Use calculated" revert button.
- **Export compat:** `e.exposures || e.triggers || []` ensures old entries render correctly. Export headers read "TOP EXPOSURES" and per-episode lines read "Exposures:".

## Files changed

- `index.html` — `EP_STEPS[4]`, `startEpisode()` epData init, `renderEpStep()` case 4, `exportReport()`.
- `sw.js` — cache bumped to v3.

## What to test

### 1. Step title and subtitle

1. Open **Log Episode** and navigate to step 5 (the exposures step).
2. Confirm the step title reads **"What was going on today?"**.
3. Confirm the subtitle reads **"Select anything that was present"**.
4. Confirm the word "Triggers" does not appear anywhere in the step.

### 2. Exposure chips — selection

1. On the same step, confirm all 10 chips appear: Weather/travel, Fasting, Animal exposure, Chemical/perfume, New environment, Poor sleep, High stress, Physical exertion, Hormonal/cycle, Mold/musty space.
2. Tap several chips — confirm they toggle on (highlighted) and off.
3. Navigate forward and back — confirm selections persist.

### 3. Auto-fasting — meal logged

1. Go home. Log a meal (any size) if one isn't already logged.
2. Start a new episode and navigate to the exposures step.
3. Confirm the fasting field shows a calculated value (e.g. "2.3h") with the text "from your last logged meal" and an "Edit" link.
4. Confirm the value is approximately correct (hours since your last meal log).

### 4. Auto-fasting — edit override

1. On the auto-fasting display, tap **Edit**.
2. Confirm the display switches to a number input (empty) with a "Use calculated" button.
3. Type a manual value (e.g. "5").
4. Navigate forward and back — confirm the manual value persists and the auto-display does not reappear.
5. Tap **Use calculated** — confirm it reverts to the auto-calculated display.

### 5. Auto-fasting — no meal logged

1. Clear meal data: in devtools console, run `DB.del('meal:last')` and `DB.del('meal:last_drink')`.
2. Start a new episode and navigate to the exposures step.
3. Confirm the fasting field shows a number input with "No meal logged — enter manually".
4. Confirm no "Use calculated" button appears.

### 6. Save and verify data key

1. Select a few exposure chips and save the episode.
2. In devtools console, find the most recent episode entry and confirm it has an `exposures` array (not `triggers`).
3. Confirm the `exposures` array contains the values you selected.

### 7. Log view — new entry

1. Open **View Log**.
2. Confirm the new episode entry renders without errors.

### 8. Log view — old entry (backward compat)

1. If old entries with `triggers` arrays exist, confirm they still display correctly in the log view.
2. If no old entries exist, skip this test.

### 9. Export — new entry

1. Tap **Export Report**.
2. Confirm the summary section reads **"TOP EXPOSURES"** (not "TOP TRIGGERS").
3. Find the new episode in the export and confirm it reads **"Exposures: ..."** (not "Triggers:").

### 10. Export — old entry (backward compat)

1. In the same export, find an old episode entry (one saved before this change).
2. Confirm it reads **"Exposures: ..."** with the old trigger values rendered correctly.
3. If no old entries exist, skip this test.

### 11. Fasting label

1. Confirm the label above the fasting field reads **"Hours fasted at episode onset"** (not "Hours since last meal").

### 12. Service worker

1. Hard-reload the app (Cmd+Shift+R or clear cache).
2. In devtools → Application → Cache Storage, confirm the cache key is `isobar-v3`.
