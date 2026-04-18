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

## 2. `DB.keys(prefix)` is a prefix scan, not an all-keys dump

**Rule.** Never call `DB.keys('')` (or any equivalent empty-prefix call) to
enumerate every key in storage. When you need all-keys semantics — e.g. to
wipe or export everything — go through Dexie directly
(`idb.kv.where('key').notEqual(...).delete()`, `idb.kv.toCollection().primaryKeys()`,
or `idb.kv.toArray()`).

**Why.** Dexie's `WhereClause.startsWith('')` short-circuits to an empty
collection as a guard against accidental full-table scans. `DB.keys(prefix)`
is implemented as `idb.kv.where('key').startsWith(prefix).primaryKeys()`, so
passing `''` silently returns `[]` instead of "every key." This drifted in
across the ISO-39 localStorage → Dexie migration: the pre-migration `DB.keys('')`
enumerated `Object.keys(localStorage)` and worked; the post-migration version
does not. ISO-21's "Clear All Data" shipped on the old contract and became a
no-op for IDB-resident keys (meal:last, entry:*) after ISO-39 landed. The
localStorage fallback loop is what kept the symptom partially masked.

**Verification.**

```sh
grep -n "DB\.keys(['\"]['\"])\|DB\.keys(\`\`)" index.html
```

Should return no matches. All callers of `DB.keys(...)` must pass a non-empty
prefix (`'entry:'`, `'draft:'`, `'morning:'`, etc.).

**Exceptions.** None. If you need every key, use Dexie directly and comment
why you're bypassing `DB`.

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
