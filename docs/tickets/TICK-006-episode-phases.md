---
id: TICK-006
title: Episode phase restructure
status: pending
priority: high
wave: 2
created: 2026-04-15
updated: 2026-05-03
plan: docs/plans/PLAN_episode_phases.md
test: null
depends-on: [TICK-004, TICK-005]
supersedes: ["UPDATES #5 episode end time", "UPDATES #7 sensations energy/restless", "UPDATES #8A episode functional impact", "UPDATES #8C muscle event severity", "UPDATES #10 muscle event quick log"]
shipped: ""
---

# TICK-006: Episode Phase Restructure

## Summary

Replace the single "Log Episode" button with phase-based logging (prodrome → per-spasm → postictal) matching standard neurology terminology. Unifies standalone muscle events and in-episode spasms into one `motor_event` data shape. Adds the "It's over" postictal wrap-up (replaces UPDATES #5 episode end time). Adds `episodeImpact` functional scale (replaces old episode severity).

This is the largest architectural change in the project — it absorbs five old UPDATES items.

## Pre-implementation reconciliation (2026-05-03)

The following items from the original scope shipped piecemeal before this ticket was started. Do not re-implement.

- ✅ Prodrome timing inputs (`prodromeTime`, `firstJerkTime`) — in current `EP_STEPS[0]`
- ✅ Prodrome symptom selection — in current `EP_STEPS[1]`
- ✅ Auto-fasting computed from `meal:last` at prodrome onset — `index.html` lines ~1312–1322
- ✅ Exposure Tier 1 fully shipped: `weather`/`new_env` retired; `directional_cold_airflow`, `prolonged_stillness`, `sleep_disruption`, `stress_acute`, `stress_chronic` present in `exposureOpts`; `substance24h` as separate yes/no with note field
- ✅ Communication level, body map pain regions, sensations, overall severity — all in current `EP_STEPS`
- ✅ Export already reads `motor_event` collection (line ~1899)

**TICK-036 interaction:** if TICK-036 (episode wrap-up intervention review) ships before this ticket, Wave 2 scope expands by one item: migrate the legacy episode wrap-up intervention step (Surface 2 in `PLAN_intervention_log.md`) into the active-episode banner's "Took something" button (Surface 3). Same data shape; surface change only. Add to AC at that time.

## Acceptance Criteria

- [ ] Home screen replaces the single `startEpisode()` button with three buttons: "Warning starting" (prodrome), "Log a spasm" (per-event), "It's over" (postictal)
- [ ] Per-spasm button logs individual motor events with body region, intensity (TWITCH / MILD / MODERATE / STRONG / SEVERE), and duration; works both inside and outside an active episode
- [ ] Spasm data shape (`motor_event`) is shared between standalone twitches and in-episode spasms
- [ ] Active episode card on home screen with running timer (auto-dismisses after 4h)
- [ ] "It's over" opens postictal wrap-up: `episodeImpact`, standing/legs assessment, stiffness regions, care-seeking boolean
- [ ] Episode duration calculated from first spasm timestamp to "It's over" end time
- [ ] Old episode entries render without error (no `episodeImpact` → show no impact chip)
- [ ] Export includes per-episode spasm count/detail and PSFS grade

## Agent Context

- Entire app is in `index.html`.
- Full design spec in `PLAN_episode_phases.md` — all 8 open questions resolved.
- Motor event severity: 5-level scale TWITCH / MILD / MODERATE / STRONG / SEVERE (per Gap 2 resolution in consolidated plan).
- SEVERE = physical intensity only ("worst I get — full-body lock or loss of control"). Care-seeking is a separate boolean (per Gap 3 resolution).
- Postictal motor assessment: standing-up scale, legs-after-standing scale, stiffness regions (per Gap 6 resolution).
- Internal data tag: `motor_event` (diagnosis-neutral). UI label: "spasm" (clinically aligned with SPS literature).
- Bump SW cache version.

## Implementation Notes

The consolidated plan (memory: project_consolidated_plan.md) resolves all cross-cutting decisions. Key ones for this ticket:
- Body map (18-region grid from TICK-002) and spasm chips (10-chip list) are **two separate surfaces** — don't unify.
- Fasting hours: computed only, no manual override on episode form. Fix at source via meal card "Edit time."
- Export splits motor activity into four buckets: per-episode spasms (PSFS-graded), sub-spasm twitches (count only), inter-episode motor activity, standalone spasms.

## Ship Notes

_(pending)_
