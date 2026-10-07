#!/usr/bin/env bash
# scripts/run-evals.sh — continuous evals for the agent configuration.
#
# Replays every task in .agents/evals/tasks/*.json against the CURRENT
# configuration (AGENTS.md, .agents/rules, skills, agents, hooks), grades each
# deterministically, and fails if the pass rate drops below
# .agents/evals/baseline.json. Loaded by the continuous-evals skill; run by
# .github/workflows/agent-config-ci.yml when agent configuration changes.
#
# Each task runs in a throwaway copy of the working tree (tracked + untracked,
# not ignored), so an eval that writes files cannot touch the repo, and local
# uncommitted config changes are what gets evaluated.
#
# Task schema (every task is scored on three rubric dimensions, AC-AI-07):
#   { "id", "why", "prompt", "permission_mode"?: "default"|"acceptEdits",
#     "expect": { "output_regex"?: ERE, "file_absent"?: path, "file_present"?: path },
#                                       -> task_success
#     "rubric": { "tool_use": { "forbidden": [ERE], "required"?: [ERE] },
#                                       -> tool_use (each ERE must match a whole tool
#                                          name, case-insensitively; MCP tools too)
#                 "trajectory": { "max_steps": N } } }
#                                       -> trajectory (model steps taken)
# The agent's transcript is parsed per harness (OpenCode --format json,
# Claude stream-json); plain-text output has no tool calls and 0 steps.
# baseline.json: { "task_success", "tool_use", "trajectory": rate 0..1 }; the
# gate fails if any dimension's rate drops below its baseline.
#
# Env:
#   EVAL_HARNESS    claude (default) or opencode
#   EVAL_MODEL      model (default: claude-haiku-4-5-20251001 for claude,
#                   google/gemini-3.1-flash-lite for opencode)
#   EVAL_AGENT_CMD  agent command; called as: $EVAL_AGENT_CMD <prompt> <permission_mode>
#                   in the task's copy. Default is the harness's CLI. Tests stub it.
#   EVAL_TASKS      task dir (default .agents/evals/tasks)
#   EVAL_BASELINE   baseline file (default .agents/evals/baseline.json)
#   EVAL_REPORT     report path (default .agents/logs/evals-report.json)
#   EVAL_TIMEOUT_RETRIES extra tries for a task that times out (default 1), each in a
#                     fresh copy; a wrong answer is never retried
#   EVAL_TASK_TIMEOUT seconds per task (default 300); a task that times out on every try fails
#
# Exit: 0 pass rate >= baseline, 1 below baseline or no tasks, 2 setup error.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

TASKS="${EVAL_TASKS:-.agents/evals/tasks}"
BASELINE="${EVAL_BASELINE:-.agents/evals/baseline.json}"
REPORT="${EVAL_REPORT:-.agents/logs/evals-report.json}"
HARNESS="${EVAL_HARNESS:-claude}"

claude_agent() {
  claude -p "$1" --model "$MODEL" --permission-mode "$2" --max-turns 8 \
    --output-format stream-json --verbose
}
# OpenCode is the other first-class harness: it reads AGENTS.md, the
# instructions in opencode.json (.agents/rules) and the .opencode plugin hooks,
# so it exercises the same configuration with any provider key the repo has.
opencode_agent() {
  opencode run --model "$MODEL" --format json "$1"
}

# transcript -> {text, tools: [lowercase names], steps}
parse_transcript() {
  jq -Rs '
    [split("\n")[] | select(length > 0) | (try fromjson catch null)] as $ev
    | if ($ev | length) > 0 and all($ev[]; type == "object") then
        if any($ev[]; .part != null) then   # OpenCode --format json
          { text: ([$ev[] | select(.type == "text") | .part.text] | join("\n")),
            tools: [$ev[] | select(.type == "tool_use") | .part.tool | ascii_downcase],
            steps: ([$ev[] | select(.type == "step_start")] | length) }
        else                                # Claude stream-json
          { text: ([$ev[] | select(.type == "result") | .result // empty] | join("\n")),
            tools: [$ev[] | select(.type == "assistant") | .message.content[]?
                    | select(.type == "tool_use") | .name | ascii_downcase],
            # one event per content block; blocks of a message share its id
            steps: ([$ev[] | select(.type == "assistant") | .message.id] | unique | length) }
        end
      else { text: ., tools: [], steps: 0 }  # plain text
      end'
}
case "$HARNESS" in
  claude) MODEL="${EVAL_MODEL:-claude-haiku-4-5-20251001}" ;;
  opencode) MODEL="${EVAL_MODEL:-google/gemini-3.1-flash-lite}" ;;
  *)
    echo "FAIL: EVAL_HARNESS must be claude or opencode, got '$HARNESS'" >&2
    exit 2
    ;;
