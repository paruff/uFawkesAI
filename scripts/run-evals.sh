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
# Task schema:
#   { "id", "why", "prompt", "permission_mode"?: "default"|"acceptEdits",
#     "expect": { "output_regex"?: ERE, "file_absent"?: path, "file_present"?: path } }
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
#
# Exit: 0 pass rate >= baseline, 1 below baseline or no tasks, 2 setup error.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 2

TASKS="${EVAL_TASKS:-.agents/evals/tasks}"
BASELINE="${EVAL_BASELINE:-.agents/evals/baseline.json}"
REPORT="${EVAL_REPORT:-.agents/logs/evals-report.json}"
HARNESS="${EVAL_HARNESS:-claude}"

claude_agent() {
  claude -p "$1" --model "$MODEL" --permission-mode "$2" --max-turns 8 --output-format text
}
# OpenCode is the other first-class harness: it reads AGENTS.md, the
# instructions in opencode.json (.agents/rules) and the .opencode plugin hooks,
# so it exercises the same configuration with any provider key the repo has.
opencode_agent() {
  opencode run --model "$MODEL" "$1"
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

command -v jq > /dev/null || {
  echo "FAIL: jq is required" >&2
  exit 2
}
[ -r "$BASELINE" ] || {
  echo "FAIL: baseline missing or unreadable: $BASELINE" >&2
  exit 2
}
baseline="$(jq -er .pass_rate "$BASELINE")" || {
  echo "FAIL: $BASELINE has no numeric pass_rate" >&2
  exit 2
}

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
  mode="$(jq -r '.permission_mode // "default"' "$f")"

  copy="${work}/${id}"
  mkdir -p "$copy"
  git ls-files -co --exclude-standard -z | tar --null -T - -cf - | tar -xf - -C "$copy"

  out="$(cd "$copy" && "$AGENT" "$prompt" "$mode" 2>&1)"
  rc=$?

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

  [ "$verdict" = pass ] && passed=$((passed + 1))
  printf '  %-4s %s%s\n' "$verdict" "$id" "${reasons[*]:+ — ${reasons[*]}}"
  results="$(jq --arg id "$id" --arg v "$verdict" --arg r "${reasons[*]:-}" --arg o "${out:0:2000}" \
    '. + [{id: $id, verdict: $v, reasons: $r, output: $o}]' <<< "$results")"
done

total="${#files[@]}"
rate="$(jq -n --argjson p "$passed" --argjson t "$total" '$p / $t')"
mkdir -p "$(dirname "$REPORT")"
jq -n --argjson r "$results" --argjson rate "$rate" --argjson base "$baseline" --arg m "$MODEL" \
  '{model: $m, pass_rate: $rate, baseline: $base, results: $r}' > "$REPORT"

echo "evals: ${passed}/${total} passed (rate ${rate}, baseline ${baseline}) — report: ${REPORT}"
if jq -en --argjson rate "$rate" --argjson base "$baseline" '$rate < $base' > /dev/null; then
  echo "FAIL: pass rate ${rate} is below baseline ${baseline} — this configuration change regresses agent behaviour" >&2
  exit 1
fi
