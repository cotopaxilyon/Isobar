# Isobar — Check-in Card Visibility

**Status:** Draft  
**Date:** 2026-05-01  
**Scope:** Hide morning check-in after completion; keep evening check-in visible until 3am

---

## Problem

**Morning check-in** — the action button is always visible, even after the day's check-in is done. No feedback that it's already been logged.

**Evening check-in card** — `getHours() < eveningHour` makes it disappear at midnight. If you finish the day late (1am, 2am), the card is already gone.

---

## Changes

### 1. Morning check-in: hide after completion

**HTML** (`index.html` ~line 418)  
Add `id="morning-checkin-btn"` to the morning action card button.

**New function** `renderMorningCard()`  
Mirrors the pattern of `renderEodCard()`:

```js
async function renderMorningCard() {
  const btn = document.getElementById('morning-checkin-btn');
  if (!btn) return;
  const now = new Date();
  const todayKey = localDateISO(now);
  const entries = await DB.allEntries();
  const hasCiToday = entries.some(e => e.type === 'checkin' && e.entryDate === todayKey);
  btn.style.display = hasCiToday ? 'none' : '';
}
```

**Call sites** — add `renderMorningCard()` alongside `renderEodCard()` in `updateStats()`. That covers:
- Home screen load
- After `saveCheckin()`
- After `switchView('home')`
- After backup import / data wipe

No other call sites needed.

---

### 2. Evening card: extend visibility until 3am

**In `renderEodCard()`** — replace the current early-exit:

```js
// before
if (now.getHours() < hour) { card.style.display = 'none'; return; }
```

```js
// after
const h = now.getHours();
const isEarlyMorning = h < 3;
const afterEvening = h >= hour;
if (!afterEvening && !isEarlyMorning) { card.style.display = 'none'; return; }
```

**Date key for completion/snooze checks** — when in the early-morning window, the entry and snooze were recorded against *yesterday's* date:

```js
const todayKey = localDateISO(now);
const checkKey = isEarlyMorning
  ? localDateISO(new Date(now.getTime() - 86400000))
  : todayKey;
```

Replace both uses of `todayKey` in `renderEodCard()` (snooze check + `hasEodToday`) with `checkKey`.

---

## Acceptance criteria

- [ ] After saving a morning check-in, the Morning Check-in button is no longer visible on the home screen
- [ ] Reloading the app (same day, after a check-in is saved) keeps the button hidden
- [ ] The button reappears the following day (new `todayKey`)
- [ ] Evening card remains visible at 12:30am if not yet completed that evening
- [ ] Evening card is hidden at 12:30am if already completed before midnight
- [ ] Evening card disappears at 3:00am regardless
- [ ] Snooze set before midnight still suppresses the card in the early-morning window
- [ ] No change to card behavior between 3am and the configured evening hour

---

## Non-changes

- The morning check-in is still accessible via history — this only affects the home-screen shortcut button
- Evening card snooze behavior is otherwise unchanged
- No new settings; the 3am cutoff is hardcoded
