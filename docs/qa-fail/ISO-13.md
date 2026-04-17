---
ticket: ISO-13
title: Service worker getRegistrations() returns 0 on every load
status: reviewed
drafted: 2026-04-16
---

# Fix plan — ISO-13

## TL;DR

The SW install fails silently at every non-`/Isobar/` origin (including local QA at `localhost:8000/`) because `sw.js:2` hardcodes the GitHub Pages base path in its asset precache list. `manifest.json` has the same hardcoded assumption. Recommend switching both to **relative paths**, which works everywhere, and codifying "no hardcoded base path" as a standing rule so the issue doesn't regress on the next asset addition.

## Failure classification

**Type (a) — surface bug in new code, partially.** `c7d0335` ("SW registration fix") added the missing `register()` call and was correct, but left the underlying `sw.js` asset paths untouched. The visible registration now succeeds in the browser, but ~2s later the SW install transitions to `redundant` because `caches.addAll()` rejects on 404s for `/Isobar/index.html` et al.

**More precisely: latent defect exposed by the fix.** The hardcoded `/Isobar/` paths were introduced in `ed772c1` ("Rename to Isobar") — the rename switched sw.js from `['/', '/index.html', …]` to `['/Isobar/', '/Isobar/index.html', …]` to match GitHub Pages. That silently broke every non-production origin for two months. The defect only became observable once `c7d0335` fixed the separate issue of the missing `register()` call.

## Root cause

Three hardcoded references to the GitHub Pages base path:

| File            | Line | Current                                                                                 | Problem                                                                 |
|-----------------|------|-----------------------------------------------------------------------------------------|-------------------------------------------------------------------------|
| `sw.js`         | 2    | `const ASSETS = ['/Isobar/', '/Isobar/index.html', '/Isobar/manifest.json', '/Isobar/icon.svg'];` | At any origin not rooted at `/Isobar/`, all four are 404 → install fails |
| `manifest.json` | 5    | `"start_url": "/Isobar/"`                                                                | PWA install / launch tries `/Isobar/` at any origin                      |
| `manifest.json` | 6    | `"scope": "/Isobar/"`                                                                    | SW scope restricted to `/Isobar/` subtree                                |

`index.html:1834-1838` correctly registers with the relative path `'sw.js'`, which is why registration *appears* to succeed for the first ~2s. The failure is downstream in the install handler's `addAll`.

The reason this cache-version bumps keep missing users: **none of them ever installed a working SW in the first place on environments that aren't the GitHub Pages origin.** Each `isobar-v1 → v2 → v3 → v4` bump was a no-op for local dev and for the QA harness.

## Why this is architecturally brittle

The app hardcodes a single deployment target (`github.io/Isobar/`) into artifacts that should be origin-agnostic. That coupling will keep biting any time the asset surface changes:

- Adding a new precached file = one more path to hardcode (and one more opportunity to forget).
- Moving the repo (fork, rename, custom domain) = silent breakage.
- Local dev = SW never installs, so offline-capability claims aren't testable without a reverse proxy.
- QA env = same, which is how this one slipped through two cache-version bumps.

PWAs generally handle this by making paths relative to the service-worker script or the manifest. When `sw.js` lives at `/Isobar/sw.js`, `./index.html` inside it resolves to `/Isobar/index.html` automatically — same absolute URL as today's hardcoded string. At `localhost:8000/sw.js`, `./index.html` resolves to `/index.html` — correct for that origin. One source, both work.

## Proposed fix

### 1. `sw.js:2` — relative paths

```diff
-const CACHE = 'isobar-v4';
-const ASSETS = ['/Isobar/', '/Isobar/index.html', '/Isobar/manifest.json', '/Isobar/icon.svg'];
+const CACHE = 'isobar-v5';
+// Relative paths — resolved against the SW script URL so the app is origin-agnostic.
+const ASSETS = ['./', './index.html', './manifest.json', './icon.svg'];
```

Why bump to `v5`: any GitHub Pages user whose browser still has a working `v3` or `v4` registration (unlikely given this has been broken, but possible) gets a clean shell on next visit.

