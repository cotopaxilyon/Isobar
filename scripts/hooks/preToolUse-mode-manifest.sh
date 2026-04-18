#!/bin/sh
# PreToolUse hook: enforce per-mode tool manifest.
#
# When a slash command (/autopilot, /qa-check) is active, restricts which
# tools the model can call to those listed in
# .claude/mode-manifests/<mode>.txt. When no mode is active, the hook is a
# no-op and normal session behavior applies.
#
# State file: .claude/active-mode (two lines: mode name, unix timestamp).
# A stale file (mtime > STALE_AFTER seconds) is treated as absent and
# removed. SessionEnd is intentionally not used — see PLAN_injection_guardrails.md
# Wave 3 for why.

set -e

REPO=/Users/cotopaxilyon/WebstormProjects/Isobar
MODE_FILE="$REPO/.claude/active-mode"
MANIFEST_DIR="$REPO/.claude/mode-manifests"
STALE_AFTER=7200

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

[ -f "$MODE_FILE" ] || exit 0

mode=$(sed -n '1p' "$MODE_FILE")
ts=$(sed -n '2p' "$MODE_FILE")
now=$(date +%s)

case "$ts" in
  ''|*[!0-9]*) rm -f "$MODE_FILE"; exit 0 ;;
esac

if [ "$((now - ts))" -gt "$STALE_AFTER" ]; then
  rm -f "$MODE_FILE"
  exit 0
fi

manifest="$MANIFEST_DIR/$mode.txt"
if [ ! -f "$manifest" ]; then
  jq -cn --arg m "$mode" --arg t "$tool" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: ("active-mode \"" + $m + "\" has no manifest at .claude/mode-manifests/; refusing " + $t)
    }
  }'
  exit 0
fi

if grep -Fxq "$tool" "$manifest"; then
  exit 0
fi

jq -cn --arg m "$mode" --arg t "$tool" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ($t + " is not in the " + $m + " mode manifest. To allow, add it to .claude/mode-manifests/" + $m + ".txt and re-run.")
  }
}'
exit 0
