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
# $STUB_STDERR is written to stderr (a crashed harness explains itself there).
# STUB_FORMAT=opencode|claude emits that harness's JSON transcript with
# $STUB_STEPS steps and the comma-separated $STUB_TOOLS calls; default: plain text.
cat > "$tmp/stub.sh" << 'EOF'
#!/usr/bin/env bash
[ "${STUB_WRITE_ENV:-0}" = 1 ] && echo "API_KEY=placeholder" > .env
[ -n "${STUB_COUNT_FILE:-}" ] && echo run >> "$STUB_COUNT_FILE"
[ -n "${STUB_STDERR:-}" ] && echo "$STUB_STDERR" >&2
# STUB_FLAKE_ONCE=<marker>: the first call anywhere crashes (exit 1, no output),
# later ones answer normally. STUB_STEPS_FIRST=<n> with STUB_FIRST_MARKER=<marker>:
# the first call takes n steps instead of $STUB_STEPS (a one-off long trajectory).
if [ -n "${STUB_FLAKE_ONCE:-}" ] && [ ! -e "$STUB_FLAKE_ONCE" ]; then
  : > "$STUB_FLAKE_ONCE"
  exit 1
fi
if [ -n "${STUB_STEPS_FIRST:-}" ] && [ ! -e "${STUB_FIRST_MARKER:-/nonexistent}" ]; then
  : > "$STUB_FIRST_MARKER"
  STUB_STEPS="$STUB_STEPS_FIRST"
fi
# STUB_STALL_ONCE=<marker>: the first call anywhere stalls like a hung provider
# call, later ones answer normally (a transient stall, not a broken agent).
if [ -n "${STUB_STALL_ONCE:-}" ] && [ ! -e "$STUB_STALL_ONCE" ]; then
  : > "$STUB_STALL_ONCE"
  sleep "${STUB_STALL_SECONDS:-5}"
fi
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

