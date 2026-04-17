# QA Fail fix plans

Each file here is a fix plan drafted by the QA watcher for a ticket that moved to `QA Fail` in Linear. No code changes are made until a human reviews and approves.

## Lifecycle

1. Watcher detects a ticket in `QA Fail`, investigates, and writes `ISO-NNN.md` here with `status: pending-review`.
2. Human reads the plan, discusses in Claude, and either accepts or revises it.
3. On approval, implementation proceeds, the commit references the ticket, and this file is updated to `status: reviewed`.
4. Reviewed files remain in-tree as history. They can be archived later if the directory grows noisy.

## Frontmatter convention

```yaml
---
ticket: ISO-042
title: <ticket title>
status: pending-review   # or: reviewed
drafted: 2026-04-16
---
```

The prompt-submit hook scans this directory for files with `status: pending-review` and prepends a banner to your next prompt so nothing is forgotten across sessions.
