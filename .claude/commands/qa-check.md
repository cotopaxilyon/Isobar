---
description: Scan Linear for QA Pass/Fail tickets and act on them (on-demand replacement for the 5-min cron)
---

Run one pass of the QA watcher logic. Capability constraints from [`docs/plans/PLAN_injection_guardrails.md`](../../docs/plans/PLAN_injection_guardrails.md).

0. **Activate mode (mandatory first step).** Run:

   ```sh
   printf 'qa-check\n%s\n' "$(date +%s)" > /Users/cotopaxilyon/WebstormProjects/Isobar/.claude/active-mode
   ```

   This enables the per-mode tool manifest at `.claude/mode-manifests/qa-check.txt`. Tools not on that list will be denied for the rest of this session (file auto-expires after 2h).

1. Query Linear (team Isobar) for tickets currently in status `QA Pass` or `QA Fail`.
2. Load `.claude/qa-watcher-seen.json` to skip tickets already handled; update it after processing.
3. For each `QA Pass` ticket:
   - **Read the QA comment before anything else.** `list_comments` and read the most recent UAT write-up first. A "PASS WITH ISSUES" verdict means the ticket is still passable but the comment logged advisories — new bugs spawned as separate tickets, ticket-doc hygiene issues (fictional file paths, inaccurate claims), product gaps, informational notes. For each advisory: decide whether it needs a new backlog ticket, a doc amendment on the current ticket, or just a note in the final summary. Do not transition the ticket silently past the comment.
   - Verify code-verifiable acceptance criteria (behavioral ACs are the QA agent's job — do not re-check those).
   - Commit as `ISO-NNN: <title>` with `Linear: <url>` in the body. No Claude/AI attribution.
   - Push directly to `main` (no feature branches).
   - Transition the Linear issue to `Done` and post a comment with the commit SHA. Post advisory follow-ups (new tickets filed, doc edits made) in the summary at step 6.
4. For each `QA Fail` ticket:
   - Investigate root cause: read relevant code, `git log`, and research medical/POTS/PWA best practices if applicable.
   - Write `docs/qa-fail/ISO-NNN.md` with `status: pending-review` frontmatter.
   - Post a short Linear comment linking to the plan and apply the `needs-human-review` label.
   - **Do not touch code** — the human approves the plan first.
5. When implementing an approved fix plan (human has reviewed `docs/qa-fail/ISO-NNN.md` and greenlit the work): after committing/pushing the fix, **remove the `needs-human-review` label** from the Linear ticket and flip the plan's frontmatter `status: pending-review` → `status: shipped` (or delete the file). The label should never outlive the fix.
6. Report a summary: tickets seen, passes shipped, fails drafted, labels cleared, and any skipped.

If nothing new, say so and stop.
