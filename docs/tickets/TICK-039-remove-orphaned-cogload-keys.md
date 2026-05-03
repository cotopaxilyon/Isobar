---
id: TICK-039
title: Remove orphaned cog-load keys from data model, export map, and log chip
status: done
priority: normal
wave: cleanup
created: 2026-05-03
updated: 2026-05-03
plan: null
test: null
linear:
  id: ISO-108
  parent: null
  test: ""
depends-on: [TICK-030]
supersedes: [TICK-038]
shipped: "2026-05-03"
---

# TICK-039: Remove Orphaned Cog-Load Keys

## Summary

Three cognitive-load keys (communicationProduction, efLogistics, anticipatory) were intentionally dropped from the EOD form during TICK-030 (too noisy for regular use) but survived in three places in index.html:

- `eodData.cogLoad` initializer — keys initialized to `false` on every new EOD entry
- `cogMap` export array — dead entries, could never match (keys always `false`)
- Log chip `some()` key list — dead keys in the truthy check

All three removed. No behavior change for any active data path. Historical records have these keys as `false` so nothing disappears from existing exports.

## Acceptance Criteria

- [x] `eodData.cogLoad` initializer has 5 keys only (thinkingSustained, masking, maskingHeavy, highSensory, emotionalRegulation)
- [x] `cogMap` export array has 5 entries only
- [x] Log chip `some()` key list has 5 keys only
- [x] No SW cache bump
- [x] Architecture check returns empty

## Ship Notes

QA Pass 2026-05-03. All 6 ACs verified. Silent-loss contract change confirmed safe: live IDB audit shows all 3 dropped keys are `false` in all historical records. Split commit: ISO-108 carries only this cleanup; `backfillMissingWeather` shipped separately.
