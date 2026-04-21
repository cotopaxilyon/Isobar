#!/bin/sh
# PreToolUse hook: domain allowlist for WebFetch.
#
# WebFetch is one of two outbound network surfaces from the agent (the
# other is Playwright browser_navigate — handled in preToolUse-browser-navigate.sh).
# Promoted from the Wave 1 deny-floor design after confirming Claude Code's
# permission engine evaluates deny before allow and short-circuits on first
# match: a bare `WebFetch` deny would mask every domain-qualified allow in
# settings.local.json. A PreToolUse hook with an explicit allowlist is the
# correct enforcement shape.
#
# Always-on (no active-mode gating): a new domain requires an explicit edit
# to this script, not an in-flight permission grant. This is the whole point
# of promoting the allowlist out of settings.local.json.

set -e

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
[ "$tool" = "WebFetch" ] || exit 0

url=$(printf '%s' "$input" | jq -r '.tool_input.url // empty')

if [ -z "$url" ]; then
  jq -cn '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: "WebFetch denied: empty url."
    }
  }'
  exit 0
fi

# Extract host from URL without relying on external parsers.
# Order: strip scheme, strip path/query/fragment, strip userinfo, strip port,
# lowercase. Handles spoof variants like foo@attacker.com and ALLCAPS hosts.
rest=${url#*://}
case "$rest" in
  "$url") host="" ;;   # no scheme separator — reject
  *)
    authority=${rest%%/*}
    authority=${authority%%\?*}
    authority=${authority%%#*}
    case "$authority" in
      *@*) hostport=${authority#*@} ;;
      *)   hostport=$authority ;;
    esac
    host=${hostport%%:*}
    host=$(printf '%s' "$host" | tr '[:upper:]' '[:lower:]')
    ;;
esac

case "$host" in
  www.hopkinsmedicine.org)       exit 0 ;;
  dev.to)                        exit 0 ;;
  mesonet.agron.iastate.edu)     exit 0 ;;
esac

jq -cn --arg u "$url" --arg h "$host" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("WebFetch denied: " + (if $h == "" then ("unparsable url " + $u) else ("host " + $h) end) + " is not in the allowlist (www.hopkinsmedicine.org, dev.to, mesonet.agron.iastate.edu). To add a domain, edit scripts/hooks/preToolUse-webfetch-allowlist.sh.")
  }
}'
exit 0
