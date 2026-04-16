# Testing — Wave 2: Environmental Risk Surface

One ticket replacing the entire pressure/weather risk system.

---

## Tickets

| # | Ticket | File |
|---|--------|------|
| ENV-RISK | Three-axis environmental risk engine | [TICKET_ENV_RISK_engine.md](TICKET_ENV_RISK_engine.md) |

---

## Test order

1. **Ticket ENV-RISK** — all 9 check groups
2. **Smoke test** — full pass to catch regressions

---

## Smoke test

After testing the ticket, run a clean end-to-end pass:

1. Load the app in incognito → set PIN → allow location → reach home screen.
2. Confirm weather card loads and displays the three-axis layout.
3. **Log a check-in** — go through all steps, save.
4. **Log an episode** — go through all steps, save.
5. Open **View Log** — confirm both entries appear with correct data.
6. Tap **Export** — confirm the report generates without errors.
7. Open **Settings** — confirm the page loads.
8. Check the browser console for any JavaScript errors throughout.

---

## Results template

Copy and fill in:

```
## Wave 2 Test Results — [DATE]

### Ticket ENV-RISK: Environmental risk surface
- [ ] Weather card shows 3 risk cells (dwell full-width, drop+rise side by side)
- [ ] Colored left borders match axis risk level
- [ ] Reference row shows current readings + 6h trends
- [ ] Header shows dwell-hours, not absolute pressure
- [ ] Banner appears on red axis, static (no flash)
- [ ] Banner text includes "episode likely" and "Recommend"
- [ ] Banner absent when all axes green
- [ ] Axis A thresholds correct (green < 12, amber 12–24, red ≥ 24)
- [ ] Axis B thresholds correct (green < 10, amber 10–14, red ≥ 14)
- [ ] Axis C thresholds correct (green < 10, amber 10–14, red ≥ 14)
- [ ] Compound meal alert fires on any axis amber/red + fasting ≥ 4h
- [ ] Compound sub-text says "Environmental risk elevated"
- [ ] Logged entry weather object contains new fields
- [ ] Export includes dwell + temp drop/rise lines for new entries
- [ ] Old entries export without error
- [ ] No layout overflow on 375px
- [ ] No old weather card layout visible
- [ ] No old header pressure display
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
