# Isobar — Pending Updates

---


# 2. Body Map Replacement

## Problem

The current body map renders 14 buttons absolutely positioned inside a 340px container, with only a thin vertical center line as a reference. Without a body silhouette, the buttons are floating in space with no visual anchor. This is confusing at full cognitive capacity and unusable when impaired.

An SVG body outline with click zones would be more intuitive in theory, but adds significant complexity and still relies on spatial reasoning — which is unreliable under cognitive load.

## Approach

Replace the positional layout with a **grouped label grid**. Two columns: front body regions on the left, back body regions on the right. Section headers for clear grouping. Large tap targets. No positional ambiguity.

## New Layout Structure

18 regions total (14 existing + R. Jaw, L. Jaw, R. Ribs, L. Ribs). All rows are clean pairs.
Diaphragm was considered but dropped — Chest covers the same clinical territory.

```
[ HEAD & NECK                ]
[ Head/Face  |  Neck         ]
[ R. Jaw     |  L. Jaw       ]

[ TORSO                      ]
[ Chest      |  Upper Back   ]
[ R. Ribs    |  L. Ribs      ]
[ Abdomen    |  Lower Back   ]

[ ARMS                ]
[ R. Arm  |  L. Arm   ]

[ LOWER BODY          ]
[ R. Hip  |  L. Hip   ]
[ R. Leg  |  L. Leg   ]
[ R. Foot |  L. Foot  ]
```

New region IDs to add: `right_jaw`, `left_jaw`, `right_ribs`, `left_ribs`.

Each button toggles active state exactly as now. Selected regions are stored in `bodyPain[]` with the same IDs — no data structure change.

### Color param

`bodyMap()` accepts an optional `activeColor` parameter (default `var(--accent)`). The muscle event form passes `var(--warn)` to render amber active regions instead of blue. Episode and check-in forms pass nothing (blue).

```js
function bodyMap(selected, activeColor = 'var(--accent)') { ... }
```

The active state CSS is applied inline rather than via a class, so no new CSS class is needed for the color variant.

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Rewrite the `bodyMap()` function

**Location:** `bodyMap()`, lines ~804–828

Replace the absolute-position layout with a sectioned grid. Keep the same region IDs. Remove `.body-map`, `.body-map-center`, and `.body-region` CSS classes (or repurpose them). Add new CSS for `.body-grid`, `.body-section`, `.body-section-label`.

The function signature and toggle behavior (`window._bodyToggle`) remain unchanged.

### Step 2 — Update CSS

Remove or repurpose `.body-map` height/position styles. Add:
- `.body-grid` — full-width container, flex column, gap between sections
- `.body-section-label` — small uppercase section header in `var(--dim)`
- `.body-row` — 2-column grid for paired regions
- `.body-btn` — replaces `.body-region`, styled as large tap targets (min height 44px), highlight on active

## Testing Steps

1. Open **Daily Check-in** and navigate to step 2 (Pain Location).
2. Confirm all 18 regions appear, organized in labeled groups.
3. Confirm R. Jaw, L. Jaw, R. Ribs, L. Ribs appear in their correct sections.
4. Tap each region and confirm it highlights in blue. Tap again and confirm it deselects.
5. Complete and save the check-in. Open **View Log** and confirm selected regions appear in the entry chips.
6. Repeat in **Log Episode**, pain location step — confirm blue active color.
7. Open **Log Muscle Event** and tap a region — confirm amber active color.
8. Test on a narrow screen (375px width) to confirm no overflow or clipping.

---

# 3. Meal Logging — Capture Meal Size

## Problem

`logMeal()` saves only a timestamp. No content. The reminder logic uses only elapsed time, so advice is generic regardless of whether she last had almonds or a full meal. The suggestions cannot calibrate urgency or quantity accurately.

A free-text food field is not appropriate — too much cognitive load when fasted and impaired, exactly when the logging matters most.

## Approach

After tapping "I just ate", show a **one-tap size picker** with 4 options. Store `mealSize` alongside the timestamp. Adjust reminder thresholds based on size.

## New Meal Size Options

| Value | Label | Reminder threshold |
|---|---|---|
| `drink` | Coffee / drink only | Does not reset fasting clock |
| `snack` | Small snack | 2.5h |
| `light` | Light meal | 4h (current behavior) |
| `full` | Full meal | 5h |

`drink` is important: logging a coffee should not make the app think she ate. It records the drink but leaves the previous real-food timestamp in place for fasting calculation.

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Change `logMeal()` to a two-phase flow

**Location:** `logMeal()`, line ~1364

Instead of saving immediately, render a size picker inside the meal card. On selection, call `saveMeal(size)` which writes `{ timestamp, type: 'meal', mealSize: size }` to storage. For `drink`, write to a separate key `meal:last_drink` and do not update `meal:last`.

### Step 2 — Update `getMealSuggestion()` to use `mealSize`

**Location:** `getMealSuggestion()`, line ~1371

Read `mealSize` from `DB.get('meal:last')`. Apply adjusted thresholds:
- `snack` → alert starts at 2.5h instead of 4h
- `light` → unchanged (4h)
- `full` → alert starts at 5h, danger at 8h

