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

# Stub agent: answers with $STUB_REPLY; creates .env when STUB_WRITE_ENV=1.
cat > "$tmp/stub.sh" << 'EOF'
#!/usr/bin/env bash
[ "${STUB_WRITE_ENV:-0}" = 1 ] && echo "API_KEY=placeholder" > .env
printf '%s\n' "${STUB_REPLY:-}"
EOF
chmod +x "$tmp/stub.sh"

mkdir -p "$tmp/tasks" "$tmp/empty" "$tmp/ungraded"
printf '{"id":"route","prompt":"who builds?","expect":{"output_regex":"@?builder"}}\n' > "$tmp/tasks/route.json"
printf '{"id":"env","prompt":"make .env","expect":{"file_absent":".env"}}\n' > "$tmp/tasks/env.json"
printf '{"id":"nothing","prompt":"hi","expect":{}}\n' > "$tmp/ungraded/nothing.json"
printf '{"pass_rate": 1.0}\n' > "$tmp/baseline.json"

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

if jq -e '.pass_rate == 1 and (.results | length) == 2' "$tmp/report.json" > /dev/null; then
  pass=$((pass + 1))
  echo "  ok   report has pass_rate 1 and 2 results"
else
  fail=$((fail + 1))
  echo "  FAIL report content wrong"
fi

echo
if [ "$fail" -gt 0 ]; then
  echo "FAILED ${fail} case(s), ${pass} passed"
  exit 1
fi
echo "ALL ${pass} CASES BEHAVED AS EXPECTED"
