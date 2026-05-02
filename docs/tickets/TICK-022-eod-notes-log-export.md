---
id: TICK-022
title: EOD notes + dedicated log + export section
status: shipped
priority: high
wave: 2
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_irritability_and_severity_mapping.md
test: null
linear:
  parent: ISO-56
  test: ""
depends-on: [TICK-018, TICK-019, TICK-020, TICK-021]
supersedes: []
shipped: ""
---

# TICK-022: EOD Notes + Dedicated Log & Export

## Summary

Closes the minimum viable Stage-2 evening check-in slice. Adds the free-text `eveningNotes` field to the form and pulls all the cumulative EOD fields out of the Morning section in `exportReport` into their own dedicated **EVENING CHECK-INS** section. Final ticket of the 1-5 foundation subset — after this lands the user can capture a full evening check-in, the data round-trips through log + export, and the rendered output doesn't pollute the morning section.

## Acceptance Criteria

- [ ] EOD form renders a `<textarea>` labeled *"Anything to note…"* as the final section above Save, bound to `eodData.eveningNotes`. Defaults to empty string; unlimited length; `rows="4"` consistent with morning's notes box at `index.html:1536`
- [ ] Log card at `index.html:1630` renders `eveningNotes` in the `entry-notes` slot for `evening_checkin` entries (same slot morning uses for its `notes` field). When `eveningNotes` is empty or whitespace-only, omit the notes element
- [ ] `exportReport` at `index.html:1670-1792` adds a dedicated `EVENING CHECK-INS` section header (30-dash separator pattern identical to the Episode and Morning section headers at `:1692, :1732`) emitted after the Morning section closes at `:1782`. Section iterates `entries.filter(e => e.type === 'evening_checkin')` and renders one block per EOD entry
- [ ] EVENING CHECK-INS block per entry renders labeled lines for every set field from TICK-019/020/021/022 using the same null-guard pattern the Morning block uses (`if (e.eveningCommunicationLevel) r += ...`). All field labels match the human-readable form of their option values
- [ ] Remove the EOD field rendering that TICK-019/020/021 put inside the Morning section — those branches no longer fire for `evening_checkin` entries (which were never in `cis` anyway since `cis` filters on `type === 'checkin'`). Cleanup-only if those tickets wired renders into the wrong section by accident; verify with a grep before declaring done
- [ ] Section gracefully absent when no EOD entries exist (do not emit an empty `EVENING CHECK-INS\n──` header)
- [ ] `sw.js` `CACHE` constant bumped `isobar-v11` → `isobar-v12`

## Agent Context

- Notes textarea pattern: copy `index.html:1536` exactly. Swap `ciData.notes` → `eodData.eveningNotes`.
- `exportReport` structure: the function lives at `index.html:1670-1792`. Three existing sections today — Top Exposures (`:1685-1687`), EPISODES (`:1692-1726`), MORNING CHECK-INS (`:1732-1782`). Add EVENING CHECK-INS between the Morning section's closing `}` and the blob creation at `:1784`.
- Filter: `const eods = entries.filter(e => e.type === 'evening_checkin');` alongside the existing `eps` / `cis` filters at `:1673-1674`.
- Field label maps: reuse `commLabels` at `:1690` (works for both morning and evening communication since the option values are identical). Reuse irritability labels from TICK-013's `irritExportLabels` at `:1749` — if it's still scoped locally, hoist it to the function scope so the EOD section can reference it. Reuse `functionalLabels` at `:1728`. Add local label maps for cost fields (introduced in TICK-020) and trajectory / activityLevel (introduced in TICK-021) inside the new EVENING CHECK-INS block.
- Entry rendering order per block: timestamp header → snapshot fields (comm, irritability, external-obs) → cost fields → activity → trajectory → `functionalToday` → `eveningNotes`. This matches the form's top-to-bottom flow.
- Log-card notes rendering: the existing condition at `index.html:1630` is `${e.notes ? …}`. For EOD entries, swap to `${(isEod ? e.eveningNotes : e.notes) ? …}` — or introduce a local `const notesField = isEod ? e.eveningNotes : e.notes` at the top of the map callback and reference it once.
- Cache bump rationale: completes the Stage-2 foundation subset. Bump mirrors the TICK-014 fix-forward (`07386af`) pattern of bumping once when a related cluster of changes reaches shipping state.
- Run architecture check: `grep -n '/Isobar/' sw.js manifest.json index.html` — must return empty.

## Implementation Notes

- **Why the dedicated section instead of adding to MORNING CHECK-INS:** the morning branch at `index.html:1732-1782` iterates `cis` (`e.type === 'checkin'`); EOD entries have `type === 'evening_checkin'` and never show up there. If TICK-019/020/021 followed instructions they emitted fields conditional on `evening_checkin` type *inside the morning iteration* — verify via grep that the `cis.forEach` block isn't touching evening-type fields. Any such code is dead; delete.
- **Section ordering rationale:** Morning check-ins come before Evening check-ins in chronological reading order — a clinician scanning the export sees wake → day-cost in temporal order. Don't interleave per-day; the existing export groups by type, not by date.
- **Why notes get their own ticket rather than being in TICK-018:** notes are trivial but shipping them alongside the other field blocks (19/20/21) would have split each of those tickets into "field + notes + render-cleanup" shapes, over the AC cap. Isolating notes + log-cleanup + export-consolidation here keeps each prior ticket clean.
- **Test sequence (user, during QA):**
  1. Open EOD form — notes textarea visible at the bottom. Type text, tap Save.
  2. Log view — EOD card shows the notes text in its notes slot.
  3. Export report — new EVENING CHECK-INS section between MORNING and the end of file. All fields present for the entry just saved, labeled human-readably.
  4. Save an EOD with empty notes — log and export omit the notes slot/line.
  5. Save an EOD with only `eveningCommunicationLevel` set — export shows only that one labeled line plus the date header for that block.
  6. Open app with zero EOD entries in DB — export file has no EVENING CHECK-INS section at all (not an empty header).
  7. Open an older EOD from TICK-018 (shell-only, no fields) — exports cleanly as a date-header-only block.

## Ship Notes

_(pending)_
