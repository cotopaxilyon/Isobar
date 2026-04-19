#!/bin/sh
# PreToolUse hook: scan the staged diff for injection patterns before
# allowing the agent to run `git commit`.
#
# Always-on (no active-mode gating). Only intercepts tool-issued commits
# — the user's manual `git commit` from a terminal bypasses this hook,
# which is the correct trust boundary (user trusts themselves; we don't
# trust agent output that may have been steered by external text).
#
# Patterns checked in added lines:
#   1. Dynamic code: eval(), new Function(), document.write(),
#      setTimeout("string"), setInterval("string")
#   2. Inline external resources: <script src="http…">, <iframe …>, <link …>
#   3. Imports from external URLs
#   4. Base64-shaped blobs over 200 chars on one line
#   5. URLs not in .claude/diff-scanner-url-allowlist.txt
#
# Skipped in v1 (documented as known gaps):
#   - on*= event handlers (false-positive risk on copy edits)
#   - localStorage destructive ops (ISO-21 was a legitimate fix of exactly that)

set -e

REPO=/Users/cotopaxilyon/WebstormProjects/Isobar
URL_ALLOWLIST="$REPO/.claude/diff-scanner-url-allowlist.txt"

input=$(cat)
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
[ "$tool" = "Bash" ] || exit 0

cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
trimmed=$(printf '%s' "$cmd" | sed 's/^[[:space:]]*//')
case "$trimmed" in
  "git commit"*) ;;
  *) exit 0 ;;
esac

cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || cwd="$REPO"
diff=$(git -C "$cwd" diff --cached -U0 2>/dev/null || true)
[ -n "$diff" ] || exit 0

added=$(printf '%s\n' "$diff" | grep -E '^\+[^+]' | sed 's/^\+//' || true)
[ -n "$added" ] || exit 0

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

# 1. Dynamic code execution
match=$(printf '%s\n' "$added" | grep -nE '\beval[[:space:]]*\(|\bnew[[:space:]]+Function[[:space:]]*\(|\bdocument\.write[[:space:]]*\(|\bsetTimeout[[:space:]]*\([[:space:]]*["'\'']|\bsetInterval[[:space:]]*\([[:space:]]*["'\'']' | head -3 || true)
[ -n "$match" ] && deny "diff-scanner: dynamic code execution pattern in added lines:
$match
Either remove the pattern, or commit by hand if this is intentional (the hook only fires for tool-issued commits)."

# 2. Inline external script/iframe/stylesheet
match=$(printf '%s\n' "$added" | grep -nE '<(script|iframe)[^>]+src=["'\'']https?://|<link[^>]+href=["'\'']https?://' | head -3 || true)
[ -n "$match" ] && deny "diff-scanner: inline external resource in added lines:
$match"

# 3. Import from external URL
match=$(printf '%s\n' "$added" | grep -nE 'import[[:space:]]+.*from[[:space:]]+["'\'']https?://|import[[:space:]]*["'\'']https?://' | head -3 || true)
[ -n "$match" ] && deny "diff-scanner: import from external URL in added lines:
$match"

# 4. Base64-shaped blob
match=$(printf '%s\n' "$added" | grep -nE '[A-Za-z0-9+/=]{200,}' | head -3 || true)
[ -n "$match" ] && deny "diff-scanner: base64-shaped blob >200 chars in added lines:
$match"

# 5. URL allowlist (only enforced if allowlist file exists)
if [ -f "$URL_ALLOWLIST" ]; then
  url_lines=$(printf '%s\n' "$added" | grep -oE 'https?://[A-Za-z0-9._/:-]+' | sort -u || true)
  if [ -n "$url_lines" ]; then
    printf '%s\n' "$url_lines" | while IFS= read -r url; do
      [ -n "$url" ] || continue
      allowed=0
      while IFS= read -r pattern; do
        pattern=$(printf '%s' "$pattern" | tr -d '\r')
        case "$pattern" in
          ''|\#*) continue ;;
        esac
        case "$url" in
          *"$pattern"*) allowed=1; break ;;
        esac
      done < "$URL_ALLOWLIST"
      if [ "$allowed" = "0" ]; then
        deny "diff-scanner: URL not in allowlist: $url
Add the host substring to .claude/diff-scanner-url-allowlist.txt if legitimate."
      fi
    done
  fi
fi

exit 0
