---
status: in progress — base harness shipped (ISO-25, ISO-21 ran through it); critical-thinking safeguards added 2026-04-17 (adversary + dossier + critic + drift tripwire); awaiting first live run with the new gates
created: 2026-04-17
updated: 2026-04-17
resume-at: "First live run with the new safeguards on the next agent-ok ticket. Verify validator runs, adversary/critic subagents are reachable, drift tripwire fires when expected."
---

# PLAN: `/autopilot` harness for autonomous low-risk backlog work

## Goal

Let the agent independently pick up small, low-risk Linear tickets (copy fixes, isolated bugfixes, a11y attribute adds) so that when the user is in session working on complex things, parallel Claude Code sessions can clear backlog polish without human interaction per ticket.

Analogue pattern: existing `/qa-check` — on-demand, single-pass, human-visible outcome.

## Context

- 16 open Linear tickets in the Isobar backlog as of 2026-04-17 (ISO-15 … ISO-30).
- Roughly a third are pure-copy or isolated-bugfix scope that does not need a PLAN doc.
- User wants to delegate those without per-ticket hand-off friction.
- Existing autopilot pattern (`/qa-check`) already has the right shape: narrow scope, commits directly to `main`, posts Linear comment with SHA, human-gated bail-out into `docs/qa-fail/` for anything it can't confidently handle.

## Research summary (2026-04-17)

Anthropic's own guidance on harnesses:

- **Reversibility is the design axis.** The harder an action is to undo, the more declarative the guardrail needs to be. See *Effective harnesses for long-running agents* and *Measuring AI agent autonomy in practice*.
- **The harness does more work than the model.** Same model, different harness, wildly different outcomes. Scoping rules are where correctness lives.
- **Narrow autonomy, broad escalation.** Keep the autonomous lane tight; draft plans and escalate for anything ambiguous. See *Enabling Claude Code to work more autonomously*.
- **Context-aware risk evaluation** (Claude Code "auto mode") beats static allowlists — but static allowlists are a perfectly good backstop for the bespoke-tool case.

Principles cited (from `docs/PRINCIPLES.md`):

- Principle 13 (single user, not a market) — we can hardcode the scope to this repo; no need for a generic harness.
- Principle 10 (data privacy) — no telemetry in this harness; local-only state.

Architectural invariants (`docs/ARCHITECTURE.md`):

- §1 (no hardcoded `/Isobar/` paths) — the autopilot's pre-commit architecture grep enforces this automatically.

## Proposed mechanism

New slash command `/autopilot` in `.claude/commands/autopilot.md`, following the `/qa-check` template.

Single-pass behaviour:

1. Query Linear (team `Isobar`) for tickets in `Backlog` or `Todo` with label `agent-ok` and **no** `agent-blocked` label.
2. Pick the oldest one (FIFO).
3. Verify scope gate (see §4). Bail out to `docs/autopilot/ISO-NNN.md` with `status: pending-review` if any check fails.
4. Transition Linear to `In Progress`.
5. Implement, update any linked `TEST-NNN` checklist.
6. Run architecture grep (`grep -n '/Isobar/' sw.js manifest.json index.html`) — must be empty.
7. Run self-QA via Playwright MCP — actual DOM verification at 375×812 for UI changes, or a ticket-specific functional check.
8. Commit with `ISO-NNN: <title>` and Linear URL in the body. No AI attribution (per global rule).
9. Push to `main` (no feature branches, per project convention).
10. Transition Linear to `Ready for QA` — not `Done`. User does final acceptance.
11. Post Linear comment with commit SHA plus any flags discovered (stale test references, missing files, etc).
12. Stop. One ticket per invocation.

### Linear labels needed

- `agent-ok` — user applies to mark "this is fair game".
- `agent-blocked` — autopilot applies on bailout, with a comment pointing to `docs/autopilot/ISO-NNN.md`.

### Files & locations

- `.claude/commands/autopilot.md` — slash command definition.
- `docs/autopilot/` — drafted plans for tickets the autopilot couldn't handle autonomously. Mirrors `docs/qa-fail/`. Each file has `status: pending-review` frontmatter and is gated behind human approval before code changes.
- `.claude/autopilot-seen.json` — per-session deduplication, optional. Low-priority since the `agent-ok` label already gates intake.

## Ticket intake preconditions

Mirrors `docs/PROCESS.md` §"Before `agent-ok`". These are requirements on the *ticket as written*, independent of what the ticket's change is about — a ticket that fails either precondition is not machine-processable, regardless of whether its content is in scope. The adversary and critic gates reject by citing whichever item fails, rather than inventing ad-hoc objections per ticket.

