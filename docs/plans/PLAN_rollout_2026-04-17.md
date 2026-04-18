---
status: active — sequencing plan for the post-irritability-critical-review queue
created: 2026-04-17
supersedes: any prior informal ticket ordering since the irritability plan refold
---

# PLAN: Rollout Sequencing (post-critical-review, 2026-04-17)

## Purpose

Coordinate the currently-open planning docs into a single shippable order. Produced after the 16-item critical-review walkthrough of `PLAN_irritability_and_severity_mapping.md` locked a number of structural changes that interact with the morning-check-in and episode-phases plans already in the pipeline.

This doc is the sequencing spec. Individual plans remain the source of truth for WHAT to build; this doc answers WHEN.

## Plan inventory (as of 2026-04-17)

| Plan | Status | Role in rollout |
|---|---|---|
| `PLAN_environmental_risk.md` | ✅ shipped 2026-04-15 (UAT 30/30 PASS) | Done; its three-axis output feeds downstream ticket composites |
| `PLAN_morning_checkin.md` | Ready for implementation (all 5 design questions resolved) | TICK-005 (Wave 1) |
| `PLAN_episode_phases.md` | Ready for implementation (all 8 open questions resolved) | TICK-006 (Wave 2) |
| `PLAN_irritability_and_severity_mapping.md` | Ready for implementation — critical review COMPLETE (16 items) 2026-04-17 | Split across Stage 0 precursor + Waves 1, 2, 3, 4 below |
| `PLAN_trigger_surface_expansion.md` | Planning phase — awaiting user scope decision on Tier 1 | Can slot into Wave 2 if decided; otherwise defer |
| `PLAN_autopilot_harness.md` | Paused on Playwright MCP tooling gap (§6) | Out-of-band operational tool; not on this rollout |
| `UPDATES.md` | Meta-document | Items 1–9 shipped or folded into tickets; Item 10 folded into TICK-006 |

## Completed (reference)

| Ship date | Deliverable |
|---|---|
| 2026-04-14 | UPDATE-1 (communication scale revision) |
| 2026-04-15 | ENV-RISK — three-axis environmental risk surface |
| 2026-04-16 | TICK-004 — exposure rename (exposures-not-triggers framing) |

---

## Hard precursor

### Stage 0 — Data persistence hardening (NEW TICKET — call it `TICK-009-persistence` or `PRECURSOR-001`)

**From `PLAN_irritability_and_severity_mapping.md` critical-review Items 1+2.**

Migrate from `localStorage` to **Dexie.js** (IndexedDB wrapper) + enable `navigator.storage.persist()` + add weekly auto-prompt to export full JSON via Web Share API → user saves to iCloud Drive + add "Import from JSON" button in settings for recovery.

**Why this must ship before everything else:**

- localStorage cap (~5 MB) will fill as evening check-in data + behavioral anchors + load tracking accumulate.
- iOS Safari's 7-day eviction policy for unused PWA sites will eventually destroy the dataset.
- Waves 1–4 all accumulate more data. Shipping them against the current storage layer builds technical debt that compounds.

**Scope:**
- Dexie schema wrapper for existing entry types (`checkin`, `episode`, `spasm`, settings blobs).
- `navigator.storage.persist()` call during app init; graceful degradation if denied.
- Web Share API integration for weekly JSON export; reminder card on home screen (dismissible).
- Import-from-JSON flow in settings with schema-version compatibility checks.

**Rejected:**
- Dexie Cloud (not E2EE by default, single-maintainer commercial, no HIPAA compliance).

**Estimate:** 1–2 weeks single-developer.

**Blocks:** all subsequent waves.

---

## Wave 1 — Morning foundation

### TICK-005 — Morning check-in restructure + Part A1 + cycle-phase rename

**Integrates:**
- `PLAN_morning_checkin.md` in full (5-step restructure: sleep, overnight events, communication, body, functional-today).
- `PLAN_irritability_and_severity_mapping.md` **Part A1** (morning `irritabilityLevel` field as parallel-polarity capacity axis).
- `PLAN_irritability_and_severity_mapping.md` **Item 12 lock** (cycle-phase `moodShift` → `cycleRelatedDay` data rename + *"Overall: today feels cycle-related"* label prefix).

