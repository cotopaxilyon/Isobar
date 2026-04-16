# Isobar — Testing Guide

## Core Principle

Test data must never mix with real data. All testing happens in an **incognito/private browser window**, which isolates localStorage completely from your real session and wipes it when the window closes.

---

## Local Testing (before committing)

Since changes live in `index.html` on disk, you can test them before committing by opening the file directly in an incognito window.

1. Make your changes to `index.html`
2. Open an incognito window (Safari: ⌘⇧N, Chrome: ⌘⇧N, Firefox: ⌘⇧P)
3. Drag `index.html` into the incognito window, or use File > Open
4. Test the app — localStorage is isolated from your real data
5. Close the window when done — test data is gone automatically

---

## Post-Deploy Testing (after pushing)

Once changes are live at https://cotopaxilyon.github.io/Isobar/, open that URL in an incognito window and repeat the same steps. This confirms the deployed version works correctly.

---

## Smoke Test (run after any change)

1. Load the app in incognito
2. Set up a PIN — confirm you reach the home screen
3. Log a check-in — go through all steps, save it
4. Log an episode — go through all steps, save it
5. Open the log — confirm both entries appear correctly

If you changed a specific form or flow, pay extra attention to that part.

---

## Notes

- No automated tests — all testing is manual in a browser
- The service worker caches aggressively; hard refresh (⌘⇧R) in incognito if you're not seeing your latest local changes
- The "Clear All Data" button in settings wipes all entries but keeps the PIN — use this if you ever accidentally log something in the real session
