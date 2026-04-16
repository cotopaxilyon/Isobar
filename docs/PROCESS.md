# Isobar — Ticket & Tracking Process

## File structure

```
docs/
  BACKLOG.md              # ordered queue + dashboard (index, not source of truth)
  PROCESS.md              # this file
  tickets/                # one file per work item
    TICK-003-meal-size.md
    TICK-004-exposure-rename.md
    ...
  plans/                  # design specs (pre-implementation, linked from tickets)
    PLAN-005-morning-checkin.md
    ...
  testing/                # test checklists (flat checkboxes, linked from tickets)
    TEST-003-meal-size.md
    ...
  findings/               # research & data analysis (not tied to a ticket)
  archive/                # shipped or abandoned tickets, plans, and tests
```

## Naming convention

All ticket-related files share a **numeric ID** as the join key:

```
TICK-NNN-kebab-slug.md    # the ticket (hub document)
PLAN-NNN-kebab-slug.md    # design spec (if the feature needs one)
TEST-NNN-kebab-slug.md    # test checklist
```

- **NNN** is zero-padded to 3 digits (`003`, `012`).
- The **slug** is for humans. The number is the key.
- Glob `docs/**/???-003-*` to find everything for ticket 003.
- Use kebab-case for slugs. No underscores in filenames.

### What gets a ticket

Every discrete unit of work that changes `index.html` gets a ticket. Research, data analysis, and clinical findings stay in `docs/findings/` without a ticket number.

### What gets a plan

Features that need design before implementation. Small changes (add a chip, rename a label) don't need a plan — the ticket's implementation notes are sufficient. If a plan already exists (e.g. `PLAN_morning_checkin.md`), rename it to match the ticket ID when the ticket is created.

### What gets a test file

Any ticket with more than 5 test steps. For simpler tickets, inline test steps in the ticket itself under `## Testing`.

## Ticket template

```markdown
---
id: TICK-NNN
title: Short descriptive title
status: pending
priority: high
wave: 3
created: YYYY-MM-DD
updated: YYYY-MM-DD
plan: docs/plans/PLAN-NNN-slug.md
test: docs/testing/TEST-NNN-slug.md
depends-on: []
supersedes: []
shipped: ""
---

# TICK-NNN: Title

## Summary
One paragraph — what this changes and why it matters clinically.

## Acceptance Criteria
- [ ] Observable, testable condition
- [ ] Another condition
- [ ] Backwards compat: old entries without new fields render without error

## Agent Context
Scoped instructions for the implementing agent:
- Which functions to touch
- Which functions NOT to touch
- Data shape changes
- Cache version bump needed?

## Implementation Notes
Key decisions, edge cases, data shapes. Reference the plan for full design.

## Ship Notes
_(filled after shipping)_
Commit: ...
Date: ...
UAT: .../... PASS
```

## Status lifecycle

```
pending → in-progress → testing → shipped
              ↓
           blocked → (back to pending or in-progress)
              ↓
          abandoned → moved to archive/
```

| Status | Meaning | Who sets it |
|---|---|---|
| `pending` | Spec is ready, work hasn't started | Default |
| `in-progress` | Agent is actively implementing | Agent, on starting work |
| `testing` | Code is written, UAT in progress | Agent, when implementation is done |
| `shipped` | UAT passed, live in app | User, after confirming UAT pass |
| `blocked` | Can't proceed — dependency or open question | Either |
| `abandoned` | Superseded or no longer needed | User |

**Rule:** the agent updates `status` in the ticket frontmatter as it works. The agent also updates `BACKLOG.md` to keep the index in sync.

## BACKLOG.md conventions

BACKLOG.md is the **at-a-glance dashboard**. It is an index, not the source of truth — ticket frontmatter is canonical. Format:

```markdown
## Testing
- **TICK-003** Meal size + edit time (wave 3)

## In Progress
(none)

## Pending — by wave
### Wave 4
- **TICK-004** Exposure rename (high)
```

One line per ticket. Keep it under 60 lines. When a ticket ships, move it to the Shipped section with a date.

## Test checklist conventions

Test files use flat checkboxes grouped by test case. Each test case has a short ID for reference.

```markdown
## TC-1: Size picker renders
- [ ] Tap "I just ate"
- [ ] Four options visible
- [ ] Selecting one closes the sheet

## TC-2: Time editing
- [ ] Tap "Edit time" on resting card
- [ ] Input prefilled with logged time
```

After UAT, mark each checkbox and add a result line:

```markdown
## TC-1: Size picker renders — PASS
- [x] Tap "I just ate"
- [x] Four options visible
- [x] Selecting one closes the sheet
```

## Archiving

When a ticket ships or is abandoned:
1. Move `TICK-NNN-*.md` to `docs/archive/`
2. Move its `TEST-NNN-*.md` to `docs/archive/`
3. Leave `PLAN-NNN-*.md` in `docs/plans/` (design docs are reference material)
4. Update `BACKLOG.md`

## Supersession

When a larger feature absorbs a smaller ticket:
1. Set the smaller ticket's status to `abandoned`
2. Add `superseded-by: TICK-NNN` to its frontmatter
3. Add the smaller ticket's ID to the larger ticket's `supersedes: []` list
4. Move the abandoned ticket to archive

## Migration from old system

The old system used `UPDATES.md` (monolithic), `PLAN_name.md` (no IDs), and mixed naming (`TICKET_2_body_map` vs `TICKET-2-body-map`). The new system retains the content but reorganizes it:

| Old | New |
|---|---|
| UPDATES.md entries | Individual TICK files |
| UPDATES.md "Shipped" section | Archive + BACKLOG.md shipped list |
| `PLAN_morning_checkin.md` | `PLAN-005-morning-checkin.md` |
| `TICKET_3_meal_logging.md` | `TEST-003-meal-size.md` |
| `TESTING_WAVE_3.md` | Retired — waves tracked in BACKLOG.md |

UPDATES.md is retired once migration is complete. Existing archive files keep their names (not worth the churn to rename shipped work).