esac
AGENT="${EVAL_AGENT_CMD:-${HARNESS}_agent}"
TASK_TIMEOUT="${EVAL_TASK_TIMEOUT:-300}"
TIMEOUT_RETRIES="${EVAL_TIMEOUT_RETRIES:-1}"
case "$TIMEOUT_RETRIES" in
  '' | *[!0-9]*)
    echo "FAIL: EVAL_TIMEOUT_RETRIES must be a number, got '$TIMEOUT_RETRIES'" >&2
    exit 2
    ;;
esac
# GNU timeout (gtimeout on macOS); exit 124 on timeout. Shell functions can't
# be exec'd by timeout, so they run through a child bash with the same env.
TIMEOUT_BIN="$(command -v timeout || command -v gtimeout || true)"
run_bounded() {
  if [ -z "$TIMEOUT_BIN" ]; then
    "$@"
  elif declare -F "$1" > /dev/null; then
    "$TIMEOUT_BIN" "$TASK_TIMEOUT" bash -c "$(declare -f "$1"); MODEL='${MODEL}'; \"\$@\"" _ "$@"
  else
    "$TIMEOUT_BIN" "$TASK_TIMEOUT" "$@"
  fi
}

command -v jq > /dev/null || {
  echo "FAIL: jq is required" >&2
  exit 2
}
[ -r "$BASELINE" ] || {
  echo "FAIL: baseline missing or unreadable: $BASELINE" >&2
  exit 2
}
for dim in task_success tool_use trajectory; do
  jq -e --arg d "$dim" '.[$d] | numbers' "$BASELINE" > /dev/null || {
    echo "FAIL: $BASELINE has no numeric $dim rate" >&2
    exit 2
  }
done

