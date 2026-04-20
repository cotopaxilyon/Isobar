---
id: TEST-ISO-29
ticket: ISO-29
status: pending
last-run: ""
---

# TEST-ISO-29: Body-Map L/R Mirror Layout

## What changed

The body-map button pairs in `bodyMap()` (`index.html`) now render in mirror convention: L-labeled buttons sit in the left visual column, R-labeled buttons in the right. This matches what the patient sees when looking down at her own body. Stored values remain anatomically correct — `L. Jaw` still stores `left_jaw`, `R. Arm` still stores `right_arm`; only the visual column order flipped.

### Key behaviors

- **Visual order:** `L. *` in left column, `R. *` in right column across all four body regions (Head & Neck, Torso, Arms, Lower Body).
- **Data integrity:** Storage keys unchanged — `left_jaw`, `right_jaw`, `left_ribs`, `right_ribs`, `left_arm`, `right_arm`, `left_hip`, `right_hip`, `left_leg`, `right_leg`, `left_foot`, `right_foot`.
- **Subtitles unchanged:** Step subtitles ("Tap anywhere that hurts right now" for Check-in, "Tap all areas that hurt" for Episode) are NOT modified.
- **No grid restructure:** No CSS or layout changes; only pair order in the `sections` data.

## Files changed

- `index.html` — `bodyMap()` `sections` array at lines 1033–1052.

## What to test

### 1. Morning Check-in — body-map layout

1. From Home, tap **Morning Check-in**.
2. Advance to the **Pain Location** step.
3. Confirm chip layout in each region:
   - Head & Neck: `L. Jaw` (left column), `R. Jaw` (right column).
   - Torso: `L. Ribs` (left), `R. Ribs` (right).
   - Arms: `L. Arm` (left), `R. Arm` (right).
   - Lower Body: `L. Hip` / `R. Hip`, `L. Leg` / `R. Leg`, `L. Foot` / `R. Foot` — all `L` in left column.

### 2. Morning Check-in — data integrity

1. On the Pain Location step, tap `L. Jaw`.
2. Open devtools console.
3. Inspect the active button's onclick: it should call `window._bodyToggle('left_jaw')`.
4. Save the check-in and open **View Log**.
5. Confirm the new entry shows `L. Jaw` selected (not `R. Jaw`).

### 3. Episode form — body-map layout

1. From Home, tap **Log Episode**.
2. Advance to the **Pain Location** step (Step 6).
3. Confirm the same mirror layout as in Check-in (L in left column throughout).

### 4. Episode form — data integrity

1. Tap `R. Arm`.
2. Confirm the button's onclick calls `window._bodyToggle('right_arm')`.
3. Save the episode and confirm in the log view that `R. Arm` is the selection.

### 5. Export backward compatibility

1. If any pre-existing episodes or check-ins have body-pain data, export the report.
2. Confirm the export renders pain locations correctly — old entries with `right_jaw`/`left_jaw` keys still display as `R. Jaw`/`L. Jaw`.
3. No entries should show "undefined" or missing regions.

### 6. Visual regression

1. At viewport 375×812 (iPhone SE), confirm the 2-column body-map grid layout is unchanged — only the order of chips within each row differs.
2. Confirm no chip overflow, truncation, or wrapping regressions.
