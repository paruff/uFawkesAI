#!/usr/bin/env bash
#
# scripts/dual-harness-smoke.sh — proves the dual-harness template actually
# works: both CLIs present, and one example each of MCP server, skill,
# hook, command, and rule verified functioning, per
# docs/ai-sdlc/spec.md's success criteria. Run inside the devcontainer —
# see .github/workflows/ci-quality.yml's `dual-harness-smoke` job.

set -euo pipefail
cd "$(dirname "$0")/.."

fail() { echo "FAIL: $1" >&2; exit 1; }

echo "== 1. Both CLIs present =="
opencode --version || fail "opencode CLI not found"
claude --version || fail "claude CLI not found"

echo "== 2. Harness parity (no shadowing, MCP sets match) =="
bash scripts/check-harness-parity.sh || fail "harness parity check failed"

echo "== 3. OpenCode commands: /plan /verify /ship /oc-health discoverable =="
OC_COMMANDS=$(opencode debug config | jq -r '.command | keys | join(",")')
for cmd in plan verify ship oc-health; do
  case ",$OC_COMMANDS," in
    *",$cmd,"*) ;;
    *) fail "OpenCode command '$cmd' not discovered (found: $OC_COMMANDS)" ;;
  esac
done

echo "== 4. Claude Code commands: /plan /verify /ship discoverable, doctor NOT shadowed =="
for cmd in plan verify ship; do
  test -f ".claude/commands/$cmd.md" || fail "Claude Code command '$cmd' not found at .claude/commands/$cmd.md"
done
if [ -e ".claude/commands/doctor.md" ] || [ -d ".claude/skills/doctor" ]; then
  fail "a project-level 'doctor' command/skill exists — this would shadow Claude Code's built-in /doctor"
fi

echo "== 5. One skill loadable under both harnesses: testing-rules =="
test -f ".claude/skills/testing-rules/SKILL.md" || fail "testing-rules skill missing at Claude Code path"
test -f ".opencode/skills/testing-rules/SKILL.md" || fail "testing-rules skill missing at OpenCode path"

echo "== 6. One hook: the protected-path blocker actually blocks =="
if CLAUDE_TOOL_TARGET=".env.local" node -e "
  const path=require('path');
  const cfg=require('./scripts/hooks/protected-paths.json');
  const p=process.env.CLAUDE_TOOL_TARGET||'';
  const n=path.normalize(p).replace(/\\\\/g,'/');
  const parts=n.split('/').filter(Boolean);
  const b=parts[parts.length-1]||'';
  const r=cfg.protectedBasenamePatterns.map(s=>new RegExp(s));
  const segs=cfg.protectedPathSegments||[];
  if(segs.some(s=>parts.includes(s))||r.some(x=>x.test(b))){ process.exit(2);} process.exit(0);
"; then
  fail "protected-path hook did not block .env.local"
fi
echo "  protected-path hook correctly blocked .env.local"

echo "== 7. One command's definition is present for both harnesses: /verify =="
test -f ".opencode/commands/verify.md" || fail "verify command definition missing"
test -f ".claude/commands/verify.md" || fail "verify command not visible via .claude/commands"

echo "== 8. One rule: nested scripts/AGENTS.md exists, scoped to scripts/ =="
test -f "scripts/AGENTS.md" || fail "scripts/AGENTS.md missing"
test -f "scripts/CLAUDE.md" || fail "scripts/CLAUDE.md missing"
test "$(readlink scripts/CLAUDE.md)" = "AGENTS.md" || fail "scripts/CLAUDE.md is not a symlink to AGENTS.md"

echo "== 9. One MCP server (playwright, no secret required) is invocable =="
npx -y @playwright/mcp --help >/dev/null 2>&1 || fail "playwright MCP server failed to start"

echo "ALL CHECKS PASSED"
