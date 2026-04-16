# Testing -- Wave 5: Morning Check-in Restructure

One combined ticket: morning check-in restructure + Tier 1 exposure additions + functional-today scale.

---

## Test order

1. **Home screen label** (quick, 1 check)
2. **Step 0 -- Overnight Sleep + Alcohol** (8 checks)
3. **Step 1 -- Overnight Events + Stiffness + Cycle Proxies** (9 checks)
4. **Step 2 -- Communication** (2 checks)
5. **Step 3 -- Body** (2 checks)
6. **Step 4 -- How's Today + Notes** (3 checks)
7. **Save + data integrity** (5 checks)
8. **Log view** (4 checks)
9. **Export** (5 checks)
10. **Legacy compat** (3 checks)
11. **Smoke test**

---

## 1. Home screen label

- [ ] Home screen action card reads **"Morning Check-in"** with subtitle **"How you woke up"**

## 2. Step 0 -- Overnight Sleep + Alcohol

- [ ] Progress bar shows 5 segments
- [ ] Date input present, defaults to today
- [ ] Bed time input (type=time) present, accepts HH:MM
- [ ] Wake time input (type=time) present, accepts HH:MM
- [ ] Awakenings number input present
- [ ] Sleep quality buttons: Restorative / Somewhat / Poor / RLS bad -- tap toggles selection
- [ ] Alcohol "None / 1 / 2 / 3+" buttons present; selecting None does NOT show time-of-last-drink
- [ ] Selecting 1, 2, or 3+ reveals "Time of last drink" time input

## 3. Step 1 -- Overnight Events + Stiffness + Cycle Proxies

- [ ] 7 overnight event chips present (Muscle twitching, Jaw spasming, Intercostal, Woke locked, Night sweats, Breathing trouble, Woke in pain)
- [ ] Multi-select works: can select multiple chips simultaneously
- [ ] "Slept through -- nothing noticed" chip at bottom, styled italic, full width
- [ ] Tapping "Slept through" clears all other selections
- [ ] Tapping any event chip after "Slept through" clears the nothing-noticed selection
- [ ] Morning stiffness: 5 options (None / <15 min / 15-60 min / 1+ hours / Still stiff) with "How long until you loosened up?" prompt
- [ ] Cycle phase section: 3 toggle buttons (Breast tenderness, Mood/irritability shift, Bloating/fluid retention)
- [ ] Libido: 3 choices (Higher than usual / Lower than usual / About the same)
- [ ] All selections persist across Back/Next navigation

## 4. Step 2 -- Communication

- [ ] Same 4-level comm scale as before (Talking easily / Quieter / Shorter responses / Brief only)
- [ ] External observation question present (Yes / No / No one around)

## 5. Step 3 -- Body

- [ ] Body map renders with all 18 regions in grouped grid
- [ ] Step subtitle reads "Tap anywhere that hurts right now"

## 6. Step 4 -- How's Today + Notes

- [ ] 4 functional-today options: Good day / OK day / Scaled back / Bad day
- [ ] Colors: green / blue / amber / red
- [ ] No Arizona reference anywhere on this step
- [ ] Notes textarea present below the scale

## 7. Save + data integrity

- [ ] Tapping Save on step 4 saves and returns to home
- [ ] Toast reads "Check-in saved"
- [ ] With bed=22:30 and wake=06:30, saved entry has `sleepHours: 8`
- [ ] With bed=01:00 and wake=09:00, saved entry has `sleepHours: 8`
- [ ] Alcohol units stored as string ('0', '1', '2', '3+')

## 8. Log view

- [ ] New check-in entry shows "Check-in" label in blue
- [ ] Border color matches functional-today selection (green/blue/amber/red)
- [ ] Severity badge shows "Good day" / "OK day" / "Scaled back" / "Bad day"
- [ ] Sleep hours chip appears (e.g. "8h sleep")

## 9. Export

- [ ] Section header reads "MORNING CHECK-INS"
- [ ] New fields appear: Sleep quality, Sleep hours, Bed time, Wake time, Awakenings
- [ ] Overnight events listed if non-empty; morning stiffness shown if not "none"
- [ ] Alcohol shown if units > 0; includes last drink time if provided
- [ ] Cycle proxy flags shown if any active; "libido higher" / "libido lower" shown if not "same"
- [ ] "Today:" line shows functional label (not Arizona label)

## 10. Legacy compat

- [ ] Old check-in entries (with `severity`, `nap`, `workCapacity`, etc.) render in log view without errors
- [ ] Old entries show Arizona severity label in severity badge, not functional-today label
- [ ] Export prints legacy fields (nap, work capacity, cancelled plans, heat therapy, hormonal symptoms) when present on old entries

## 11. Smoke test

After all checks above pass:

1. Load app in incognito -> set PIN -> reach home screen
2. Confirm home screen renders: header, env-risk tile, action grid with "Morning Check-in"
3. Meal card renders normally
4. Log an episode -> go through all steps -> save. Confirm episode form is unaffected.
5. Open View Log -> confirm both episode and check-in entries render
6. Export -> confirm both sections present, no errors