**Dependency:** Stage 0 must ship first (data layer ready).

**Ships after Stage 0; nothing in Waves 2+ can proceed until Wave 1 ships.**

**Why bundle these:** all three modify the morning-check-in form. Separate tickets would create merge-conflict churn on the same section. Single coordinated ticket is cleaner.

---

## Wave 2 — Episode foundation + optional scope expansion

### TICK-006 — Episode phases + Part A2/A3 + (optional) trigger-surface Tier 1

**Integrates:**
- `PLAN_episode_phases.md` in full (prodrome → per-spasm → postictal phase-based logging; integrates standalone muscle events).
- `PLAN_irritability_and_severity_mapping.md` **Parts A2 + A3** (episode prodrome chip for `edgy/overstimulated`; per-spasm emotional-trigger toggle).
- **If user decides Tier 1 scope:** `PLAN_trigger_surface_expansion.md` Tier 1 exposure chips added to the episode form.

**Dependency:** TICK-005 must ship first (episode form references the stable meal-history model and morning-check-in baseline).

**Open decision needed from user:** whether to include Tier 1 trigger-surface expansion in this ticket or defer. Decision scope: which of the 6 tier-1 exposure categories (environmental, exertional, stillness, serotonergic, thermal, cycle) are in-scope for v1.

---

## Wave 3 — Evening check-in (the big irritability-plan delivery)

### NEW TICKET — Evening check-in + behavioral anchors + load tracking + multi-shift trajectory

**Not yet numbered.** Suggest `TICK-010-evening-checkin`.

**Integrates from `PLAN_irritability_and_severity_mapping.md` Stage 2:**
- **Part C evening check-in form** (new entry type, new home-screen card, soft prompt after configurable hour).
- **Behavioral-anchor Y/N fields** per Items 3 + 6: social/irritability anchors, cognition Y/N counts (morning + evening paired), fatigue Y/N anchors, pain Y/N anchors.
- **Cognitive load anchor set** — 8 items, 4 core, weighted (fully specced in walkthrough Item 10).
- **Social load + emotional load anchor sets** — frameworks locked; per-item specs to be designed in a walkthrough at the start of this ticket (same pattern as the cognitive walkthrough).
- **Multi-shift trajectory capture** (Item 11): `up_down` selection opens up to 3 shift-timestamp inputs with direction.
- **Weather re-fetch with interpolation fallback** at shift timestamps (Item 14).
- **`painEpisodePeak` write-time denormalization** hook on episode save (Item 7).

**Dependency:** TICK-005 ships first (morning baseline stable); TICK-006 ideally ships first as well so episode→day-level denormalization has a target.

**Pre-ticket design task:** walkthrough the social + emotional load anchor lists with the user using the same structured method the cognitive set used. ~2 hours of design conversation before ticket drafting begins.

---

## Wave 4 — Composite engine + export + documentation

### TICK-007 — Composite engine + baseline wizard + export consolidation

**Integrates from `PLAN_irritability_and_severity_mapping.md` Stages 3 + 4:**
- **Declarative `axisConfig` dispatcher** + three strategy functions (`peakOfPaired`, `trajectory`, `single`) — Item 7.
- **`functionalToday` validation-signal concordance** (rolling correlation between composite and `functionalToday` rank) — Item 6.
- **Monte Carlo sensitivity + one-at-a-time perturbation** — Item 5.
- **Dual-period baseline wizard** — direct for Arizona 2026, anchor-derived for Summers 2022/23 — Item 8.
- **Personal-baseline delta** computation and default-to-2022/23 export framing.
- **Cold-start thresholds** split 4-day (UI) / 7-day (clinical export) — Item 15.
- **Versioning infrastructure** — semver on `axisConfig.version`, config-object hash, `docs/COMPOSITE_VERSIONS.md` changelog, dual-view export (original + recomputed_to_current) — Item 13.
- **Stage provenance** headers — Item 16.
- **PROMIS labeling enforcement** — "Derived Interference Index" everywhere, structured disclaimer block, N-threshold validation status tier — Items 4 + 9.

