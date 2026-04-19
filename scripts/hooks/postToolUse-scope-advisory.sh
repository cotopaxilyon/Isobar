#!/bin/sh
# PostToolUse hook: advisory when autopilot's commit diff spreads beyond
# the files declared in the dossier.
#
# This is Wave 10 of the injection-guardrails plan. Advisory only — does
# not block (PostToolUse runs after the command has already executed). The
# plan originally called for a separate Linear comment; hooks can't invoke
# MCP tools, so the advisory is instead written to
# `docs/autopilot/<ticket>.scope-advisory.md`, and autopilot's step 14
# mentions it in the ticket comment it already posts.
#
# Fires only when:
#   - active mode is `autopilot` (non-stale)
#   - the command began with `git commit` (after whitespace strip)
#   - the tool response is not an error
#   - HEAD's subject line starts with `ISO-NNN:`
#   - `docs/autopilot/<ticket>.dossier.json` exists
#
# Implied-by set (never flagged as over-reach):
#   - files literally in `dossier.files_to_touch`
#   - any `docs/autopilot/<ticket>.*` file (dossier, critic, bailout, advisory)
#   - any `docs/testing/TEST-*.md` (autopilot may update linked checklists)
#   - `docs/qa-fail/<ticket>.md` (if implementing an approved fix plan)
#
# Always writes a fresh advisory (SHA-keyed content) — if the user has
# already reviewed a prior advisory on the same ticket and committed
# annotations, those live in the Linear thread, not in this file. The
# file is generated output.

set -e

REPO=/Users/cotopaxilyon/WebstormProjects/Isobar
MODE_FILE="$REPO/.claude/active-mode"
STALE_AFTER=7200

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
[ "$tool" = "Bash" ] || exit 0

is_error=$(printf '%s' "$input" | jq -r '(.tool_response.isError // .tool_response.is_error // false) | tostring')
[ "$is_error" = "true" ] && exit 0

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
trimmed=$(printf '%s' "$cmd" | sed 's/^[[:space:]]*//')
case "$trimmed" in
  "git commit"*) ;;
  *) exit 0 ;;
esac

[ -f "$MODE_FILE" ] || exit 0
mode=$(sed -n '1p' "$MODE_FILE")
ts=$(sed -n '2p' "$MODE_FILE")
case "$ts" in
  ''|*[!0-9]*) exit 0 ;;
esac
now=$(date +%s)
[ "$((now - ts))" -gt "$STALE_AFTER" ] && exit 0
[ "$mode" = "autopilot" ] || exit 0

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || cwd="$REPO"

subject=$(git -C "$cwd" log -1 --format=%s 2>/dev/null || true)
ticket=$(printf '%s' "$subject" | sed -n 's/^\(ISO-[0-9][0-9]*\):.*$/\1/p')
[ -n "$ticket" ] || exit 0

dossier="$REPO/docs/autopilot/$ticket.dossier.json"
[ -f "$dossier" ] || exit 0

expected=$(jq -r '.files_to_touch // [] | .[]' "$dossier" 2>/dev/null || true)

changed=$(git -C "$cwd" show --name-only --format= HEAD 2>/dev/null | sed '/^$/d' || true)
[ -n "$changed" ] || exit 0

over_reach=""
while IFS= read -r f; do
  [ -n "$f" ] || continue

  if [ -n "$expected" ] && printf '%s\n' "$expected" | grep -Fxq "$f"; then
    continue
  fi

  case "$f" in
    docs/autopilot/"$ticket".*) continue ;;
    docs/testing/TEST-*.md)     continue ;;
    docs/qa-fail/"$ticket".md)  continue ;;
  esac

  over_reach="${over_reach}${f}
"
done <<EOF
$changed
EOF

over_reach=$(printf '%s' "$over_reach" | sed '/^$/d')

[ -n "$over_reach" ] || exit 0

advisory="$REPO/docs/autopilot/$ticket.scope-advisory.md"
sha=$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null || echo UNKNOWN)
today=$(date +%Y-%m-%d)

{
  printf -- '---\n'
  printf -- 'ticket: %s\n' "$ticket"
  printf -- 'commit: %s\n' "$sha"
  printf -- 'generated: %s\n' "$today"
  printf -- 'status: pending-review\n'
  printf -- '---\n\n'
  printf -- '# Scope advisory: %s\n\n' "$ticket"
  printf -- 'Commit `%s` modified files not listed in `docs/autopilot/%s.dossier.json` `files_to_touch` or the implied set. Advisory only; the commit is not reverted. Review at QA time.\n\n' "$sha" "$ticket"
  printf -- '## Declared (dossier.files_to_touch)\n\n'
  if [ -n "$expected" ]; then
    printf '%s\n' "$expected" | sed 's|^|  - `|; s|$|`|'
  else
    printf -- '  _(empty)_\n'
  fi
  printf -- '\n## Over-reach (changed files outside declared + implied)\n\n'
  printf '%s\n' "$over_reach" | sed 's|^|  - `|; s|$|`|'
  printf -- '\n## Implied set (not flagged)\n\n'
  printf -- '  - `docs/autopilot/%s.*`\n' "$ticket"
  printf -- '  - `docs/testing/TEST-*.md`\n'
  printf -- '  - `docs/qa-fail/%s.md`\n' "$ticket"
} > "$advisory"

{
  printf 'Wave 10: scope advisory written to %s\n' "$advisory"
  printf 'Commit %s modified files outside the dossier files_to_touch for %s:\n' "$sha" "$ticket"
  printf '%s\n' "$over_reach" | sed 's/^/  /'
} 1>&2

exit 0
