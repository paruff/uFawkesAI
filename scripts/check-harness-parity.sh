#!/usr/bin/env bash
#
# scripts/check-harness-parity.sh — verify every harness is wired to the one
# canonical .agents/ tree and stays in sync: no shadowing, no broken symlinks,
# no drifted MCP server sets, no reserved-name collisions. This is the
# automated version of the `doctor`/`oc-health` collision this repo found and
# fixed by hand — see docs/ai-sdlc/dual-harness-template/spec.md R5.
#
# Wiring contract: .agents/ is canonical. Everything a harness dispatches to
# is a symlink into it:
#   .opencode/{skills,commands}  -> ../.agents/{skills,commands}
#   .claude/{skills,commands}    -> ../.agents/{skills,commands}
#   .cursor/rules/AGENTS.md      -> ../../AGENTS.md
#   .github/copilot-instructions.md, CLAUDE.md, GEMINI.md, .cursorrules
#                                 -> AGENTS.md
# .opencode/agents/{planner,builder,verifier,operator}.md are symlinks into
# .agents/agents/. The OpenCode-only reviewer agents were dropped — the roster
# is the canonical 4 (AGENTS.md §5), so there is one source for every agent.
#
# Exit 0 = clean. Exit 1 = drift found (fails CI and pre-commit).

set -euo pipefail
cd "$(dirname "$0")/.."

FAIL=0
say_ok() { printf '  OK   %s\n' "$1"; }
say_fail() {
  printf '  FAIL %s\n' "$1"
  FAIL=1
}

# --identity: run only the agent commit identity check (seam R6a.3); the test uses it on a fixture tree.
ONLY_IDENTITY=0
[ "${1:-}" = "--identity" ] && ONLY_IDENTITY=1

# 4. Agent commit identity (seam R6a): both harnesses must set the same bot name and email, and
#    the email must be in .sdlc-engine.json botIdentities so the engine refuses its approvals.
check_identity() {
  echo "-- agent commit identity --"
  local cc_name cc_email oc_name oc_email plugin=.opencode/plugins/ai-sdlc-hooks.ts v
  cc_name=$(jq -r '.env.GIT_AUTHOR_NAME // empty' .claude/settings.json 2> /dev/null || true)
  cc_email=$(jq -r '.env.GIT_AUTHOR_EMAIL // empty' .claude/settings.json 2> /dev/null || true)
  oc_name=$(sed -n 's/^const BOT_NAME = "\(.*\)";$/\1/p' "$plugin" 2> /dev/null || true)
  oc_email=$(sed -n 's/^const BOT_EMAIL = "\(.*\)";$/\1/p' "$plugin" 2> /dev/null || true)
  for v in GIT_COMMITTER_NAME:"$cc_name" GIT_COMMITTER_EMAIL:"$cc_email"; do
    [ "$(jq -r --arg k "${v%%:*}" '.env[$k] // empty' .claude/settings.json 2> /dev/null || true)" = "${v#*:}" ] \
      || say_fail "$v: .claude/settings.json author and committer identity differ"
  done
  if [ -z "$cc_name" ] || [ -z "$cc_email" ]; then
    say_fail ".claude/settings.json sets no GIT_AUTHOR_NAME/GIT_AUTHOR_EMAIL"
  elif [ -z "$oc_name" ] || [ -z "$oc_email" ]; then
    say_fail "$plugin sets no BOT_NAME/BOT_EMAIL"
  elif [ "$cc_name <$cc_email>" != "$oc_name <$oc_email>" ]; then
    say_fail "identities differ: claude '$cc_name <$cc_email>' vs opencode '$oc_name <$oc_email>'"
  elif ! jq -e --arg e "$cc_email" '(.botIdentities // []) | index($e)' .sdlc-engine.json > /dev/null 2>&1; then
    say_fail "$cc_email is not in .sdlc-engine.json botIdentities (the bot could approve)"
  else
    say_ok "both harnesses commit as $cc_name <$cc_email>, listed in botIdentities"
  fi
}

if [ "$ONLY_IDENTITY" -eq 1 ]; then
  check_identity
  exit $FAIL
fi

echo "== Harness parity check =="

