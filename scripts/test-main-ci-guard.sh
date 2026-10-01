#!/usr/bin/env bash
# scripts/test-main-ci-guard.sh — proves the Main CI Guard decides correctly,
# including falling back to the commit's `✅ CI Complete` check run when the
# workflow-run listing has no completed ci-quality run for main's HEAD.
#
# Offline: the github-script body is extracted from the workflow and run under
# node against a stubbed GitHub client. Needs python3 (PyYAML) and node.
# Exit: 0 every case behaved as specified, 1 otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

for tool in python3 node; do
  command -v "$tool" > /dev/null 2>&1 || {
    echo "FAIL: required tool not found: $tool" >&2
    exit 1
  }
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

python3 - "$tmp/guard.js" << 'PY' || exit 1
import sys, yaml
wf = yaml.safe_load(open(".github/workflows/main-ci-guard.yml"))
steps = wf["jobs"]["main-ci-guard"]["steps"]
script = next(s["with"]["script"] for s in steps if s.get("name", "").startswith("Check latest CI Quality Gate"))
open(sys.argv[1], "w").write(script)
PY

cat > "$tmp/run.js" << 'JS'
const fs = require("fs");
const sc = JSON.parse(process.argv[3]);
const script = fs.readFileSync(process.argv[2], "utf8");
const AsyncFunction = Object.getPrototypeOf(async function () {}).constructor;
const result = { failed: null, usedChecks: false };
const github = { rest: {
  repos: { getBranch: async () => ({ data: { commit: { sha: "HEAD1" } } }) },
  actions: { listWorkflowRuns: async () => ({ data: { workflow_runs: sc.runs || [] } }) },
  checks: { listForRef: async () => { result.usedChecks = true; return { data: { check_runs: sc.checks || [] } }; } },
} };
const core = { info() {}, warning() {}, setFailed: (m) => { result.failed = String(m); } };
const context = { repo: { owner: "o", repo: "r" } };
new AsyncFunction("github", "context", "core", script)(github, context, core)
  .then(() => console.log(JSON.stringify(result)))
  .catch((e) => { console.log(JSON.stringify({ failed: "THROWN: " + e.message })); });
JS

pass=0
fail=0
# case <label> <expect: pass|fail> <scenario-json>
case_() {
  local label="$1" want="$2" out failed
  out="$(node "$tmp/run.js" "$tmp/guard.js" "$3")"
  failed="$(python3 -c 'import json,sys; print(json.load(sys.stdin)["failed"] is not None)' <<< "$out")"
  if { [ "$want" = pass ] && [ "$failed" = False ]; } || { [ "$want" = fail ] && [ "$failed" = True ]; }; then
    pass=$((pass + 1))
    echo "  ok   $label"
  else
    fail=$((fail + 1))
    echo "  FAIL $label: want $want, got $out"
  fi
}

ok_run='{"head_sha":"HEAD1","conclusion":"success","html_url":"u"}'
bad_run='{"head_sha":"HEAD1","conclusion":"failure","html_url":"u"}'
other='{"head_sha":"OLD","conclusion":"success","html_url":"u"}'
done_ok='{"name":"✅ CI Complete","status":"completed","conclusion":"success","html_url":"c"}'
done_bad='{"name":"✅ CI Complete","status":"completed","conclusion":"failure","html_url":"c"}'
running='{"name":"✅ CI Complete","status":"in_progress","conclusion":null,"html_url":"c"}'

echo "== main-ci-guard =="
case_ "completed green run for HEAD -> pass" pass "{\"runs\":[$ok_run]}"
case_ "run for HEAD failed -> fail" fail "{\"runs\":[$bad_run]}"
case_ "run listing misses HEAD, check run green -> pass (fallback)" pass "{\"runs\":[$other],\"checks\":[$done_ok]}"
case_ "run listing empty, check run green -> pass (fallback)" pass "{\"runs\":[],\"checks\":[$done_ok]}"
case_ "run listing misses HEAD, check run failed -> fail" fail "{\"runs\":[$other],\"checks\":[$done_bad]}"
case_ "run listing misses HEAD, check run still running -> fail, never a pass" fail "{\"runs\":[],\"checks\":[$running]}"
case_ "no run and no check run at all -> fail" fail '{"runs":[],"checks":[]}'

echo
if [ "$fail" -gt 0 ]; then
  echo "FAILED ${fail} case(s), ${pass} passed"
  exit 1
fi
echo "ALL ${pass} CASES BEHAVED AS EXPECTED"
