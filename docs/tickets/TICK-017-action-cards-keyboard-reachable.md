---
id: TICK-017
title: Home action cards not in keyboard tab order
status: pending
priority: high
wave: null
created: 2026-04-20
updated: 2026-04-20
plan: null
test: null
linear:
  parent: ISO-17
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-017: Home action cards not in keyboard tab order

## Summary

`Log Episode` and `Morning Check-in` are rendered as `<div class="action-card" onclick=...>` with no `tabindex`, no `role="button"`, no keydown handler. Keyboard-only users can't activate the app's two primary actions. WCAG 2.1.1 Level A direct failure.

## Acceptance Criteria

- [ ] Both action cards are reachable in the sequential tab order
- [ ] Enter and Space activate each card
- [ ] Visible focus indicator on each card when focused (`:focus-visible` outline)
- [ ] Each card exposes a button role and an accessible name to assistive tech
- [ ] No visual regression — cards look the same as before
- [ ] SW cache version bumped

## Agent Context

- Cards rendered at `index.html:407` (Log Episode) and `index.html:412` (Morning Check-in).
- CSS at `index.html:162-172`.
- Preferred fix: convert `<div>` → `<button type="button">`. Buttons get tab order, Enter/Space activation, and `role=button` for free. Requires small CSS reset (`font: inherit; color: inherit; width: 100%`) because button defaults would otherwise break the layout.
- Add `:focus-visible` outline for the focus indicator.
