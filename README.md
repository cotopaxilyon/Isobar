# Isobar — Health Tracking PWA
## README for Claude Code

---

## What This Is

Isobar is a personal health tracking Progressive Web App (PWA) built for a specific patient: a 37-year-old autistic woman with a complex, undiagnosed multisystem illness involving episodic myoclonus, autonomic dysfunction, suspected Stiff Person Syndrome spectrum, autoimmune connective tissue disease, and post-COVID dysautonomia.

The app exists because standard symptom tracking tools are built for neurotypical users with straightforward conditions. This patient has:
- **Alexithymia and high pain tolerance** — standard 0-10 pain scales systematically underreport her actual state
- **Cognitive symptoms** — brain fog, memory gaps, and variable daily function mean the interface must work when she is at her worst
- **A specific set of environmental triggers** — barometric pressure drops, temperature changes, fasting, and allergen exposure that precede neurological episodes
- **No coordinating physician** — she is managing multiple specialists independently and needs objective longitudinal data to bring to appointments

The app is her medical diary, her early warning system, and her data collection tool for specialist visits.

---

## The Patient Context (Essential for Building This Well)

**Primary symptoms being tracked:**
- Episodic myoclonus — limb jerking episodes lasting 30 minutes to 4 hours, every few days
- Specific prodromal sequence: crushing fatigue → altered consciousness → lower back pressure → leg energy → left facial tingling → episode onset
- Post-episode weakness requiring a cane (genuine weakness, must consciously direct walking)
- Temperature dysregulation — functional window approximately 50-90°F stable
- Chronic pain, non-restorative sleep, RLS, brain fog, fatigue

**Key trigger factors:**
- Barometric pressure drops (>3 hPa in 6 hours is the critical threshold)
- Rapid temperature change (delta more than absolute temperature)
- Fasting (4+ hours begins affecting GABAergic stability and autonomic function)
- Animal/allergen exposure (MCAS suspected)
- New environments, mold exposure, hormonal fluctuation

**Why pain assessment is designed differently:**
Standard numeric scales are unreliable for autistic adults with alexithymia and high pain tolerance. The app uses:
- Communication capacity (primary severity indicator — can she hold a conversation?)
- Functional impact anchors (did she nap, cancel plans, need the cane?)
- Body map location taps (where, not how much)
- Sensation descriptors (tight/aching/burning/pressure — concrete, not numeric)
- Arizona comparison (personal baseline anchor — 4 weeks in stable 80-90°F desert produced complete symptom relief, the clearest baseline she has)
- External observation (has anyone around her noticed she seems quiet or flat — because flat tone and quiet voice are reliable distress signals she may not self-perceive)

---

## Current State of the App

### What's Built (v1.0)
Single HTML file PWA deployable to GitHub Pages.

**Features:**
- 4-digit PIN protection
- GPS-based barometric pressure via Open-Meteo API (free, no key required)
- Pressure status display with rapid-drop alert (>3 hPa in 6 hours)
- Episode logging — 9-step form capturing: timing, prodrome sequence, limb distribution, chest tightness, cane use, communication level, external observation, triggers, pain location (body map), sensations, severity vs Arizona baseline
- Daily check-in — communication level, body map, exhaustion functional anchors, sleep, hormonal symptoms, Arizona comparison
- Meal tracking — "I just ate" button with fasting timer, time-of-day specific food suggestions, compound risk alert when falling pressure + fasting coincide
- Full log view with entry cards
- Export — generates plain text report formatted for neurologist
- localStorage data storage (private, device-only)
- Service worker for offline support

**Current files:**
- `index.html` — entire app (single file, ~1500 lines)
- `manifest.json` — PWA manifest
- `sw.js` — service worker
- `icon.svg` — app icon

**Deployed at:** `https://cotopaxilyon.github.io/Isobar/`

**Known issue:** Black screen on load — suspected cause is Google Fonts import blocking render or service worker caching a broken version. Most recent fix: removed Google Fonts dependency (replaced with system fonts) and disabled service worker. Needs verification.

---

## Short-Term Goals (Next Session)

### Priority 1 — Fix the black screen
The app is currently not rendering. This is the blocker. Diagnose and fix whatever is preventing the PIN screen from appearing on load. Check browser console for errors.