shopt -s nullglob
files=("$TASKS"/*.json)
# An eval gate with nothing to evaluate is not a gate: fail, never pass empty.
if [ "${#files[@]}" -eq 0 ]; then
  echo "FAIL: no eval tasks in $TASKS — refusing to report a pass" >&2
  exit 1
fi

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
results='[]'
passed=0
n_task=0
n_tool=0
n_traj=0

for f in "${files[@]}"; do
  id="$(jq -er .id "$f")" || {
    echo "FAIL: $f has no id" >&2
    exit 2
  }
  prompt="$(jq -er .prompt "$f")" || {
    echo "FAIL: $id has no prompt" >&2
    exit 2
  }
  if ! jq -e '.expect | (.output_regex // .file_absent // .file_present)' "$f" > /dev/null; then
    echo "FAIL: $id has no expectation — an ungraded task always passes" >&2
    exit 2
  fi
  if ! jq -e '(.rubric.tool_use.forbidden | arrays) and (.rubric.trajectory.max_steps | numbers)' "$f" > /dev/null; then
    echo "FAIL: $id has no rubric (rubric.tool_use.forbidden and rubric.trajectory.max_steps) — score all three dimensions" >&2
    exit 2
  fi
  mode="$(jq -r '.permission_mode // "default"' "$f")"

  # A stalled provider call must fail its task, not hang the whole gate. A timeout
  # is not a verdict on the configuration either: the same task takes seconds when
  # the provider answers, so it gets EVAL_TIMEOUT_RETRIES more tries, each in a
  # fresh copy so a half-finished attempt can't leak into the next. A task that
  # stalls every time still fails, and a wrong answer is never retried.
  attempt=0
  while :; do
    copy="${work}/${id}.${attempt}"
    mkdir -p "$copy"
    git ls-files -co --exclude-standard -z | tar --null -T - -cf - | tar -xf - -C "$copy"
    raw="$(cd "$copy" && run_bounded "$AGENT" "$prompt" "$mode" 2> "${copy}.stderr")"
    rc=$?
    [ "$rc" -eq 124 ] && echo "agent timed out after ${TASK_TIMEOUT}s" >> "${copy}.stderr"
    if [ "$rc" -ne 124 ] || [ "$attempt" -ge "$TIMEOUT_RETRIES" ]; then break; fi
    attempt=$((attempt + 1))
    echo "  retry ${id}: agent timed out after ${TASK_TIMEOUT}s, attempt ${attempt} of ${TIMEOUT_RETRIES} retries" >&2
  done
  t="$(parse_transcript <<< "$raw")"
  out="$(jq -r .text <<< "$t")"
  [ -n "$out" ] || out="$(cat "${copy}.stderr")"

  verdict=pass
  reasons=()
  # A task may opt out of grading the exit code (expect.ignore_agent_exit) when
  # a non-zero exit is a legitimate way to refuse, e.g. a blocked tool call.
  # Only its outcome checks below then decide. Trade-off: a crashed agent also
  # leaves a file absent, so use this only for "must not happen" tasks.
  if [ "$rc" -ne 0 ] && ! jq -e '.expect.ignore_agent_exit == true' "$f" > /dev/null; then
    verdict=fail
    reasons+=("agent exited $rc")
  fi
  if re="$(jq -er '.expect.output_regex // empty' "$f")"; then
    grep -Eiq -- "$re" <<< "$out" || {
      verdict=fail
      reasons+=("output did not match /$re/")
    }
  fi
  if p="$(jq -er '.expect.file_absent // empty' "$f")"; then
    [ ! -e "${copy}/${p}" ] || {
      verdict=fail
      reasons+=("$p exists")
    }
  fi
  if p="$(jq -er '.expect.file_present // empty' "$f")"; then
    [ -e "${copy}/${p}" ] || {
      verdict=fail
      reasons+=("$p missing")
    }
  fi

  task_ok=$verdict
  tool_bad="$(jq -r --slurpfile task "$f" '
    ($task[0].rubric.tool_use) as $r | .tools as $used
    | def hits($p): [$used[] | select(test("^(" + $p + ")$"; "i"))];
    [($r.forbidden[] | hits(.)[] | "used forbidden tool \(.)"),
     ($r.required // [] | .[] | select(hits(.) | length == 0) | "did not use \(.)")]
    | join("; ")' <<< "$t")"
  tool_ok=pass
  [ -z "$tool_bad" ] || {
    tool_ok=fail
    reasons+=("$tool_bad")
  }
  steps="$(jq .steps <<< "$t")"
  max_steps="$(jq .rubric.trajectory.max_steps "$f")"
  traj_ok=pass
  [ "$steps" -le "$max_steps" ] || {
    traj_ok=fail
    reasons+=("${steps} steps > max ${max_steps}")
  }

  [ "$task_ok" = pass ] && n_task=$((n_task + 1))
  [ "$tool_ok" = pass ] && n_tool=$((n_tool + 1))
  [ "$traj_ok" = pass ] && n_traj=$((n_traj + 1))
  [ "$task_ok$tool_ok$traj_ok" = passpasspass ] || verdict=fail
  [ "$verdict" = pass ] && passed=$((passed + 1))
  printf '  %-4s %s%s\n' "$verdict" "$id" "${reasons[*]:+ — ${reasons[*]}}"
  results="$(jq --arg id "$id" --arg v "$verdict" --arg r "${reasons[*]:-}" --arg o "${out:0:2000}" \
    --arg ts "$task_ok" --arg tu "$tool_ok" --arg tr "$traj_ok" --argjson tx "$t" \
    '. + [{id: $id, verdict: $v, reasons: $r, output: $o,
           scores: {task_success: $ts, tool_use: $tu, trajectory: $tr},
           tools: $tx.tools, steps: $tx.steps}]' <<< "$results")"
done

total="${#files[@]}"
rates="$(jq -n --argjson t "$total" --argjson a "$n_task" \
  --argjson b "$n_tool" --argjson c "$n_traj" \
  '{task_success: ($a / $t), tool_use: ($b / $t), trajectory: ($c / $t)}')"
rate="$(jq -n --argjson p "$passed" --argjson t "$total" '$p / $t')"
mkdir -p "$(dirname "$REPORT")"
jq -n --argjson r "$results" --argjson rate "$rate" --argjson rates "$rates" \
  --slurpfile base "$BASELINE" --arg m "$MODEL" \
  '{model: $m, pass_rate: $rate, rates: $rates, baseline: $base[0], results: $r}' > "$REPORT"

echo "evals: ${passed}/${total} fully passed; rates $(jq -c . <<< "$rates") vs baseline $(jq -c '{task_success, tool_use, trajectory}' "$BASELINE") — report: ${REPORT}"
below="$(jq -r --argjson rates "$rates" '[to_entries[] | select(.key | IN("task_success", "tool_use", "trajectory"))
  | select($rates[.key] < .value) | "\(.key) \($rates[.key]) < \(.value)"] | join(", ")' "$BASELINE")"
if [ -n "$below" ]; then
  echo "FAIL: below baseline: ${below} — this configuration change regresses agent behaviour" >&2
  exit 1
fi
