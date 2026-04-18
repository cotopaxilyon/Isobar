---
status: queued — design captured, not scheduled
created: 2026-04-17
updated: 2026-04-17
resume-at: "Not before one currently-parked plan lands (WIP rule, 2026-04-17 process critique)"
---

# PLAN: Split the single file and retire inline template strings

## Goal

`index.html` is 1,844 lines of HTML + CSS + JS and approaching the ceiling of what one file comfortably holds. The same file writes inline `style="…"` into template literals, coupling presentation and logic inside JS strings. Neither is broken today — both will bite on the next major feature.

This plan captures two **independent** moves that buy breathing room without adopting a build step or a framework:

1. **File split.** `index.html` → `index.html` + `app.css` + `app.js`, served as three static files.
2. **Template retirement.** Replace the large inline template literals with `<template>` elements and class-based styling; kill `style="…"` strings inside JS.

Each move is shippable on its own. Both preserve the "no build step, deployable to GitHub Pages" property that makes the offline/privacy invariants trivially true.

## Why now

- Process drift critique (2026-04-17) flagged the file size + inline templates as the next structural pressure point.
- "Not broken today" is the point — this is a move to make *before* the next feature, not after, so the next feature doesn't carry the cost.
- Both moves are mechanical. They do not require design thinking about patient behavior, so they don't compete with clinical plans for review attention.

## Why not a framework

Preact, Lit, Alpine, etc. were considered and explicitly rejected:

- They require a build step or a runtime CDN dependency. Both break the "ship static files to GitHub Pages" property.
- The "no build step" property is load-bearing for Principle 11 (offline) and Principle 10 (privacy — fewer moving parts means fewer audit surfaces).
- The current pain is real but small. The cheapest fix (split files + native `<template>`) solves ~80% of it. Adopt a framework only if a forcing function appears.

## Principles honored

- **Principle 11 (offline-first).** No new network dependency. Three static files cache the same way one does.
- **Principle 13 (single user).** The simplest move that solves *this* codebase's pain. No attempt to generalize.

## Principles tensioned against

- **Principle 2 (works at worst).** A split across three files adds a navigation hop for any future agent/human reading the code. Mitigated by keeping the split along natural concern lines (style / logic / markup) rather than arbitrary module boundaries.

## Architectural invariants this plan must honor

- **ARCHITECTURE.md §1 — no hardcoded `/Isobar/` paths in shell assets.** The split adds two new shell assets (`app.css`, `app.js`) to the list covered by the grep. The invariant's verification command must be updated to include them, and the new files must use relative paths (`./manifest.json`, etc.) the same way `index.html` does.
- **Service worker cache list.** `sw.js` currently precaches the shell. Splitting adds two new entries. Cache version bump required.

## Proposed mechanism

### Move 1 — File split

Three files, same directory, same origin-agnostic discipline:

- `index.html` — document structure only: `<head>`, meta/manifest links, `<link rel="stylesheet" href="./app.css">`, body markup scaffold, navigation, `<script src="./app.js" defer>`. Inline `<template>` elements go here (see Move 2).
- `app.css` — everything currently inside the `<style>` block (lines 12–523).
- `app.js` — everything currently inside the `<script>` block (lines 525–1843).

No module system. `app.js` is loaded with `defer` and remains a single script file accessing globals as it does today.

Estimated line counts after split: `index.html` ≈ 400, `app.css` ≈ 500, `app.js` ≈ 1300. Each is navigable; none is unwieldy.

**Service worker changes:**
- Add `./app.css` and `./app.js` to the precache list.
- Bump `CACHE_NAME` to force a fresh precache on next load.
- Verify `./` relative paths resolve correctly against the SW scope at both origins (GH Pages and local dev), per §1 invariant.

**Deployment smoke test:**
- Run the architecture grep (now widened to include the new files).
- Open the app at `file:///`, localhost, and `cotopaxilyon.github.io/Isobar/`. All three must load.
- Confirm service worker registers and precaches the three files (DevTools → Application → Cache Storage).

### Move 2 — Retire inline template strings

Current pattern (seen throughout `renderLog`, `updateStats`, etc.):
```js
return `<div class="entry-card" style="border-left-color:${borderColor}">
  …
</div>`;
```

