---
ticket: ISO-48
title: TICK-014 Cycle-phase moodShift → cycleRelatedDay rename
status: resolved
drafted: 2026-04-20
resolved: 2026-04-20
commits:
  - 6513dff — ISO-48: rename cycle-phase moodShift → cycleRelatedDay (local only)
  - fix-forward — ISO-48/ISO-51: render cycle-proxy chips in log + bump SW cache v9 → v10 (local only, QA-gated)
---

# Fix plan — ISO-48

## TL;DR

The rename itself is clean — AC-1/2/3/5/6/7 passed, export half of AC-4 works via the `cp.cycleRelatedDay ?? cp.moodShift` coalesce at `index.html:1757`. AC-4's **log-surface half** fails because `renderLog()` (`index.html:1600–1607`) has never rendered cycle-proxy chips on entry cards for any entry shape — legacy or post-rename. Proposed fix: add one chip expression to the `renderLog()` chips array that mirrors the export coalesce. ~5 lines, same rendering surface, same legacy-forward semantics.

## Failure classification

**Type (c) — ticket AC exposed a pre-existing gap.** The log-render omission pre-dates ISO-48; it was never wired into `renderLog()`. ISO-48's AC-4 wording ("surface in log and export") made the gap explicit. QA correctly flagged the failure against ISO-48 *and* spawned **ISO-51** for the underlying log-render bug. Net: one fix closes both tickets.

## Root cause

`index.html:1600–1607` — `renderLog()` entry-card chips array:

```js
const chips = [
  e.communicationLevel ? `<span class="entry-chip" style="color:${commColors[e.communicationLevel]||'var(--mid)'}">${e.communicationLevel}</span>` : '',
  e.irritabilityLevel ? `<span class="entry-chip" style="color:${irritColors[e.irritabilityLevel]||'var(--mid)'}">${irritLabels[e.irritabilityLevel]||e.irritabilityLevel}</span>` : '',
  ...(isEp ? (e.limbsAffected||[]).map(l=>`<span class="entry-chip">${l.replace(/_/g,' ')}</span>`) : []),
  ...(e.bodyPain||[]).map(p=>`<span class="entry-chip">${p.replace(/_/g,' ')}</span>`),
  e.weather?.pressure ? `<span class="entry-chip mono">${e.weather.pressure}hPa (${e.weather.trend>0?'+':''}${e.weather.trend})</span>` : '',
  isCi && e.sleepHours != null ? `<span class="entry-chip">${e.sleepHours}h sleep</span>` : '',
].filter(Boolean).join('');
```

No reference to `e.cyclePhaseProxy`. The toggles (`cycleRelatedDay`, `breastTender`, `bloating`, `libido`) all persist correctly and render in the text export at `index.html:1752–1761`, but the log entry card never surfaces them. The oversight is structural — `cyclePhaseProxy` is a nested object, while every other chip reads a flat field, so it never got added when the other chips did.

## Proposed fix

Add cycle-proxy chips to the `chips` array, mirroring the export path's label set and legacy coalesce. One new inline expression:

```js
const chips = [
  e.communicationLevel ? `<span class="entry-chip" style="color:${commColors[e.communicationLevel]||'var(--mid)'}">${e.communicationLevel}</span>` : '',
  e.irritabilityLevel ? `<span class="entry-chip" style="color:${irritColors[e.irritabilityLevel]||'var(--mid)'}">${irritLabels[e.irritabilityLevel]||e.irritabilityLevel}</span>` : '',
  ...(isEp ? (e.limbsAffected||[]).map(l=>`<span class="entry-chip">${l.replace(/_/g,' ')}</span>`) : []),
  ...(e.bodyPain||[]).map(p=>`<span class="entry-chip">${p.replace(/_/g,' ')}</span>`),
  ...(() => {
    const cp = e.cyclePhaseProxy; if (!cp) return [];
    const out = [];
    if (cp.breastTender) out.push('<span class="entry-chip">breast tenderness</span>');
    if (cp.cycleRelatedDay ?? cp.moodShift) out.push('<span class="entry-chip">cycle-related day</span>');
    if (cp.bloating) out.push('<span class="entry-chip">bloating</span>');
    if (cp.libido && cp.libido !== 'same') out.push(`<span class="entry-chip">libido ${cp.libido}</span>`);
    return out;
  })(),
  e.weather?.pressure ? `<span class="entry-chip mono">${e.weather.pressure}hPa (${e.weather.trend>0?'+':''}${e.weather.trend})</span>` : '',
  isCi && e.sleepHours != null ? `<span class="entry-chip">${e.sleepHours}h sleep</span>` : '',
].filter(Boolean).join('');
```

Points:

