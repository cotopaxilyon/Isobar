---
finding-type: observed-defect
tracked-in: pending    # Bug 1 + Bug 2 fixes pending ticket creation
remediation-landed:
  - "docs/ARCHITECTURE.md §4 — orphan-write grep (narrow form)"
  - "docs/ARCHITECTURE.md — 'Preference: derive live, don't cache'"
  - "docs/PLAN_REVIEW.md Q29 — absence-of-side-effect AC needs paired visibility AC"
  - ".claude/commands/autopilot-adversary.md — single orphan-write mechanical check"
remediation-retracted:
  - "Data-shape contract ticket-template field (original Mechanic #3)"
  - "PLAN_REVIEW.md Q28–Q31 invariant-enumeration suite (original Mechanic #1)"
  - "ARCHITECTURE.md Derived Fields ledger (original addendum §B)"
  - "Findings-to-ticket gate (original Mechanic #5) — downgraded to optional convention"
  - "pending-reader: ISO-NNN marker machinery (original addendum §C)"
  - "autopilot-adversary.md ledger-row and findings-tracker auto-escalates"
---

# State-Coherence Postmortem: Two Meal Bugs, and Where Else the Same Class May Hide

A writeup for a reader with no prior context. This document was originally circulated on 2026-04-22 with a five-mechanic process-remediation suite. A critical re-evaluation on the same day (see §Critical revision below) retracted most of that suite in favour of a smaller set of changes the evidence actually supports. What stayed, what went, and why — documented below so the decision is auditable.

---

## What shipped

Two live defects in the meal-logging path of `index.html` on `main`. Both were detected by the external testing agent on 2026-04-22 while trying to reproduce a user-reported symptom ("I logged a meal and the card didn't reflect it"). Both have been live for a week or more. Both passed through every UAT session that touched the meal card.

### Bug 1 — `meal:last` overwritten out of chronological order

`saveMeal` at `index.html:2288-2290` executes:

```js
await DB.set(`meal:entry:${newTsMs}`, { timestamp: ts.toISOString(), type: 'meal', mealSize: size });
const existing = (await DB.get('meal:last')) || {};
await DB.set('meal:last', { ...existing, timestamp: ts.toISOString(), type: 'meal', mealSize: size });
```

The `...existing` spread is performative. Every field that matters — `timestamp`, `type`, `mealSize` — is overwritten on the very next line by whatever the user just saved. There is no comparison against the previous `meal:last.timestamp`. So logging breakfast at 8 AM *after* logging lunch at 12 PM silently replaces lunch as the "latest" meal on the home card, even though lunch is still present in `meal:entry:*` history.

The datetime picker at `index.html:2253` is the affordance that made this a common case, not an edge case — it literally invites the user to pick any time in the last 24 hours.

Bug introduced by commit `c7d0335` (2026-04-16, *TICK-004: derived fasted-hours from meal history*). That commit added `meal:entry:*` as a parallel history alongside `meal:last` but did not update `saveMeal` to preserve the implied invariant.

### Bug 2 — `meal:last_drink` is a write-only key

`saveMeal` at `index.html:2278`:

```js
await DB.set('meal:last_drink', { timestamp: ts.toISOString(), type: 'meal', mealSize: 'drink' });
showToast('Drink logged ✓');
```

`grep -c "meal:last_drink" index.html` returns `1`. There is no read site anywhere in the codebase. A drink log writes a success toast, persists a record nothing consumes, and is functionally invisible to every downstream surface — home card, episode snapshots, export, fasting calculations, suggestion engine.

Bug introduced by commit `a6da7be` (2026-04-15, *Ship Waves 2–5*). The branch was a deliberate choice — drinks should not reset the fasting clock — but the implementation stopped at the write and never wired a corresponding read. The TICKET-3 findings report on 2026-04-15 names the key explicitly (*"Drink does not reset fasting clock (writes to `meal:last_drink`, not `meal:last`)"*) as verified behavior.

The specific failure mode around this finding is **AC satisfaction treated as investigation closure.** The TICKET-3 AC tested a narrow behavior ("drink doesn't reset the fasting clock"); the observed behavior matched; the parenthetical got recorded as supporting detail; no one asked the follow-up question *"who reads this?"*. The localStorage inspection at the time confirmed the write key and stopped there — because the AC was about the absence of a reset, not about the visibility of the drink log. Had the AC included the read-side clause ("the drink log is captured and surfaced somewhere the user sees"), the orphan would have been the gate on passing the AC, and the bug would not have shipped.

### Downstream impact — corrected scope