### 2. `manifest.json` — relative `start_url` and `scope`

```diff
 {
   "name": "Isobar",
   "short_name": "Isobar",
   "description": "Personal health tracking",
-  "start_url": "/Isobar/",
-  "scope": "/Isobar/",
+  "start_url": "./",
+  "scope": "./",
```

Relative values resolve against the manifest URL. On GitHub Pages, `./` at `/Isobar/manifest.json` = `/Isobar/` (unchanged). On localhost, it's `/` (correct).

### 3. Standing rule — no hardcoded base paths in shell assets

Add a short note to `docs/PROCESS.md` (or a new `docs/ARCHITECTURE.md` — see open questions) documenting: *`sw.js`, `manifest.json`, and `index.html` must not hardcode `/Isobar/` or any origin. Use relative paths. Any grep for `/Isobar/` in those three files should be empty outside of comments.*

This turns the invariant into a reviewable rule the watcher agent can enforce on future changes, and a commit hook could be added later if regression repeats.

## Out of scope (intentionally)

I considered and set aside the following — each is a real issue but not this ticket:

- **Automated cache-version bumping.** Manual `CACHE = 'isobar-vN'` is fragile — devs forget. Could be auto-derived from a content hash. But that wants a build step, which this repo deliberately doesn't have. Separate discussion.
- **Workbox / SW library.** Overkill for a single-page app that ships as raw HTML.
- **Network-first for app shell.** The current cache-first shell is correct for a PWA; the reason it looked broken was the install failure, not the shell strategy.
- **Playwright smoke check for `registrations.length >= 1`.** QA agent already suggested this and the test harness lives outside the app repo. They'll add it.

## Tradeoffs / risks

| Decision                                         | Upside                                                             | Downside / risk                                                                                                                           |
|--------------------------------------------------|--------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------|
| Relative paths in sw.js                          | Works at any origin; cleanest, most idiomatic fix                   | None significant — this is the established PWA pattern                                                                                     |
| Relative `start_url` / `scope` in manifest.json  | Matches sw.js strategy; aligns the PWA shell at any origin          | **Unknown**: browsers may treat changed `scope` as a manifest identity change for already-installed PWAs, forcing re-install. Affects at most 1 user (the patient). Acceptable but flag for verification. |
| Bump CACHE to `isobar-v5`                        | Ensures any working v4 install drops its (potentially stale) cache | Trivially larger one-time download for anyone on v4                                                                                        |
| Add standing rule to PROCESS.md                  | Prevents regression                                                 | Another doc to maintain; slight overhead on PRs                                                                                            |

## Verification plan (for the QA re-run)

