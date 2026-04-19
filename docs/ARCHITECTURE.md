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

## 3. Security floor in Claude Code config

**Rule.** `.claude/settings.json` contains a load-bearing `permissions.deny`
list and a set of PreToolUse / PostToolUse hooks that enforce the
injection-guardrails plan. Do not remove entries, relax matchers, or disable
hooks without writing a new plan.

**Why.** `/autopilot` ships code to `main`; `/qa-check` writes Linear
comments and pushes commits. Both ingest attacker-controllable text from
Linear tickets. Without the capability floor plus hook enforcement, a
hostile comment body could steer the model into fetching arbitrary URLs,
writing attacker code into `index.html`, or reading SSH / AWS credentials.
The model itself is not a security boundary; the hooks are. Full threat
model and wave-by-wave rationale in
[`docs/plans/PLAN_injection_guardrails.md`](plans/PLAN_injection_guardrails.md).

The four load-bearing components:

- **Deny floor** — destructive bash (`rm -rf`, `git push --force`,
  `git reset --hard`), credential paths (`.ssh`, `.aws`, Keychains),
  and auth escapes are denied before any hook runs.
- **Outbound network allowlists** — `WebFetch` and
  `mcp__playwright__browser_navigate` go through per-URL allowlists in
  `scripts/hooks/preToolUse-webfetch-allowlist.sh` and
  `…browser-navigate.sh`. Adding a new domain is an explicit script edit,
  not a permission prompt.
- **Linear output templating** — `mcp__linear__save_comment` and
  `save_issue` bodies go through `scripts/hooks/preToolUse-linear-output.sh`
  which enforces an opener allowlist and a restricted ASCII char class.
  Mode-gated to `/autopilot` and `/qa-check`.
- **Per-mode tool manifests** — `.claude/mode-manifests/` contains the
  per-mode tool allowlist, write-path allowlist, and comment-opener
  allowlist for each slash command. The manifests are the source of truth;
  the hooks are the enforcement.

**Verification.**

```sh
grep -q '"Bash(rm -rf\*)"' .claude/settings.json \
  && grep -q '"Bash(git push --force\*)"' .claude/settings.json \
  && grep -q '"Read(//Users/.*/\.ssh/\*\*)"' .claude/settings.json \
  && grep -q '"Read(//Users/.*/\.aws/\*\*)"' .claude/settings.json \
  && test -x scripts/hooks/preToolUse-mode-manifest.sh \
  && test -x scripts/hooks/preToolUse-write-path.sh \
  && test -x scripts/hooks/preToolUse-diff-scanner.sh \
  && test -x scripts/hooks/preToolUse-browser-navigate.sh \
  && test -x scripts/hooks/preToolUse-webfetch-allowlist.sh \
  && test -x scripts/hooks/preToolUse-linear-output.sh \
  && test -x scripts/hooks/postToolUse-scope-advisory.sh \
  && test -x scripts/hooks/postToolUse-trust-label.sh \
  && echo ok
```

Should print `ok`. Any missing deny entry or missing/non-executable hook
script means the security floor has drifted and must be restored before
`/autopilot` or `/qa-check` is invoked.

**Exceptions.** None. A new threat model or ticket-specific carve-out
requires updating `PLAN_injection_guardrails.md` before the settings
change lands.

---

## 3. Security floor in Claude Code config

**Rule.** `.claude/settings.json` contains a load-bearing `permissions.deny`
list and a set of PreToolUse / PostToolUse hooks that enforce the
injection-guardrails plan. Do not remove entries, relax matchers, or disable
hooks without writing a new plan.

**Why.** `/autopilot` ships code to `main`; `/qa-check` writes Linear
comments and pushes commits. Both ingest attacker-controllable text from
Linear tickets. Without the capability floor plus hook enforcement, a
hostile comment body could steer the model into fetching arbitrary URLs,
writing attacker code into `index.html`, or reading SSH / AWS credentials.
The model itself is not a security boundary; the hooks are. Full threat
model and wave-by-wave rationale in
[`docs/plans/PLAN_injection_guardrails.md`](plans/PLAN_injection_guardrails.md).

The four load-bearing components:

- **Deny floor** — destructive bash (`rm -rf`, `git push --force`,
  `git reset --hard`), credential paths (`.ssh`, `.aws`, Keychains),
  and auth escapes are denied before any hook runs.
- **Outbound network allowlists** — `WebFetch` and
  `mcp__playwright__browser_navigate` go through per-URL allowlists in
  `scripts/hooks/preToolUse-webfetch-allowlist.sh` and
  `…browser-navigate.sh`. Adding a new domain is an explicit script edit,
  not a permission prompt.
- **Linear output templating** — `mcp__linear__save_comment` and
  `save_issue` bodies go through `scripts/hooks/preToolUse-linear-output.sh`
  which enforces an opener allowlist and a restricted ASCII char class.
  Mode-gated to `/autopilot` and `/qa-check`.
- **Per-mode tool manifests** — `.claude/mode-manifests/` contains the
  per-mode tool allowlist, write-path allowlist, and comment-opener
  allowlist for each slash command. The manifests are the source of truth;
  the hooks are the enforcement.

**Verification.**

```sh
grep -q '"Bash(rm -rf\*)"' .claude/settings.json \
  && grep -q '"Bash(git push --force\*)"' .claude/settings.json \
  && grep -q '"Read(//Users/.*/\.ssh/\*\*)"' .claude/settings.json \
  && grep -q '"Read(//Users/.*/\.aws/\*\*)"' .claude/settings.json \
  && test -x scripts/hooks/preToolUse-mode-manifest.sh \
  && test -x scripts/hooks/preToolUse-write-path.sh \
  && test -x scripts/hooks/preToolUse-diff-scanner.sh \
  && test -x scripts/hooks/preToolUse-browser-navigate.sh \
  && test -x scripts/hooks/preToolUse-webfetch-allowlist.sh \
  && test -x scripts/hooks/preToolUse-linear-output.sh \
  && test -x scripts/hooks/postToolUse-scope-advisory.sh \
  && test -x scripts/hooks/postToolUse-trust-label.sh \
  && echo ok
```

Should print `ok`. Any missing deny entry or missing/non-executable hook
script means the security floor has drifted and must be restored before
`/autopilot` or `/qa-check` is invoked.

**Exceptions.** None. A new threat model or ticket-specific carve-out
requires updating `PLAN_injection_guardrails.md` before the settings
change lands.

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
