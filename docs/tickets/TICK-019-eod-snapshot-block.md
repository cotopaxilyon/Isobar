---
id: TICK-019
title: EOD snapshot block — communication + irritability + external observation
status: ready-for-qa
priority: high
wave: 2
created: 2026-04-20
updated: 2026-04-21
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-53
  test: ""
depends-on: [TICK-018]
supersedes: []
shipped: 2026-04-21
---

# TICK-019: EOD Snapshot Block

## Summary

Adds the "right now" snapshot section to the evening check-in — the three fields the user already answers in the morning (`communicationLevel`, `irritabilityLevel`, `externalObservation`), re-captured at end of day. Stored under evening-prefixed keys on the `evening_checkin` record so the composite can treat morning and evening readings as two inputs to the same axis. Mirrors the morning shape exactly — same 4-button communication row, same 4-button irritability ramp, same 3-button external-observation row.

## Acceptance Criteria

- [ ] EOD form body at `#eod-content` renders three blocks in order: (1) "Right now — communication" (4-button, same options and ramp as morning), (2) "Right now — fuse / sensory tolerance" (4-button, same options and ramp as morning's irritability block), (3) "Did anyone today comment on you seeming quiet, snappy, or off?" (3-button Yes / No / No one around). All three blocks land above the existing Save button from TICK-018
- [ ] Stored on `eodData` as `eveningCommunicationLevel` (`normal | quieter | shortened | brief`), `eveningIrritabilityLevel` (`normal | edgy | overload | snap_line`), `eveningExternalObservation` (label-string `Yes | No | No one around` — matches the morning convention established in TICK-013 / `index.html:1511`)
- [ ] Log card at `index.html:1590-1632` renders a communication chip and an irritability chip for `evening_checkin` entries using the *evening-prefixed* field names, not the morning names. Same color ramps as the morning chips. Chips omit silently when null
- [ ] `exportReport` at `index.html:1670-1792` emits the three fields as labeled lines when present — use the existing `commLabels` / irritability label table from `:1749`; add a one-line `Observed as snapping/on edge` mirror for evening external-observation. (Rendering inside the Morning section is acceptable for this ticket — the dedicated Evening section comes in TICK-022.)
- [ ] Partial saves round-trip: an evening_checkin with any subset of the three fields null re-renders in the log and exports without throwing

## Agent Context

- `eodData` initializer lives in `startEvening()` (added by TICK-018). Add three new keys: `eveningCommunicationLevel: null, eveningIrritabilityLevel: null, eveningExternalObservation: null`.
- For markup, **copy the existing morning blocks verbatim** — communication at `index.html:1483-1490`, external-observation row at `:1491-1494`, irritability block at `:1498-1508`, irritability external-observation at `:1509-1513`. Swap `ciData.*` references for `eodData.*` and swap `renderCiStep()` for the evening re-render function (introduced in TICK-018 — likely `renderEvening()` or equivalent; confirm from the shell).
- **Skip the morning block's second external-observation row** (the one tied to irritability at `:1509-1513`). The plan folds evening's one external-observation into a single combined question: "Did anyone today comment on you seeming quiet, snappy, or off?" — one row, covers both communication and irritability.
- Log card chips at `index.html:1600-1602` currently read `e.communicationLevel` and `e.irritabilityLevel`. For EOD entries (`e.type === 'evening_checkin'`), read `e.eveningCommunicationLevel` and `e.eveningIrritabilityLevel` instead. Simplest: compute local variables at the top of the map callback that pick the right field based on `e.type`, then reference those vars in the chips.
- Same color ramps: `commColors` at `:1589`, `irritColors` at `:1598`. No new palettes needed.
- **Do NOT touch morning check-in fields** — `communicationLevel` / `irritabilityLevel` / `externalObservation` / `morningIrritabilityExternalObservation` stay exactly as they are on the `checkin` record. The morning-vs-evening distinction lives in the field-name prefix and the `type` field.
- **Do NOT bump SW cache version in this ticket** — TICK-018 just bumped to v11, and no shell assets change here. Cache next bumps when TICK-022 closes the Stage-2 slice.
- Run architecture check: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

- **Why re-capture communication/irritability at evening:** plan §"Part C — Problem #3" — "Communication and irritability are sampled once at wake. Whether the day depleted them, and by how much, is not captured." Paired morning+evening readings enable the `peakOfPaired` aggregation from Item 7 (`PLAN_irritability_and_severity_mapping.md:1067-1069`).
- **Why one external-observation row instead of two:** plan §"Part C — Form structure" lists a single question 6: *"Did anyone today comment on you seeming quiet, snappy, or off?"* covering both dimensions. This is deliberate — one evening recall question is easier than two, and the signal is similar enough.
- **Field naming convention:** `evening*` prefix is explicit rather than implicit via `type`. Plan §"Part C — Schema" uses `eveningCommunicationLevel` and `eveningIrritabilityLevel` explicitly. Do not rename to plain `communicationLevel` on the EOD record — that would require disambiguation every time the composite engine reads the field.
- **Test sequence (user, during QA):**
  1. Open EOD form, see three new blocks above Save.
  2. Tap each button in each row — single-select behavior, right color tint.
  3. Save with all three set — log card shows communication + irritability chips; export has three new labeled lines.
  4. Save with only communication set — log card shows one chip; irritability and observation omit silently.
  5. Save completely empty — no chips, no export lines, no console errors.
  6. Open an EOD saved before this ticket (from TICK-018 shell) — renders cleanly with no chips.

## Ship Notes

Stale citations in the spec (drafted pre-ISO-52; ISO-52 inserted ~121 lines). Actual locations when edits landed:
- morning comm block: `index.html:1519-1527` (not 1483-1490)
- morning ext-obs after comm: `:1528-1532` (not 1491-1494)
- morning irritability block: `:1534-1544` (not 1498-1508)
- morning irritability ext-obs: `:1546-1550` (not 1509-1513)
- log card: `renderLog` at `:1613`, chips at `:1639-1640` (not 1590-1632 / 1600-1602)
- `commColors` log `:1626`, export `:1690`; `irritColors` log `:1636`
- `exportReport` starts `:1714`; `commLabels` `:1733` (not 1670-1792 / 1749)
- `eodData` init inside `startEvening` at `:1949`; `renderEvening` at `:1958`; `#eod-content` is the target

Implementation matches spec. Three evening-prefixed fields added to `eodData`, three form blocks rendered in `renderEvening`, log chips branch on `e.type === 'evening_checkin'` via `commVal`/`irritVal` locals, export filter broadened to include `evening_checkin` and three new labeled lines emitted inside the existing MORNING CHECK-INS loop (guarded by `if (e.evening...)` so morning entries skip silently and vice versa).

Minor scope notes:
- **Morning export label lifted out of the `if (e.irritabilityLevel)` block** — `irritExportLabels` was declared inside the conditional; moved to outer scope so the new `Evening irritability` line can reuse it. Behavior unchanged for morning entries.
- **Export line for evening external-observation** labeled `Observed as snapping/on edge (evening)` rather than a bare mirror of the morning label, to disambiguate when the same-day morning+evening entries both print into the (pre-TICK-022) MORNING CHECK-INS section. TICK-022 will move evening fields to a dedicated section where the suffix can drop.
- **`updateStats` checkin count NOT changed** — evening entries intentionally excluded from the home-screen "Check-ins" counter; TICK-022 likely adds a dedicated evening stat.
- **SW cache NOT bumped** (per ticket instruction; no shell assets changed).

Verified end-to-end in a live Playwright session: all three fields round-trip through DB → log chips → export; partial saves (only comm) render correctly; empty saves produce no chips and no export lines; no JS errors; morning path regression-checked (chips and export lines still identical for a synthetic morning entry).