1. At `localhost:8000/`: fresh load → `await navigator.serviceWorker.getRegistrations()` returns length ≥ 1 after ~3s.
2. At `localhost:8000/`: `caches.keys()` returns `['isobar-v5']` and `caches.open('isobar-v5').then(c => c.keys())` returns 4 cached request URLs.
3. At `localhost:8000/`: offline reload (DevTools → Network → Offline, then reload) returns the app from cache with no `ERR_INTERNET_DISCONNECTED`.
4. At `cotopaxilyon.github.io/Isobar/`: same three checks pass (ensures we didn't regress production).
5. `grep -r '/Isobar/' index.html sw.js manifest.json` returns no matches (except comments).

## Open questions for you

1. **Manifest scope change** — any concern about breaking your installed PWA on `cotopaxilyon.github.io/Isobar/`? Worst case, one re-install for the patient. If that's risky, we can leave `scope` hardcoded to `/Isobar/` and only fix `start_url` + `sw.js` — the SW install will still succeed at both origins because `scope: "/Isobar/"` on localhost just means the SW doesn't control `/` (annoying for QA but not broken).
2. **Standing rule destination** — add to `docs/PROCESS.md` (keeps it with your other agent rules) or create `docs/ARCHITECTURE.md`?
3. **Cache version** — bump to `v5` as proposed, or leave at `v4`? Bumping is safer; leaving is tidier for the current in-flight `TICK-004` which already bumped to `v4`.
4. **README.md / docs/archive/TESTING.md** — both mention `github.io/Isobar/`. Those are documentation of where the app is deployed, not hardcoded paths in code. Leave untouched unless you want a docs audit.

---

## Decisions (2026-04-16, reviewed by human)

1. **Q1 — Option 1**: both `start_url` and `scope` → `./`. Re-install risk for the patient is acceptable (zero data loss — localStorage is origin-scoped, origin doesn't change).
2. **Q2 — Create `docs/ARCHITECTURE.md`**. Discoverability via four channels: ARCHITECTURE.md itself + new `CLAUDE.md` at repo root + one-line pointer from `README.md` + one-line pointer from `docs/PROCESS.md`.
3. **Q3 — Bump CACHE to `isobar-v5`**. `manifest.json` content changes in this fix, so the cache genuinely needs refreshing for already-registered SWs.
4. **Q4 — Leave `README.md` / `docs/archive/TESTING.md` alone**. Rule applies to shell assets (`sw.js`, `manifest.json`, `index.html`), not docs describing the live URL.

## Implementation plan (approved — awaiting "go")

### Files to change (7 total)

| File                         | Change                                                                                               |
|------------------------------|------------------------------------------------------------------------------------------------------|
| `sw.js`                      | Line 1: `CACHE = 'isobar-v5'`. Line 2: `ASSETS = ['./', './index.html', './manifest.json', './icon.svg']`. Add inline comment explaining why paths are relative. |
| `manifest.json`              | Line 5: `"start_url": "./"`. Line 6: `"scope": "./"`.                                                |
| `docs/ARCHITECTURE.md` (new) | "Architectural invariants" doc. First rule: no hardcoded base paths in shell assets. Include verification grep command. Structured so future rules slot in. |
| `CLAUDE.md` (new, repo root) | Short auto-loaded header. Pointers to `README.md`, `docs/PROCESS.md`, `docs/ARCHITECTURE.md`.         |
| `README.md`                  | One new line near "Current State" pointing to `docs/ARCHITECTURE.md`.                                 |
| `docs/PROCESS.md`            | One-line pointer at top to `docs/ARCHITECTURE.md`.                                                    |
| `docs/qa-fail/ISO-13.md`     | Frontmatter: `status: reviewed`.                                                                      |

### Commit

One logical commit. Proposed message:

```
ISO-13: make PWA shell origin-agnostic

Switches sw.js precache list and manifest.json start_url/scope from
hardcoded /Isobar/ paths to relative paths so the app's SW installs
correctly at any origin (local QA at localhost:8000/, GitHub Pages at
/Isobar/, or any other host). Bumps CACHE to isobar-v5 so existing v4
registrations pick up the new manifest contents.

Adds docs/ARCHITECTURE.md codifying the "no hardcoded base paths in
shell assets" invariant with a grep-based verification command, and
wires it into CLAUDE.md / README.md / PROCESS.md so future work can't
drift back.

Linear: https://linear.app/isobar/issue/ISO-13
```

### Verification before commit

- `grep -rn '/Isobar/' sw.js manifest.json index.html` returns empty (the rule's own check)
- `python3 -m json.tool manifest.json > /dev/null` (valid JSON)
- `git diff` review of all 7 changes

### Linear workflow after commit

- Transition ISO-13 → `Ready for QA`
- Remove `needs-human-review` label
- Post a Linear comment linking to the commit SHA
- Update `docs/qa-fail/ISO-13.md` frontmatter to `status: reviewed` (part of the commit)

### Explicitly NOT doing

- **No push.** 5 prior cleanup commits + this fix all stay local until human says push.
- **No ISO-6 / ISO-12 processing.** Both marked seen in `.claude/qa-watcher-seen.json`. Once human says "push and process those," push everything then process them autonomously.
- **No README.md / docs/archive/TESTING.md edits** beyond the one-line ARCHITECTURE.md pointer in README.md (per Q4).
