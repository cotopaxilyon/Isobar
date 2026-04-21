# TEST-028: Places view — stay reconstruction + three-way counter-example split

Parent: TICK-028
Plan: `docs/plans/PLAN_trigger_trap.md`

Test window assumes ≥5 reconstructed stays at one place and at least one episode logged; use fixture pings if needed.

## TC-1: Empty state

- [ ] Fresh install (no pings, no places): Places view opens, shows an empty-state message ("No places yet — start moving around or tap 'Log location' to seed pings")
- [ ] No stay rows rendered; no crash

## TC-2: Three-way counter-example split rendering

- [ ] Place with ≥5 stays and mixed outcomes: header shows "{N} stays" with three sub-counts (episode / aborted / clean) that sum to N
- [ ] Episode association correct: a stay whose window (stay start → stay close + 48h) contains an `ictal_onset` counts as "episode"
- [ ] Aborted-event association correct: same window containing only aborted events counts as "aborted"
- [ ] Clean stays are the remainder (neither episode nor aborted in the 48h window)

## TC-3: "Not enough data yet" threshold

- [ ] Place with 1–4 stays: renders "Not enough data yet for a base-rate view (minimum 5)" — no ratio, no counts split
- [ ] Place with exactly 5 stays: three-way split begins rendering (threshold inclusive)

## TC-4: Observed-dwell lower-bound framing

- [ ] Each listed stay shows "observed dwell (lower bound)" with the computed span
- [ ] No bare duration claim anywhere in the stay rows
- [ ] Disclaimer text appears next to or under each stay row

## TC-5: Rename (opt-in naming)

- [ ] Unnamed place renders as "Place near (lat, lon)" with coords rounded to 3 decimals
- [ ] Tapping rename opens a text input; entering a name + confirming updates the place's `name` field
- [ ] Canceling the rename leaves the place unnamed
- [ ] Rename persists across reload

## TC-6: Adjust radius

- [ ] Radius control is reachable from the place row
- [ ] Changing radius updates `place.radiusM` in Dexie
- [ ] Next render of the view reflects the new radius in reconstructed stays (stays may regroup)

## TC-7: Merge

- [ ] Selecting two places and tapping merge presents a confirmation with which name to keep
- [ ] On confirm: one place remains with the chosen name, coords of the kept place; the other place record is deleted
- [ ] Pings previously attributed to either place now cluster against the merged place on next reconstruction

## TC-8: Delete

- [ ] Delete action presents a confirmation ("Pings will be kept; the place label will be removed")
- [ ] On confirm: `places` row removed
- [ ] `locationPings` rows untouched
- [ ] Next out-of-radius ping re-creates an unnamed place at that location

## TC-9: Naming entry-point exclusivity

- [ ] No place-name prompt appears anywhere in the app other than the Places view (morning check-in, episode form, manual location log should all be silent)

## TC-10: Persistence across reload

- [ ] Rename, radius change, merge, delete all survive a full page reload
- [ ] Stay reconstruction output is stable for identical ping sets (same inputs → same stays)
