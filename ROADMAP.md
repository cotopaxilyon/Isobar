# Isobar — Roadmap

Items here are not yet specced. Each requires a research phase before implementation can be planned. When research is complete, implementation steps move to UPDATES.md.

---

## 1. Database

**Current state:** All data is stored in `localStorage` as JSON blobs with hand-rolled keys. This works but has no structure, no querying, and no schema enforcement.

**Research needed:**
- What are best practices for client-side storage in health tracking PWAs? (IndexedDB, SQLite via WASM, localStorage limits and failure modes)
- What structure suits this app's access patterns — frequent appends, occasional full reads for export, keyed lookups for open episodes?
- What migration path exists from the current flat localStorage format to a proper schema without data loss?

**Output:** A written implementation plan (UPDATES.md format) covering chosen storage layer, schema design, migration strategy, and any changes to the read/write API used throughout `index.html`.

---

## 2. Testing

**Current state:** No automated tests. All verification is manual, step-by-step checks in UPDATES.md.

**Research needed:**
- What are best practices for testing a vanilla JS single-file PWA with no build step?
- What testing tools work without a bundler or framework (e.g. Playwright, Puppeteer, or lightweight unit test runners)?
- What test coverage makes sense for this app — unit tests for logic (pressure calculations, fasting timers, duration math), integration tests for form flows, or end-to-end tests for critical paths?
- How do we test offline behavior and service worker logic?

**Output:** A written testing plan covering chosen tools, setup steps, test categories, and which critical paths to cover first.

---

## 3. Hormonal Cycle Tracker

**Current state:** The daily check-in has a single `hormonalSymptoms` yes/no/mild field. This produces noisy daily data and does not capture cycle phase, which is what actually correlates with autoimmune symptom flares and episode frequency. The field is being removed from the morning check-in (see PLAN_morning_checkin.md) and needs a better home.

**Research needed:**
- What cycle-tracking structure is most useful for a perimenopausal patient with irregular cycles (not a predictive fertility model)?
- What symptoms correlate with cycle phase in the autoimmune / dysautonomia / MCAS literature, and how are they typically captured?
- What's the minimum data entry burden that still produces useful phase-correlated output for specialists?
- How should cycle-phase data be joined against episode frequency and check-in severity for the export report?

**Output:** A written implementation plan covering data model (cycle start/end, phase inference, symptom tagging), UI entry points (separate view vs inline prompts), and how the export report should surface cycle-correlated patterns.

---

## 4. Reminders & Notifications

**Current state:** The app has no reminder system. Consistent logging depends on memory. For a morning check-in specifically, a scheduled prompt would meaningfully improve data consistency — which is the single biggest factor in whether the longitudinal data is clinically useful.

**Research needed:**
- What notification capabilities are available to an installed PWA on iOS and Android in 2026, and what are the permission flows?
- What works offline and what requires a push service? (Local scheduled notifications vs server-pushed)
- What is the simplest implementation that works without adding backend infrastructure? (The app is currently fully client-side and should stay that way if possible.)
- What reminder cadence is supported by the research on adherence in chronic-illness symptom tracking — morning-only, morning + fasting alerts, configurable?
- How do we handle missed reminders gracefully (don't shame, don't pile up)?

**Output:** A written implementation plan covering notification API choices, permission UX, scheduling logic, user controls (enable/disable, time selection), and offline behavior.
