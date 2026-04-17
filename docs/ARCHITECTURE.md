# Isobar — Architectural Invariants

This document records the small set of rules the codebase must keep true. Each
rule has a one-line statement, the reasoning, and a mechanical check anyone
(human or agent) can run to verify it.

If you are about to violate one of these, stop and update the rule first.

---

## 1. No hardcoded base paths in shell assets

**Rule.** `sw.js`, `manifest.json`, and `index.html` must not contain the
string `/Isobar/` or any other origin/base-path literal. Use paths relative
to the asset itself (e.g. `./index.html`, `./manifest.json`).

**Why.** The app ships as static files served at multiple origins:
GitHub Pages (`cotopaxilyon.github.io/Isobar/`), local dev
(`localhost:8000/`), and any future fork or custom domain. Hardcoding
`/Isobar/` couples the shell to one deployment target and silently breaks
every other origin — the failure mode is "service worker install rejects on
404, app appears registered but never caches anything." Lost two months of
working SW installs at non-prod origins to this exact bug (ISO-13).

**How relative paths resolve.**
- In `sw.js`, paths resolve against the SW script URL. `./index.html` from
  `/Isobar/sw.js` → `/Isobar/index.html`. From `/sw.js` → `/index.html`.
- In `manifest.json`, paths resolve against the manifest URL. Same logic.
- In `index.html`, paths resolve against the document URL. Same logic.

One source, every origin works.

**Verification.**

```sh
grep -n '/Isobar/' sw.js manifest.json index.html
```

Should return no matches outside of comments. CI / the QA watcher can run
this as a regression check on every change to those three files.

**Exceptions.** Documentation files (`README.md`, `docs/**`) are allowed to
mention the live URL `https://cotopaxilyon.github.io/Isobar/` because they
describe deployment, not behavior.

---

## How to add a new invariant

1. The rule is one sentence at the top of its section. Imperative, testable.
2. Explain *why* — usually a past incident or a constraint that isn't
   obvious from the code.
3. Give a mechanical check (a grep, a script, a test). If it can't be
   checked mechanically, it isn't an invariant — it's a guideline; put it
   in `docs/PROCESS.md` instead.
4. Note any exceptions explicitly, so future readers don't have to guess
   what counts as a violation.
