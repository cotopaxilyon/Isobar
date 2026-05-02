#!/bin/sh
# PreToolUse hook: domain allowlist for Playwright browser_navigate.
#
# browser_navigate is one of two outbound network surfaces from the agent
# (the other is WebFetch — handled separately in Wave 2a). Locks target
# URL to the local PWA dev server only.
#
# Always-on (no active-mode gating): both /autopilot and /qa-check use
# Playwright against the local server; no mode legitimately navigates
# elsewhere. A new domain requires an explicit edit to this script, not
# an in-flight permission grant.

set -e

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
[ "$tool" = "mcp__playwright__browser_navigate" ] || exit 0

url=$(printf '%s' "$input" | jq -r '.tool_input.url // empty')

case "$url" in
  http://127.0.0.1:8765|http://127.0.0.1:8765/*) exit 0 ;;
  http://localhost:8765|http://localhost:8765/*) exit 0 ;;
  http://127.0.0.1:8000|http://127.0.0.1:8000/*) exit 0 ;;
  http://localhost:8000|http://localhost:8000/*) exit 0 ;;
  https://cotopaxilyon.github.io|https://cotopaxilyon.github.io/*) exit 0 ;;
esac

jq -cn --arg u "$url" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("browser_navigate denied: " + (if $u == "" then "<empty url>" else $u end) + " is not in the allowlist (http://127.0.0.1:8765/*, http://localhost:8765/*). To add a domain, edit scripts/hooks/preToolUse-browser-navigate.sh.")
  }
}'
exit 0
