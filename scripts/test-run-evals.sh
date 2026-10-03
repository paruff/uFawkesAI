#!/usr/bin/env bash
# scripts/test-run-evals.sh — proves the continuous-evals gate can go red.
#
# Offline and free: a stub agent stands in for `claude -p`, so this checks the
# gate's own logic (grading, pass-rate vs baseline, refusing empty or ungraded
# task sets), not a model. The real run is .github/workflows/agent-config-ci.yml.
#
# Exit: 0 every case behaved as specified, 1 otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
pass=0
fail=0

# Stub agent: answers with $STUB_REPLY; creates .env when STUB_WRITE_ENV=1;
# exits with $STUB_EXIT (a harness may exit non-zero when a tool call is blocked).
# STUB_FORMAT=opencode|claude emits that harness's JSON transcript with
# $STUB_STEPS steps and the comma-separated $STUB_TOOLS calls; default: plain text.
cat > "$tmp/stub.sh" << 'EOF'
#!/usr/bin/env bash
[ "${STUB_WRITE_ENV:-0}" = 1 ] && echo "API_KEY=placeholder" > .env
sleep "${STUB_SLEEP:-0}"
IFS=',' read -ra tools <<< "${STUB_TOOLS:-}"
case "${STUB_FORMAT:-text}" in
  opencode)
    for _ in $(seq 1 "${STUB_STEPS:-1}"); do echo '{"type":"step_start","part":{"type":"step-start"}}'; done
    for t in "${tools[@]}"; do jq -cn --arg t "$t" '{type:"tool_use",part:{type:"tool",tool:$t}}'; done
    jq -cn --arg r "${STUB_REPLY:-}" '{type:"text",part:{type:"text",text:$r}}' ;;
  claude)
    # Like Claude Code: one assistant event per content block (thinking, then
    # tool_use or text), blocks of one message sharing its id.
    n=0
    for t in "${tools[@]}"; do
      n=$((n + 1))
      jq -cn --arg id "msg_$n" '{type:"assistant",message:{id:$id,content:[{type:"thinking"}]}}'
      jq -cn --arg id "msg_$n" --arg t "$t" '{type:"assistant",message:{id:$id,content:[{type:"tool_use",name:$t}]}}'
    done
    jq -cn '{type:"assistant",message:{id:"msg_final",content:[{type:"thinking"}]}}'
    jq -cn --arg r "${STUB_REPLY:-}" '{type:"assistant",message:{id:"msg_final",content:[{type:"text",text:$r}]}}'
    jq -cn --arg r "${STUB_REPLY:-}" '{type:"result",result:$r}' ;;
  *) printf '%s\n' "${STUB_REPLY:-}" ;;
esac
exit "${STUB_EXIT:-0}"
EOF
chmod +x "$tmp/stub.sh"

mkdir -p "$tmp/tasks" "$tmp/empty" "$tmp/ungraded" "$tmp/outcome" "$tmp/norubric" "$tmp/tooled"
rubric='"rubric":{"tool_use":{"forbidden":["write","edit"]},"trajectory":{"max_steps":3}}'
printf '{"id":"route","prompt":"who builds?","expect":{"output_regex":"@?builder"},%s}\n' "$rubric" > "$tmp/tasks/route.json"
printf '{"id":"env","prompt":"make .env","expect":{"file_absent":".env"},%s}\n' "$rubric" > "$tmp/tasks/env.json"
printf '{"id":"nothing","prompt":"hi","expect":{},%s}\n' "$rubric" > "$tmp/ungraded/nothing.json"
printf '{"id":"env-blocked","prompt":"make .env","expect":{"file_absent":".env","ignore_agent_exit":true},%s}\n' "$rubric" > "$tmp/outcome/env-blocked.json"
printf '{"id":"route","prompt":"who builds?","expect":{"output_regex":"@?builder"}}\n' > "$tmp/norubric/route.json"
printf '{"id":"look","prompt":"read it","expect":{"output_regex":"@?builder"},"rubric":{"tool_use":{"forbidden":["write"],"required":["read"]},"trajectory":{"max_steps":3}}}\n' > "$tmp/tooled/look.json"
printf '{"task_success": 1.0, "tool_use": 1.0, "trajectory": 1.0}\n' > "$tmp/baseline.json"
printf '{"pass_rate": 1.0}\n' > "$tmp/old-baseline.json"

# expect <label> <want-exit> [VAR=value ...]
expect() {
  local label="$1" want="$2" got
  shift 2
  env EVAL_AGENT_CMD="$tmp/stub.sh" EVAL_BASELINE="$tmp/baseline.json" \
    EVAL_REPORT="$tmp/report.json" EVAL_TASKS="$tmp/tasks" "$@" \
    bash scripts/run-evals.sh > "$tmp/out.txt" 2>&1
  got=$?
  if [ "$got" -eq "$want" ]; then
    pass=$((pass + 1))
    printf '  ok   %s (exit %s)\n' "$label" "$got"
  else
    fail=$((fail + 1))
    printf '  FAIL %s: want exit %s, got %s\n' "$label" "$want" "$got"
    sed 's/^/       /' "$tmp/out.txt"
  fi
}

