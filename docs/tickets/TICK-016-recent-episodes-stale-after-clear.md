---
id: TICK-016
title: Recent episodes section stays visible after Clear All Data
status: pending
priority: low
wave: null
created: 2026-04-20
updated: 2026-04-20
plan: null
test: null
linear:
  parent: ISO-43
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-016: Recent episodes section stays visible after Clear All Data

## Summary

`updateStats()` only wires the truthy branch for the Home "Recent episodes" section. When the entries list empties (Clear All Data), the section stays at `display:block` with the last-rendered HTML until the page is reloaded. Same staleness class as ISO-21's meal card, different element.

## Acceptance Criteria

- [ ] After Clear All Data (with entries previously logged), Home "Recent episodes" section is hidden without a reload
- [ ] `recent-list` innerHTML is emptied in the no-entries branch (no stale DOM)
- [ ] No regression to the truthy path — section still renders when episodes exist
- [ ] SW cache version bumped (index.html changed; cache-first strategy requires new version to propagate)

## Agent Context

- Render site: `index.html:1639-1652` inside `updateStats()`.
- Initial state: `<div id="recent-section" style="display:none">` at `index.html:443`. The bug is that once flipped to `block`, it's never flipped back.
- Fix is the else branch shown in the ticket description: set `display:none` and clear `recent-list.innerHTML`.