# saw <label> <present|absent> <text>: checks the last expect's combined output.
saw() {
  local label="$1" mode="$2" text="$3" found=0
  grep -qF -- "$text" "$tmp/out.txt" && found=1
  if { [ "$mode" = present ] && [ "$found" = 1 ]; } || { [ "$mode" = absent ] && [ "$found" = 0 ]; }; then
    pass=$((pass + 1))
    printf '  ok   %s\n' "$label"
  else
    fail=$((fail + 1))
    printf '  FAIL %s: "%s" should be %s in the output\n' "$label" "$text" "$mode"
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
# A crashed agent must explain itself in the log, not only in a temp file.
expect "non-zero agent exit shows the agent's stderr" 1 STUB_REPLY="@builder" STUB_EXIT=1 STUB_STDERR="boom: model not found"
saw "  the stderr of the failed agent is printed" present "boom: model not found"
expect "agent stderr on a passing run stays out of the log" 0 STUB_REPLY="@builder" STUB_STDERR="harmless warning"
saw "  no stderr is printed when the agent exits 0" absent "harmless warning"
# A harness that reports its error on stdout (opencode --format json) leaves stderr
# empty: show the bounded tail of stdout instead, so the crash still explains itself.
expect "non-zero exit, empty stderr: the stdout tail is shown" 1 STUB_REPLY="fatal: provider error" STUB_EXIT=1
saw "  the header says stderr was empty" present "stderr empty, stdout (last 1500 bytes):"
saw "  the stdout of the failed agent is printed" present "fatal: provider error"
filler="$(printf 'x%.0s' $(seq 1 2000))"
expect "stdout tail is bounded to the last 1500 bytes" 1 STUB_REPLY="HEADMARK${filler}TAILMARK" STUB_EXIT=1
saw "  the end of stdout is kept" present "TAILMARK"
saw "  the start of a long stdout is dropped" absent "HEADMARK"
expect "non-zero exit with no output at all says so" 1 STUB_REPLY="" STUB_EXIT=1
saw "  the empty crash is named" present "agent exited 1; no output on stderr or stdout"
expect "non-zero exit with stderr content prints stderr only" 1 STUB_REPLY="stdout-only-text" STUB_EXIT=1 STUB_STDERR="boom: real cause"
saw "  stderr is printed" present "boom: real cause"
saw "  stdout is not printed when stderr has content" absent "stderr empty, stdout"
expect "passing run prints neither stream" 0 STUB_REPLY="@builder" STUB_STDERR=""
saw "  no crash block on a passing run" absent "agent exited"
expect "stalled agent hits EVAL_TASK_TIMEOUT -> red, not a hang" 1 STUB_REPLY="@builder" STUB_SLEEP=5 EVAL_TASK_TIMEOUT=1

# A timeout is a provider stall, not a verdict on the configuration: it gets one
# retry in a fresh copy. Only a timeout does. A wrong answer is a real failure.
expect "stalls once, then answers -> green (the timeout is retried)" 0 STUB_REPLY="@builder" STUB_STALL_ONCE="$tmp/stalled-once" EVAL_TASK_TIMEOUT=1
expect "EVAL_TIMEOUT_RETRIES=0: a stall fails, as before" 1 STUB_REPLY="@builder" STUB_STALL_ONCE="$tmp/stalled-once-0" EVAL_TASK_TIMEOUT=1 EVAL_TIMEOUT_RETRIES=0
rm -f "$tmp/runs"
expect "wrong answer -> red" 1 STUB_REPLY="@planner" STUB_COUNT_FILE="$tmp/runs"
if [ "$(wc -l < "$tmp/runs")" -eq 2 ]; then
  pass=$((pass + 1))
  echo "  ok   a wrong answer is not retried (2 tasks, 2 runs)"
else
  fail=$((fail + 1))
  echo "  FAIL a wrong answer was retried: $(wc -l < "$tmp/runs") runs for 2 tasks"
fi

# Flakes that are not a verdict on the configuration get one retry (EVAL_FLAKE_RETRIES):
# a crash with no output, and a right answer that took too many steps. Nothing else.
runs_is() { # runs_is <label> <n>: the stub was called n times in the last expect
  if [ "$(wc -l < "$tmp/runs")" -eq "$2" ]; then
    pass=$((pass + 1))
    echo "  ok   $1 ($2 runs)"
  else
    fail=$((fail + 1))
    echo "  FAIL $1: $(wc -l < "$tmp/runs") runs, want $2"
  fi
}
rm -f "$tmp/runs" "$tmp/crashed-once"
expect "crashes once, then answers -> green (the crash is retried)" 0 STUB_REPLY="@builder" STUB_FLAKE_ONCE="$tmp/crashed-once" STUB_COUNT_FILE="$tmp/runs"
saw "  the retry is logged" present "retry env: crash, attempt 1 of 1"
saw "  the summary counts the retried task" present "1 task(s) needed a retry"
runs_is "  2 tasks and 1 retry" 3
if jq -e '([.results[] | select(.attempts == 2)] | length) == 1 and ([.results[] | select(.attempts == 1)] | length) == 1' "$tmp/report.json" > /dev/null; then
  pass=$((pass + 1))
  echo "  ok   the report records attempts per task"
else
  fail=$((fail + 1))
  echo "  FAIL attempts missing from the report: $(jq -c '[.results[] | {id, attempts}]' "$tmp/report.json")"
fi
rm -f "$tmp/runs"
expect "crashes every time -> red after the retry" 1 STUB_EXIT=1 STUB_COUNT_FILE="$tmp/runs"
runs_is "  each task tried twice" 4
rm -f "$tmp/runs" "$tmp/first-steps"
expect "too many steps once, then within the cap -> green" 0 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read STUB_STEPS=2 STUB_STEPS_FIRST=4 STUB_FIRST_MARKER="$tmp/first-steps" STUB_REPLY="@builder" STUB_COUNT_FILE="$tmp/runs"
saw "  the overrun retry is logged" present "retry look: steps 4 > max 3, attempt 1 of 1"
runs_is "  1 task and 1 retry" 2
rm -f "$tmp/runs"
expect "too many steps every time -> red" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read STUB_STEPS=4 STUB_REPLY="@builder" STUB_COUNT_FILE="$tmp/runs"
runs_is "  retried once, then failed" 2
rm -f "$tmp/runs" "$tmp/first-steps"
expect "EVAL_FLAKE_RETRIES=0: a one-off overrun fails" 1 EVAL_FLAKE_RETRIES=0 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read STUB_STEPS=2 STUB_STEPS_FIRST=4 STUB_FIRST_MARKER="$tmp/first-steps" STUB_REPLY="@builder" STUB_COUNT_FILE="$tmp/runs"
runs_is "  no retry" 1
rm -f "$tmp/runs"
expect "forbidden tool plus overrun is not retried" 1 EVAL_TASKS="$tmp/tooled" STUB_FORMAT=opencode STUB_TOOLS=read,write STUB_STEPS=4 STUB_REPLY="@builder" STUB_COUNT_FILE="$tmp/runs"
runs_is "  a tool-use failure runs once" 1
rm -f "$tmp/runs"
expect "protected .env written is not retried" 1 STUB_REPLY="@builder" STUB_WRITE_ENV=1 STUB_COUNT_FILE="$tmp/runs"
runs_is "  2 tasks, 2 runs" 2
rm -f "$tmp/runs"
expect "ignore_agent_exit: a refusal that exits non-zero is not a crash" 0 EVAL_TASKS="$tmp/outcome" STUB_EXIT=1 STUB_COUNT_FILE="$tmp/runs"
runs_is "  not retried" 1
saw "  a plain run prints no retry summary" absent "needed a retry"

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
