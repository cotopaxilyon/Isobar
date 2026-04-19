#!/bin/sh
# PostToolUse hook: wrap untrusted MCP tool output with a trust boundary marker.
#
# The content returned by these tools is attacker-controllable:
#   - Linear comment bodies and issue descriptions come from external users.
#   - Browser snapshots / evaluated JS expressions run against DOM that
#     may contain data seeded from localStorage, URL, or network.
#
# This hook replaces the tool response with the original content wrapped in
# an <untrusted source="..."> marker. The model then sees a clear structural
# boundary between "what the tool returned" and "what you (the model) should
# reason about as data, not instructions."
#
# Per-field wrapping (e.g. marking each comment.body individually) is
# skipped intentionally — it would require parsing Linear's response schema
# and would break silently if Linear ever changes its shape. Whole-response
# wrapping is robust to schema drift.
#
# Always-on (no active-mode gating) — the marker is harmless in any mode.
# Wave 5 of the injection-guardrails plan; defensive depth on top of the
# load-bearing Waves 1-4 + 8-10 enforcement.

set -e

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

case "$tool" in
  mcp__linear__list_comments|mcp__linear__get_issue)
    source="linear"
    ;;
  mcp__playwright__browser_snapshot|mcp__playwright__browser_evaluate)
    source="dom"
    ;;
  *) exit 0 ;;
esac

is_error=$(printf '%s' "$input" | jq -r '(.tool_response.isError? // .tool_response.is_error? // false) | tostring' 2>/dev/null || echo false)
[ "$is_error" = "true" ] && exit 0

# Extract the existing content text. MCP tools wrap text responses as
# { content: [{ type: "text", text: "..." }] }. Concatenate text parts if
# there are multiple. If the response isn't in that shape, fall back to
# serializing the whole thing. Null/missing tool_response yields empty.
original=$(printf '%s' "$input" | jq -r '
  .tool_response
  | if . == null then ""
    elif type == "object" and (.content? | type == "array") then
      .content | map(select(.type == "text") | .text) | join("\n")
    elif type == "string" then .
    else tojson
    end
' 2>/dev/null || true)

[ -n "$original" ] || exit 0

wrapped="<untrusted source=\"$source\" tool=\"$tool\">
$original
</untrusted source=\"$source\">"

jq -cn --arg w "$wrapped" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    updatedMCPToolOutput: $w
  }
}'
exit 0