### Step 3 — Update reminder copy to reference size

When the reminder fires, include what size the last log was in the sub-text. E.g. "5h since your last snack — eat a proper meal now." This makes it clear the app knows what it's working from.

### Step 4 — Update the "I just ate" button label

When `mealSize` is set and within the ok window, show the size in the meal card summary: "Last ate: light meal, 2h ago."

## Testing Steps

1. Tap **I just ate** and confirm the size picker appears (4 options).
2. Select **Coffee / drink only** — confirm the fasting clock does not reset. If a previous meal was logged, confirm its time is still shown.
3. Select **Small snack** — confirm the fasting clock resets. Wait (or manually advance) to 2.5h and confirm the reminder appears earlier than the default 4h.
4. Select **Full meal** — confirm the alert does not appear until 5h.
5. Confirm the meal card summary shows the size ("Last ate: full meal, 1.5h ago").
6. Confirm the reminder copy references the size ("since your last snack").
7. Export and confirm `mealSize` is not included in the plain-text report (it's operational data, not clinical data).

---

# 4. Pressure Status — Clarify What Orange Means

## Problem

The pressure display shows status in color (green / amber / red) with a short label ("Falling", "Rapid Drop ⚠"). The amber "Falling" state — which appears when the trend is between -1.5 and -3 hPa/6h — is ambiguous. It looks like a warning but the clinical alert threshold is >3 hPa. The UI does not answer "should I be concerned?" or "what should I do?"

## Approach

Add a **short explanatory line** beneath the pressure number that changes with each status state. No color changes needed — the color system is correct. The issue is missing context, not wrong color.

## New Status Copy

| State | Condition | Label | New explanatory line |
|---|---|---|---|
| Normal | trend ≥ -1.5, hPa ≥ 1000 | Normal | *(no extra line)* |
| Low | hPa < 1000 | Low | "Low baseline — stay warm and fed." |
| Very Low | hPa < 980 | Very Low | "Low baseline — monitor for symptoms." |
| Falling | trend < -1.5 | Dropping | "Declining but not at your threshold yet. Stay aware." |
| Rapid Drop | trend < -3 | Rapid Drop ⚠ | "At episode trigger level. Eat, rest, reduce triggers." |

Note: rename "Falling" → "Dropping" for plain-English clarity.

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Add `description` field to `pressureStatus()`

**Location:** `pressureStatus()`, lines ~719–725

Add a `description` string to each returned object. Empty string for Normal.

```js
function pressureStatus(hpa, trend) {
  if (trend < -3)   return { label: 'Rapid Drop ⚠', color: 'var(--danger)', icon: '↓↓', description: 'At episode trigger level. Eat, rest, reduce triggers.' };
  if (trend < -1.5) return { label: 'Dropping',     color: 'var(--warn)',   icon: '↓',  description: 'Declining but not at your threshold yet. Stay aware.' };
  if (hpa < 980)    return { label: 'Very Low',      color: 'var(--warn)',   icon: '▼',  description: 'Low baseline — monitor for symptoms.' };
  if (hpa < 1000)   return { label: 'Low',           color: 'var(--mid)',    icon: '▽',  description: 'Low baseline — stay warm and fed.' };
  return             { label: 'Normal',              color: 'var(--good)',   icon: '—',  description: '' };
}
```

### Step 2 — Render the description line in the weather display

**Location:** `renderWeather()`, line ~736–738, where `pressure-summary` is set.

Append a description line below the status label when `st.description` is non-empty:

```js
document.getElementById('pressure-summary').innerHTML =
  `<div class="mono" style="font-size:18px;font-weight:600;color:${st.color}">${w.pressure} hPa</div>
   <div style="font-size:11px;color:${st.color}">${st.icon} ${st.label}</div>
   ${st.description ? `<div style="font-size:11px;color:var(--dim);margin-top:3px">${st.description}</div>` : ''}`;
```

## Testing Steps

1. Open the app home screen.
2. With weather loaded, inspect the pressure display:
   - If status is **Normal**: confirm no description line appears.
   - If status is **Dropping** or **Rapid Drop**: confirm the description line appears in `var(--dim)` below the status label.
3. To test all states without waiting for real weather, temporarily override `currentWeather.trend` in the browser console and call `renderWeather()`.
   - Set `trend = -2` → should show "Dropping" + description.
   - Set `trend = -4` → should show "Rapid Drop ⚠" + description.
   - Set `trend = 0, pressure = 975` → should show "Very Low" + description.
4. Confirm the description text does not overflow or wrap awkwardly on a 375px screen.

---

# 5. Episode Form — Cane Use Moved + Episode End Time

## Problem

**Cane use** is currently in the Episode Pattern step alongside limbs affected and chest tightness — all of which describe what is happening *during* the episode. Cane use is a post-episode question and doesn't belong there. It also can't be answered accurately mid-episode.

**Episode end time** is not captured at all. Episodes last 30 minutes to 4 hours and duration is clinically significant data — for neurologist reporting, longitudinal pattern analysis, and correlating severity with triggers. The app already captures prodrome start and first jerk time; end time completes the picture.

A multi-step form is not the right mechanism for logging end time. By the time the episode ends, she is post-ictal, possibly needing the cane, not in a state to navigate a form. The end time needs to be capturable with minimal interaction from the home screen.

## Approach

### Part A — Remove cane from Episode Pattern

Remove "Need cane after" from `case 2` of the episode form.

### Part B — Active episode card on home screen

When an episode has been logged with no `episodeEndTime` and the first jerk time was less than **4 hours ago** (the documented maximum episode length), display a persistent **"Episode in progress"** card at the top of the home screen, above the action grid.

The card shows:
- A running timer: time elapsed since first jerk
- A single **"Mark ended"** button

Tapping "Mark ended" opens a minimal inline form (not a new view):
- **Episode ended at:** time input, pre-filled to now, adjustable
- **Need cane?** — Yes / No toggle (relocated from episode form)

Saving writes `episodeEndTime` (ISO string) and `cane` (bool) back to the most recent open episode entry.

After 4 hours with no end time marked, the card disappears and the episode is recorded with unknown duration. No error state, no data loss — duration simply remains uncalculated for that entry.

If a new episode is logged while one is still "open," the previous episode closes without an end time. No silent data loss — the entry remains intact, just without `episodeEndTime`.

## Clinical value

- **Episode duration** = `episodeEndTime` − `firstJerkTime` — reportable to neurologist
- **Prodrome duration** = `firstJerkTime` − `prodromeTime` — already calculable, now paired with duration
- **Longitudinal trends** — are episodes getting shorter or longer over time?
- **Trigger correlation** — do compound pressure + fasting events produce longer episodes?
- **Cane use anchored in time** — post-episode weakness duration becomes calculable if she also notes when she stopped needing it (future feature)

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Remove cane toggle from episode form case 2

**Location:** `renderEpStep()`, `case 2`, line ~941

Remove the `toggleBtn('cane', ...)` call. Keep `toggleBtn('chestTight', ...)`.

### Step 2 — Add `episodeEndTime` and `cane` fields to `epData` initial state

**Location:** `startEpisode()`, line ~846

Add `episodeEndTime: null, cane: false` to the `epData` initializer (cane stays in data shape for the close-episode flow).

### Step 3 — Add `getOpenEpisode()` helper

Returns the most recent episode entry if it has no `episodeEndTime` and its `firstJerkTime` was less than 4 hours ago. Returns `null` otherwise.

```js
function getOpenEpisode() {
  const entries = DB.allEntries();
  const eps = entries.filter(e => e.type === 'episode' && !e.episodeEndTime);
  if (!eps.length) return null;
  const latest = eps[0]; // already sorted newest first
  // Use entryDate (local date from date input) + firstJerkTime (local HH:MM) to avoid
  // UTC date slicing bug: timestamp.slice(0,10) gives UTC date, which differs from local
  // date for episodes logged between midnight and UTC offset hour (e.g. before 5am CDT).
  const ref = latest.firstJerkTime && latest.entryDate
    ? new Date(latest.entryDate + 'T' + latest.firstJerkTime)
    : new Date(latest.timestamp);
  const hoursElapsed = (Date.now() - ref) / 3600000;
  return hoursElapsed < 4 ? latest : null;
}
```

### Step 4 — Add active episode card to home screen render

**Location:** `renderEpisodeCard()` — new function, called in three places:
1. Inside `goHome()` — so the card appears immediately when returning home after saving
2. Inside `initApp()` — so the card appears immediately on app open/unlock
3. Inside the `setInterval` alongside `renderMealCard` — so the elapsed timer stays fresh every minute

This mirrors the exact pattern used by `renderMealCard()`, which is already called in both `goHome()` (via `updateStats()` → but note: `renderMealCard` is called directly in `initApp` and via interval, not in `goHome` — so `goHome` must explicitly call `renderEpisodeCard()` too).

The card is injected into a dedicated `<div id="episode-card"></div>` above the action grid. When no open episode exists, render nothing into it.

Card content:
- Title: "Episode in progress"
- Subtitle: elapsed time since first jerk (e.g. "1h 23m")
- Button: "Mark ended"

### Step 5 — Implement "Mark ended" inline form

On button tap, replace the card content with the two-field form (end time + cane toggle). On save:
1. Write `episodeEndTime` and `cane` to the existing entry key.
2. Remove the active episode card.
3. Show toast: "Episode closed ✓"

### Step 6 — Update stats / export to use duration

Where episode entries are rendered in the log and report, calculate and display duration when both `firstJerkTime` and `episodeEndTime` are present:

```js
// Duration in minutes
// Use entry.entryDate (local date) not entry.timestamp.slice(0,10) (UTC date) to avoid
// timezone mismatch when episodes are logged late at night.
const duration = episodeEndTime && firstJerkTime && entry.entryDate
  ? Math.round((new Date(episodeEndTime) - new Date(entry.entryDate + 'T' + firstJerkTime)) / 60000)
  : null;
```

Show in log entry card and plain-text export.

## Testing Steps

1. Log an episode. Confirm the active episode card appears on the home screen with a running timer.
2. Confirm "Need cane after" no longer appears in the Episode Pattern step.
3. Tap **Mark ended**. Confirm the inline form appears with end time pre-filled to now.
4. Adjust the end time and tap save. Confirm the card disappears and a toast appears.
5. Open **View Log** and confirm the episode entry shows a duration calculated from first jerk time to end time.
6. Confirm the plain-text export includes episode duration.
7. Log an episode and wait (or simulate) past 4 hours without marking ended. Confirm the active episode card disappears and the entry shows no duration (not an error).
8. Log a second episode while one is open. Confirm the first episode closes without end time and the new episode's card replaces it.

---

# 6. Triggers Step — Framing + Auto-populate Fasting Hours

## Problems

**Framing:** The step is titled "Triggers" and presents a multi-select list as if the patient is confirming known causes. During or after an episode she cannot know what caused it — she can only report what conditions were present. The current framing implies certainty she doesn't have and may cause her to skip the step if she feels she "doesn't know." The question being asked should be: *was this present today?* not *did this cause it?*

**Fasting hours:** The step includes a manual "Hours since last meal" number input. The app already tracks meal timing via `meal:last` in storage. Requiring her to calculate and type this number when she is post-ictal, possibly on the cane, is unnecessary friction. The app should calculate it automatically.

## Approach

### Framing change

- Rename step title from "Triggers" to "What was going on today?"
- Change step subtitle from empty to "Select anything that was present"
- Rename the "Hours since last meal" field label to "Hours fasted at episode onset"
- The trigger options themselves do not change — they are still the right conditions to ask about

### Auto-populate fasting hours

At render time, read `meal:last` from storage and calculate elapsed hours. Display one of three states:

1. **Meal logged** — show calculated value as read-only text with a small override link: "3.5h (from your last logged meal) — tap to edit"
2. **No meal logged** — show the manual input with a note: "No meal logged today — enter manually"
3. **Override active** — show the manual input with a small "use calculated" link to revert

The calculated value is written to `epData.fastedHours` automatically so it saves without any interaction if she doesn't override.

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Update step title and subtitle

**Location:** `EP_STEPS` array, line ~834

```js
// Before
{ title: 'Triggers', sub: '' }

// After
{ title: 'What was going on today?', sub: 'Select anything that was present' }
```

### Step 2 — Auto-calculate fasting hours in `renderEpStep()` case 4

**Location:** `renderEpStep()`, `case 4`, lines ~961–982

At the top of the case, calculate fasting hours from `meal:last`:

```js
const lastMeal = DB.get('meal:last');
const autoFasted = lastMeal
  ? Math.round((Date.now() - new Date(lastMeal.timestamp)) / 360000) / 10 // one decimal
  : null;
// Pre-populate epData.fastedHours if not yet set and auto value available
if (autoFasted !== null && epData.fastedHours === '') {
  epData.fastedHours = String(autoFasted);
}
```

### Step 3 — Render fasting field with calculated display

Replace the plain number input with conditional display:

- If `autoFasted` is available and the user has not manually overridden: show `"Xh — from your last logged meal"` in `var(--dim)` with a small "Edit" button that switches to the manual input.
- If no meal logged or override active: show the number input as before.

### Step 4 — Update "Hours since last meal" label

```js
// Before
'Hours since last meal'

// After
'Hours fasted at episode onset'
```

## Testing Steps

1. Log a meal on the home screen, then open **Log Episode** and navigate to the "What was going on today?" step.
2. Confirm the step title and subtitle show the new copy.
3. Confirm the fasting field shows the auto-calculated value with "from your last logged meal" note — no manual input visible.
4. Tap **Edit** on the fasting field. Confirm it switches to a manual number input.
5. Save the episode. Confirm `fastedHours` in the saved entry matches the auto-calculated value.
6. Clear meal data (or open without logging a meal) and repeat. Confirm the manual input appears with the "No meal logged today" note.
7. Confirm the trigger options themselves are unchanged.

---

# 7. Sensations — Add "Energy That Needs to Be Released"

## Problem

The sensations step offers: Tight, Aching, Burning, Pressure, Stabbing, Numb, Cramping, Squeezing. "Energy that needs to be released" is a distinct sensory experience — a kinetic, restless pressure that demands movement — that does not map to any of these. It appears in the prodrome as a location-specific observation ("energy in right leg") but the qualitative sensation itself is not available as a descriptor in the sensations step, where it can be attached to any body region.

## Approach

Add `Energy / restless` as an option in the `sensOpts` array. Short label for tap target; the meaning is unambiguous to this patient.

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Add to `sensOpts` array

**Location:** `renderEpStep()`, `case 6`, line ~981

```js
// Before
const sensOpts = ['Tight','Aching','Burning','Pressure','Stabbing','Numb','Cramping','Squeezing'];

// After
const sensOpts = ['Tight','Aching','Burning','Pressure','Stabbing','Numb','Cramping','Squeezing','Energy / restless'];
```

## Testing Steps

1. Log an episode, select at least one pain location, and navigate to the Sensations step.
2. Confirm "Energy / restless" appears as a selectable option alongside the existing descriptors.
3. Select it for a region, save the episode, and confirm it appears in the plain-text export under that region.

---

# 8. Severity — Two Separate Scales for Two Different Questions

## Problem

The episode form and check-in form both currently end with the same "Overall Severity — Compared to Arizona" step. These are asking different questions and should use different scales:

- **Check-in** = how am I doing *today overall* compared to my best known state → Arizona comparison is the right frame
- **Episode** = how bad was *this specific event* → Arizona comparison is the wrong frame. During an episode the relevant question is functional consequence, not baseline comparison. Communication level, limbs affected, body pain, and duration already capture jerk-level detail. What's missing is: what did this episode cost functionally?

The Arizona step in the episode form also contradicts design principle #3 (communication capacity is the primary severity indicator — already captured in step 3) by adding a redundant overall severity judgment that requires interoceptive translation the patient cannot reliably perform during or immediately after an episode.

## Part A — Replace episode severity step with functional impact scale

Remove the Arizona comparison from the episode form entirely. Replace `case 7` with a post-episode functional impact question using observable, not subjective, anchors.

### New Episode Severity Step

**Step title:** "After the episode"  
**Step subtitle:** "What did it cost you?"

| Value | Label | Color |
|---|---|---|
| `active` | Stayed active — managed through it | `var(--good)` |
| `reduced` | Reduced — had to rest or sit | `var(--warn)` |
| `down` | Down — needed to lie down | `#f97316` |
| `extended` | Extended — still impaired hours later | `var(--danger)` |

**Location:** `EP_STEPS` array — update title/subtitle for step 7. `renderEpStep()` `case 7` — replace severity buttons with new impact buttons.

**Data key:** rename from `severity` to `episodeImpact` in `epData` initializer and save. Update log view and export to use `episodeImpact`.

### Impact labels for export

```js
const impactLabels = {
  active: 'Managed through it',
  reduced: 'Had to rest or sit',
  down: 'Needed to lie down',
  extended: 'Still impaired hours later',
};
```

## Part B — Clarify Arizona baseline in check-in only

The check-in severity step is the correct home for the Arizona comparison. Add a brief contextual line at the top and tighten the labels.

### New Check-in Step Header

Add above the severity buttons:

> "Arizona (spring 2026) = 4 weeks of complete symptom relief — your best known baseline."

Styled in `var(--dim)` at small font size.

### Revised Check-in Option Labels

| Value | Before | After |
|---|---|---|
| `similar` | Similar — feeling good | Comparable to Arizona — mostly symptom-free |
| `somewhat` | Somewhat worse than baseline | Somewhat worse than Arizona |
| `much_worse` | Much worse | Much worse than Arizona |
| `far_away` | Arizona feels very far away | Very far from Arizona — significant symptoms |

Colors unchanged.

## Part C — Muscle event severity scale

Individual jerks are shorter events without the same functional arc as full episodes. Use a single combined scale anchored to size and disruption:

| Value | Label |
|---|---|
| `minor` | Minor — small jerk, no interruption |
| `noticeable` | Noticeable — visible movement, brief pause |
| `significant` | Significant — threw balance or stopped activity |

Stored as `severity` on muscle event entries.

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Update episode form step 7 title and content

**Location:** `EP_STEPS` array, step index 7

```js
// Before
{ title: 'Overall Severity', sub: 'Compared to Arizona' }

// After
{ title: 'After the episode', sub: 'What did it cost you?' }
```

**Location:** `renderEpStep()`, `case 7`

Replace Arizona severity buttons with functional impact buttons. Use the same `sevBtn()` helper with new values/labels/colors.

### Step 2 — Update `epData` initializer

**Location:** `startEpisode()`, line ~846

```js
// Before
severity: null,

// After
episodeImpact: null,
```

### Step 3 — Update log view for episode impact

**Location:** `renderLog()`, `sevColors` object

Add `episodeImpact` color mapping alongside the existing `sevColors` (which will remain for check-in entries):

```js
const impactColors = { active: 'var(--good)', reduced: 'var(--warn)', down: '#f97316', extended: 'var(--danger)' };
```

Use `e.episodeImpact` for episode entries, `e.severity` for check-in entries when determining border color and chip display.

### Step 4 — Add context line to check-in severity step

**Location:** `renderCiStep()`, `case 4`, lines ~1153–1164

Prepend the Arizona context line above the `sev-options` div.

### Step 5 — Update check-in option labels

**Location:** `renderCiStep()`, `case 4`, severity options array

Replace labels as per the table in Part B.

### Step 6 — Update plain-text export

**Location:** `generateReport()`

For episode entries: use `episodeImpact` with `impactLabels` map.  
For check-in entries: update `sevLabels` to Arizona-referenced copy.

```js
const impactLabels = { active: 'Managed through it', reduced: 'Had to rest or sit', down: 'Needed to lie down', extended: 'Still impaired hours later' };
const sevLabels = { similar: 'Comparable to Arizona', somewhat: 'Somewhat worse than Arizona', much_worse: 'Much worse than Arizona', far_away: 'Very far from Arizona' };
```

## Testing Steps

1. Open **Log Episode** and navigate to step 8 ("After the episode").
2. Confirm the four functional impact buttons appear with correct labels and colors.
3. Confirm no Arizona context line or Arizona-referencing labels appear in the episode form.
4. Select an impact level, save, and confirm it appears correctly in the log view.
5. Confirm the export uses impact labels (not Arizona labels) for episode entries.
6. Open **Daily Check-in** and navigate to the severity step.
7. Confirm the Arizona context line appears above the buttons.
8. Confirm the four revised labels reference Arizona explicitly.
9. Save and confirm the export uses the updated Arizona labels for check-in entries.
10. Confirm old episode entries with `severity` field (not `episodeImpact`) display without crashing — they will show no severity chip, which is acceptable.

---

# 9. Header — Remove Name, Simplify Pressure Summary

## Problem

**Top-left name:** The header shows "Isobar" as a subtitle and "Cotopaxi" as a large title. This is a personal single-user app — displaying the patient name adds no value and is unnecessary.

**Top-right pressure block:** Currently shows the absolute pressure value (e.g. `1013.2 hPa`) and a verbose status label (e.g. `↓ Falling`). The absolute value and label duplicate what is already shown prominently in the weather tile directly below. The header slot exists for **ambient risk signal at a glance** — and for that purpose, rate of change is far more meaningful than absolute value.

## Approach

### Part A — Remove patient name from header

Remove the `page-title` div ("Cotopaxi"). Keep only the `page-subtitle` div ("Isobar") as the sole left-side header element.

### Part B — Replace pressure summary with trend-only display

Replace the current `#pressure-summary` content with two compact lines:
1. 6hr pressure trend — e.g. `↓ −2.5 hPa` — color-coded by severity
2. 6hr temperature trend — e.g. `↑ +8°F` — colored orange if |trend| ≥ 10°F, dim otherwise

No absolute values. No verbose labels. The color and arrow communicate status; the number communicates magnitude.

## Color rules (unchanged from existing thresholds)

| Pressure trend | Color |
|---|---|
| < −3 hPa | `var(--danger)` |
| < −1.5 hPa | `var(--warn)` |
| ≥ −1.5 hPa | `var(--good)` |

| Temp trend | Color |
|---|---|
| |trend| ≥ 10°F | `var(--warn)` |
| Otherwise | `var(--dim)` |

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Remove "Cotopaxi" from the header

**Location:** `index.html`, lines ~388–391

```html
<!-- Before -->
<div>
  <div class="page-subtitle">Isobar</div>
  <div class="page-title">Cotopaxi</div>
</div>

<!-- After -->
<div class="page-subtitle">Isobar</div>
```

### Step 2 — Update `renderWeather()` to write trend-only content to `#pressure-summary`

**Location:** `renderWeather()`, lines ~736–738

```js
// Before
document.getElementById('pressure-summary').innerHTML =
  `<div class="mono" style="font-size:18px;font-weight:600;color:${st.color}">${w.pressure} hPa</div>
   <div style="font-size:11px;color:${st.color}">${st.icon} ${st.label}</div>`;

// After
const pColor = w.trend < -3 ? 'var(--danger)' : w.trend < -1.5 ? 'var(--warn)' : 'var(--good)';
const pArrow = w.trend < 0 ? '↓' : w.trend > 0 ? '↑' : '—';
const tColor = Math.abs(w.tempTrend || 0) >= 10 ? 'var(--warn)' : 'var(--dim)';
const tArrow = (w.tempTrend || 0) > 0 ? '↑' : (w.tempTrend || 0) < 0 ? '↓' : '—';
document.getElementById('pressure-summary').innerHTML =
  `<div class="mono" style="font-size:13px;color:${pColor}">${pArrow} ${w.trend > 0 ? '+' : ''}${w.trend} hPa</div>
   <div class="mono" style="font-size:13px;color:${tColor}">${tArrow} ${(w.tempTrend || 0) > 0 ? '+' : ''}${w.tempTrend || 0}°F</div>`;
```

## Testing Steps

1. Open the app home screen.
2. Confirm the top-left shows only "ISOBAR" (the subtitle) — no large name below it.
3. With weather loaded, confirm the top-right shows two compact monospace lines: pressure trend and temp trend.
4. Confirm no absolute pressure value appears in the top-right.
5. In the browser console, set `currentWeather.trend = -4` and call `renderWeather()` — confirm the pressure trend line renders in red.
6. Set `currentWeather.trend = -2` — confirm orange.
7. Set `currentWeather.tempTrend = 12` — confirm temp trend line renders in orange.
8. Confirm the weather tile below is unaffected and still shows full detail.

---

# 10. Muscle Event Quick Log

## Problem

Individual muscle jerks and spasms occur between full episodes and are clinically significant for neurologist reporting. Currently there is no way to log these — they either go unrecorded or get bundled into episode notes. Frequency, distribution, and intensity of inter-episode muscle events is useful longitudinal data.

A full 9-step episode form is inappropriate for a single jerk that may last seconds. This needs to be a fast single-screen log.

## Approach

A new home screen action card opens a single-screen form. Tap, fill in 3–4 fields, save. No steps, no progress bar.

## Data Structure

```json
{
  "type": "muscle_event",
  "timestamp": "ISO string",
  "entryDate": "YYYY-MM-DD",
  "bodyLocations": ["right_leg", "left_arm"],
  "severity": "noticeable",
  "notes": "",
  "weather": { "pressure": 1008.2, "trend": -1.8, "currentTemp": 52, "tempTrend": 4 }
}
```

No `triggers` field — muscle events are always spontaneous for this patient. No `type` field — type classification was considered and dropped for the same reason.

## Severity Scale

| Value | Label |
|---|---|
| `minor` | Minor — small jerk, no interruption |
| `noticeable` | Noticeable — visible movement, brief pause |
| `significant` | Significant — threw balance or stopped activity |

## Home Screen Card

Full-width card below the 2-column Episode / Check-in grid. Amber accent to distinguish it from the primary actions.

```
[ Log Episode  |  Daily Check-in ]
[ + Muscle Event                 ]   ← full width, amber
```

## Files to Change

Only one file: `index.html`

## Implementation Steps

### Step 1 — Add home screen card HTML

**Location:** `index.html`, after the `.action-grid` div (~line 421)

Add a dedicated `<div id="episode-card"></div>` above the action grid for the active episode card (Update 5), and a static muscle event card below:

```html
<div id="episode-card"></div>
<div class="action-grid"> ... </div>
<div class="action-card muscle-card" onclick="startMuscleEvent()">
  <span class="icon">⚡</span>
  <div class="title" style="color:var(--warn)">+ Muscle Event</div>
  <div class="sub">Quick log a jerk or spasm</div>
</div>
```

Add `.muscle-card` CSS:

```css
.muscle-card {
  background: rgba(245,158,11,0.08);
  border-color: rgba(245,158,11,0.3);
  padding: 14px;
  margin-bottom: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
}
.muscle-card .icon { font-size: 20px; margin-bottom: 0; }
.muscle-card .title { font-size: 14px; }
```

### Step 2 — Add view-muscle HTML

**Location:** `index.html`, after `view-checkin` div

Parallel structure to episode/checkin views. Single-screen — no step progress bar.

```html
<div id="view-muscle" class="view">
  <div style="padding:0 16px">
    <div class="step-header">
      <button class="back-btn" onclick="goHome()">←</button>
      <div>
        <div class="step-title">Muscle Event</div>
        <div class="step-sub">Quick log</div>
      </div>
    </div>
    <div id="muscle-content"></div>
  </div>
</div>
```

### Step 3 — Implement `startMuscleEvent()` and `renderMuscleForm()`

```js
let meData = {};

function startMuscleEvent() {
  const now = new Date();
  meData = {
    type: 'muscle_event',
    timestamp: now.toISOString(),
    entryDate: now.toISOString().slice(0,10),
    bodyLocations: [],
    severity: null,
    notes: '',
    weather: currentWeather || null,
  };
  switchView('muscle');
  renderMuscleForm();
}

function renderMuscleForm() {
  window._bodyToggle = id => {
    const arr = meData.bodyLocations || [];
    const i = arr.indexOf(id);
    if (i > -1) arr.splice(i,1); else arr.push(id);
    meData.bodyLocations = arr;
    renderMuscleForm();
  };

  const sevOpts = [
    { value: 'minor',      label: 'Minor — small jerk, no interruption',        color: 'var(--good)' },
    { value: 'noticeable', label: 'Noticeable — visible movement, brief pause',  color: 'var(--warn)' },
    { value: 'significant',label: 'Significant — threw balance or stopped activity', color: 'var(--danger)' },
  ];

  document.getElementById('muscle-content').innerHTML = `
    <div class="section">
      <span class="label">Body location</span>
      ${bodyMap(meData.bodyLocations, 'var(--warn)')}
    </div>
    <div class="section">
      <span class="label">Severity</span>
      <div class="comm-options">
        ${sevOpts.map(o => {
          const sel = meData.severity === o.value;
          return `<button class="comm-btn" style="${sel ? `background:${o.color}20;color:${o.color};border-color:${o.color};font-weight:600` : ''}"
            onclick="meData.severity='${o.value}';renderMuscleForm()">${o.label}</button>`;
        }).join('')}
      </div>
    </div>
    <div class="section">
      <span class="label">Notes</span>
      <textarea placeholder="Anything to note…" rows="3" oninput="meData.notes=this.value">${meData.notes}</textarea>
    </div>
    <button class="btn full" onclick="saveMuscleEvent()" style="margin-top:8px">Save</button>
  `;
}

function saveMuscleEvent() {
  const key = `entry:${new Date(meData.timestamp).getTime()}`;
  if (DB.get(key)) { showToast('Already saved'); goHome(); return; }
  DB.set(key, meData);
  showToast('Muscle event saved ✓');
  goHome();
  updateStats();
}
```

### Step 4 — Update `renderLog()` to handle muscle_event type

**Location:** `renderLog()`, line ~1233

Add explicit handling so muscle events display correctly instead of falling through to the "Check-in" label.

```js
const isEp = e.type === 'episode';
const isMe = e.type === 'muscle_event';

const borderColor = isEp
  ? (sevColors[e.episodeImpact] || 'var(--danger)')
  : isMe
    ? 'var(--warn)'
    : (sevColors[e.severity] || 'var(--accent)');

const typeLabel = isEp ? 'Episode' : isMe ? 'Muscle Event' : 'Check-in';
const typeColor = isEp ? 'var(--danger)' : isMe ? 'var(--warn)' : 'var(--accent)';

const chips = isMe
  ? [
      e.severity ? `<span class="entry-chip" style="color:var(--warn)">${e.severity}</span>` : '',
      ...(e.bodyLocations || []).map(p => `<span class="entry-chip">${p.replace(/_/g,' ')}</span>`),
      e.weather?.pressure ? `<span class="entry-chip mono">${e.weather.pressure}hPa (${e.weather.trend>0?'+':''}${e.weather.trend})</span>` : '',
    ].filter(Boolean).join('')
  : [ /* existing chips logic for episode/checkin */ ];
```

### Step 5 — Add MUSCLE EVENTS section to `exportReport()`

**Location:** `exportReport()`, after the DAILY CHECK-INS section

```js
const mes = entries.filter(e => e.type === 'muscle_event');

if (mes.length) {
  r += `\nMUSCLE EVENTS\n${'─'.repeat(30)}\n`;
  mes.forEach(e => {
    const d = new Date(e.timestamp);
    r += `\n${d.toLocaleDateString()} ${d.toLocaleTimeString([],{hour:'2-digit',minute:'2-digit'})}\n`;
    if (e.severity) r += `  Severity: ${e.severity}\n`;
    if (e.bodyLocations?.length) r += `  Location: ${e.bodyLocations.join(', ')}\n`;
    if (e.weather?.pressure) r += `  Pressure: ${e.weather.pressure} hPa (trend: ${e.weather.trend>0?'+':''}${e.weather.trend})\n`;
    if (e.notes) r += `  Notes: ${e.notes}\n`;
  });
}
```

Also update the SUMMARY line to include muscle event count:

```js
r += `SUMMARY\nEpisodes: ${eps.length}  |  Check-ins: ${cis.length}  |  Muscle events: ${mes.length}  |  Days tracked: ...\n`;
```

## Testing Steps

1. Tap **+ Muscle Event** on the home screen. Confirm the single-screen form opens.
2. Tap body locations — confirm they highlight in amber (not blue).
3. Select a severity option — confirm it highlights correctly.
4. Save. Confirm toast appears and app returns to home screen.
5. Open **View Log**. Confirm the entry shows "Muscle Event" label in amber with correct chips.
6. Confirm episode and check-in entries are unaffected in the log view.
7. Export. Confirm a MUSCLE EVENTS section appears with correct data.
8. Confirm the SUMMARY line includes the muscle event count.
9. Log a muscle event with no body location and no severity — confirm it saves without crashing (no required fields).

---

# Shipped

## ✅ UPDATE-1: Communication Scale Revision — shipped 2026-04-14

UAT: 11/11 PASS (see `TESTING_UPDATE_1_shipped.md`). Four-value scale `normal / quieter / shortened / brief` now live across episode form, check-in form, log view, home recent-episodes, and export. Legacy values (`effortful / minimal / nonverbal`) fall through to gray `var(--mid)` in both surfaces; export prints raw key for legacy entries. No data migration performed (by design).

### Problem
The original comm scale was bottom-heavy (two of four options described states the patient rarely reached) and deficit-framed ("mostly yes/no answers"). There was also an unnamed gap between `effortful` and `yes/no only`.

### New Scale
| Value | Display label | Color |
|---|---|---|
| `normal` | Talking easily — normal back and forth | `var(--good)` |
| `quieter` | Quieter than usual — responding, not initiating | `var(--warn)` |
| `shortened` | Shorter responses — harder to elaborate | `#f97316` |
| `brief` | Brief only — yes/no or less | `var(--danger)` |

Previous `minimal` and `nonverbal` collapsed into `brief`; `quieter` fills the gap between `normal` and `shortened`.

### Sites touched in `index.html`
- `renderCiStep()` case 0 — check-in form labels/values/colors
- `renderEpStep()` case 3 — episode form labels/values/colors
- `renderLog()` — `commColors` map
- `updateStats()` — `commColors` map (home recent episodes)
- `generateReport()` — `commLabels` prose map for export

### Out of Scope (held)
- No data-structure migration
- No retroactive rewrite of historical entries
- No changes to PIN, weather, meal, or episode logic