**Dependency:** Wave 3 (TICK-010 evening check-in) must have shipped and accumulated ≥7 days of evening data before the composite produces a publishable clinical-export value. UI surface can render raw composite earlier at 4 days.

### TICK-008 — `MEDICAL_PURPOSE.md` full refold + doc updates

**Integrates:**
- Full `MEDICAL_PURPOSE.md` rewrite to reflect all 16 locked decisions from the irritability-plan critical review.
- Anchor-to-Likert conversion table (transparent, no hidden heuristics) — Item 8.
- Retrospective-reliability literature citations — Item 8.
- PROMIS labeling rules and N-threshold semantics — Items 4 + 9.
- Sensitivity methodology (both analyses) — Item 5.
- Three aggregation strategies explained — Item 7.
- Semver versioning scheme and dual-view mode semantics — Item 13.
- Cold-start threshold rationale — Item 15.
- Stage-provenance reading guide — Item 16.
- `docs/COMPOSITE_VERSIONS.md` changelog seeded with v2.0.0 entry.

**Can ship in parallel with TICK-007** — doc work is independent of code work; both fold into the same methodology story.

---

## Post-launch (deferred analytics)

These are NOT part of the Wave 1–4 ticket pipeline. They emerge from accumulated data after Wave 4 ships.

- **PROMIS calibration protocol** (Item 4): 2 admins at Stage 1 of irritability plan, monthly thereafter, accumulating toward N≥10 over ~10 months. Single-subject reference, never population-normed.
- **PEM correlation across four load types** (Item 10): physical + cognitive + social + emotional cross-day regression against next-day composite. Becomes meaningful after ≥14 paired days of post-Wave-3 data.
- **Variance-dominance re-check**: after ~3 months of data, confirm no single axis exceeds 40% of composite variance. If any does, revisit weights (MINOR version bump).
- **Axis consolidation refactor** (Item 6 Change 3 deferred): after ~3 months of data, identify co-varying pairs (fatigue↔cognition, social↔irritability) and consolidate. MAJOR version bump.
- **Likert-mapping perturbation** (Item 5 rejected D): add if a clinician raises the linear-mapping assumption. Currently deferred.

---

## Summary graph

```
Stage 0 (persistence)
  │
  ▼
Wave 1: TICK-005  (morning + Part A1 + cycle rename)
  │
  ▼
Wave 2: TICK-006  (episodes + Part A2/A3 + optional Tier 1 exposures)
  │
  ▼
Wave 3: TICK-010  (evening check-in + behavioral anchors + load tracking)
  │                            (social/emotional load walkthrough happens HERE)
  ├───────────────┐
  ▼               ▼
Wave 4:      Wave 4:
TICK-007    TICK-008
(composite  (docs
 engine)     refold)
  │
  ▼
Post-launch analytics (PROMIS accumulation, PEM correlation, variance check,
                      axis consolidation)
```

## Open decisions still owed by the user

1. **Tier 1 trigger-surface expansion scope** — include in TICK-006 or defer? If include, which of the 6 exposure categories are in v1?
2. **Social and emotional load anchor items** — to be designed via walkthrough at the start of Wave 3 (TICK-010), not pre-committed now.
3. **Ticket numbering** — the naming above (`TICK-009-persistence`, `TICK-010-evening-checkin`) is a placeholder. Confirm with the `docs/PROCESS.md` numbering convention before creation.

## What this plan does NOT change

- Individual plan docs remain source of truth for WHAT to build.
- `docs/PROCESS.md` ticket/plan/test workflow unchanged.
- Principles in `docs/PRINCIPLES.md` and invariants in `docs/ARCHITECTURE.md` are authoritative; any rollout step that would violate them is a rollout bug, not a principle waiver.
