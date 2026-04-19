#!/bin/sh
# PreToolUse hook: template + character-class enforcement for Linear writes.
#
# Matched on mcp__linear__save_comment and mcp__linear__save_issue.
# Active only when /autopilot or /qa-check is the current mode — manual
# sessions retain full capability (user is in the loop).
#
# Two checks on any body/description/title being set:
#
#   1. Body must start with an allowed opener prefix. Openers live in
#      .claude/mode-manifests/<mode>-comment-openers.txt — one literal
#      prefix per line; #-prefixed and blank lines are comments. Match is
#      a case-sensitive prefix (not regex) against the raw body.
#
#   2. Body may only contain chars in the restricted ASCII class:
#         A-Za-z0-9, space, newline, and the punctuation . , : / _ - ( ) [ ] ` #
#      This is the load-bearing defense: it catches HTML tags, URLs with
#      query strings or fragments, code fences beyond backticks, non-ASCII,
#      @mentions, and the long tail of injection payloads. Deliberately
#      strict; tight-enough-to-ship iteration expected per plan's
#      calibration note.
#
# state/label-only updates to save_issue (no description, no title) pass
# through — the hook only fires when actual text content is being set.

set -e

REPO=/Users/cotopaxilyon/WebstormProjects/Isobar
MODE_FILE="$REPO/.claude/active-mode"
MANIFEST_DIR="$REPO/.claude/mode-manifests"
STALE_AFTER=7200

# Negated char class used with grep -E. In ERE, ']' must be the first char
# of the class to be literal (here, immediately after ^). '-' placed last is
# literal. Backtick inside single quotes is literal (no command substitution).
CHAR_CLASS_NEG='[^]A-Za-z0-9 .,:/_()[`#-]'

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

case "$tool" in
  mcp__linear__save_comment|mcp__linear__save_issue) ;;
  *) exit 0 ;;
esac

[ -f "$MODE_FILE" ] || exit 0

mode=$(sed -n '1p' "$MODE_FILE")
ts=$(sed -n '2p' "$MODE_FILE")
now=$(date +%s)

case "$ts" in
  ''|*[!0-9]*) exit 0 ;;
esac

if [ "$((now - ts))" -gt "$STALE_AFTER" ]; then
  exit 0
fi

case "$mode" in
  autopilot|qa-check) ;;
  *) exit 0 ;;
esac

openers_file="$MANIFEST_DIR/$mode-comment-openers.txt"
if [ ! -f "$openers_file" ]; then
  jq -cn --arg m "$mode" --arg t "$tool" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ($t + " denied: mode " + $m + " has no comment-openers allowlist at .claude/mode-manifests/" + $m + "-comment-openers.txt. Create the file (one prefix per line) to allow Linear writes under this mode.")
    }
  }'
  exit 0
fi

deny() {
  jq -cn --arg r "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $r
    }
  }'
  exit 0
}

check_body() {
  field=$1
  body=$2

  [ -z "$body" ] && return 0

  if printf '%s' "$body" | LC_ALL=C grep -qE "$CHAR_CLASS_NEG"; then
    sample=$(printf '%s' "$body" | LC_ALL=C grep -oE "$CHAR_CLASS_NEG" | LC_ALL=C tr -d '\n' | LC_ALL=C head -c 30)
    deny "$tool $field contains chars outside the allowed class (A-Za-z0-9, space, newline, . , : / _ - ( ) [ ] backtick #). Offending chars: '$sample'. Restructure the body to ASCII letters/digits plus listed punctuation; no HTML, no query-string URLs, no @mentions, no em-dash."
  fi

  matched=0
  while IFS= read -r opener || [ -n "$opener" ]; do
    opener=$(printf '%s' "$opener" | tr -d '\r')
    case "$opener" in
      ''|\#*) continue ;;
    esac
    case "$body" in
      "$opener"*) matched=1; break ;;
    esac
  done < "$openers_file"

  if [ "$matched" -eq 0 ]; then
    first_line=$(printf '%s' "$body" | sed -n '1p' | head -c 80)
    deny "$tool $field does not start with an allowed opener for mode $mode (first line: '$first_line'). See .claude/mode-manifests/$mode-comment-openers.txt for the allowlist."
  fi
}

if [ "$tool" = "mcp__linear__save_comment" ]; then
  body=$(printf '%s' "$input" | jq -r '.tool_input.body // empty')
  if [ -z "$body" ]; then
    deny "mcp__linear__save_comment called with empty body; refusing under active Linear output policy."
  fi
  check_body "body" "$body"
  exit 0
fi

if [ "$tool" = "mcp__linear__save_issue" ]; then
  desc=$(printf '%s' "$input" | jq -r '.tool_input.description // empty')
  title=$(printf '%s' "$input" | jq -r '.tool_input.title // empty')
  check_body "description" "$desc"
  check_body "title" "$title"
  exit 0
fi

exit 0
