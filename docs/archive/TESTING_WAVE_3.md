# Testing — Wave 3: Meal Logging

One ticket in this wave. Test the ticket, then run the smoke test.

---

## Tickets

| # | Ticket | File |
|---|--------|------|
| 3 | Meal size + edit time | [TICKET_3_meal_logging.md](TICKET_3_meal_logging.md) |

---

## Test order

1. **Ticket 3** — meal logging (14 test groups)
2. **Smoke test** — full pass to catch regressions

---

## Smoke test

After testing Ticket 3, run a clean end-to-end pass to confirm nothing else broke:

1. Load the app in incognito → set PIN → reach home screen.
2. Confirm home screen renders cleanly: header shows "ISOBAR" only, env-risk tile loads, action grid present.
3. Confirm the meal card renders (either no-meal-logged or ok state).
4. **Log a check-in** — go through all steps including body map. Save.
5. **Log an episode** — go through all steps. Save.
6. Open **View Log** — confirm both entries appear with correct data.
7. Tap **Export** — confirm the report generates without errors.
8. Confirm env-risk tile still updates and displays correctly.
9. Check the browser console for any JavaScript errors throughout.

---

## Results template

Copy and fill in:

```
## Wave 3 Test Results — [DATE]

### Ticket 3: Meal size + edit time
- [ ] Picker opens on "I just ate" with 4 sizes + time input
- [ ] Save without size selection shows toast, does not save
- [ ] Cancel returns card to previous state
- [ ] Light meal: saves, shows "light meal", threshold at 4h
- [ ] Small snack: saves, shows "snack", threshold at 2.5h
- [ ] Full meal: saves, shows "full meal", threshold at 5h
- [ ] Drink: saves, does NOT reset fasting clock
- [ ] Backdated time: card shows correct elapsed/alert state
- [ ] Future time rejected with toast
- [ ] >24h ago rejected with toast
- [ ] Edit link (ok state): reopens picker pre-populated
- [ ] Edit time link (alert state): reopens picker pre-populated
- [ ] Size change via edit updates threshold display
- [ ] Reminder copy includes meal size
- [ ] Episode export shows "(last: size)" on fasting line
- [ ] mealSize not exported as standalone field
- [ ] Data persists across reload
- [ ] No-meal-logged state works in incognito
- [ ] No console errors

### Smoke test
- [ ] PIN setup works
- [ ] Home screen renders cleanly (header, env-risk, meal card)
- [ ] Check-in end-to-end saves
- [ ] Episode end-to-end saves
- [ ] Log view renders entries
- [ ] Export generates cleanly
- [ ] Env-risk tile functional
- [ ] No JS errors in console

OVERALL: [ PASS / FAIL ]
Notes:
```
