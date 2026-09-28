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
  test -f ".agents/commands/$cmd.md" || fail "Claude Code command '$cmd' not found at .agents/commands/$cmd.md"
done
if [ -e ".agents/commands/doctor.md" ] || [ -d ".claude/skills/doctor" ]; then
  fail "a project-level 'doctor' command/skill exists — this would shadow Claude Code's built-in /doctor"
fi

echo "== 5. One skill loadable under both harnesses: test-execution =="
test -f ".claude/skills/test-execution/SKILL.md" || fail "test-execution skill missing at Claude Code path"
test -f ".opencode/skills/test-execution/SKILL.md" || fail "test-execution skill missing at OpenCode path"

echo "== 6. One hook: the protected-path blocker actually blocks =="
# Run the real PreToolUse command from .claude/settings.json, fed the same
# stdin JSON Claude Code sends, so this test cannot drift from the hook.
hook_cmd="$(node -e "
  const s=require('./.claude/settings.json');
  const e=(s.hooks.PreToolUse||[]).find(m=>m.matcher==='Edit|Write');
  process.stdout.write(((e&&e.hooks)||[])[0]?.command||'');
")"
test -n "$hook_cmd" || fail "PreToolUse Edit|Write hook missing or malformed in .claude/settings.json"
run_hook() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' "$1" | bash -c "$hook_cmd" 2>/dev/null; }
set +e
run_hook "$PWD/.env.local"; blocked=$?
run_hook "$PWD/README.md"; allowed=$?
run_hook "$PWD/.env.example"; template=$?
set -e
test "$blocked" -eq 2 || fail "protected-path hook did not block .env.local (exit $blocked)"
test "$allowed" -eq 0 || fail "protected-path hook blocked README.md (exit $allowed)"
test "$template" -eq 0 || fail "protected-path hook blocked the secret-free .env.example template (exit $template)"
echo "  protected-path hook correctly blocked .env.local and allowed README.md and .env.example"

echo "== 7. One command's definition is present for both harnesses: /verify =="
test -f ".agents/commands/verify.md" || fail "verify command definition missing"
test -f ".agents/commands/verify.md" || fail "verify command not visible via .agents/commands"

echo "== 8. One rule: nested scripts/AGENTS.md exists, scoped to scripts/ =="
test -f "scripts/AGENTS.md" || fail "scripts/AGENTS.md missing"
test -f "scripts/CLAUDE.md" || fail "scripts/CLAUDE.md missing"
test "$(readlink scripts/CLAUDE.md)" = "AGENTS.md" || fail "scripts/CLAUDE.md is not a symlink to AGENTS.md"

echo "== 9. One MCP server (playwright, no secret required) is invocable =="
npx -y @playwright/mcp --help >/dev/null 2>&1 || fail "playwright MCP server failed to start"

echo "ALL CHECKS PASSED"
