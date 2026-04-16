# Tickets — Update 1: Communication Scale Revision

Replace the old comm scale (`normal` / `effortful` / `minimal` / `nonverbal`) with the new four-value scale (`normal` / `quieter` / `shortened` / `brief`) across all surfaces.

Test plan: see `TESTING_UPDATE_1.md`.

---

## ISO-1 — Episode form: new comm scale

**Area:** `renderEpStep()` step 3 (`index.html` ~line 944)

Replace the four `commBtn(...)` calls with the new keys and labels:

- `normal` — "Talking easily — normal back and forth" *(green)*
- `quieter` — "Quieter than usual — responding, not initiating" *(yellow)*
- `shortened` — "Shorter responses — harder to elaborate" *(orange)*
- `brief` — "Brief only — yes/no or less" *(red)*

Selection persists on `epData.communicationLevel`.

---

## ISO-2 — Check-in form: new comm scale

**Area:** `renderCiStep()` (`index.html` ~line 1099)

Update the `['normal','effortful','minimal','nonverbal']` array and matching labels array to the new four keys/labels (same set as ISO-1). Colors array unchanged. Selection persists on `ciData.communicationLevel` across step navigation.

---

## ISO-3 — Log view & home recent-episodes: chip colors

**Area:** `renderLog()` (~line 1229) and `updateStats()` (~line 1267)

Update both `commColors` maps to key off the new values:

```js
{ normal:'var(--good)', quieter:'var(--warn)', shortened:'#f97316', brief:'var(--danger)' }
```

Both surfaces must color-match the new scale. Old keys fall through to the existing gray fallback.

---

## ISO-4 — Export: prose labels for comm

**Area:** `exportReport()` (~line 1304)

Add a `commLabels` map and use it when printing communication for both episodes and check-ins:

```js
const commLabels = {
  normal:'Talking easily',
  quieter:'Quieter than usual',
  shortened:'Shorter responses',
  brief:'Brief only / yes-no or less'
};
// ...
if (e.communicationLevel) r += `  Communication: ${commLabels[e.communicationLevel]||e.communicationLevel}\n`;
```

Unknown keys (legacy data) print the raw value rather than `undefined`.

---

## ISO-5 — Legacy data: no-crash regression

**Area:** all read sites above

Entries saved before this change carry `effortful` / `minimal` / `nonverbal`. They must continue to render:

- Log view & home chips: gray fallback (`var(--mid)`), raw key as label — no JS error.
- Export: raw key printed (e.g. `Communication: effortful`) via the `||e.communicationLevel` fallback in ISO-4.

No data migration; fallbacks only.
