---
status: active — sequencing plan for the post-irritability-critical-review queue
created: 2026-04-17
last_updated: 2026-05-01 (summary graph corrected; physician-report emergent work added; Decision #5 resolved — Wave 5 export trio before Wave 4)
supersedes: any prior informal ticket ordering since the irritability plan refold
---

# PLAN: Rollout Sequencing (post-critical-review, 2026-04-17)

## Purpose

Coordinate the currently-open planning docs into a single shippable order. Produced after the 16-item critical-review walkthrough of `PLAN_irritability_and_severity_mapping.md` locked a number of structural changes that interact with the morning-check-in and episode-phases plans already in the pipeline.

This doc is the sequencing spec. Individual plans remain the source of truth for WHAT to build; this doc answers WHEN.

---

## Status snapshot — 2026-04-30

Two changes since 2026-04-22:

1. **Intervention log plan landed.** `PLAN_intervention_log.md` drafted 2026-04-30 in response to the patient's THC abort observation (low-dose THC reliably stops episodes; mechanism research in `project_thc_treatment_response.md` memory). Adds a new `intervention_event` entry type. Decomposed into TICK-035/036/037. **Not a numbered wave** — slots in as an urgent additive track because the highest-signal piece (TICK-035) has zero dependencies and every delayed day loses structured data on the strongest treatment-response observation in the dataset. See "Intervention log — urgent additive" section below.

2. **Tier 1 trigger-surface expansion closed.** Audit of `index.html` on 2026-04-30 confirmed Tier 1 items 1–6 of `PLAN_trigger_surface_expansion.md` shipped piecemeal. Item 7 (aborted-episode intervention chips) is superseded by the intervention log. Tier 2/3 are deferred without an open decision pending. Open decision #3 closed.

Everything in the 2026-04-22 snapshot below remains current except for those two points.

---

## Status snapshot — 2026-04-22

Five days since this plan was drafted. The shape has held, but the ticket numbering drifted and the inside of each wave shipped differently than anticipated. Summary:

- **Stage 0 (persistence)** — ✅ fully shipped. All four tickets (ISO-39/40/41/42) Done 2026-04-18/19.
- **Wave 1 (morning foundation)** — ✅ **fully shipped**. All acceptance criteria confirmed in code (2026-04-23 audit). TICK-005 closed as housekeeping 2026-04-22 — scope accreted across ISO-47, ISO-48, ISO-28, ISO-29, ISO-35, ISO-36, ISO-38, ISO-51 between 2026-04-18 and 2026-04-21. Every AC verified at specific `index.html` line numbers in the ticket's ship notes.
- **Wave 2 (episode foundation)** — ❌ **not started**. `PLAN_episode_phases.md` still specced; `docs/tickets/TICK-006-episode-phases.md` drafted but untouched. Per-wave blocker on Wave 1, which only half-shipped, so the original gate is ambiguous.
- **Wave 3 (evening check-in)** — 🚧 **in flight, 3 of 5 original tickets done + 5 new anchor tickets in Backlog**. Renumbered from the plan's placeholder "TICK-010" to TICK-018..022; the Item 10 load-anchor work added TICK-030..032 (ISO-73/74/75) and the Item 3+6 symptom-axis behavioral Y/N anchors added TICK-033..034 (ISO-76/77). ISO-52/53/54 (foundation / snapshot / cost block) shipped 2026-04-21 and 2026-04-23. ISO-55/56 (activity+trajectory / notes+export) are Backlog. ISO-73..77 created 2026-04-23.
- **Wave 4 (composite engine + docs)** — ❌ **not started**. TICK-007 and TICK-008 drafted, dependent on Wave 3 accumulating ≥7 days of evening data.
- **New Wave 5 (Places / Trigger-trap)** — ❌ **not started, but fully drafted**. Eight tickets ISO-57..64 / TICK-023..029 + TEST-028, all Backlog, drafted 2026-04-19 from `PLAN_trigger_trap.md`. This wave did not exist when the rollout plan was first written — it was added after the 2026-04-19 flight-leg postmortem.

**What this means practically:** the dependency graph is now partially inverted. Wave 3 is ahead of Wave 1+2 because evening check-in work did not actually depend on the morning restructure or the episode-phase restructure — both the irritability plan and the evening form were additively layerable on the existing forms. The bundled Wave 1 / Wave 2 tickets should be reconsidered before shipping: either reconfirm the bundle still makes sense, or close them out as superseded by the piecemeal work.

---

## Plan inventory (as of 2026-04-22)

| Plan | Status | Role in rollout |
|---|---|---|
| `PLAN_environmental_risk.md` | ✅ shipped 2026-04-15 (UAT 30/30 PASS) | Done; its three-axis output feeds downstream ticket composites |
| `PLAN_morning_checkin.md` | ✅ fully shipped — TICK-005 closed 2026-04-22, all ACs verified 2026-04-23 | Wave 1 — Done |
| `PLAN_episode_phases.md` | ❌ not started; TICK-006 drafted | Wave 2 |
| `PLAN_irritability_and_severity_mapping.md` | 🚧 Stage 0+1 done; Stage 2 foundation done; cost/activity/notes tickets in Backlog (ISO-54/55/56) | Spans Stage 0 + Waves 1, 2, 3, 4 |
| `PLAN_trigger_surface_expansion.md` | ✅ Tier 1 shipped piecemeal (verified 2026-04-30); item 7 superseded by `PLAN_intervention_log.md`; Tier 2/3 deferred without open decision | Closed |
| `PLAN_intervention_log.md` | ❌ tickets drafted (TICK-035/036/037), not started; specced 2026-04-30 | **Urgent additive** — not a numbered wave; see dedicated section below |
| `PLAN_trigger_trap.md` | ❌ tickets drafted (ISO-57..64); no implementation started | **New Wave 5 (Places)** — see below |
| `PLAN_autopilot_harness.md` | 🚧 harness live; Wave 6 canary still remaining on the injection-guardrails plan | Operational tool, not on this rollout |
| `PLAN_injection_guardrails.md` | 🚧 Waves 1/2/2a/3/4/5/7/8/9/10 shipped; Wave 6 (canary) outstanding | Security floor; not a user-facing rollout wave |
| `UPDATES.md` | Meta-document | Items 1–9 shipped or folded into tickets; Item 10 folded into TICK-006 (still pending) |

## Completed (reference)

| Ship date | Deliverable | Ticket(s) |
|---|---|---|
| 2026-04-14 | UPDATE-1 (communication scale revision) | — |
| 2026-04-15 | ENV-RISK — three-axis environmental risk surface | — |
| 2026-04-16 | TICK-004 — exposure rename (exposures-not-triggers framing) | ISO-6..14 cluster |
| 2026-04-17 | TEST-004 QA checklist + service worker fix + "Fasting" chip drop | ISO-11, ISO-12, ISO-13 |
| 2026-04-18 | Stage 0 Wave 1 — Dexie migration | ISO-39 (TICK-009) |
| 2026-04-18 | Clear-data sweep + meal-card countdown + functional-today voice + various polish | ISO-21, ISO-25, ISO-28, ISO-35, ISO-36, ISO-38 |
| 2026-04-19 | Stage 0 Wave 2+3+4 — storage.persist + weekly backup + JSON import | ISO-40, ISO-41, ISO-42 (TICK-010/011/012) |
| 2026-04-20 | Action-card keyboard reachability + Recent Episodes hide-when-empty + body-map L/R + morning irritability block + selected-button tint + chip mirror ordering | ISO-17, ISO-43, ISO-29, ISO-47 (TICK-013), ISO-49 (TICK-015), ISO-50 |
| 2026-04-21 | Cycle-phase rename + cycle-proxy log chips + EOD foundation + EOD snapshot | ISO-48 (TICK-014), ISO-51, ISO-52 (TICK-018), ISO-53 (TICK-019) |
| 2026-04-23 | Meal-coherence trio (unplanned — surfaced by 2026-04-22 postmortem) | ISO-67, ISO-68, ISO-69 |
| 2026-04-23 | EOD cost block — activities / connection / fun / sleep readiness | ISO-54 (TICK-020) |

---

## Hard precursor — ✅ SHIPPED

### Stage 0 — Data persistence hardening

**Originally:** NEW TICKET (`TICK-009-persistence` or `PRECURSOR-001`) — Dexie + `navigator.storage.persist()` + weekly JSON export + import-from-JSON.

**Actually shipped as four tickets (2026-04-18 / 2026-04-19):**
- **ISO-39 / TICK-009** — Dexie.js migration from localStorage. Done.
- **ISO-40 / TICK-010** — `navigator.storage.persist()` opt-in + settings indicator. Done.
- **ISO-41 / TICK-011** — Weekly backup prompt + Web Share JSON export. Done.
- **ISO-42 / TICK-012** — JSON import for recovery. Done.

**Rejected (as originally):** Dexie Cloud (not E2EE by default, single-maintainer commercial, no HIPAA compliance).

**Emergent follow-up after Stage 0 shipped:** ISO-65 (Backup card weekly-admin placement) and ISO-66 (cycle-related day label review) — both Todo, both UX postmortem findings, not blockers for subsequent waves.

---

## Wave 1 — Morning foundation — ✅ DONE

### TICK-005 — Morning check-in restructure + Part A1 + cycle-phase rename

**Closed as housekeeping 2026-04-22.** All acceptance criteria shipped piecemeal across ISO-47, ISO-48, ISO-28, ISO-29, ISO-35, ISO-36, ISO-38, ISO-51 (2026-04-18 to 2026-04-21). Every AC verified against `index.html` on 2026-04-23 audit:

- ✅ "Morning Check-in" label — line 416
- ✅ 5-step `CI_STEPS` (Sleep / Overnight Events / Communication / Body / Functional-Today) — lines 1349–1355
- ✅ `sleepBedTime`, `sleepWakeTime`, `sleepAwakenings` — line 1363
- ✅ `overnightEvents`, `morningStiffness` — line 1365
- ✅ "Woke up locked / couldn't move" chip — line 1455
- ✅ "Slept through — nothing noticed" mutually exclusive — line 1483
- ✅ `functionalToday` Good/OK/Scaled back/Bad — lines 1376, 1567
- ✅ Body map subtitle "right now" — line 1353
- ✅ Export handles new fields, legacy-tolerant — lines 1809–1814, 1857
- ✅ Part A1 irritability block — ISO-47 / TICK-013
- ✅ Cycle-phase rename — ISO-48 / TICK-014

---

## Wave 2 — Episode foundation — ❌ NOT STARTED

### TICK-006 — Episode phases + Part A2/A3

**Planned:**
- `PLAN_episode_phases.md` in full (prodrome → per-spasm → postictal phase-based logging; integrates standalone muscle events).
- `PLAN_irritability_and_severity_mapping.md` **Parts A2 + A3** (episode prodrome chip for `edgy/overstimulated`; per-spasm emotional-trigger toggle).
- ~~Optional: `PLAN_trigger_surface_expansion.md` Tier 1 exposure chips.~~ **Removed 2026-04-30** — Tier 1 items 1–6 already shipped piecemeal; item 7 superseded by `PLAN_intervention_log.md`. No remaining Tier 1 scope.

**Status:** not started. `docs/tickets/TICK-006-episode-phases.md` drafted, not in flight. Adjacent episode-form polish (ISO-50 chip ordering, ISO-36 L/R ordering, ISO-43 Recent Episodes) shipped around the bundle without touching the phase restructure.

**Blockers:**
- ~~Wave 1 bundle ambiguity~~ — **resolved 2026-04-23**. TICK-005 is fully done; Wave 1 gate is clear.
- ~~User decision on Tier 1 trigger-surface expansion scope~~ — **resolved 2026-04-30**. Closed; not blocking.

**Recommendation before starting:** reconcile the TICK-006 draft with what actually shipped into the episode form in the interim (ISO-36, ISO-50, ISO-51 cycle-proxy chips, ISO-33 exposure backdating framing is still Backlog). Expect the draft to be partially redundant.

**Pre-implementation note (2026-04-30):** if TICK-036 ships before Wave 2 (the recommended path — see Intervention Log section below), Wave 2 scope expands to migrate the legacy episode-wrap-up intervention step (Surface 2 in `PLAN_intervention_log.md`) into the active-episode banner's "Took something" button (Surface 3). Same data shape; surface change only. Bounded refactor — list once, account for in TICK-006 acceptance criteria when reconciliation happens.

---

## Wave 3 — Evening check-in (Stage 2 of irritability plan) — 🚧 IN FLIGHT

### Ticket set (renumbered from placeholder TICK-010-evening-checkin)

Originally drafted as a single "TICK-010-evening-checkin" ticket; actually split into five staged pieces TICK-018..022 as the scope was walked through:

- ✅ **ISO-52 / TICK-018** — Evening check-in foundation (new entry type, soft-prompt card, empty frame). Shipped 2026-04-21.
- ✅ **ISO-53 / TICK-019** — EOD snapshot block (communication + irritability + external observation). Shipped 2026-04-21.
- ✅ **ISO-54 / TICK-020** — EOD cost block (activities / connection / fun / sleep readiness). Shipped 2026-04-23 (commit `dfae136`).
- ❌ **ISO-55 / TICK-021** — EOD activity + single-shift trajectory + `functionalToday`. Backlog.
- ❌ **ISO-56 / TICK-022** — EOD notes + dedicated log + export section. Backlog.
- ❌ **ISO-73 / TICK-030** — EOD cognitive load anchor set (8 items). Backlog.
- ❌ **ISO-74 / TICK-031** — EOD social load anchor set (7 items). Backlog.
- ❌ **ISO-75 / TICK-032** — EOD emotional load anchor set (5 items). Backlog.
- ❌ **ISO-76 / TICK-033** — Cognition behavioral Y/N anchors — morning + evening paired (3 items, cross-form). Backlog. **Required for composite:** cognition axis (weight 0.15) has no inputs until this ships.
- ❌ **ISO-77 / TICK-034** — EOD symptom-axis behavioral Y/N anchors: fatigue (3) + pain (3) + social/irritability (4). Backlog.

**Still owed from `PLAN_irritability_and_severity_mapping.md` Stage 2 and not yet drafted into a ticket:**
- ~~**Cognitive load anchor set** (8 items)~~ ✅ ticket drafted 2026-04-23 as **TICK-030**.
- ~~**Social load anchor set** (7 items)~~ ✅ ticket drafted 2026-04-23 as **TICK-031**.
- ~~**Emotional load anchor set** (5 items)~~ ✅ ticket drafted 2026-04-23 as **TICK-032**.
- ~~**Symptom-axis behavioral Y/N anchors** per Items 3 + 6~~ ✅ locked 2026-04-23; tickets drafted as **TICK-033** (cognition paired morning+evening) and **TICK-034** (EOD fatigue + pain + social/irritability).
- **Multi-shift trajectory capture** (Item 11): `up_down` selection opens up to 3 shift-timestamp inputs with direction. TICK-021 scopes single-shift only — multi-shift is a follow-up.
- **Weather re-fetch with interpolation fallback** at shift timestamps (Item 14).
- **`painEpisodePeak` write-time denormalization** hook on episode save (Item 7). Depends on Wave 2.

**Dependency:** none of the remaining Wave 3 tickets are blocked by Wave 1 or Wave 2 bundles not having shipped. They *are* blocked by the preceding EOD tickets (TICK-020 before TICK-021 before TICK-022, because the UI stacks).

**Pre-ticket design task:** ✅ social + emotional load anchor walkthroughs complete 2026-04-23. Both sets locked in Item 10. TICK-020 implementation is no longer gated on design.

---

## Wave 4 — Composite engine + export + documentation — ❌ NOT STARTED

### TICK-007 — Composite engine + baseline wizard + export consolidation

Scope unchanged from original plan. Key items recap:
- Declarative `axisConfig` dispatcher + three strategy functions — Item 7.
- `functionalToday` validation-signal concordance — Item 6.
- Monte Carlo sensitivity + OAT perturbation — Item 5.
- Dual-period baseline wizard (Arizona 2026 direct, Summers 2022/23 anchor-derived) — Item 8.
- Personal-baseline delta + default-to-2022/23 export framing.
- Cold-start thresholds split 4-day (UI) / 7-day (clinical export) — Item 15.
- Versioning infrastructure — Item 13.
- Stage provenance headers — Item 16.
- PROMIS labeling enforcement — Items 4 + 9.

**Dependency:** Wave 3 must have shipped (all five TICK-018..022) and accumulated ≥7 days of evening data before the composite produces a publishable clinical-export value. UI surface can render raw composite earlier at 4 days.

**Draft location:** `docs/tickets/TICK-007-export-consolidation.md`.

### TICK-008 — `MEDICAL_PURPOSE.md` full refold + doc updates

Scope unchanged. Can ship in parallel with TICK-007.

**Draft location:** `docs/tickets/TICK-008-docs-updates.md`.

---

## Wave 5 — Places / Trigger-trap — ❌ NOT STARTED (added post-plan)

**Not in the 2026-04-17 plan.** Added 2026-04-19 after `PLAN_trigger_trap.md` was specced in response to a flight-leg episode cluster that exposed the old trigger-capture surface as misleading. Eight tickets drafted 2026-04-19:

- **ISO-57 / TICK-023** — Export window split (primer / prodrome-adjacent / prodrome).
- **ISO-58 / TICK-024** — Export parallel prodrome timelines (real-time vs retrospective).
- **ISO-59 / TICK-025** — Export counter-example framing (base-rate denominators for exposures).
- **ISO-60 / TICK-026** — Dexie schema: places + locationPings collections.
- **ISO-61 / TICK-027** — Opportunistic location-ping capture.
- **ISO-62 / TICK-028** — Places view: stay reconstruction + three-way counter-example split.
- **ISO-63 / TICK-029** — Export integration: primer-window stays with three-way split.
- **ISO-64 / TEST-028** — Places view QA checklist.

**Dependency:** independent of Waves 1–4. Touches export + a new Dexie collection + a new Places tab. Could run in parallel once Wave 3 is done.

**Sub-ordering within Wave 5:**
1. TICK-023/024/025 are export-only changes, no new schema — can ship first as a batch.
2. **TICK-037** (intervention log export) lands after the export trio — interleaves intervention events into the per-episode block established by TICK-023/024/025. See Intervention Log section below.
3. TICK-026 unblocks TICK-027 and TICK-028.
4. TICK-029 depends on TICK-028.
5. TEST-028 pairs with TICK-028.

---

## Intervention log — urgent additive (2026-04-30)

Not a numbered wave. Three pieces with three different timings, driven by `PLAN_intervention_log.md`. Origin: the patient's reproducible THC abort observation; structured capture of treatment response across all intervention categories (cannabinoid, MCAS rescue, heat, hydration, etc.).

| Ticket | Timing | Reasoning |
|---|---|---|
| **TICK-035** — schema + home-screen "Took something" card + opportunistic effect-capture strip | Ship now, parallel with anything | Zero dependencies. Additive: new entry type, new home-screen card. Doesn't touch `startEpisode()` or `exportReport()`. Every delayed day loses structured intervention data on the highest-signal treatment-response observation in the dataset. |
| **TICK-036** — episode wrap-up intervention review (legacy flow) | Before Wave 2 | Builds against the legacy `startEpisode()` 9-step wizard. When Wave 2 lands, the wrap-up step (Surface 2) migrates into the active-episode banner's "Took something" button (Surface 3) — bounded refactor, same data shape. Alternative (waiting for Wave 2) costs every episode in the gap; Wave 2 is "drafted, not in flight" with no scheduled start. |
| **TICK-037** — log view cards + export intervention timeline | After Wave 5 export trio (TICK-023/024/025) | Both touch `exportReport()`. Cleaner to plumb interventions through the new export structure (window split, parallel prodrome timelines, counter-example framing) than to merge concurrent edits. |

**Coordination dependencies summarized:**
- TICK-035: no dependencies, no blockers.
- TICK-036: ships against legacy episode form; Wave 2 inherits a one-line scope expansion to migrate the surface.
- TICK-037: ships after Wave 5 TICK-025; ordering inside Wave 5 is TICK-023→024→025→**037**→026→027→028→029.

**Linear note:** when creating the parent issues for TICK-035/036/037, add the `agent-ok` label only after the pre-`agent-ok` checklist (`PROCESS.md`) passes for each. TICK-035 is the lowest-risk autopilot candidate; TICK-036 is borderline (touches the episode form); TICK-037 is risky (touches export rendering — manual review preferred).

---

## Emergent / out-of-band work since 2026-04-17

Not on the original wave plan; emerged from postmortems or bug-hunt sessions.

- **Meal-state coherence trio** (2026-04-22 postmortem): ISO-67, ISO-68, ISO-69. All Done 2026-04-23. Drove `meal:last` out of the write path in favor of live derivation from `meal:entry:*` history. Postmortem at `docs/findings/FINDINGS_2026-04-22_meal_state_coherence.md`.
- **UX postmortem tickets** (ISO-65 backup-card placement, ISO-66 cycle-related day label). Both Todo. Followups from the 2026-04-19 backup-card + cycle toggle postmortem.
- **Injection-guardrails plan** — security floor running underneath all this. Waves 1/2/2a/3/4/5/7/8/9/10 shipped and pushed. Only Wave 6 (canary) remains.
- **qa-check workflow hardening** — advisory-verification discipline baked into the skill (2026-04-22) after ISO-68's "pure render issue" framing was relayed without tracing.
- **Physician report + sleep pickers** (2026-04-28): ISO-91 (24h custom time pickers for prodrome/firstJerk), ISO-92 (sleep bed/wake time pickers), ISO-93 (exportReport restructured into specialist-readable clinical summary). All committed and pushed, QA Pass 2026-04-28. ISO-94 (episode time inputs, same picker treatment) in Backlog. ISO-95 (fix Appendix B bed-time to read `sleepBedTimeCorrected`) committed 2026-04-30.
- **CBCT report ingested** — `CBCT Report.pdf` on disk; clinical summary docs (`Clinical_Summary_Lyon_20260428.*`, `Medical_Summary_Cotopaxi_Lyon_20260428.*`) drafted 2026-04-28 alongside the physician report work.

None of these blocked or were blocked by a wave in the rollout plan; they're noted here so the Completed-by-date timeline reads honestly.

---

## Post-launch (deferred analytics)

Unchanged from original plan. NOT part of the Wave 1–4 ticket pipeline. They emerge from accumulated data after Wave 4 ships.

- **PROMIS calibration protocol** (Item 4): 2 admins at Stage 1, monthly thereafter, accumulating toward N≥10 over ~10 months. Single-subject reference, never population-normed.
- **PEM correlation across four load types** (Item 10): physical + cognitive + social + emotional cross-day regression against next-day composite. Meaningful after ≥14 paired post-Wave-3 days.
- **Variance-dominance re-check**: after ~3 months of data, confirm no single axis exceeds 40% of composite variance.
- **Axis consolidation refactor** (Item 6 Change 3 deferred): after ~3 months of data, identify co-varying pairs and consolidate. MAJOR version bump.
- **Likert-mapping perturbation** (Item 5 rejected D): add if a clinician raises the linear-mapping assumption.

---

## Summary graph (current state)

```
Stage 0 (persistence) ✅ DONE — ISO-39/40/41/42
  │
  ▼
Wave 1: TICK-005 ✅ DONE (all ACs shipped piecemeal, verified 2026-04-23)
  • Part A1 (TICK-013) ✅ ISO-47
  • Cycle rename (TICK-014) ✅ ISO-48
  • 5-step morning restructure ✅ fully shipped (confirmed index.html audit)
  │
  ▼
Wave 2: TICK-006 (episode phases) ❌ NOT STARTED — drafted, not in flight
  │
  ▼
Wave 3: TICK-018..022 (evening check-in) 🚧 3 of 5 DONE
  • TICK-018 ✅ ISO-52
  • TICK-019 ✅ ISO-53
  • TICK-020 ✅ ISO-54 (cost block — shipped 2026-04-23)
  • TICK-021 ❌ ISO-55 Backlog (activity + single-shift trajectory)
  • TICK-022 ❌ ISO-56 Backlog (notes + export)
  ├───────────────┐
  ▼               ▼
Wave 4:      Wave 4:
TICK-007    TICK-008       ❌ NOT STARTED
(composite  (docs refold)
 engine)
  │
  ▼
Post-launch analytics (PROMIS, PEM, variance, axis consolidation)

─── Wave 5 export trio ships during Wave 3 data-accumulation wait; Wave 4 follows ───

Wave 5 export batch (TICK-023→024→025) — ships before Wave 4
  → TICK-037 (intervention export — after 025, before Wave 4)
  → Wave 4 (composite engine — builds on established export structure)
  → Wave 5 remainder: TICK-026 schema → TICK-027 ping → TICK-028 Places view (TEST-028) → TICK-029 export integration

─── Urgent additive (not a wave) — 2026-04-30 ───

TICK-035 (intervention schema + home logging + strip) — ship now, no deps
TICK-036 (episode wrap-up intervention review) — before Wave 2
TICK-037 (log view cards + export timeline) — after Wave 5 TICK-025
```

## Open decisions still owed by the user

1. ~~**Wave 1 bundle reconciliation**~~ — **resolved 2026-04-23.** TICK-005 is fully done; all ACs verified in code. No remaining gaps.
2. **Wave 2 bundle reconciliation** — re-read TICK-006 against the current episode form before starting; expect partial redundancy with ISO-33/36/50/51 work that shipped around it. **Note (2026-04-30):** if TICK-036 ships before Wave 2 (recommended), the Wave 2 bundle also inherits the Surface 2 → Surface 3 migration.
3. ~~**Tier 1 trigger-surface expansion scope**~~ — **resolved 2026-04-30.** Audit confirmed Tier 1 items 1–6 shipped piecemeal in `index.html`; item 7 (aborted-episode intervention chips) is superseded by `PLAN_intervention_log.md`. Tier 2/3 are deferred without an open decision pending — they become open only when someone wants to build them.
4. ~~**Social and emotional load anchor items** — walkthrough owed before TICK-020 implementation begins.~~ ✅ **Resolved 2026-04-23.** Social=7 items, Emotional=5 items (with documented 1-item deviation), both locked in Item 10.
5. ~~**Wave ordering: Wave 5 before or after Wave 4?**~~ **Resolved 2026-05-01.** Wave 5 export trio (TICK-023→024→025) ships first, then TICK-037 (intervention export), then Wave 4. Rationale: the window split, parallel prodrome timelines, and counter-example framing are structural changes to report organization; Wave 4's composite scores slot into an established structure more cleanly than retrofitting structural changes onto a composite-first report. The Wave 3 data-accumulation gate (≥7 days) provides the natural window to land TICK-023/024/025 before Wave 4 opens.

## What this plan does NOT change

- Individual plan docs remain source of truth for WHAT to build.
- `docs/PROCESS.md` ticket/plan/test workflow unchanged.
- Principles in `docs/PRINCIPLES.md` and invariants in `docs/ARCHITECTURE.md` are authoritative; any rollout step that would violate them is a rollout bug, not a principle waiver.