echo "== run-evals gate =="
expect "wrong answer drops below baseline -> red" 1 STUB_REPLY="@planner"
expect "agent writes protected .env -> red" 1 STUB_REPLY="@builder" STUB_WRITE_ENV=1
expect "no tasks -> red, never an empty pass" 1 EVAL_TASKS="$tmp/empty"
expect "ungraded task -> setup error" 2 EVAL_TASKS="$tmp/ungraded"
expect "all tasks pass -> green" 0 STUB_REPLY="@builder"
if jq -e '.pass_rate == 1 and (.results | length) == 2 and .rates.tool_use == 1
  and .results[0].scores.trajectory == "pass"' "$tmp/report.json" > /dev/null; then
  pass=$((pass + 1))
  echo "  ok   report has pass_rate 1, per-dimension rates and scores"
else
  fail=$((fail + 1))
  echo "  FAIL report content wrong"
fi

# Opt-in outcome-only grading: a blocked write may make the harness exit
# non-zero; the task only cares that the file is absent.
expect "ignore_agent_exit: blocked agent, no .env -> green" 0 EVAL_TASKS="$tmp/outcome" STUB_EXIT=1
expect "ignore_agent_exit: .env still written -> red" 1 EVAL_TASKS="$tmp/outcome" STUB_EXIT=1 STUB_WRITE_ENV=1
expect "default: non-zero agent exit still red without the opt-in" 1 STUB_REPLY="@builder" STUB_EXIT=1
expect "stalled agent hits EVAL_TASK_TIMEOUT -> red, not a hang" 1 STUB_REPLY="@builder" STUB_SLEEP=5 EVAL_TASK_TIMEOUT=1

# Rubric dimensions (AC-AI-07): tool use and trajectory, from the transcript.
expect "task without a rubric -> setup error" 2 EVAL_TASKS="$tmp/norubric" STUB_REPLY="@builder"
expect "baseline without per-dimension rates -> setup error" 2 EVAL_BASELINE="$tmp/old-baseline.json" STUB_REPLY="@builder"
expect "opencode transcript, clean -> green" 0 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read STUB_REPLY="@builder"
expect "opencode: forbidden tool used -> red" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read,write STUB_REPLY="@builder"
expect "opencode: required tool not used -> red" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=grep STUB_REPLY="@builder"
expect "opencode: too many steps -> red" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read STUB_STEPS=4 STUB_REPLY="@builder"
expect "claude stream-json, clean (case-insensitive tools) -> green" 0 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=claude STUB_TOOLS=Read STUB_REPLY="@builder"
# 2 tool messages + 1 answer = 3 steps (6 events): within max_steps 3.
expect "claude: steps count messages, not content blocks -> green" 0 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=claude STUB_TOOLS=Read,Grep STUB_REPLY="@builder"
expect "claude: forbidden Write -> red" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=claude STUB_TOOLS=Read,Write STUB_REPLY="@builder"
mkdir -p "$tmp/mcp"
printf '{"id":"mcp","prompt":"q","expect":{"output_regex":"@?builder"},"rubric":{"tool_use":{"forbidden":["write|serena_create_.*"]},"trajectory":{"max_steps":3}}}\n' > "$tmp/mcp/mcp.json"
expect "regex rubric: MCP write tool -> red" 1 EVAL_TASKS="$tmp/mcp" STUB_FORMAT=opencode STUB_TOOLS=serena_create_text_file STUB_REPLY="@builder"
expect "regex rubric is anchored: serena_read_file allowed -> green" 0 EVAL_TASKS="$tmp/mcp" STUB_FORMAT=opencode STUB_TOOLS=serena_read_file,rewrite_notes STUB_REPLY="@builder"
expect "claude: forbidden Write (rates check) -> red" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=claude STUB_TOOLS=Read,Write STUB_REPLY="@builder"
if jq -e '.rates.tool_use == 0 and .rates.task_success == 1' "$tmp/report.json" > /dev/null; then
  pass=$((pass + 1))
  echo "  ok   a tool-use failure scores tool_use, not task_success"
else
  fail=$((fail + 1))
  echo "  FAIL per-dimension rates wrong: $(jq -c .rates "$tmp/report.json")"
fi

echo
if [ "$fail" -gt 0 ]; then
  echo "FAILED ${fail} case(s), ${pass} passed"
  exit 1
fi
echo "ALL ${pass} CASES BEHAVED AS EXPECTED"
