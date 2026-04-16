# Ticket 3 — Meal Size + Edit Time

## What changed

The one-tap "I just ate" button has been replaced with a **two-phase meal logging flow**. Tapping the button now opens a picker where the user selects meal size and optionally adjusts the timestamp. Fasting thresholds are now size-aware, and existing meal logs can be edited after the fact.

### New meal size options

| Value | Label | Fasting clock behavior | Alert threshold |
|---|---|---|---|
| `drink` | Coffee / drink only | Does NOT reset fasting clock | N/A |
| `snack` | Small snack | Resets | 2.5h |
| `light` | Light meal | Resets | 4h (default) |
| `full` | Full meal | Resets | 5h |

### Key behaviors

- **Drink isolation:** Selecting "Coffee / drink only" writes to `meal:last_drink`, not `meal:last`. The fasting clock is unaffected — the previous real-food timestamp remains.
- **Time editing:** A `datetime-local` input is pre-filled with the current time. Can be backdated (up to 24h ago) but not set to the future.
- **Edit affordance:** The resting meal card shows an "Edit" link (ok state) or "Edit time" link (alert state) that reopens the picker with existing values pre-populated.
- **Size-aware thresholds:** `getMealSuggestion()` adjusts warn/danger/severe tiers based on the logged meal size.
- **Reminder copy references size:** e.g. "5h since your last snack — consider a snack"
- **Episode snapshot:** At episode save time, `lastMealSize` and `lastMealTimestamp` are captured on the episode entry for export context.
- **Export:** Episode fasting line now includes meal size when available: `Hours fasted: 3.5 (last: snack)`. `mealSize` on the `meal:last` key itself is not exported (operational data).

## Files changed

- `index.html` — rewrote `logMeal()`, added `saveMeal()`, `localDateTimeISO()`, `mealSizeOpts`, `mealSizeLabels`. Updated `getMealSuggestion()` signature and thresholds. Updated `renderMealCard()` display and edit links. Updated `saveEpisode()` to snapshot meal info. Updated `exportReport()` fasting line.

## What to test

### 1. Picker flow — new meal log

1. Open the app home screen.
2. Tap **I just ate**.
3. Confirm a picker sheet appears inside the meal card with:
   - 4 size buttons (Coffee/drink, Small snack, Light meal, Full meal)
   - A `datetime-local` input pre-filled with the current time
   - Save and Cancel buttons
4. Tap **Save** without selecting a size — confirm a toast appears: "Pick a size first". Record is NOT saved.
5. Tap **Cancel** — confirm the card returns to its previous state.

### 2. Save — light meal (default behavior)

1. Tap **I just ate** → select **Light meal** → accept default time → **Save**.
2. Confirm toast: "Meal logged".
3. Confirm the card shows: "Last ate: light meal, 0 min ago" (or similar).
4. Confirm "Next check at 4 hours" appears in the sub-text.

### 3. Save — snack (shorter threshold)

1. Tap **I just ate** → select **Small snack** → **Save**.
2. Confirm the card shows: "Last ate: snack, 0 min ago".
3. Confirm "Next check at 2.5 hours" appears.

### 4. Save — full meal (longer threshold)

1. Tap **I just ate** → select **Full meal** → **Save**.
2. Confirm the card shows: "Last ate: full meal, 0 min ago".
3. Confirm "Next check at 5 hours" appears.

### 5. Drink — does not reset fasting clock

1. First, log a **Light meal** so the fasting clock has a real-food timestamp.
2. Wait a moment, then tap **I just ate** → select **Coffee / drink only** → **Save**.
3. Confirm toast: "Drink logged".
4. Confirm the meal card still shows the previous light meal's timestamp and elapsed time — NOT "0 min ago".
5. The fasting clock should be counting from the light meal, not the drink.

### 6. Time backdating

1. Tap **I just ate** → select **Light meal** → change the time to 5 hours ago → **Save**.
2. Confirm the card immediately shows the 5h+ alert tier (warn or danger depending on thresholds).
3. If environmental risk is elevated, confirm the compound banner appears.

### 7. Guardrails — future time

1. Tap **I just ate** → select **Light meal** → set the time to 1 hour in the future → **Save**.
2. Confirm a toast appears: "Time cannot be in the future".
3. Confirm the record is NOT saved — card returns to previous state after cancel.

### 8. Guardrails — too old

1. Tap **I just ate** → select **Light meal** → set the time to 25 hours ago → **Save**.
2. Confirm a toast appears: "Time cannot be more than 24h ago".
3. Confirm the record is NOT saved.

### 9. Edit — ok state

1. Log a **Full meal** at the current time so the card shows the ok (green) state.
2. Confirm an **Edit** link appears in the sub-text next to "Next check at 5 hours".
3. Tap **Edit**.
4. Confirm the picker reopens with **Full meal** pre-selected and the original timestamp pre-filled.
5. Change the size to **Small snack**, leave time unchanged → **Save**.
6. Confirm the card now shows "Last ate: snack" and "Next check at 2.5 hours".

### 10. Edit — alert state

1. Log a meal backdated to 5h ago so the alert state is showing.
2. Confirm an **Edit time** link appears in the alert sub-text.
3. Tap **Edit time**.
4. Confirm the picker reopens with the existing size and timestamp pre-populated.
5. Change the time to 30 minutes ago → **Save**.
6. Confirm the card drops back to the ok (green) state.

### 11. Size-aware reminder copy

1. Log a **Small snack** backdated to 3 hours ago.
2. Confirm the reminder title references the size: e.g. "3h since your last snack — consider a snack".

### 12. Episode snapshot + export

1. Log a **Light meal** at the current time.
2. Log an episode (any data is fine).
3. Tap **Export**.
4. Find the episode entry in the report.
5. If `fastedHours` is present, confirm the line reads: `Hours fasted: X (last: light meal)`.
6. Confirm `mealSize` does NOT appear as a standalone field anywhere in the export.

### 13. Persistence

1. Log a meal with a specific size and time.
2. Reload the page (hard refresh).
3. Confirm the meal card reflects the saved size and timestamp — not reset.

### 14. No-meal-logged state

1. In an incognito window (no prior data), confirm the meal card shows: "No meal logged yet today" with an "I just ate" button.
2. Tap "I just ate" — confirm the picker opens normally.

## Pass criteria

- Picker shows 4 sizes + time input on every "I just ate" tap
- Drink does not reset fasting clock
- Snack/light/full each apply correct thresholds (2.5h / 4h / 5h)
- Future and >24h timestamps are rejected with toast
- Edit link on ok-state card reopens picker with pre-populated values
- Edit time link on alert-state card reopens picker with pre-populated values
- Reminder copy includes meal size
- Episode export includes `(last: size)` on fasting line
- mealSize not exported as standalone field
- Card state updates immediately after save/edit
- Data persists across reload
- No console errors
