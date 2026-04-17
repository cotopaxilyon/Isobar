# Isobar — Claude Code entry point

This file is auto-loaded by Claude Code at the start of every session.
Treat it as a table of contents, not a spec.

## Read these first
- [`README.md`](README.md) — what the app is, who it's for, current state, design principles
- [`docs/PROCESS.md`](docs/PROCESS.md) — ticket / plan / test workflow and Linear integration
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — invariants the codebase must keep true (with verification commands)

## Where things live
- `index.html` — the entire app (single-file PWA)
- `sw.js`, `manifest.json`, `icon.svg` — PWA shell
- `docs/tickets/` — active work items (`TICK-NNN-*.md`)
- `docs/plans/` — design specs (`PLAN-NNN-*.md`)
- `docs/testing/` — QA checklists (`TEST-NNN-*.md`)
- `docs/qa-fail/` — fix plans drafted by the QA watcher for failed QA runs
- `docs/findings/` — research and data analysis (no ticket)
- `docs/archive/` — shipped or abandoned tickets

## Before changing shell assets
Run the architecture check:

```sh
grep -n '/Isobar/' sw.js manifest.json index.html
```

Empty output = the invariant in `docs/ARCHITECTURE.md` §1 still holds.
