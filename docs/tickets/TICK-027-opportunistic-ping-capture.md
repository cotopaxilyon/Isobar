---
id: TICK-027
title: Opportunistic location-ping capture
status: pending
priority: medium
wave: 9
created: 2026-04-20
updated: 2026-04-20
plan: docs/plans/PLAN_trigger_trap.md
test: null
linear:
  parent: ISO-61
  test: ""
depends-on: [TICK-026]
supersedes: []
shipped: ""
---

# TICK-027: Opportunistic location-ping capture

## Summary

Wire up foreground-only location sampling that writes a row to `locationPings` whenever the app is opened or the user transitions between certain views (morning check-in submit, episode-form open, Places view open, explicit "log location" tap). No background scheduler — the PWA has no service-worker geolocation. Requests geolocation permission on first use with a clear purpose prompt. Auto-creates an unnamed `places` row when a ping arrives further than `radiusM` from all known places. See `PLAN_trigger_trap.md` §Change 2 ("Places (persisted)" and "Place creation").

## Acceptance Criteria

- [ ] First-use permission prompt explains why location is requested and is dismissable without breaking the rest of the app
- [ ] Pings are written on: app open (if permission granted), morning-checkin submit, episode-form open, Places view open, manual "log location" button
- [ ] When a ping is outside `radiusM` of all known places, a new `places` row is created with `name: null`, `lat/lon` from the ping, `radiusM: PING_RADIUS_M_DEFAULT`
- [ ] User is not prompted to name the place at creation time (opt-in naming is a TICK-028 concern)
- [ ] Low-accuracy pings (e.g. `accuracyM > 200`) are still written but flagged for later filtering at query time; no client-side discard beyond that

## Agent Context

- Entire app is in `index.html`. Touch points: Dexie write wrapper, geolocation API call site (new), the view-transition hooks for the listed triggers.
- Use `navigator.geolocation.getCurrentPosition` with `{ enableHighAccuracy: false, timeout: 10000, maximumAge: 60000 }`. The opportunistic model does not need high accuracy — 75m default radius tolerates coarse samples.
- Do not write a ping on every render or every tick. The trigger list in the ACs is exhaustive.
- Permission denial path must not break any other feature.
- Bump SW cache version.

## Implementation Notes

Foreground-only sampling is the intentional trade-off from the opportunistic-ping model. Missed visits are fine — the plan's "observed dwell (lower bound)" framing in TICK-028 surfaces the gap honestly rather than pretending we have full coverage.

## Ship Notes

_(pending)_