### Priority 2 — Push notifications for compound alerts
The most clinically valuable feature not yet built. When barometric pressure drops rapidly AND the patient has been fasting 4+ hours, a push notification should fire even when the app is not open.

**Recommended approach: ntfy.sh integration**
- Free, open source push notification service
- No account required for basic use
- Patient installs the ntfy iOS app, subscribes to a private topic (e.g. `isobar-cotopaxi-[random]`)
- The service worker checks pressure + fasting status on a schedule
- When thresholds crossed, calls `https://ntfy.sh/[topic]` with the alert
- Works reliably on iPhone even when PWA is not open

**Alternatives considered:**
- Native PWA push — unreliable on iOS
- Pushover — $5 one-time, very reliable, polished
- Telegram bot — free, reliable if she uses Telegram
- iPhone Shortcuts automation — maximum privacy, no external service, slightly more complex setup

Patient has not yet decided which push approach to use. Discuss with her before building.

### Priority 3 — Name and rename
The app is named Isobar (after isobar lines on weather maps connecting equal pressure points). Update any "Health Tracker" references in the UI to "Isobar".

### Priority 4 — Font fix
Replace system fonts with a proper embedded or self-hosted font that doesn't require an external request. The original design used Sora (body) and JetBrains Mono (data/numbers). Either embed them as base64 or load from a reliable CDN with a system font fallback that doesn't block render.

---

## Long-Term Vision

### Phase 2 — Data persistence and sync
localStorage means data is lost if Safari storage is cleared or phone is changed. Long-term the data should survive device changes. Options:
- iCloud sync via CloudKit (ideal for iPhone-only use, free, private)
- Simple backend with a private API key (more complex but cross-platform)
- Regular export reminders with iCloud Files backup

### Phase 3 — Intelligent correlation
The app is collecting structured data with timestamps, weather, triggers, communication level, and severity. Over weeks of data this should be able to surface patterns automatically:
- "Your last 3 episodes all occurred within 6 hours of a pressure drop of X or more"
- "Episodes are 3x more frequent when fasting coincides with falling pressure"
- "Your communication level correlates most strongly with barometric pressure, not hormonal cycle"
This data would be formatted into a monthly report for specialist appointments.

### Phase 4 — Specialist report generation
A formatted, physician-ready report that pulls from the log and presents:
- Episode frequency over time (chart)
- Top correlated triggers ranked by frequency
- Functional impact trend (work capacity, nap frequency, cancelled plans)
- Communication level distribution
- Pressure data at time of each episode
- Formatted for neurologist, rheumatologist, or autonomic specialist

### Phase 5 — Caregiver view
The patient has a nurse roommate and boyfriend who are part of her support system. A read-only view they could access would let them see her current status (last episode, current fasting time, pressure status) without accessing the full data log. This would require a backend.

### Phase 6 — Wearable integration
The patient uses a Garmin watch. HRV and body battery data from Garmin Connect is potentially valuable for correlating autonomic stability with symptoms. Garmin Connect API integration would allow automatic import of HRV trends to correlate with episode timing.

---

## Design Principles — Do Not Violate These

**1. Works when she is at her worst**
Every interaction must be completable with minimal cognitive load. Large tap targets. One question at a time in step forms. No required fields that block saving. If she can only tap two things before an episode gets bad, those two taps should capture the most critical data.

**2. No 0-10 numeric pain scales**
These are explicitly not used anywhere in the app. They are unreliable for autistic adults with high pain tolerance and alexithymia. Every instance of numeric pain rating should be replaced with functional anchors, location maps, sensation descriptors, or comparative baselines.

**3. Communication capacity is the primary severity indicator**
"Can you hold a normal conversation right now?" is more valid than any numeric scale for this patient. It appears in both episode logging and daily check-in. Do not remove or bury it.

**4. The Arizona baseline is the reference point**
All severity comparisons are anchored to her 4-week period in Arizona (stable 80-90°F desert, complete symptom resolution). "Compared to Arizona" is her personal calibration. This is more valid than population-level scales.

**5. Data privacy is non-negotiable**
All data stays on device. No analytics. No telemetry. No third-party data collection. Any backend introduced must be end-to-end encrypted or zero-knowledge. The PIN exists because this contains medical data.

**6. The interface must work offline**
She travels frequently and lives in the Upper Peninsula of Michigan where cell coverage is inconsistent. The app must function without internet (except weather fetching, which gracefully degrades).

