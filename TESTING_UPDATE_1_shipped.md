# Testing — Update 1: Communication Scale Revision

Tests the new four-value comm scale: `normal` / `quieter` / `shortened` / `brief`.

---

## 1. Check-in form

1. Open app → **Daily Check-in**.
2. On the communication step (step 0), confirm four buttons appear in this order:
   - Talking easily — normal back and forth *(green)*
   - Quieter than usual — responding, not initiating *(yellow)*
   - Shorter responses — harder to elaborate *(orange)*
   - Brief only — yes/no or less *(red)*
3. Tap each — confirm highlight color matches the label.
4. Select one, tap **Next →**, then go **Back** — confirm selection persists.
5. Complete and save the check-in.

## 2. Episode form

1. **Log Episode** → step through to the communication step (step 3).
2. Confirm the same four labels and colors appear as in the check-in form.
3. Select one, continue, and save the episode.

## 3. Log view — colors

1. Open **View Log**.
2. Find the entries saved above.
3. Check-in entry: confirm the comm chip shows the value in the correct color.
4. Episode entry: confirm the comm text in the expanded card shows in the correct color.
5. Home screen recent episodes: confirm the comm chip renders in the new color (this comes from `updateStats()`).

## 4. Export

1. Tap **Export**.
2. In the generated text, confirm communication lines read as prose, not raw keys:
   - `Communication: Talking easily`
   - `Communication: Quieter than usual`
   - `Communication: Shorter responses`
   - `Communication: Brief only / yes-no or less`
3. Verify both an episode entry and a check-in entry show the mapped label.

## 5. Legacy data (regression)

Old entries saved before this change carry `effortful` / `minimal` / `nonverbal` values. They must still render without crashing.

1. If any pre-change entries exist, open **View Log** and confirm:
   - The page loads (no JS error in console).
   - Old comm chips render in gray (`var(--mid)` fallback), with the raw key as label.
2. In **Export**, confirm old entries print the raw key (e.g. `Communication: effortful`) rather than crashing.

If no legacy entries exist, skip — or temporarily inject one via DevTools:

```js
const data = JSON.parse(localStorage.getItem('isobarData'));
data.entries.unshift({
  type:'checkin', timestamp:new Date().toISOString(),
  entryDate:new Date().toISOString().slice(0,10),
  communicationLevel:'effortful'
});
localStorage.setItem('isobarData', JSON.stringify(data));
location.reload();
```

Remove the injected entry after testing.

---

## Pass criteria

- All four new labels appear in both forms, in order, with correct colors.
- Selections persist across step navigation and save correctly.
- Log view and home recent-episodes chips color-match the new scale.
- Export prints prose labels, not raw keys, for new entries.
- Legacy entries render without error (gray fallback acceptable).
