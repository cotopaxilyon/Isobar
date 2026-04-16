# Testing — Wave 1: Header Cleanup + Body Map Grid

Two changes shipped in Wave 1. Test each ticket independently, then run the smoke test.

---

## Tickets

| # | Ticket | File |
|---|--------|------|
| 9A | Remove patient name from header | [TICKET_9A_header_cleanup.md](TICKET_9A_header_cleanup.md) |
| 2 | Body map grid replacement | [TICKET_2_body_map_grid.md](TICKET_2_body_map_grid.md) |

---

## Test order

1. **Ticket 9A** — header cleanup (quick, 2 checks)
2. **Ticket 2** — body map grid (larger, 6 check groups)
3. **Smoke test** — full pass to catch regressions

---

## Smoke test

After testing both tickets individually, run a clean end-to-end pass:

1. Load the app in incognito → set PIN → reach home screen.
2. Confirm home screen renders cleanly: header, weather card, action grid.
3. **Log a check-in** — go through all steps including pain location. Save.
4. **Log an episode** — go through all steps including pain location. Save.
5. Open **View Log** — confirm both entries appear with correct data.
6. Tap **Export** — confirm the report generates without errors and includes pain data.
7. Open **Settings** — confirm the page loads and all options are functional.
8. Check the browser console for any JavaScript errors throughout.

---

## Results template

Copy and fill in:

```
## Wave 1 Test Results — [DATE]

### Ticket 9A: Header cleanup
- [ ] Home screen shows "ISOBAR" only
- [ ] No "Cotopaxi" text
- [ ] Log/Settings headers unaffected
- [ ] Layout looks clean

### Ticket 2: Body map grid
- [ ] 18 regions in 4 labeled sections
- [ ] 4 new regions present (R. Jaw, L. Jaw, R. Ribs, L. Ribs)
- [ ] Blue toggle on/off works
- [ ] Selections persist across step nav
- [ ] Check-in form — body map works
- [ ] Episode form — body map works
- [ ] Log view shows selected regions
- [ ] Export includes region data
- [ ] No overflow on 375px width
- [ ] No console errors

### Smoke test
- [ ] PIN setup works
- [ ] Check-in end-to-end saves
- [ ] Episode end-to-end saves
- [ ] Log view renders both entries
- [ ] Export generates cleanly
- [ ] No JS errors in console

OVERALL: [ PASS / FAIL ]
Notes:
```
