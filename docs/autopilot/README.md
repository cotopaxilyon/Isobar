# `/autopilot` bail-out drafts

When `/autopilot` can't autonomously handle a ticket tagged `agent-ok`, it drops a fix plan here and tags the Linear issue `agent-blocked`. Human reviews the plan before any code change.

Mirrors the `docs/qa-fail/` pattern, for a different failure mode (scope-gate fail, not QA-fail).

## File conventions

Three artifact types live here, all keyed by ticket ID:

- **`ISO-NNN.md`** — bail-out plan. Drafted when the autopilot can't (or won't) proceed autonomously.
  - Frontmatter: `status: pending-review` while awaiting human, `status: shipped` (or file deleted) once the user-approved fix is committed.
  - Body: root cause, proposed fix, open questions, scope concerns that triggered the bail-out.
- **`ISO-NNN.dossier.json`** — pre-implementation planning artifact. Written by the executor before any code changes. Schema enforced by `scripts/autopilot/validate-dossier.mjs`. Contains scope-gate evidence, adjacent-surface greps, root cause, chosen approach, pre-mortem failure mode, post-implementation drift tripwires, and the self-QA plan. Persisted as part of the run record; do not delete after a successful ship.
- **`ISO-NNN.critic.json`** — independent verdict from the `autopilot-critic` subagent. Written after the dossier, before any code change. If `agreement: false`, the executor bails to `needs-human-review` and does not touch code.

Validate either JSON file:

```sh
node scripts/autopilot/validate-dossier.mjs docs/autopilot/ISO-NNN.dossier.json
node scripts/autopilot/validate-dossier.mjs --critic docs/autopilot/ISO-NNN.critic.json
```

## Design spec

Full harness spec: [`docs/plans/PLAN_autopilot_harness.md`](../plans/PLAN_autopilot_harness.md) (see the "Critical-thinking safeguards" section for the adversary / dossier / critic / drift-tripwire flow).
Slash command: [`.claude/commands/autopilot.md`](../../.claude/commands/autopilot.md).
Subagents: [`.claude/commands/autopilot-adversary.md`](../../.claude/commands/autopilot-adversary.md), [`.claude/commands/autopilot-critic.md`](../../.claude/commands/autopilot-critic.md).