- **Coalesce `cp.cycleRelatedDay ?? cp.moodShift`** matches the export path exactly, so legacy entries (`moodShift:true`) still render under the new "cycle-related day" label.
- **Order of chips** matches the export (`breast tenderness → cycle-related day → bloating → libido <value>`).
- **IIFE wrap** keeps the logic inline in the same array the other chips use — no new helper, no restructuring. If the pattern recurs later for another nested field, we can extract then.
- **No schema change**, no export change (export already works), no cache bump required beyond what the original ISO-48 commit already did (v8 → v9, now absorbed into the reorder as v9 with ISO-17 bumping from v8).

## Alternative considered

**Option B — ship the fix under ISO-51, leave ISO-48 as-is and re-QA.** Cleaner ticket-hygiene case (ISO-51 was filed specifically for the log-render gap), but the fix is identical either way, and splitting it makes ISO-48 gate on ISO-51 shipping first, which is pointless sequencing. Recommendation: ship under ISO-48, close ISO-51 as duplicate in the same commit.

## Out of scope

- **Styling the cycle-proxy chips distinctly** (color, icon). Other chips are flat-styled; no reason to distinguish cycle ones.
- **Mobile layout pass** for wide entry cards. The chips are flex-wrap already; four new chips fit in the same wrap pattern.
- **Backfill old chip-rendering tests.** No test suite to backfill; UAT covers log rendering.

## Verification plan (for QA re-run)

1. Fresh check-in with "Overall: today feels cycle-related" toggled ON; also toggle breast tenderness and bloating; leave libido at "same".
2. Go to Log → entry card for this check-in shows chips: `breast tenderness`, `cycle-related day`, `bloating` (no libido chip).
3. Seed a legacy entry via devtools: `cyclePhaseProxy: { moodShift: true }` → Log entry card shows `cycle-related day` chip (coalesce path).
4. Seed a legacy entry with `libido: 'higher'` → entry card shows `libido higher` chip.
5. Seed a neutral entry (`cyclePhaseProxy: {}` or absent) → entry card shows no cycle-proxy chips (no empty chip, no label).
6. Spot-check export: still reads `Cycle proxies: cycle-related day` for entries from step 1 and 3. Unchanged behavior.
7. No layout regression at 375×812 — chips wrap as before.

## Open questions for you

1. **Close ISO-51 in the same commit?** ISO-51 is the bug ticket for the underlying gap. Recommendation: yes — mention it in the commit message, then transition ISO-51 → Done with the same SHA in the post-push step. Keeps the audit trail tight.
2. **SW cache bump on the re-run?** The ISO-48 commit already bumped v8 → v9 (now v9 after the reorder-absorb). The AC-4 fix is additive to the same commit surface. If we fix-forward as a new commit on top, bump to v10; if we amend-rebase (discouraged per CLAUDE.md), keep v9. Recommendation: new commit, v9 → v10.
3. **Keep the existing ISO-48 commit (`6513dff`) or squash into the fix?** The existing commit is a clean rename; the fix adds log rendering. Recommendation: keep separate — two commits, two concerns. The reorder already shuffled history once; further churn is noise.

## Resolution (2026-04-20)

All three open questions decided by user:

1. **Close ISO-51 in the same commit** — yes. Commit message references ISO-51; post-push step transitions ISO-51 → Done with the same SHA.
2. **Cache bump** — v9 → v10 in this fix-forward commit. Discovery during execution: 6513dff's commit message claimed "SW cache bumped v8 → v9" but the diffstat showed only `index.html` + tickets doc touched — sw.js was already at v9 from `3552a35 ISO-13` and was never bumped by 6513dff. AC-7 was therefore unmet on the original commit; this fix-forward retroactively satisfies it.
3. **Keep 6513dff separate** — yes. Two commits, two concerns: rename (6513dff) and log-render + cache bump (fix-forward).

**Live verification passed** against Playwright-driven local build on 127.0.0.1:8765:

- Fresh check-in (`cyclePhaseProxy: { breastTender:true, cycleRelatedDay:true, bloating:true, libido:'same' }`) → chips: `breast tenderness`, `cycle-related day`, `bloating` (libido `same` suppressed as designed)
- Legacy `cyclePhaseProxy: { moodShift:true }` → chip: `cycle-related day` (coalesce path exercised)
- Legacy `cyclePhaseProxy: { libido:'higher' }` → chip: `libido higher`
- Neutral `cyclePhaseProxy: {}` → no cycle chips
- Neutral absent `cyclePhaseProxy` → no cycle chips
- Architecture invariant: `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty
- No console errors beyond the expected favicon 404

Export path at `index.html:1752-1761` was not modified — the legacy coalesce continues to work as before.

**Next steps outside this fix-forward commit:**

- Deviation comment posted on ISO-48 describing AC-4 closure via log-render and AC-7 closure via this commit's cache bump.
- Push blocked pending QA Pass per `feedback_push_gate.md`.
- ISO-51 transition to Done deferred until after QA Pass + push.
