---
id: TEST-ISO-50
ticket: ISO-50
status: pending
last-run: ""
---

# TEST-ISO-50: Episode Prodrome + Limbs chip ordering — mirror convention

## What changed

Two Episode-form chip-option arrays were reordered so laterality-tagged pairs list L before R — matching the mirror convention established for the body-map in ISO-29. Stored `value` keys are unchanged; only the on-screen order of option objects flipped.

### Arrays changed

- **Prodrome** (`index.html:1158–1168`, `prodOpts`) — `left_leg_energy` now precedes `right_leg_energy`; `left_face` precedes `right_face`.
- **Episode Pattern → Limbs affected** (`index.html:1173–1180`, `limbOpts`) — `left_leg` precedes `right_leg`; `left_arm` precedes `right_arm`. `bilateral_legs` ("Both legs") stays between the legs and the arms pair. `sleep_continue` ("Continues in sleep") stays last.

### Unchanged

- Value keys: `left_leg_energy`, `right_leg_energy`, `left_face`, `right_face`, `left_leg`, `right_leg`, `bilateral_legs`, `left_arm`, `right_arm`, `sleep_continue` — all preserved exactly.
- Non-lateral options (Crushing fatigue, Blurry vision, Throat tightening, etc.) keep their positions.
- No rendering, CSS, or grid changes.

## Files changed

- `index.html` — `prodOpts` at lines 1158–1168; `limbOpts` at lines 1173–1180.

## What to test

### 1. Episode Prodrome — chip order

1. `http://localhost:8765` → unlock.
2. **Log Episode** → **Next** to Step 2 (Prodrome).
3. Confirm chips appear in this order: Crushing fatigue, Feeling 'high' / altered, Blurry vision, Lower back pressure, **Energy in left leg**, **Energy in right leg**, **Left face tingling**, **Right face tingling**, Throat tightening.
4. Confirm `Energy in left leg` is visually before `Energy in right leg`.
5. Confirm `Left face tingling` is visually before `Right face tingling`.

### 2. Episode Prodrome — value mapping

1. Tap `Energy in left leg`. Open devtools.
2. Inspect the button's onclick — it should toggle `left_leg_energy`.
3. Tap `Right face tingling` — should toggle `right_face`.
4. Save the episode. Confirm the saved `prodrome` array contains the expected keys (`left_leg_energy`, `right_face`, etc.).

### 3. Episode Pattern — Limbs affected order

1. From Step 2, advance to Step 3 (Episode Pattern).
2. Under "Limbs affected", confirm order: **Left leg**, **Right leg**, Both legs, **Left arm**, **Right arm**, Continues in sleep.
3. Confirm `Left leg` is before `Right leg` and `Left arm` is before `Right arm`.

### 4. Episode Pattern — value mapping

1. Tap `Left leg`. The button's onclick should toggle `left_leg`.
2. Tap `Right arm`. Should toggle `right_arm`.
3. Tap `Both legs`. Should toggle `bilateral_legs`.
4. Save and confirm the saved `limbsAffected` array contains the expected keys.

### 5. Backward compatibility — existing episodes

1. If you have prior episodes saved with `right_leg`, `left_leg`, `right_arm`, `left_arm`, `right_leg_energy`, etc., open **View Log**.
2. Confirm those entries render correctly — the labels in the log view should still match the stored keys.
3. Export the report and confirm old entries render with the expected chip labels.

### 6. Visual regression

1. At 375×812, confirm the chip-cloud layout for both screens still wraps and spaces correctly.
2. No chips should overflow, truncate, or wrap unexpectedly.
