---
id: TICK-006
title: Episode phase restructure + exposure tier 1
status: pending
priority: high
wave: 6
created: 2026-04-15
updated: 2026-04-15
plan: docs/plans/PLAN_episode_phases.md
test: null
depends-on: [TICK-004, TICK-005]
supersedes: ["UPDATES #5 episode end time", "UPDATES #7 sensations energy/restless", "UPDATES #8A episode functional impact", "UPDATES #8C muscle event severity", "UPDATES #10 muscle event quick log"]
shipped: ""
---

# TICK-006: Episode Phase Restructure + Exposure Tier 1

## Summary

Replace the single "Log Episode" button with phase-based logging (prodrome → per-spasm → postictal) matching standard neurology terminology. Unifies standalone muscle events and in-episode spasms into one `motor_event` data shape. Adds the "It's over" postictal wrap-up (replaces UPDATES #5 episode end time card). Adds `episodeImpact` functional scale (replaces old episode severity). Adds Tier 1 exposure chips to the episode form.

This is the largest architectural change in the project — it absorbs five old UPDATES items.

## Acceptance Criteria

- [ ] Home screen shows three buttons: "Warning starting" (prodrome), "Log a spasm" (per-event), "It's over" (postictal)
- [ ] Prodrome flow captures prodromal symptoms with timestamps
- [ ] Per-spasm button logs individual motor events with location, intensity (5-level TWITCH→SEVERE), duration
- [ ] Spasm data shape is shared between standalone muscle events and in-episode spasms
- [ ] "It's over" opens postictal wrap-up: `episodeImpact`, cane use, standing/legs assessment, stiffness regions, care-seeking boolean
- [ ] Episode duration calculated from first spasm to end time
- [ ] Active episode card on home screen with running timer (auto-dismisses after 4h)
- [ ] Exposure Tier 1 chips on episode form: retire `weather`/`new_env`, add `prolonged_stillness`, `sleep_disruption`, `directional_cold_airflow`, `substance24h`, split `stress`
- [ ] Auto-fasting computed from `meal:last` at prodrome onset
- [ ] Old episode entries render without error (no `episodeImpact` → show no impact chip)
- [ ] Export includes per-episode phase metrics and spasm detail

## Agent Context

- Entire app is in `index.html`.
- Full design spec in PLAN_episode_phases.md — all 8 open questions resolved.
- Motor event severity: 5-level scale TWITCH / MILD / MODERATE / STRONG / SEVERE (per Gap 2 resolution in consolidated plan).
- SEVERE = physical intensity only ("worst I get — full-body lock or loss of control"). Care-seeking is a separate boolean (per Gap 3 resolution).
- Postictal motor assessment: standing-up scale, legs-after-standing scale, stiffness regions (per Gap 6 resolution).
- Internal data tag: `motor_event` (diagnosis-neutral). UI label: "spasm" (clinically aligned with SPS literature).
- This ticket depends on TICK-004 (exposure rename) and TICK-005 (morning checkin) being shipped first.
- Bump SW cache version.

## Implementation Notes

The consolidated plan (memory: project_consolidated_plan.md) resolves all cross-cutting decisions. Key ones for this ticket:
- Body map (18-region grid from TICK-002) and spasm chips (10-chip list) are **two separate surfaces** — don't unify.
- Fasting hours: computed only, no manual override on episode form. Fix at source via meal card "Edit time."
- Export splits motor activity into four buckets: per-episode spasms (PSFS-graded), sub-spasm twitches (count only), inter-episode motor activity, standalone spasms.

## Ship Notes

_(pending)_