- For every `index.html:<N>` citation in Agent Context: `grep -n` for the symbol and confirm the cited line sits inside the right render path (check-in vs. episode vs. morning, etc.). Origin: ISO-47 cited `:1624` as a check-in surface; it belonged to the episode render path, and the executor edited the wrong scope.
- For every AC that describes DOM placement: the AC names one sibling + one relative position (`"directly after <div class='comm-options'> and before <section id='externalObservation'>"`), not a region (`"below the communication options"`). Regions are unverifiable; sibling+position is a grep target.

Adversary behaviour: if either precondition fails, emit a `block`-severity objection pointing at this section. Critic behaviour: if the dossier doesn't cite verified greps / named siblings for the surfaces it touches, `agreement: false`.

## Scope — allowlist and bailout conditions

### In scope (autopilot may act)

- Label on Linear issue: `Bug` or `Improvement`. **Not** `Feature`.
- Priority: any. Not a filter — filter is `agent-ok` label, which the user applies deliberately.
- Change fits one of:
  - Pure copy / label / microcopy change.
  - CSS tweak that does not reflow layout (font size, color, spacing inside an existing container).
  - a11y attribute add (aria-label, role, heading promotion) that does not restructure.
  - Isolated bugfix with a single clear root cause (e.g. "function X forgets to delete key Y").
- Acceptance criteria are fully code-verifiable per `feedback_acceptance_criteria.md` (diff + grep + browser render).

### Out of scope — bail out to `docs/autopilot/`

- Touches `docs/PRINCIPLES.md`, `docs/ARCHITECTURE.md`, `sw.js`, `manifest.json`, cache version string, or service-worker registration path.
- Changes a localStorage data shape or adds a tracked field.
- Needs a PLAN doc that doesn't exist yet.
- Any acceptance criterion requires felt-sense judgment (UX flow comfort, interoceptive fit) — those belong to the user's UAT.
- Architecture grep (`grep -n '/Isobar/' sw.js manifest.json index.html`) returns any match.
- Playwright self-QA fails on any asserted condition.
- Another open ticket would conflict (e.g. a sibling Feature ticket is in flight for the same component).

### Hard stops (never act, regardless of scope)

- No `--no-verify` on commits, no skipping hooks.
- No force-pushes. No rebasing published commits. No destructive git ops.
- No label named `needs-human-review` on the ticket (reserved for QA-fail flow; autopilot treats this as "human has eyes on it").

## Dry run outcome (2026-04-17) — ISO-25

First test case: ISO-25, a pure template-literal copy change in `index.html:1800` — "Next check at X hours" → "Flags after Xh of fasting". Chosen because it's Low priority, `Improvement` label, no data shape change, no layout risk.

**Reached step 7 (self-QA) before bailing.**

Caught a real harness precondition failure:

- Playwright MCP server is configured at the user-level `~/.claude/settings.json`, but tools are not surfaced in this session's tool discovery.
- Project has no Node-side Playwright/Puppeteer dependency (and shouldn't — the PWA is intentionally dependency-free).
- `feedback_test_before_qa` rule forbids marking Ready for QA without real browser verification.

**No files touched. Linear state unchanged. Bail-out worked as designed.**

Secondary finding during the dry run:

- ISO-25 description claims "verified via regression tests `S11b` and `S11c` in `tests/client-isobar/uat-wave-3.spec.ts`" but that path does not exist in the repo. Worth surfacing in Linear if/when ISO-25 is resumed. Suggests either the ticket was drafted against an assumed/planned test suite, or the tests were never checked in. Either way: autopilot's Linear comment should flag it.

## Open questions — the resume list

Priority order. Top is what to solve first when picking this back up.

1. **Playwright MCP availability.** Resolved 2026-04-17 via option (b). Added `playwright` stdio server to `.mcp.json` (invokes `npx -y @playwright/mcp --isolated`) and added `"playwright"` to `enabledMcpjsonServers` in `.claude/settings.local.json`. MCP servers only register at session start, so verification requires a fresh Claude Code session. First live run on ISO-25 will also serve as the smoke test that the config works.

2. **First-run candidate selection.** Which of the 16 open tickets the user applies `agent-ok` to. Suggested starting set based on dry-run analysis:
   - ISO-25 (Low, Improvement, copy) — already analysed in the dry run, lowest-risk ticket in the backlog.
   - ISO-27 (High, UX, copy) — Morning Check-in "Somewhat" sleep chip. Template-literal style.
   - ISO-28 (High, UX, copy) — Morning Check-in "How's Today?" retrospective voice.
   - ISO-29 (High, UX, copy) — Body map L/R perspective declaration.
   - ISO-21 (Medium, Bug, isolated) — `clearData()` missing two localStorage keys. Single-function fix.

   Out of scope for v1 autopilot — need human plan:
   - ISO-15 (Urgent, data integrity), ISO-16 (drafts + abandonment UX), ISO-17 (tab order — possibly in scope), ISO-18 (timezone rework), ISO-19 (layout rework), ISO-20 (touch target CSS — may be in scope), ISO-22 (quota error handling), ISO-23 (semantic headings — may be in scope), ISO-24 (date picker), ISO-26 (live countdown feature), ISO-30 (Save/Cancel overflow CSS — may be in scope).

   The "may be in scope" ones are judgement calls. Safer to start narrow.

3. **Test-suite reference** (`tests/client-isobar/uat-wave-N.spec.ts`). Resolved 2026-04-17. Clarified by user: these tests are maintained by a **separate testing agent** in a different workspace, not in this repo. References like "verified via regression tests S##" in ticket descriptions point to work that exists, just not locally. Autopilot should **not** flag them per-ticket, and should **not** attempt to read or grep for these paths. Browser-level self-QA via Playwright MCP (step 7) is the autopilot's own verification and is independent of the external test agent's suite.

4. **Commit convention.** `/qa-check` uses `ISO-NNN: <title>` with the Linear URL in the body. Matches. Keep the same. No AI attribution anywhere (global rule).

5. **Concurrency.** Only one autopilot run at a time. If user is actively editing `index.html` in the main session, autopilot shouldn't race. Practical answer: user invokes `/autopilot` deliberately in a side session, so this is implicitly serialised. Don't over-engineer it unless a conflict actually happens.

6. **Rollback.** If autopilot commits something the user disagrees with on review, flow is: user reverts on main (normal git), moves Linear back to Backlog, removes `agent-ok` label, adds a comment explaining what was wrong. No machinery needed beyond git.

## Critical-thinking safeguards (added 2026-04-17)

### Why

The base harness shipped with a scope-gate checklist (§"Scope") and the assumption that the executor would honestly self-review against it. In practice, an executor with no audience degrades to checklist compliance — it ticks boxes without testing them. The QA-side analogue (the QA agent's drafted-fail review) catches this *after* code lands. Autopilot needs equivalent structural pressure *before* code lands, because there's no human gate between scope-gate and commit.

The pattern: replace exhortation with structural artifacts that fail closed. Each safeguard below maps to a specific failure mode the absent human gate would have caught.

### The four gates

**1. Adversary pass — `.claude/commands/autopilot-adversary.md`**

Separate subagent. Reads only the ticket + scope rules; not the executor's reasoning. Produces a structured objection list at severity `block` / `escalate` / `flag`. Different system prompt = different prior = genuine pushback.

- Catches: scope laundering (executor accepts an old `agent-ok` label on a ticket whose surface area grew), AC paraphrasing, unstated coupling.
- Enforcement: `block`-severity objections cause immediate bail-out. `escalate`-severity objections must be addressed in the dossier's `scope_gate[]` or `judgement_note`, with cited evidence.

**2. Structured intake dossier — `docs/autopilot/ISO-NNN.dossier.json`**

Rigid schema. No prose verdicts. Validated by `scripts/autopilot/validate-dossier.mjs`. Missing fields halt the run.

Key fields, each chosen to defeat a known failure mode:

- `ac_verbatim` + `ac_paraphrase_check` — defeats AC paraphrasing.
- `scope_gate[]` with `evidence_cmd` per row — defeats checkbox compliance.
- `adjacent_surfaces[]` with executed greps and full call-site lists — defeats grep-blindness.
- `approach_chosen` + `approach_alternatives_considered` — defeats cargo-cult solutions.
- `premortem_embarrassment` (named failure mode, not a confidence number) — defeats hand-waving.
- `drift_tripwire_grep[]` — see Gate 4.

The dossier MUST be written before any code change. Once written, any later edit to make a tripwire pass is forbidden by the hard-stops list — the executor must bail out instead.

**3. Critic pass — `.claude/commands/autopilot-critic.md`**

Separate subagent in fresh context. Reads ticket + dossier + adversary report; not the executor's narrative. Produces an independent verdict at `docs/autopilot/ISO-NNN.critic.json`. If the critic's `agreement` is `false`: ticket → `needs-human-review`, no code is touched, no averaging or tie-breaking.

- Catches: scope laundering missed by the adversary, dossier evidence that doesn't actually support its verdict, missed adjacent surfaces.
- Optional hardening (deferred): use a different model for executor vs. critic (e.g., Opus executor, Sonnet critic). Different training cuts and tunings reduce shared bias. Reassess after the first calibration window.

**4. Drift tripwire (post-implementation, pre-commit)**

Mechanical. Executor runs every command in `dossier.drift_tripwire_grep[]` against the working tree. Any deviation from `expected` halts the run and forces a bail-out plan.

- Catches: mid-flight scope drift ("I'll just clean up this one helper while I'm here"), unintended file changes, architecture invariant violations introduced during implementation.
- Enforcement is structural, not ethical: the dossier was committed to disk before code changes. If the diff doesn't match what the dossier promised, the autopilot stops. There is no "update the dossier to reflect what I actually did" path.

### Calibration ladder (placeholder — fill in after first 5 live runs)

The safeguards above catch *known failure classes*. They do not prove critical thinking — that has to be measured against a known-good human verdict. The calibration ladder is what tells us whether the safeguards are actually working or just adding ceremony.

Two metrics worth tracking once we have data:

- **Scope-gate agreement rate**: (autopilot's `decision: proceed` ∩ user's post-hoc "this was fair to ship") / (autopilot's `decision: proceed`). Target: ≥ 85% over a rolling 10-ticket window. Drop below threshold → tighten the allowlist.
- **Adversary-utility rate**: (adversary objections that turned out to matter on review) / (total adversary objections). If too low (< 20%), the adversary is producing noise; tune the prompt. If too high (> 60%), the executor is missing things the adversary catches → the scope gate itself needs widening.

TBD after first 5 live runs:

- Where the run-log lives. Likely `docs/autopilot/calibration.json`, appended to per run, with: ticket ID, dossier decision, critic agreement, drift tripwires fired, eventual human verdict on review.
- Threshold review cadence. Suggested: after every 10 runs, glance at the rolling rates; major decisions at 30 runs.

### Honest limits

None of these substitute for a critical human reviewer. They catch the common failure shapes — checkbox compliance, paraphrase drift, grep-blindness, cargo-cult solutions, mid-flight scope drift. A novel ticket whose subtle scope creep threads all four gates will still pass. The calibration ladder exists precisely because we cannot prove critical thinking in the abstract; we measure it by agreement rate with the user's eventual judgment, and roll back the allowlist if the rate degrades.

This is structural pressure, not intelligence. Making the cheap path harder than the careful one is the entire mechanism.

### Worked example

`docs/autopilot/ISO-21.dossier.json` — retrospective dossier against the (already-shipped) ISO-21 fix, written 2026-04-17 to pressure-test the schema before wiring it into the harness. Surfaced one judgement-call subtlety (sweep-vs-allowlist contract change) that prose would have buried; the schema captured it cleanly in `scope_gate[2].judgement_note` and `premortem_embarrassment`.

## When we resume

Progress as of 2026-04-17:

- [x] Q1 — Playwright MCP registered at project level (§6 Q1).
- [x] Q3 — Stale-test-reference audit completed; known template boilerplate, not a per-ticket flag (§6 Q3).
- [x] Slash command drafted: `.claude/commands/autopilot.md`.
- [x] Bail-out drafts directory: `docs/autopilot/` with `README.md`.
- [x] Linear labels created: `agent-ok` (green) and `agent-blocked` (grey).

Remaining:

1. **User restarts Claude Code.** Required for the newly-added Playwright MCP entry in `.mcp.json` to register. On first tool use, the user will see a permission prompt for `mcp__playwright__*` — approve to allowlist.
2. **User applies `agent-ok` label to ISO-25.** First live run. The session will invoke `/autopilot`, which should pick ISO-25 (oldest `agent-ok`-tagged Backlog ticket), run end-to-end, and either ship it to Ready for QA or bail out with a clear reason.
3. If ISO-25 completes cleanly, apply `agent-ok` to ISO-27, ISO-28, ISO-29, ISO-21 in that order for successive runs.
4. Review after five runs. Tune scope. Decide whether to lift any of the "may be in scope" tickets (ISO-17, ISO-20, ISO-23, ISO-30) into the allowlist, or add examples of what each ruling means to this plan.

## References

- `.claude/commands/qa-check.md` — precedent pattern.
- `docs/PROCESS.md` — ticket / plan / test workflow.
- `docs/PRINCIPLES.md` — priorities 8 (don't gate user) and 13 (single-user).
- `docs/ARCHITECTURE.md` §1 — the grep check the autopilot must run.
- [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents).
- [Measuring AI agent autonomy in practice](https://www.anthropic.com/news/measuring-agent-autonomy).
- [Enabling Claude Code to work more autonomously](https://www.anthropic.com/news/enabling-claude-code-to-work-more-autonomously).