An initial reading of this incident held that Bug 1 corrupted every read site of "the most recent meal," including the episode export's `liveMeal` fallback at `index.html:1757`. Direct code inspection proves otherwise: the `liveMeal` reference is the result of `findMealForEpisode(e.timestamp)`, and `findMealForEpisode` at `index.html:2214-2226` is already a max-by-timestamp scan over `meal:entry:*` — it queries the history, not `meal:last`. The episode export path, fasting calculations (`fastedHoursFor`), and episode-logging context (`index.html:1265-1266`) are all **unaffected** by Bug 1. They already use the derive-live pattern.

The full read-site audit for `meal:last`:

| Line | Use | Affected by Bug 1? |
|------|-----|---|
| 2207 | `migrateMealsToHistory` seeds `meal:entry:*` on first run (idempotent) | No |
| 2237 | Edit-mode prefill in `logMeal(true)` | Yes — consequence of 2362's display being wrong |
| 2289 | `saveMeal`'s own buggy `existing` spread | Is the bug |
| 2290 | `saveMeal`'s overwrite | Is the bug |
| 2362 | `renderMealCard` home-card display | Yes — the primary symptom |

Bug 1's impact is confined to the home meal card and its edit prefill. This is a mitigating factor for severity — and, more importantly, it is **also the template the fix should follow**, because the derive-live pattern is already in the codebase; applying it to the last two read sites is a code consolidation, not a new architecture.

---

## Root cause — three distinct modes, not one

