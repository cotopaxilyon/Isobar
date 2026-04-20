---
id: TICK-015
title: Selected-button background tint lost for `var(--*)` colors
status: pending
priority: low
wave: null
created: 2026-04-20
updated: 2026-04-20
plan: null
test: null
linear:
  parent: ISO-49
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-015: Selected-button background tint lost for `var(--*)` colors

## Summary

The `comm-btn` selected-state style concatenates a two-char hex-alpha onto the button color: `background:${colors[i]}20`. That works when `colors[i]` is a hex literal like `#f97316` (yields `#f9731620` — valid 8-digit hex). It does not work when `colors[i]` is a CSS variable like `var(--good)` — the browser sees `var(--good)20`, which isn't a valid color, and drops the background.

Net effect: the translucent selected-state fill only shows on the one position per ramp that uses a hex literal. Text color and border still render correctly (those don't use the `20` suffix). The bug is cosmetic — selection is still visible via border and color — but the ramp reads inconsistently.

Observed during TICK-013 QA: on the new irritability 4-button block, "Sensory overload" (the `#f97316` position) gets the translucent tint; "Normal", "Edgy", and "Snap-line" (all `var(--*)`) get only border + text color. Same pattern is in the existing `communicationLevel` block and the meal-size picker — pre-existing, not introduced by TICK-013.

## Affected sites

- `index.html:1484` — communicationLevel 4-button row (Communication step)
- `index.html:1501` — irritabilityLevel 4-button row (Communication step, TICK-013)
- `index.html:2085-2086` — meal-size picker (hardcoded `var(--good)20`)

## Acceptance Criteria

- [ ] Selected-state background tint renders on all four positions of the `communicationLevel` block
- [ ] Selected-state background tint renders on all four positions of the `irritabilityLevel` block
- [ ] Selected-state background tint renders on the meal-size picker
- [ ] No regression to border-color or text-color behavior
- [ ] Works on Safari iOS (the target viewport)

## Implementation Notes

Two candidate approaches:

1. **`color-mix`**: `background: color-mix(in srgb, ${colors[i]} 12%, transparent)`. Works for both hex and `var(--*)`. Modern browsers only; check iOS Safari support — should be fine on anything from 2023+.
2. **Alpha-variable pairs**: define `--good-12`, `--accent-12`, `--warn-12`, `--danger-12` in `:root` alongside the base vars. Selected-state style uses the paired variable. More verbose but no `color-mix` dependency.

No schema impact, no migration, no SW cache bump needed (pure CSS-rendering fix). No new AC for `communicationLevel` behavior — it's visual only.
