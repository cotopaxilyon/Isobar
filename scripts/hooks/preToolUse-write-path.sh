#!/bin/sh
# PreToolUse hook: enforce per-mode write-path allowlist for Edit/Write/NotebookEdit.
#
# Companion to preToolUse-mode-manifest.sh. The mode-manifest hook controls
# *which tools* the model can call; this one controls *which paths* it can
# write to. Reads the active-mode sentinel (same logic), then consults
# .claude/mode-manifests/<mode>-write-paths.txt — a list of POSIX shell
# glob patterns, one per line. If file_path matches any pattern, allow;
# else deny.
#
# Empty file_path is denied conservatively (we can't check what we can't
# see). Missing manifest is permissive (no policy for this mode's writes).

set -e

REPO=/Users/cotopaxilyon/WebstormProjects/Isobar
MODE_FILE="$REPO/.claude/active-mode"
MANIFEST_DIR="$REPO/.claude/mode-manifests"
STALE_AFTER=7200

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')

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

manifest="$MANIFEST_DIR/$mode-write-paths.txt"
[ -f "$manifest" ] || exit 0

if [ -z "$path" ]; then
  jq -cn --arg t "$tool" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ($t + " called with empty file_path; refusing under active write-path policy")
    }
  }'
  exit 0
fi

while IFS= read -r pattern || [ -n "$pattern" ]; do
  pattern=$(printf '%s' "$pattern" | tr -d '\r')
  case "$pattern" in
    ''|\#*) continue ;;
  esac
  case "$path" in
    $pattern) exit 0 ;;
  esac
done < "$manifest"

jq -cn --arg m "$mode" --arg t "$tool" --arg p "$path" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ($t + " path " + $p + " is not in the " + $m + " write-path allowlist. To allow, add a glob to .claude/mode-manifests/" + $m + "-write-paths.txt and re-run.")
  }
}'
exit 0