The original draft of this document framed both bugs under a single root cause (*the derivation rule was left in the author's head*). The critical revision split that frame because the two bugs and the UAT miss have genuinely different shapes and call for different remediations.

**Bug 1 — unnamed-invariant miss (structural).** The `meal:last` / `meal:entry:*` relationship introduced in TICK-004 was never written down as a reviewable object. Downstream affordances (datetime picker, edit link) extended the feature without revisiting a contract that had no artifact to revisit. The fix for Bug 1 — *drop `meal:last`, derive live from `meal:entry:*`* — doesn't name the invariant, it dismantles the cache that required the invariant to exist. This dissolution, not a new process gate, is the real structural remediation. If the codebase shouldn't have snapshots drifting from histories, the leverage is a modeling preference: *derive live, don't cache*.

**Bug 2 — completion-discipline miss (attention).** The TICKET-3 findings report on 2026-04-15 wrote down in plain prose that `meal:last_drink` was a dead write. The information existed, was legible, and still shipped. No one — author, reviewer, tester — asked *"so what reads it?"*. Adding process machinery to force a review of one's own findings docs is a band-aid over attention, not structural repair. The mechanical defence that *does* survive this argument is the orphan-write grep: a literal storage key with no reader is a shape a computer can check in four seconds, and that check runs cheaply enough to keep.

**Both bugs — testing-coverage miss (co-equal on the Isobar side).** Either bug dies to a two-minute smoke test. *Log breakfast at 8 AM after logging lunch at noon; does the home card show lunch?* (Bug 1). *Log a drink; does anything, anywhere, change visibly?* (Bug 2). That no one ran these tests after TICK-004 and TICKET-3 shipped is the UAT-coverage half of this incident. The original draft positioned this as the testing agent's concern and framed the Isobar-side issue as structural; the honest reading is that testing coverage and structural miss are co-equal contributors, and the postmortem initially under-weighted the testing half.

---

## Critical revision — what the original draft got wrong

The original draft proposed a five-mechanic remediation suite:

1. `PLAN_REVIEW.md` Q28–Q32 — a five-question invariant-enumeration pass
2. `ARCHITECTURE.md §4` — orphan-write grep with `pending-reader: ISO-NNN` marker machinery
3. `PROCESS.md` ticket-template *Data-shape contract* field + `/autopilot` adversary gate
4. `CLAUDE.md` cross-reference to the testing agent's state-coherence protocol
5. `PROCESS.md` findings-to-ticket gate (added in addendum §A)

Plus a `Derived Fields` ledger in `ARCHITECTURE.md §5` (added in addendum §B) and marker-aware grep with stale-age check (addendum §C).

Three observations about that suite, on re-evaluation:

**The Bug 1 fix retroactively undermines half the machinery.** The action-item fix for Bug 1 is *drop-and-derive* — delete `meal:last`. If drop-and-derive is the correct remediation, then the lesson is *don't introduce derived caches without justification* (a modeling preference, in one paragraph), not *enumerate and track every derived-field invariant at every handoff* (five mechanics and a ledger). Mechanics #1, the ledger, and the data-shape-contract field all exist to manage the complexity of derived caches; the fix itself is dismantling those caches. Keeping that machinery is paying process cost forever to track artifacts we're simultaneously agreeing to remove.

**Bug 2's class is discipline, not structure.** Mechanic #5 (findings-to-ticket gate) codifies "we will read our own findings docs for contract violations" — a band-aid over attention rather than a structural repair. The mechanical check that genuinely catches Bug 2's shape is the orphan-write grep, because it runs without requiring anyone to read anything. The plan-review Q about paired visibility ACs (original Q32, new Q29) is also a survivor — it would have caught the AC-shape problem at authoring time, and it's a single question rather than a suite.

**Proportionality is never challenged.** Five mechanics + a ledger + marker-aware grep + ticket-template field + findings-to-ticket gate is a lot of process machinery for two bugs in a solo-dev PWA. Redundancy across handoff artifacts sounds defensible until you count the per-ticket cost. For a one-person project, "grep more carefully after shape-change commits, plus one cheap CI-style check" dominates the five-mechanic solution on cost/benefit.

These three observations drive the retractions documented in the frontmatter. The remediation list below is what survives.

---

## Remediation — what actually landed

### Kept (three survivors)

1. **`ARCHITECTURE.md §4` — orphan-write grep (narrow form).** A literal storage key with no reader is a shape a script can check in a few seconds. The marker machinery (`pending-reader: ISO-NNN`, stale-age checks) was retracted because it's scaffolding for a workflow the project doesn't have; the unmarked form is sufficient. Against current `main`, the check prints `meal:last_drink` as the only orphan, which is Bug 2.

2. **`ARCHITECTURE.md` *Preference: derive live, don't cache*.** One paragraph, not an invariant. States the modeling lesson from Bug 1: when a history and a cached summary of it coexist, prefer to drop the cache and derive live. Makes stale-cache bugs structurally impossible rather than process-policed. Replaces the *Derived Fields* ledger — ledgers track caches; preferring not to have caches makes the ledger empty by construction.

3. **`PLAN_REVIEW.md` Q29 — absence-of-side-effect AC needs paired visibility AC.** The single sharpest insight from this incident. An AC of the form *"X does not reset Y"* tells the reviewer what to check for but not what to check for the *presence* of. When the absence is satisfied by writing to a new storage key, the paired AC must cover what surface the new key shows up on. This is one question, enforceable by human reading, no machinery required.

### Also landed

- **`PLAN_REVIEW.md` Q28 — storage-key reader landing.** Narrower than the original Q28. Flags if a plan writes to a new key whose reader doesn't land in the same ticket. Backed by the ARCHITECTURE.md §4 grep; the plan-review question is the human-readable half.
- **`PROCESS.md` findings-doc convention.** Note the tracking ticket at the top of an observed-defect findings doc as a navigation convenience. Explicitly not a gate.
- **`autopilot-adversary.md` single mechanical check.** The orphan-write grep on the proposed diff. The three-gate suite was retracted.

### Retracted

- **`PLAN_REVIEW.md` Q30, Q31** — derived-field and out-of-order-affordance enumeration. Obviated by the *derive-live* preference; if caches are the exception rather than the default, the enumeration's baseline cost isn't justified.
- **Original Q28–Q29** — the full storage-key/write-site/read-site enumeration. Collapsed into the narrower new Q28.
- **`PROCESS.md` ticket-template *Data-shape contract* field.** Every ticket paying authoring cost to document a contract that in most cases is *n/a* is worse than letting the orphan-write grep catch the minority of tickets where it would have mattered.
- **`PROCESS.md` *Before agent-ok* Data-shape-contract bullet.** Replaced with a shorter bullet pointing at the ARCHITECTURE §4 grep.
- **`autopilot-adversary.md` three-gate mechanical checks** — Data-shape-contract-filled, ledger-row, findings-tracker. Replaced by the single orphan-write check. The findings-tracker gate was the clearest band-aid-over-attention of the three.
- **`ARCHITECTURE.md §5` Derived Fields ledger.** Replaced with the *derive-live* preference. The ledger's maintenance cost (updating a table on every derived-field change) compounded with a preference that would keep the table small by design.
- **`pending-reader: ISO-NNN` marker machinery and stale-age check.** Premature sophistication; no current ticket ships a deferred-reader scaffold, so the marker is a tool without a use case.

### Not pursued

- **CLAUDE.md cross-reference to testing-agent state-coherence protocol (original Mechanic #4).** Still pending on the testing agent's side; revisit when their protocol ships. The cross-reference itself is low-cost and remains a reasonable follow-up.

---

## Where else in the codebase this class may be hiding

Unchanged from the original draft. None is confirmed broken; each warrants a targeted pass before the next ticket lands on it. The *derive-live* preference is the lens for the pass — if a candidate surface has a snapshot cell alongside a history family, the question is "should this cache exist at all?" before "does the invariant hold?"

### Candidate 1 — the two remaining read sites of `meal:last`

`index.html:2237` (edit-mode prefill) and `index.html:2362` (home card render). Both will be fixed by the drop-and-derive direction in the action items below — each gets replaced with a call to a `mostRecentMeal()` helper that scans `meal:entry:*` the same way `findMealForEpisode` already does. Audit is mechanical: grep for every remaining `meal:last` reference, confirm each one reads from the helper or is dead.

### Candidate 2 — the migration path in `migrateMealsToHistory` (`index.html:2204-2212`)

The migration skips drinks when seeding `meal:entry:*` from `meal:last`:

```js
if (last && last.timestamp && last.mealSize && last.mealSize !== 'drink') {
  const tsMs = new Date(last.timestamp).getTime();
  if (!isNaN(tsMs)) await DB.set(`meal:entry:${tsMs}`, ...);
}
```

Pre-TICK-004, drinks were written to `meal:last`. The migration does not carry them into history. Post-TICK-004, new drinks go to the dead `meal:last_drink` key. Net effect: any historical drink log is silently dropped from the new model, and any post-migration drink log is silently not retained at all. Revisit in the Bug 2 ticket.

### Candidate 3 — episode edits and derived episode fields

`index.html:1337` writes `entry:*` keys for episodes. If the UI exposes an edit link on a logged episode, any field derived from the episode set could drift from its source the same way `meal:last` did. The `entry:*` family today appears to be append-only from the paths reviewed. Verify explicitly rather than assume. TICK-016 ("recent-episodes-stale-after-clear") is adjacent.

### Candidate 4 — backup/snooze state

`backup:lastAt` (written at 1931, read at 1870) and `backup:snoozedUntil` are single-cell timestamps with one writer each. Structurally simple — no history family they cache, so the *derive-live* preference doesn't apply. Listed only to confirm the audit was completed.

### Candidate 5 — any future ticket that adds a "latest X" caption

The *derive-live* preference is the audit rule here. Any ticket whose AC includes language like *"show the most recent X"*, *"display the latest Y"*, *"current Z summary"* should answer "does this require a cache, or can the summary be derived at render time?" before it writes any storage code. The EOD block, the export window split, and the Places pings schema (TICK-026 / TICK-028) are candidates.

---

## Action items (Isobar side, tracked separately)

### Bug 1 fix — drop-and-derive

Drop `meal:last` entirely. The derive-live helper already exists at `index.html:2214-2226` (`findMealForEpisode`).

1. Add a `mostRecentMeal()` helper (or reuse `findMealForEpisode(new Date())` directly).
2. Replace `DB.get('meal:last')` at `index.html:2237` (edit prefill) and `index.html:2362` (home card render) with the helper.
3. Remove the `meal:last` writes in `saveMeal` at `index.html:2289-2290`.
4. Remove `migrateMealsToHistory`'s seed logic after a transition period.
5. Do not touch `findMealForEpisode` or its callers — already correct.

After this change, the codebase is internally consistent: every meal-data read derives live, no snapshot-plus-history invariant exists to maintain, Bug 1 is impossible to reintroduce because there is no cache to write stale data to.

### Bug 2 fix — wire a reader or remove the write

Either (a) expose the drink log on a user-visible surface (drinks-today count on the meal card, a drinks list in the log view, or an export section), or (b) remove the write and the drink branch of the UI that produces it. Don't ship a success toast for an action with no effect. Revisit the migration-skip at `index.html:2208` in the same ticket.

### Process-change follow-ups

Already landed per the *Remediation* section above. No further doc edits pending. When the testing agent's state-coherence protocol ships, add the cross-reference in `CLAUDE.md` (the lone surviving item from the original Mechanic #4).

---

## Cross-references

- Testing-agent bug write-up: `Dolly-Isobar/tests/client-isobar/uat-writeups/BUG-meal-last-overwrite-out-of-order.md`
- Testing-agent process proposal (sibling): `Dolly-Isobar/proposals/2026-04-22_internal_state-coherence-testing-gap.md`
- UX postmortem with shared-root-cause structure: `docs/findings/FINDINGS_2026-04-21_ux_postmortem_backup_card_cycle_toggle.md`
- Architecture invariants: `docs/ARCHITECTURE.md` §4 (named readers), *Preference: derive live, don't cache*
- Plan-level review: `docs/PLAN_REVIEW.md` §*Data-shape invariants*
