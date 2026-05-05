---
id: TICK-043
title: Physician report — add WEATHER COLOR SCALE to SCALE TRANSLATION LEGEND
status: backlog
priority: low
wave: emergent
created: 2026-05-04
updated: 2026-05-04
plan: null
test: null
linear:
  id: ISO-111
  parent: ISO-109
  test: ""
depends-on: [TICK-040]
supersedes: []
shipped: ""
---

# TICK-043: Physician report — add WEATHER COLOR SCALE to SCALE TRANSLATION LEGEND

## Summary

Adds a WEATHER COLOR SCALE entry to the SCALE TRANSLATION LEGEND section in `exportReport()`. Fixes the advisory finding from ISO-109 QA: `amber+` appears 8× in the new Weather exposure section without a definition, which is opaque for a clinician who has not seen the patient-side app's color-coded weather card.

Scope: one addition to the legend block at `index.html:2096-2099`. No logic changes. No schema changes. No form changes.

## Decision

Option (b) from ISO-111: add WEATHER COLOR SCALE to SCALE TRANSLATION LEGEND. Preferred over option (a) inline definition because:
- The amber/red terminology also appears implicitly in the per-axis breakdown row labels; a legend entry covers those too.
- Consistent with the legend's existing purpose — it's where all scale terms are defined for the clinician reader.
- One authoritative definition, not repeated inline text at each of the 4 occurrences.

## Implementation

Single insertion in `exportReport()`, after the PRODROME SEQUENCE block (after line 2098) and before the closing separator (line 2099 `${'─'.repeat(60)}`):

```js
r += `WEATHER COLOR SCALE (Marquette only; used in Environmental Pattern section)\n`;
r += `  Green   All three axes below threshold: pressure dwell < 12h AND temp change < 10°F/5h\n`;
r += `  Amber   One or more axes at or above amber threshold:\n`;
r += `            pressure dwell ≥ 12h  OR  temp drop ≥ 10°F/5h  OR  temp rise ≥ 10°F/5h\n`;
r += `  Red     One or more axes at or above red threshold:\n`;
r += `            pressure dwell ≥ 24h  OR  temp drop ≥ 14°F/5h  OR  temp rise ≥ 14°F/5h\n`;
r += `  amber+  Amber or red (i.e., not green). Term used in the contingency table.\n\n`;
```

Insertion point: `index.html:2099`, directly before the `${'─'.repeat(60)}\n\n` closing line.

**Do not** change the PRODROME SEQUENCE block, the closing separator, or any other legend entry.

## Acceptance Criteria

**Code-verifiable (agent checks before transitioning to QA):**

1. WEATHER COLOR SCALE block inserted immediately before the closing `─` separator of SCALE TRANSLATION LEGEND (between PRODROME SEQUENCE and the separator).
2. All three axes listed with their amber threshold (≥12h / ≥10°F drop / ≥10°F rise) and red threshold (≥24h / ≥14°F drop / ≥14°F rise).
3. `amber+` defined explicitly as "amber or red (not green)."
4. No other legend entries modified.
5. No logic changes to `buildWeatherExposureTable` or anywhere else in `exportReport`.
6. No schema changes, no form changes, no home stat chip.
7. SW cache version NOT bumped (legend text is report content, not a shell asset behavior change).
8. Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty.

**Behavioral / user-verified during QA:**

9. The legend's WEATHER COLOR SCALE block appears near the top of the exported report, before the Period Summary.
10. The green / amber / red / amber+ definitions read correctly; thresholds match the per-axis breakdown rows in the Environmental Pattern section.
11. Report renders without errors.

## Test Sequence (user, during QA)

1. Export the report.
2. Locate SCALE TRANSLATION LEGEND near the top. Confirm new WEATHER COLOR SCALE block is present.
3. Scan down to Environmental Pattern > Weather exposure. The row label `amber+ weather day` and the phrase `amber+` in the episode-level summary now have a named definition earlier in the doc.
4. Confirm the threshold numbers in the legend match the per-axis breakdown labels (`≥12h`, `≥10°F`).
