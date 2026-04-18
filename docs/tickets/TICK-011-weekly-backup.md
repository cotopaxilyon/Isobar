---
id: TICK-011
title: Weekly backup prompt + Web Share JSON export
status: pending
priority: high
wave: 0
created: 2026-04-17
updated: 2026-04-17
plan: docs/plans/PLAN_data_persistence.md
test: null
linear:
  parent: ISO-41
  test: ""
depends-on: [TICK-009]
supersedes: []
shipped: ""
---

# TICK-011: Weekly Backup Prompt

## Summary

Every 7 days, surface a non-blocking home-screen card prompting the user to save a full JSON snapshot of their data. Tap → `navigator.share()` with a JSON file → user saves to iCloud Drive. Layer 3 of the durability strategy — the only layer that survives hardware loss or browser-level wipe. Keeps custody with the user; no server, no third party.

## Acceptance Criteria

- [ ] Home-screen card appears when `Date.now() - backup:lastAt > 7 days` (or when `backup:lastAt` is unset)
- [ ] Card shows "Back up your data — N days since last backup" and dismiss-to-snooze for 24h
- [ ] Tapping the card triggers `navigator.share({ files: [...] })` with the full `kv` export as `.json`
- [ ] Desktop fallback: if `navigator.canShare({ files })` is false, anchor-download with the same payload
- [ ] User taps "Done" in a follow-up toast → `backup:lastAt` written to `kv`

## Agent Context

- Payload shape: `{ version: 1, exportedAt: <ISO>, appVersion: <CACHE_VERSION>, rows: [{key, value, updatedAt}] }`. Pretty-printed JSON.
- MIME type `application/json`, filename `isobar-backup-YYYY-MM-DD.json`.
- Do NOT auto-confirm backup on share-sheet close — the event is unreliable across browsers. Require explicit user tap on the follow-up toast.
- Card lives on the home screen, not behind a modal. Non-blocking.
- Snooze key: `backup:snoozedUntil` (ISO timestamp). Snooze = hide card for 24h, not reset the 7-day timer.
- Copy escalation (4+ weeks overdue) is **out of scope** for v1 — ship the basic prompt first.

## Implementation Notes

Reuse the Dexie transaction from TICK-009 to dump all rows in one pass. JSON stringify can get large (MBs) in a few months — acceptable, Web Share handles it.

UX principle: user is in control. No silent exports, no background sync, no auto-dismiss. Every backup is an explicit choice.

## Ship Notes

_(pending)_
