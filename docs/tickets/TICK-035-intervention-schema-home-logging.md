---
id: TICK-035
title: Intervention event schema + standalone home-screen logging + opportunistic strip
status: ready-for-qa
priority: urgent
wave: additive
created: 2026-05-01
updated: 2026-05-01
plan: docs/plans/PLAN_intervention_log.md
test: null
linear:
  id: ISO-97
  parent: null
  test: ""
depends-on: []
supersedes: []
shipped: ""
---

# TICK-035: Intervention Event Schema + Home-Screen Logging + Opportunistic Strip

## Summary

Adds a new `intervention_event` entry type and the two UI surfaces needed to log standalone interventions in real time: a third home-screen action card ("Took something") and an opportunistic effect-capture strip above the action grid. Covers Surface 1 and Surface 1a from `PLAN_intervention_log.md`.

Does **not** touch `startEpisode()`, `exportReport()`, or the log view — all existing readers tolerate the new type without modification (additive-only change). TICK-036 wires the episode wrap-up; TICK-037 adds log cards and export integration.

Origin: patient reports 2-3mg sublingual THC reliably aborts episodes. Current schema cannot distinguish a naturally-resolved episode from an intervention-aborted one, or surface dose-response patterns across episodes.

## Acceptance Criteria

### Schema
- [ ] New `intervention_event` entries write to `entry:<timestamp>` keys with the following shape:
  ```json
  {
    "type": "intervention_event",
    "timestamp": "<ISO string>",
    "episode_id": null,
    "category": "<string>",
    "specific": "<string>",
    "perceived_effect": null,
    "time_to_effect_min": null,
    "notes": "",
    "_promptDismissed": false
  }
  ```
- [ ] All fields except `timestamp` and `category` are optional; missing fields on load default gracefully

### Home-screen action card (Surface 1)
- [ ] Home grid has a third card "Took something" with sub-text *"Log meds, heat, anything"*, styled distinct from the episode button (e.g. accent color, not danger-red)
- [ ] Tapping opens the intervention form modal/view

### Intervention form
- [ ] **Timestamp** — defaults to now; exposed as a time picker
- [ ] **Category** — 10 horizontally-scrollable chips: `cannabinoid`, `mcas_rescue`, `gaba_agonist`, `muscle_relaxant`, `otc_analgesic`, `heat`, `hydration`, `rest_position`, `supplement`, `other`
- [ ] `heat` chip shows disambiguating sub-text: *"For heat used in response to symptoms. Routine heating pad use belongs in the morning check-in."*
- [ ] **Specific** — text input; on category selection, prefilled with most recent `specific` for that category (from `intervention:recent:<category>` storage key); up to 3 most-recent distinct specifics shown as quick-pick chips below the input; tapping a chip fills the input
- [ ] **Perceived effect** — 5 optional chips: *Stopped episode* / *Reduced pain* / *No change* / *Made it worse* / *Not sure*; section labeled *"What did you notice after?"*
- [ ] **Time to effect** — appears only when perceived effect is `stopped_episode` or `reduced_pain`; quick chips: 5 min / 15 min / 30 min / 60+ min; custom number input
- [ ] **Notes** — single-line free text, optional
- [ ] **Save** — writes the entry; updates `intervention:recent:<category>` with the new specific (keeping 3 most-recent distinct values); closes the form
- [ ] Save requires only timestamp + category; all other fields optional (P9)

### Opportunistic effect-capture strip (Surface 1a)
- [ ] On home-screen render, query for `intervention_event` entries where `timestamp ∈ [now − 120min, now] && perceived_effect === null && _promptDismissed !== true`
- [ ] If any match, render an inline strip above the action grid showing the most recent match: *"You logged [specific] at [HH:MM] — notice anything?"*
- [ ] Strip shows 5 effect chips (same labels as the form)
- [ ] Tapping an effect chip writes `perceived_effect` to that entry and, if the effect is `stopped_episode` or `reduced_pain`, renders inline quick-chips for time-to-effect (5 / 15 / 30 / 60+) before dismissing
- [ ] Tapping *"Not now"* sets `_promptDismissed: true` on that entry and dismisses the strip
- [ ] Strip is absent when no eligible interventions exist
- [ ] If multiple eligible interventions exist, only the most recent is shown at a time

### Backwards compatibility
- [ ] Existing code paths that filter `type === 'episode'` or `type === 'episode_v2'` are unaffected — intervention events are not picked up by those filters
- [ ] `exportReport()` runs without error with intervention events present in the store (they are simply not rendered yet — TICK-037 adds that)
- [ ] Log view renders without error (intervention events scroll past without a render path — TICK-037 adds cards)

### Cache
- [ ] SW cache version bumped in `sw.js` (new home-screen UI = shell asset change)
- [ ] Architecture check `grep -n '/Isobar/' sw.js manifest.json index.html` returns empty

## Agent Context

- **Additive only.** Do not modify `startEpisode()`, `exportReport()`, or any existing log-view render function. The backwards-compat ACs confirm existing paths are untouched.
- **`intervention:recent:<category>` storage** — a simple array of up to 3 strings, stored via Dexie (or the same storage layer as other settings). On save: prepend the new `specific`, deduplicate, trim to 3. On category select: read the array, prefill input with `[0]`, render `[0..2]` as chips.
- **Strip query is a live read on home render** — no separate index needed; the intervention event table will be small. Query by `type === 'intervention_event'`, filter by timestamp window and both conditions.
- **`episode_id: null`** is the correct default for all entries created by this ticket. TICK-036 writes the attachment; this ticket never sets it.
- **Form fits without scrolling on iPhone** — keep it tight. 10 category chips scroll horizontally, not wrapping.
- **Why no causal framing** — "What did you notice after?" and "Stopped episode" are observational language, per P4 and P7. Do not use verbs like "worked", "helped", "caused". Check copy against this before QA.

## Implementation Notes

- **Why a new entry type, not a field on episode:** a single episode can have multiple interventions; standalone (prodrome-aborted, preventive) interventions have no episode to attach to; each intervention needs its own timestamp for time-to-effect calculations. Mirrors the `motor_event` pattern.
- **Surface 2 (episode wrap-up)** and **Surface 3 (episode banner)** are deferred to TICK-036 and the Wave 2 phase restructure respectively. This ticket stops at the home-screen card and strip.
- **LOC estimate:** ~150-200 LOC — one form view, one strip component, one storage helper for recent-list management, SW cache bump.

## Test Sequence (user, during QA)

1. Home screen shows three action cards: Log Episode / Morning Check-in / Took something.
2. Tap "Took something" — form opens; timestamp defaults to now.
3. Select `cannabinoid` — input is empty (first use, no recall yet). Type "THC 2mg sublingual", save.
4. Open form again, select `cannabinoid` — input is prefilled "THC 2mg sublingual"; one quick-pick chip visible below.
5. Log a second cannabinoid entry with "THC 3mg sublingual" — next open shows prefill "THC 3mg sublingual" and two chips: 3mg, 2mg.
6. Home screen — strip appears above action grid: *"You logged THC 3mg sublingual at [time] — notice anything?"*
7. Tap "Stopped episode" — time-to-effect chips appear inline; tap "15 min" — strip dismisses.
8. Tap "Not now" on a fresh strip — strip disappears; does not reappear for that entry.
9. Intervention older than 120min — no strip.
10. Open log view — no errors, no blank cards for intervention entries.
11. Open exportReport — no errors; intervention events are invisible in the output (TICK-037 adds them).
12. Check SW version bumped — app reloads cleanly after install.

## Ship Notes

_(pending)_
