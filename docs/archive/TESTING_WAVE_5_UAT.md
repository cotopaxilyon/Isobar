# UAT Write-Up — Wave 5: Morning Check-in Restructure

**Date:** 2026-04-15
**Ticket:** Wave 5 — Morning check-in restructure + Tier 1 exposure additions + functional-today scale
**Environment:** http://localhost:8000 (local dev server)
**Tester:** Lyon Product Quality Studio
**Execution:** Automated (Playwright spec — `tests/client-isobar/uat-wave-5.spec.ts`)

> All 42 scenarios tested passed. See scenarios below for results and recordings.

---

## Tested Results

**Scenario 1: PASS**
Home screen card reads "Morning Check-in" with subtitle "How you woke up".

**Scenario 2: PASS** Progress bar shows 5 segments.

**Scenario 3: PASS** Date field defaults to today.

**Scenario 4: PASS** Bed time input accepts HH:MM.

**Scenario 5: PASS** Wake time input accepts HH:MM.

**Scenario 6: PASS** Awakenings number input present.

**Scenario 7: PASS** Sleep quality 4 buttons toggle correctly.

**Scenario 8: PASS** Alcohol "None" hides time-of-last-drink input.

**Scenario 9: PASS** Alcohol "2" reveals time-of-last-drink input.

**Scenario 10: PASS** 7 overnight event chips present.

**Scenario 11: PASS** Multi-select works on overnight chips.

**Scenario 12: PASS** "Slept through" chip styled italic, full width.

**Scenario 13: PASS** "Slept through" clears prior event selections.

**Scenario 14: PASS** Event chip clears "Slept through" selection.

**Scenario 15: PASS** Morning stiffness: 5 options with prompt.

**Scenario 16: PASS** Cycle phase: 3 toggle buttons present.

**Scenario 17: PASS** Libido: 3 choices present.

**Scenario 18: PASS** Selections persist across Back/Next.

**Scenario 19: PASS** Communication: 4-level scale present.

**Scenario 20: PASS** External observation question present.

**Scenario 21: PASS** Body map: 18 regions in grouped grid.

**Scenario 22: PASS** Subtitle reads "Tap anywhere that hurts right now".

**Scenario 23: PASS** Functional-today: 4 options present.

**Scenario 24: PASS** Correct color coding (green/blue/amber/red).

**Scenario 25: PASS** No Arizona reference on step 4.

**Scenario 26: PASS** Save returns to home screen.

**Scenario 27: PASS** Toast reads "Check-in saved".

**Scenario 28: PASS** bed=22:30 wake=06:30 -> sleepHours=8 (midnight crossing).

**Scenario 29: PASS** bed=01:00 wake=09:00 -> sleepHours=8 (same-day).

**Scenario 30: PASS** Alcohol units stored as string "3+".

**Scenario 31: PASS** Log entry type "Check-in" in blue.

**Scenario 32: PASS** Border color matches functionalToday (red for "bad").

**Scenario 33: PASS** Severity badge shows "Scaled back".

**Scenario 34: PASS** Sleep hours chip "8h sleep" visible.

**Scenario 35: PASS** Export section header "MORNING CHECK-INS".

**Scenario 36: PASS** Export contains sleep fields.

**Scenario 37: PASS** Export contains overnight events and stiffness.

**Scenario 38: PASS** Export contains alcohol with last drink time.

**Scenario 39: PASS** Export contains cycle proxies and functional-today label.

**Scenario 40: PASS** Legacy check-in renders without errors.

**Scenario 41: PASS** Legacy severity badge shows Arizona-era label.

**Scenario 42: PASS** Legacy fields present in export.

**Smoke Test: PASS** Full incognito walkthrough complete.