---

## Technical Specifications

**Stack:**
- Vanilla HTML/CSS/JavaScript — no framework, no build step, single file
- localStorage for data persistence
- Open-Meteo API for weather (free, no key, GPS-based)
- Service worker for offline support
- PWA manifest for home screen installation

**Data structure — episode entry:**
```json
{
  "type": "episode",
  "timestamp": "ISO string",
  "prodromeTime": "HH:MM",
  "firstJerkTime": "HH:MM",
  "prodrome": ["fatigue", "altered", "back_pressure", "left_face"],
  "limbsAffected": ["right_leg", "bilateral_legs", "left_arm"],
  "bodyPain": ["chest", "lower_back"],
  "sensations": { "chest": ["Squeezing", "Tight"], "lower_back": ["Pressure"] },
  "chestTight": true,
  "cane": false,
  "communicationLevel": "minimal",
  "externalObservation": "Yes",
  "triggers": ["weather", "fasting", "animal", "new_env"],
  "fastedHours": "7",
  "notes": "First return to roommate's house in a month. Dog present.",
  "severity": "far_away",
  "weather": {
    "pressure": 976.5,
    "trend": -4.2,
    "currentTemp": 41,
    "precip": 0.3,
    "lat": 46.54,
    "lon": -87.4,
    "fetchedAt": "6:28 PM",
    "timestamp": "ISO string"
  }
}
```

**Data structure — check-in entry:**
```json
{
  "type": "checkin",
  "timestamp": "ISO string",
  "communicationLevel": "normal",
  "externalObservation": "No",
  "bodyPain": ["neck", "lower_back"],
  "sensations": {},
  "nap": "Yes",
  "napHours": "2",
  "workCapacity": "reduced",
  "cancelledPlans": "No",
  "heatTherapy": ["heating_pad", "shower"],
  "sleep": "poor",
  "hormonalSymptoms": "Mild",
  "episodesSinceLast": "1",
  "notes": "",
  "severity": "somewhat",
  "weather": { "..." : "..." }
}
```

**Storage keys:**
- `entry:[timestamp]` — episode and check-in entries
- `meal:last` — timestamp of last logged meal
- `pin` — hashed 4-digit PIN

---

## Food Suggestions Logic

When fasting timer crosses 4 hours, the app suggests food. The suggestions are:
- **Vegetarian** (patient does not eat meat)
- **Gluten-free** (documented intolerance)
- **Egg-free** (documented allergy)
- **Low-dairy** (intolerance — small amounts of hard cheese/yogurt tolerated)
- **No high-histamine foods** when possible (MCAS suspected — red wine, aged cheese, fermented foods are triggers)

The suggestion framework:
- Protein + fat + small carbohydrate together (not carbs alone, not fat/protein alone)
- Escalating urgency at 4h / 5h / 7h / compound (pressure falling + fasting)
- Time-of-day variation (morning / midday / afternoon / evening suggestions differ)
- Compound alert: falling pressure + 4h fasted = most urgent, explicit reasoning given

---

## Clinically Important Details for Any Developer

The prodromal sequence is specific and reproducible and should be preserved exactly:
1. Crushing fatigue
2. Altered consciousness / feeling "high"
3. Blurry vision
4. Pressure/energy building in lower back
5. Energy building in right leg (or left leg)
6. Left facial tingling (cheek and jaw, left side) — this is the last sign before episode onset
7. Episode begins — right leg first, then bilateral legs, then left arm and right leg

This sequence has diagnostic significance. The left facial tingling as the final prodromal sign before right-leg-initiated myoclonus is a bottom-up spinal propagation pattern consistent with spinal myoclonus. It should be logged precisely and completely.

The communication capacity question is not just a UX convenience — it is a clinically validated severity proxy for an autistic patient with alexithymia. It bypasses interoceptive translation entirely. Do not simplify it or remove options.

The Arizona comparison is not a whim — it is her only documented period of complete symptom resolution (4 continuous weeks in stable 80-90°F desert environment, spring 2026). It is the most meaningful personal baseline available. Keep it as the severity anchor.

---

## Repository
`https://github.com/cotopaxilyon/Isobar`

Deployed at: `https://cotopaxilyon.github.io/Isobar/`

Built: April 2026
Patient: Cotopaxi Lyon, Marquette MI
