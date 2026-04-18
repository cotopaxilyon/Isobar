---
status: queued — design captured, not scheduled
created: 2026-04-17
updated: 2026-04-17
resume-at: "Triage against WIP before turning any of §6 into tickets"
---

# PLAN: Local error telemetry (black-box recorder)

## Goal

Know when the app has silently broken on the one device that matters. Today, if `index.html` throws on load or a navigation path renders nothing, the user finds out when she opens the app to log an episode and sees a blank screen. No record, no stack, no history.

This plan captures a **privacy-preserving, device-local** error recorder — a black box flight recorder pattern — plus an unmissable "the app didn't boot" fallback outside the main render path.

## Why now

- README already names "Black screen on load" as a historical blocker. No mechanism exists today to detect a recurrence before the user opens the app to find it broken.
- Process drift critique (2026-04-17) flagged the absence of any error telemetry as a real clinical risk: the patient relies on this app during active symptoms, and a silent failure at that moment loses data on the days that matter most (Principle 2).
- Principle 10 rules out Sentry / third-party telemetry. Local-only is the only option that preserves the privacy invariant. That constraint defines the shape of the solution, not a limit on it.

## Principles honored

- **Principle 10 (data privacy).** Zero third parties. All error state lives in `localStorage` alongside the rest of the app's data.
- **Principle 2 (works when she is at her worst).** If the app hasn't rendered, a plain DOM fallback tells her something broke and gives her something to copy, rather than a blank screen.
- **Principle 11 (offline-first).** The recorder is local; it works without network.

## Principles tensioned against

- **Principle 13 (single user).** A full-blown error-reporting pipeline would be over-engineering for one device. Mitigated by keeping this to ~50 lines of vanilla JS and a modest settings screen.
- **Principle 9 (fields optional / don't block).** Crash banner could be perceived as gating. Mitigated by making it a passive fallback that only renders *when the app has not rendered* — it does not interrupt normal flows.

## Proposed mechanism

Three moves, independently shippable in the order listed.

### Move A — ring buffer recorder

A tiny module at the top of the `<script>` block (runs before any other code):

- Global `window.addEventListener('error', …)` and `window.addEventListener('unhandledrejection', …)` handlers.
- Each handler appends a record to a ring buffer keyed `diagnostics:errors` in `localStorage`:
  ```json
  { "ts": "ISO string", "kind": "error|rejection", "msg": "...", "src": "file:line:col", "stack": "first N lines" }
  ```
- Fixed cap (50 entries). Oldest evicted on push. Failure of the recorder itself (e.g. quota exceeded) must be swallowed — never throw from the handler.
- Also captures one "boot" record on successful app init, so gaps in the boot record stream are detectable after the fact.

### Move B — boot-failure fallback banner

A `<div id="boot-fallback">` **hardcoded in the static HTML**, rendered before any script runs. Hidden via inline style (`display:none`). On successful app init, the init code flips it to `display:none` permanently (it's already hidden — this confirms the script ran).

A setTimeout at the top of `<script>` (say 3s) checks: "has init marked itself complete?" If not, flip the fallback to visible with:
- Plain text: "Isobar didn't finish loading."
- The last entry from the ring buffer if present.
- A "copy diagnostics" button that writes the ring buffer JSON to the clipboard.
- No styling that depends on the stylesheet — inline `<style>` within the fallback div so it renders even if the main CSS never loaded.

This catches the exact failure mode that hit before: app never renders, user sees a blank screen, no signal.

### Move C — Diagnostics panel in Settings

A small section in the existing Settings view:
- Count of errors in buffer.
- List: timestamp, kind, first line of message.
- "Copy all" button — writes the full buffer to clipboard as JSON.
- "Clear diagnostics" button — empties the buffer (confirmed).

Read-only surface. Does not gate anything. Does not alter the error buffer except via the explicit clear button.

### Deferred — ntfy push on uncaught error

Out of scope for v1. When ntfy.sh is wired up for compound alerts (README Phase 2 / separate plan), the service worker can optionally POST to a private topic on uncaught errors. Deferred because:
- Requires ntfy to be wired up first.
- Privacy review needed on payload (error.message can echo user input in some cases).
- Moves A–C deliver most of the value without any external service.

## Ticket decomposition

Candidate breakdown, each within ticket sizing (≤ 1 day, ≤ 200 LOC, ≤ 5 acceptance criteria).

- **TICK-A: Error ring buffer.** Move A. Acceptance: errors thrown in console reach `localStorage`; buffer caps at 50; recorder never throws.
- **TICK-B: Boot-failure fallback.** Move B. Acceptance: deliberately-broken build renders the fallback; normal build does not; "copy diagnostics" writes to clipboard.
- **TICK-C: Diagnostics settings panel.** Move C. Acceptance: panel reads the buffer; clear button empties it; count reflects reality.

A–C should ship in that order. B depends on A (fallback reads the buffer). C depends on A (panel reads the buffer).

## Scope — what this plan does NOT do

- No third-party error reporting (Principle 10).
- No redaction pipeline — the buffer is local, only surfaced by explicit user action (copy to clipboard). If the user chooses to send it to a specialist or developer, that's her decision.
- No automatic remote push. Deferred until ntfy.sh lands.
- No breadcrumb trail (nav history, last action). Keep the buffer simple in v1; add breadcrumbs only if a real incident proves they'd have helped.
- No source maps / release tagging. Single-file app, versioned by commit SHA — git blame is the map.

## Open questions

1. **Quota handling.** `localStorage` is finite. If an error burst fills the buffer faster than `setItem` can keep up, do we silently drop (current proposal) or do we evict aggressively? Default: silently drop; recorder must never throw.
2. **Time-source in fallback.** If the fallback fires because script errored out, is `new Date().toISOString()` safe? Answer: yes, `Date` is always available — but the fallback should gracefully omit timestamp if anything goes wrong accessing it.
3. **Clipboard API availability.** `navigator.clipboard.writeText` requires secure context. GH Pages is HTTPS, local file:// is not. Plan: degrade to a textarea + manual copy when clipboard API unavailable.
4. **Does the recorder load before the PIN screen?** Yes — it must load before anything else. Otherwise a PIN-screen crash goes unrecorded.
5. **Interaction with service worker.** If the SW itself crashes, the page handlers won't see it. Worth a separate SW-internal logger in a future iteration. Not v1.

## PLAN_REVIEW.md walk

- **Q17 (privacy).** Passes — no external services, no telemetry leaves the device.
- **Q18 (offline).** Passes — works fully offline.
- **Q23 (rollback).** Remove the three inserts; delete the `diagnostics:errors` key on a clear-data action. Clean.
- **Q24 (retire criteria).** If no errors appear in the buffer over 6 months of use and no black-screen incidents occur, the fallback banner can be retired; recorder is cheap enough to keep.
- **Q26 (what it is not).** Explicitly listed in Scope.

All other questions (cognitive accessibility, clinical framing, measurement, patient invariants) are not applicable — this is an infrastructure plan, not a logging feature.

## References

- `docs/PRINCIPLES.md` — 10 (privacy), 2 (works at worst), 11 (offline).
- `docs/ARCHITECTURE.md` §1 — invariant check; the recorder must not hardcode paths.
- README "Known issue: Black screen on load" — the historical incident motivating Move B.
