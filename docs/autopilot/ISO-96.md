---
ticket: ISO-96
status: pending-review
date: 2026-05-01
bail-at: adversary-pass
---

# ISO-96 — Autopilot bail-out

Adversary pass returned 3 block-severity objections. No code was written.

## Block objections

### 1. Feature label excluded
**Rule:** PLAN_autopilot_harness.md:84 — autopilot handles `Bug` or `Improvement` only, not `Feature`.
**Evidence:** Ticket is `wave: additive`, introduces a net-new event type, a new home-screen card, a new form view, a new opportunistic strip, and a new storage namespace. No `Bug` or `Improvement` label on the issue.

### 2. Adds tracked storage fields
**Rule:** PLAN_autopilot_harness.md:96 — adding a new tracked field or storage shape is out of scope.
**Evidence:** Ticket adds `entry:<timestamp>` records of `type: 'intervention_event'` (9-field schema) and a new `intervention:recent:<category>` key namespace. The latter is outside the `entry:` prefix scanned by `allEntries()` and invisible to the backup preview UI (`index.html:2588-2596`).

### 3. Touches sw.js
**Rule:** PLAN_autopilot_harness.md:95 — `sw.js` is a categorical out-of-scope file.
**Evidence:** TICK-035 AC line 78 explicitly requires bumping the SW cache version; `sw.js:1` currently reads `const CACHE = 'isobar-v14'`.

## Escalate objection (noted for human reviewer)

### 4. DOM placement ACs use regions, not sibling+position
**Rule:** PLAN_autopilot_harness.md:75-78.
**Evidence:** "Home grid has a third card" and "render an inline strip above the action grid" are region descriptions with no grep-verifiable sibling+position citation. `index.html:409-420` shows `<div class="action-grid">` with no ID.

## Flag objections (noted for human reviewer)

### 5. Styling/fit ACs require felt-sense judgment
"styled distinct from the episode button (e.g. accent color)" and "Form fits without scrolling on iPhone" cannot be auto-verified by diff + Playwright alone.

## Next step

This ticket requires human-driven implementation. The plan is fully specced (`docs/plans/PLAN_intervention_log.md`). The ticket doc is ready (`docs/tickets/TICK-035-intervention-schema-home-logging.md`). No autopilot precondition work is outstanding — it is purely a scope class mismatch.
