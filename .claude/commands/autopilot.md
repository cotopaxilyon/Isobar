---
description: Pick up one low-risk Linear ticket tagged `agent-ok` and drive it from Backlog to Ready for QA autonomously
---

Run one pass of the autopilot harness. Full design spec: [`docs/plans/PLAN_autopilot_harness.md`](../../docs/plans/PLAN_autopilot_harness.md). Capability constraints from [`docs/plans/PLAN_injection_guardrails.md`](../../docs/plans/PLAN_injection_guardrails.md).

0. **Activate mode (mandatory first step).** Run:

   ```sh
   printf 'autopilot\n%s\n' "$(date +%s)" > /Users/cotopaxilyon/WebstormProjects/Isobar/.claude/active-mode
   ```

   This enables the per-mode tool manifest at `.claude/mode-manifests/autopilot.txt`. Any tool not on that list will be denied for the rest of this session, including subagent tool calls (the file auto-expires after 2h, or remove it manually with `rm .claude/active-mode`).

1. Query Linear (team `Isobar`) for issues in `Backlog` or `Todo` with label `agent-ok` and **no** label `agent-blocked` or `needs-human-review`. Skip anything tagged `Feature`. Pick the oldest by `createdAt`.
2. If nothing matches, say so and stop.
3. **Adversary pass.** Invoke the `autopilot-adversary` subagent (`.claude/commands/autopilot-adversary.md`) with the ticket ID. It returns objections at severity `block` / `escalate` / `flag`. Any `block` → bail out: write `docs/autopilot/ISO-NNN.md` with `status: pending-review`, apply `agent-blocked` label, post a Linear comment linking the plan, do not touch code, stop.
4. **Write the dossier** at `docs/autopilot/ISO-NNN.dossier.json`. Every `escalate`-severity adversary objection MUST be addressed in `scope_gate[]` (with cited evidence) or in a `judgement_note`. `flag`-severity objections are recorded for the final Linear comment. Run `node scripts/autopilot/validate-dossier.mjs docs/autopilot/ISO-NNN.dossier.json` — any non-zero exit halts the run.
5. **Critic pass.** Invoke the `autopilot-critic` subagent (`.claude/commands/autopilot-critic.md`) with the ticket + dossier + adversary report. Critic writes `docs/autopilot/ISO-NNN.critic.json`. Run `node scripts/autopilot/validate-dossier.mjs --critic docs/autopilot/ISO-NNN.critic.json`. If the critic's `agreement` is `false`: apply `needs-human-review` label, post a Linear comment linking both JSON files, do **not** touch code, stop.
6. **Scope-gate decision.** If the dossier's `decision` is `bail-out` or `needs-clarification`: write `docs/autopilot/ISO-NNN.md` with `status: pending-review`, apply `agent-blocked`, post a Linear comment, stop.
7. Transition Linear parent to `In Progress`. Start `python3 -m http.server 8765 --bind 127.0.0.1` in the repo root if not already running.
8. Implement, matching the dossier's `files_to_touch` and `approach_chosen` exactly. Update any linked `TEST-NNN` checklist. Keep the diff minimal — no incidental refactors.
9. **Drift tripwire.** Execute every command in `dossier.drift_tripwire_grep[]`. Any deviation from `expected` → do **not** commit; draft a root-cause plan in `docs/autopilot/ISO-NNN.md`, apply `agent-blocked`, stop. Do not amend the dossier to match reality — that would defeat the gate.
10. Architecture check: `grep -n '/Isobar/' sw.js manifest.json index.html`. Must be empty. Non-empty → bail out (per Step 9 rules).
11. **Self-QA via Playwright MCP at 375×812.** Navigate to `http://127.0.0.1:8765/`, seed localStorage per `dossier.self_qa_plan.seed_localStorage`, execute `dossier.self_qa_plan.steps`, verify each code-verifiable acceptance criterion against the rendered DOM. Mandatory per `feedback_test_before_qa`. If any assertion fails: do **not** commit; draft a root-cause plan in `docs/autopilot/ISO-NNN.md` and bail out.
12. Commit locally with message `ISO-NNN: <title>` and the Linear URL in the body. No AI attribution (global rule). **Do not push** — the commit stays on local `main` until UAT passes. `qa-check` pushes after the user flips the ticket to `QA Pass`. (No feature branches: commits go straight onto local `main`.)
13. Transition Linear parent to `Ready for QA`. Not `Done` — user does final acceptance.
14. Post a Linear comment with: commit SHA, paths to `ISO-NNN.dossier.json` and `ISO-NNN.critic.json`, and any `flag`-severity adversary observations. Do **not** flag references to `tests/client-isobar/uat-wave-N.spec.ts` — those point to a separate testing agent's workspace, not this repo (per the plan's Q3). Do not grep for or attempt to read those paths.
15. Stop. One ticket per invocation. Report: ticket ID, status reached, commit SHA (or bailout reason), critic agreement (true/false).

**Hard stops — never do any of these:**
- `--no-verify` on commits, or any flag that skips hooks.
- Force push, destructive git ops, amending published commits.
- Act on a ticket already tagged `needs-human-review` or `agent-blocked`.
- Mark a ticket `Done` — that's the user's call after UAT.
- Write the dossier *after* the implementation diff exists. The dossier is the planning artifact and must precede any code change.
- Edit the dossier mid-implementation to make a tripwire pass. If reality drifts from the dossier, bail out — re-run the adversary and critic on the next attempt.
- Skip the validator on either JSON file. A passing validator is the precondition for the next step, not a nice-to-have.
