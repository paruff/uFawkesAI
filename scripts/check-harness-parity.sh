#!/usr/bin/env bash
#
# scripts/check-harness-parity.sh — verify OpenCode and Claude Code stay in
# sync: no shadowing, no drifted MCP server sets, no reserved-name
# collisions. This is the automated version of the `doctor`/`oc-health`
# collision this repo found and fixed by hand — see docs/ai-sdlc/spec.md R5.
#
# Exit 0 = clean. Exit 1 = drift found (fails CI).

set -euo pipefail
cd "$(dirname "$0")/.."

FAIL=0
say_ok()   { printf '  OK   %s\n' "$1"; }
say_fail() { printf '  FAIL %s\n' "$1"; FAIL=1; }

echo "== Harness parity check =="

# 1. .claude/commands and .claude/skills must be symlinks to the
#    .opencode/ equivalents, not real directories. A real directory here
#    would silently shadow the canonical source instead of sharing it —
#    exactly the class of bug this check exists to catch automatically.
for pair in commands skills; do
  link=".claude/$pair"
  target=".opencode/$pair"
  if [ -L "$link" ] && [ "$(realpath "$link" 2>/dev/null)" = "$(realpath "$target" 2>/dev/null)" ]; then
    say_ok "$link -> $target (symlink intact)"
  else
    say_fail "$link is not a symlink to $target — it may be shadowing instead of sharing"
  fi
done

# 2. MCP server sets must match between opencode.json and .mcp.json —
#    the two harnesses should offer the same servers, even though each
#    keeps its own file (the two schemas aren't identical, see spec.md).
if [ -f opencode.json ] && [ -f .mcp.json ]; then
  oc_servers=$(jq -r '.mcp // {} | keys | sort | join(",")' opencode.json)
  cc_servers=$(jq -r '.mcpServers // {} | keys | sort | join(",")' .mcp.json)
  if [ "$oc_servers" = "$cc_servers" ]; then
    say_ok "MCP server sets match: $oc_servers"
  else
    say_fail "MCP server sets differ — opencode.json: [$oc_servers] vs .mcp.json: [$cc_servers]"
  fi
else
  say_fail "opencode.json or .mcp.json missing"
fi

# 3. No command/skill name may collide with a harness's own reserved
#    names. NOT EXHAUSTIVE — extend this list whenever a new collision is
#    found, the way `doctor` was found (and renamed to `oc-health`) this
#    session.
RESERVED_NAMES="doctor review help clear compact init model mcp plugin context hooks permissions config cost export login logout memory pr-comments resume status agents bug vim terminal-setup"
collision_found=0
for f in .opencode/commands/*.md; do
  [ -e "$f" ] || continue
  name=$(basename "$f" .md)
  for reserved in $RESERVED_NAMES; do
    if [ "$name" = "$reserved" ]; then
      say_fail "command '$name' collides with a reserved/built-in name ($reserved)"
      collision_found=1
    fi
  done
done
for d in .opencode/skills/*/; do
  [ -e "$d" ] || continue
  name=$(basename "$d")
  for reserved in $RESERVED_NAMES; do
    if [ "$name" = "$reserved" ]; then
      say_fail "skill '$name' collides with a reserved/built-in name ($reserved)"
      collision_found=1
    fi
  done
done
[ "$collision_found" -eq 0 ] && say_ok "no command/skill names collide with the known reserved-name list"

echo "=========================="
if [ "$FAIL" -eq 0 ]; then
  echo "PASS: no drift detected"
  exit 0
else
  echo "FAIL: drift detected — see above"
  exit 1
fi
