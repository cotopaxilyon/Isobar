# Health Tracker — GitHub Pages Deployment Guide

## What you're deploying
4 files: index.html, manifest.json, sw.js, icon.svg
These go into a GitHub repository and GitHub serves them as a website.

---

## STEP 1 — Create a GitHub repository

1. Go to github.com and sign in
2. Click the + button (top right) → "New repository"
3. Name it: health-tracker (or anything you like)
4. Set to PRIVATE (important for your medical data)
5. Check "Add a README file"
6. Click "Create repository"

---

## STEP 2 — Upload your files

1. In your new repository, click "Add file" → "Upload files"
2. Upload all 4 files:
   - index.html
   - manifest.json
   - sw.js
   - icon.svg
3. Scroll down, click "Commit changes"

---

## STEP 3 — Enable GitHub Pages

1. In your repository, click "Settings" (top menu)
2. Scroll down to "Pages" in the left sidebar
3. Under "Source", select "Deploy from a branch"
4. Branch: main | Folder: / (root)
5. Click Save
6. Wait 2-3 minutes
7. GitHub will show you your URL: https://YOURUSERNAME.github.io/health-tracker

---

## STEP 4 — Add to iPhone Home Screen

1. Open Safari on your iPhone (must be Safari, not Chrome)
2. Go to your GitHub Pages URL
3. Tap the Share button (box with arrow pointing up)
4. Scroll down and tap "Add to Home Screen"
5. Name it "Health" → tap Add
6. The app icon appears on your home screen

---

## STEP 5 — Allow Location Access

1. Open the app from your home screen
2. When prompted for location, tap Allow
3. If you missed it: Settings → Safari → Location → find your site → Allow While Using App

---

## FIRST TIME USE

1. Open the app — you'll be asked to set a 4-digit PIN
2. Choose your PIN and confirm it
3. The app loads to the home screen
4. Tap "Get Weather" to load your first pressure reading
5. Start logging

---

## IMPORTANT NOTES

**Data storage:** Your data lives ONLY on your iPhone in Safari's storage.
- Do not clear Safari website data or you will lose your history
- Export your report regularly as a backup (Log tab → Export)
- Data does NOT sync across devices — it's only on the phone you use

**Private repository:** Since your repo is private, the URL is not guessable,
but anyone who has the URL can access the app. The PIN protects the data.

**Updating the app:** If you need to update the app in the future,
just upload new files to GitHub and they'll deploy automatically within minutes.

---

## TROUBLESHOOTING

"Location denied" — Go to Settings → Safari → Location → your site → Allow
App not installing — Must use Safari, not Chrome or Firefox on iPhone
Weather not loading — Check your internet connection and retry
PIN forgotten — Go to Settings in the app → Change PIN (requires knowing current PIN)
             — If locked out: Settings → Safari → Advanced → Website Data → delete site → reinstall

---

Questions? The app is fully offline-capable once installed.
Your data never leaves your device.
