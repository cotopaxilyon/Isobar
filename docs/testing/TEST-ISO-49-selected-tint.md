---
id: TEST-ISO-49
ticket: ISO-49
status: pending
last-run: ""
---

# TEST-ISO-49: Selected-button tint restored for CSS-variable colors

## What changed

The `.comm-btn` / `.sev-btn` / `.body-btn` selected-state style previously concatenated a two-char hex-alpha onto the button color (`background:${color}20`). That only produced a valid color when `color` was a hex literal like `#f97316` (yields `#f9731620` — 8-digit hex). When `color` was a CSS variable like `var(--good)`, the browser saw `var(--good)20` which isn't a valid color, so the background dropped to transparent.

The fix replaces every `${color}20` site with `color-mix(in srgb, ${color} 12%, transparent)`. `color-mix` accepts both hex literals and `var(--*)`, so all selected positions now render the 12% translucent tint. The alpha value was chosen to match the old `0x20` (32/255 ≈ 12.5%) as closely as possible without micro-tuning.

### Sites fixed

All seven `${color}20` / `var(--good)20` occurrences in `index.html`:

1. **`commBtn()` helper** (`:1018`) — used by Episode form Communication step.
2. **`sevBtn()` helper** (`:1024`) — used by Episode severity step.
3. **`bodyMap()` selected-state** (`:1063`) — used by both Check-in and Episode body-map pain step.
4. **Check-in `communicationLevel` block** (`:1486`) — 4-button tolerance row in the Communication step.
5. **Check-in `irritabilityLevel` block** (`:1503`) — 4-button fuse/sensory row in the Communication step (from ISO-47).
6. **Check-in `functionalToday` block** (`:1531`) — 4-button sev-btn row on the final step.
7. **Meal-size picker** (`:2091–2092`) — hardcoded `var(--good)20` replaced in both the initial render and the inline onclick restyle.

### Unchanged

- Text color and border-color behavior for selected buttons (those never used the `20` suffix).
- Unselected-button appearance.
- Any hex-literal color that previously worked (e.g., `#f97316`) continues to render the tint.

## Files changed

- `index.html` — seven selected-state style sites listed above.

## What to test

### 1. Morning Check-in — Communication row (var(--good)/var(--warn)/#f97316/var(--danger))

1. Unlock and open **Morning Check-in**.
2. Advance to the Communication step (Step 3).
3. Tap each of the four "How Are You Communicating?" buttons in turn:
   - `Talking easily` (green tint — var(--good))
   - `Quieter than usual` (amber tint — var(--warn))
   - `Shorter responses` (orange tint — #f97316)
   - `Brief only` (red tint — var(--danger))
4. **Each** selected button must show a translucent tint matching its text/border color. Previously, only `Shorter responses` did.

### 2. Morning Check-in — Irritability row (var(--good)/var(--accent)/#f97316/var(--danger))

1. On the same step, scroll to "Right now — fuse / sensory tolerance".
2. Tap each of the four buttons in turn:
   - `Normal` (green tint — var(--good))
   - `Edgy` (sky-blue tint — var(--accent))
   - `Sensory overload` (orange tint — #f97316)
   - `Snap-line` (red tint — var(--danger))
3. **Each** selected button must show a translucent tint.

### 3. Morning Check-in — final `functionalToday` row

1. Advance to the final step (`How are you starting today?`).
2. Tap each of the four buttons: `Strong` (good), `OK` (accent), `Scaled back` (warn), `Bad` (danger).
3. Each selected button must show a translucent tint.

### 4. Episode form — Communication step (commBtn helper)

1. Open **Log Episode** and advance to the Communication step.
2. Tap each of the four buttons. Verify all show translucent tints.

### 5. Episode form — Overall Severity step (sevBtn helper)

1. Advance to the Overall Severity step.
2. Tap each of the severity options. Verify each selected option shows a translucent tint in its color.

### 6. Body-map tint (var(--accent))

1. Advance to the Pain Location step in either Check-in or Episode.
2. Tap any body-map button (e.g., `L. Jaw`).
3. The selected button must show a translucent sky-blue tint (var(--accent)). Pre-fix, this was broken — only border + text were colored.

### 7. Meal-size picker

1. From Home, tap `I just ate` (or edit an existing meal).
2. In the meal-size picker, tap any size option.
3. The selected size must show a translucent green tint (var(--good)). Tap another size and confirm the previous one loses its tint while the new one gains it.

### 8. Log view chips — no regression

1. Open **View Log** after saving a check-in or episode.
2. Confirm entry chips (`communicationLevel`, `irritabilityLevel`) still render with their colors correctly.
3. Confirm nothing visually broke elsewhere.

### 9. iOS Safari render check (the target viewport)

1. If testing on an iOS device, verify selected-button tints render in Safari on iOS 16.2+ (color-mix support).
2. If any position shows transparent background, note the iOS version.