# 0. Every symlink in the repo must resolve. A dangling harness symlink is
#    silent: the harness loads nothing, no error surfaces, and the agent
#    simply appears to have no skills or commands. `find -xtype l` reports
#    broken links specifically, which `test -e` alone does not.
echo "-- symlink resolution --"
broken_count=0
link_count=0
while IFS= read -r link; do
  link_count=$((link_count + 1))
  if [ -e "$link" ]; then
    say_ok "$(printf '%-40s -> %s' "$link" "$(readlink "$link")")"
  else
    say_fail "$(printf '%-40s -> %s  (DANGLING)' "$link" "$(readlink "$link")")"
    broken_count=$((broken_count + 1))
  fi
done < <(find . -maxdepth 3 -type l \
  -not -path './.git/*' \
  -not -path './opencode/*' \
  -not -path '*/node_modules/*' \
  | sed 's|^\./||' | sort)
if [ "$broken_count" -eq 0 ]; then
  say_ok "all $link_count symlink(s) resolve"
else
  say_fail "$broken_count of $link_count symlink(s) are dangling"
fi

# 1. .claude/{skills,commands} and .opencode/{skills,commands} must be
#    symlinks into the canonical .agents/ tree, not real directories. A real
#    directory here would silently shadow the canonical source instead of
#    sharing it — exactly the class of bug this check exists to catch
#    automatically. They must point at .agents/ DIRECTLY, not at each other:
#    .claude -> .opencode -> .agents is a chain that can break in the middle.
echo "-- canonical fan-out --"
for harness in .claude .opencode; do
  for pair in commands skills; do
    link="$harness/$pair"
    target=".agents/$pair"
    if [ -L "$link" ] && [ "$(realpath "$link" 2> /dev/null)" = "$(realpath "$target" 2> /dev/null)" ]; then
      say_ok "$link -> $target (symlink intact)"
    else
      say_fail "$link is not a symlink to $target (shadowing or indirection risk)"
    fi
  done
done

# 1b. The AGENTS.md aliases must be symlinks to the one source. A harness that
#     loads a stale copy of the policy is worse than one that loads none.
for alias in CLAUDE.md GEMINI.md .cursorrules .cursor/rules/AGENTS.md .github/copilot-instructions.md; do
  if [ ! -e "$alias" ]; then
    say_fail "$alias is missing (harness loads no policy)"
  elif [ -L "$alias" ] && [ "$(realpath "$alias" 2> /dev/null)" = "$(realpath AGENTS.md 2> /dev/null)" ]; then
    say_ok "$alias -> AGENTS.md"
  else
    say_fail "$alias is not a symlink to AGENTS.md"
  fi
done

# 2. MCP server sets must match between .opencode/opencode.json and .mcp.json —
#    the two harnesses should offer the same servers, even though each
#    keeps its own file (the two schemas aren't identical, see spec.md).
if [ -f .opencode/opencode.json ] && [ -f .mcp.json ]; then
  oc_servers=$(jq -r '.mcp // {} | keys | sort | join(",")' .opencode/opencode.json)
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
for f in .agents/commands/*.md; do
  [ -e "$f" ] || continue
  name=$(basename "$f" .md)
  for reserved in $RESERVED_NAMES; do
    if [ "$name" = "$reserved" ]; then
      say_fail "command '$name' collides with a reserved/built-in name ($reserved)"
      collision_found=1
    fi
  done
done
for f in .agents/skills/*/SKILL.md; do
  [ -e "$f" ] || continue
  skill_dir=$(dirname "$f")
  name=$(basename "$skill_dir")
  for reserved in $RESERVED_NAMES; do
    if [ "$name" = "$reserved" ]; then
      say_fail "skill '$name' collides with a reserved/built-in name ($reserved)"
      collision_found=1
    fi
  done
done
if [ "$collision_found" -eq 0 ]; then
  say_ok "no command/skill names collide with the known reserved-name list"
fi

check_identity

echo "=========================="
if [ "$FAIL" -eq 0 ]; then
  echo "PASS: no drift detected"
else
  echo "FAIL: drift detected — see above"
fi
exit $FAIL