Target pattern:
```html
<!-- in index.html -->
<template id="tpl-entry-card">
  <div class="entry-card">
    <!-- static structure -->
  </div>
</template>
```
```js
// in app.js
const tpl = document.getElementById('tpl-entry-card');
const node = tpl.content.cloneNode(true);
node.querySelector('.entry-card').style.setProperty('--border-color', borderColor);
// …fill text nodes…
container.appendChild(node);
```

Dynamic-colour hooks move to CSS custom properties; `style="…"` strings disappear. Text content is set via `.textContent` (safe) rather than string concatenation (XSS-adjacent).

**Scope of the templates to extract** (by current render function):
- Entry card in `renderLog()` (~line 1402).
- Recent-episode card in `updateStats()` (~line 1435).
- Any other template literal in `app.js` that produces non-trivial DOM. Audit as part of implementation.

### Move 3 — Not in this plan

Out of scope:
- Splitting `app.js` further (into `weather.js`, `storage.js`, etc.). Do only if file still feels unwieldy after Move 2. No framework adoption. No build step. No TypeScript. No npm dependency.

## Ticket decomposition

Each within ticket sizing.

- **TICK-A: File split + SW cache update.** Move 1. Acceptance: three files load at all three origins; SW precaches all three; architecture grep (updated) returns empty; cache version bumped.
- **TICK-B: ARCHITECTURE.md invariant update.** Widen §1 to cover `app.css` and `app.js`. Tiny, but separate because it amends an invariant.
- **TICK-C: Template extraction — entry card.** Move 2, first target.
- **TICK-D: Template extraction — recent episode card.** Move 2, second target.
- **TICK-E: Template audit sweep.** Grep for remaining `` ` ``-with-`<` patterns in `app.js`; extract any that survived. Close the pattern out.

Order: A must ship first. B with A or immediately after. C–E can run in any order once A lands.

## Open questions

1. **`defer` vs `type="module"` on the script tag.** `defer` is enough if we keep `app.js` as one non-module file (matches today's behaviour). `type="module"` buys proper lexical scoping but changes global-access semantics for every function. Default: `defer`. Change only if we split `app.js` further in a future plan.
2. **CSS source-of-truth for dynamic colours.** Today borders are set inline from `sevColors` / `commColors` objects in JS. Proposal: generate CSS custom properties on a root element at boot from those same objects, so JS only sets `--border-color` on the node and CSS reads it. Alternative: keep passing colours via `style.setProperty`. Former is cleaner, latter is less churn. Decide during TICK-C.
3. **Existing PWA install state.** Users who already installed the PWA will get the new `CACHE_NAME`; the old cache will be swept by the standard SW activation flow. Verify the activation flow actually deletes stale caches in `sw.js` — if it doesn't, this move surfaces that as a bug.
4. **`<template>` support in iOS Safari.** Supported since Safari 8 — safe.
5. **Order relative to PLAN_error_telemetry.** Error telemetry (ring buffer + boot fallback) is easier to wire cleanly if this split has already happened — the fallback wants its own tiny inline `<style>` inside the static HTML, which is easier to reason about when `index.html` is structure-only. Non-blocking but worth noting.

## PLAN_REVIEW.md walk

- **Q17 (privacy), Q18 (offline).** Passes — no external services, no build step, no new dependencies. Three static files behave identically to one at the privacy/offline layer.
- **Q19 (backward compat).** No data shape changes. All localStorage keys preserved.
- **Q23 (rollback).** Any move is individually reversible with `git revert`. Move 2 rollbacks are trivial (restore the inline template literal). Move 1 rollback requires reverting the SW cache bump and re-inlining — mechanical.
- **Q24 (retire criteria).** Not applicable in the usual sense. The retire condition for this plan is "both moves shipped" — after that it closes.
- **Q25 (testable end-to-end).** Every ticket has a functional path: open the app, run the affected view, verify no regression. Covered.
- **Q26 (what it is not).** Explicitly listed in "Move 3 — Not in this plan."

All other questions (clinical framing, patient invariants, measurement) are not applicable — this is a code-organization plan.

## References

- `docs/ARCHITECTURE.md` §1 — origin-agnostic paths; this plan amends the invariant's scope.
- `docs/PRINCIPLES.md` — 11 (offline), 13 (single-user simplicity).
- `docs/PROCESS.md` — ticket sizing; all child tickets fit the cap.
- `index.html` — the single file under discussion (lines 12–523 style; 525–1843 script).
- `sw.js` — service worker cache list and activation flow.
