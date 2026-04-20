---
status: pending-review
ticket: ISO-47
title: TICK-013: Morning irritability block (Part A1)
picked_at: 2026-04-19
decision: bail-out
critic_agreement: true
---

# ISO-47 — autopilot bail-out

**Ticket:** [ISO-47 / TICK-013](https://linear.app/isobar/issue/ISO-47/tick-013-morning-irritability-block-part-a1)
**Dossier:** [`ISO-47.dossier.json`](./ISO-47.dossier.json)
**Critic verdict:** [`ISO-47.critic.json`](./ISO-47.critic.json) (agreement: true)

Autopilot picked this ticket (oldest Backlog `agent-ok` without `agent-blocked` / `needs-human-review`), ran the adversary and critic passes, and bailed before writing any code. Critic independently agreed with the bail-out. No runtime code touched; only the three artifacts under `docs/autopilot/` were created.

## Why bail-out

Three independent scope-gate rules fail. Any one would be sufficient.

### 1. Tracked-field addition — scope rule `PLAN_autopilot_harness.md:87`

The rule says autopilot bails when a change "adds a tracked field." AC#6 of the ticket reads verbatim: *"Stored on the check-in record as `irritabilityLevel` (`normal | edgy | overload | snap_line`) and `morningIrritabilityExternalObservation` (`yes | no | no_one_around`)"*. AC#7 adds `ciData` defaults for both. That is two new tracked fields on the persisted check-in record defined at `index.html:1320-1337`.

The ticket's own framing of "new fields only; no schema migration" does not re-classify this — the harness rule keys on *adding a tracked field*, not on whether a migration script is required.

### 2. Ticket miscitation at `index.html:1624`

Agent Context line 45 directs the executor to *"add an irritability chip mirroring the communication chip when `irritabilityLevel` is set"* at `index.html:1624`. That line is inside the stats `recent-ep` block, which iterates `eps = entries.filter(e => e.type === 'episode')` (`index.html:1605`). `irritabilityLevel` is a check-in field, not an episode field, so any edit placed at `:1624` is unreachable. The intended render site is not specified unambiguously; an executor would have to guess.

### 3. AC#1 DOM placement is ambiguous

AC#1 says the new block renders *"below the communication options in the Communication step."* Agent Context line 41 says *"add the new block after the existing `<div class=\"section\">` that holds the external-observation prompt"* — i.e. below the existing externalObservation Y/N/No-one-around toggle, not between the two. Both orderings satisfy AC#1 literally. The DOM order is a UX flow judgment reserved for the user's UAT, per `PLAN_autopilot_harness.md:89`.

## Flag-severity observation (not blocking)

TICK-014 / ISO-48 is a sibling Stage 1 ticket drafted the same day. It renames `cyclePhaseProxy.moodShift` (touched at `index.html:1333`, `1459`, `1722`). TICK-013 does not touch `moodShift` by design, but the two tickets are in the same milestone with no ordering guarantee. Whichever ships second will rebase over the other's export branch changes. Recorded for the reviewer's sequencing decision.

## Proposed follow-up for the human reviewer

The ticket is well-specified but belongs in the human-driven path, not the autopilot path. Options:

1. **Drop `agent-ok` and ship via normal flow.** Most conservative. The Stage 1 irritability block is the first new tracked field since the Stage 0 persistence floor closed — worth a manual pass on the schema wording and the DOM placement before it lands.
2. **Re-scope the ticket.** Split the "log card + export render" work from the "new field + new DOM block" work. The render-only half might meet the autopilot scope shape; the field-addition half never will.
3. **Fix the miscitation and the AC ambiguity, keep `agent-ok`.** Tighten AC#1 to name the exact DOM position (e.g. *"directly after the four communication-level buttons and before the externalObservation section"*). Drop the `:1624` edit from Agent Context or re-point it at the correct check-in render path. Even with those fixes, the tracked-field rule still trips bail-out under the current harness — either the harness rule needs a carve-out (which is a PLAN change, not a ticket change), or the ticket moves to the manual path.

## What autopilot did this run

- Activated autopilot mode.
- Queried Linear, picked ISO-47 (oldest Backlog `agent-ok`).
- Ran adversary pass → 0 block, 3 escalate, 1 flag.
- Wrote `ISO-47.dossier.json` with `decision: bail-out`; validator passed.
- Ran critic pass → `agreement: true`, `critic_decision: bail-out`; validator passed.
- No code written, no commits, no pushes. Linear state transitioned to `agent-blocked` via label.
- Linear comment posted linking these three artifacts.
