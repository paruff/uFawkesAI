#!/usr/bin/env bash
# Self-test for scripts/sdlc-seam: config errors, usage, and the output schema.
# Add a case_<name> function and list it in CASES to extend.
set -uo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE # hooks export these
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
seam="$here/sdlc-seam"
fails=0

# run_seam <config-json|-> args...  -> sets $out (stdout), $err (stderr), $rc
run_seam() {
  local cfg="$1"
  shift
  local tmp
  tmp="$(mktemp -d)"
  if [[ "$cfg" == "-" ]]; then
    export SEAM_CONFIG="$tmp/absent.json"
  else
    printf '%s' "$cfg" > "$tmp/.sdlc-engine.json"
    export SEAM_CONFIG="$tmp/.sdlc-engine.json"
  fi
  out="$("$seam" "$@" 2> "$tmp/err")"
  rc=$?
  err="$(cat "$tmp/err")"
  rm -rf "$tmp"
}

expect() { # name, ok-condition result
  if [[ "$2" == ok ]]; then echo "  PASS  $1"; else
    echo "  FAIL  $1 ($3)"
    fails=$((fails + 1))
  fi
}

case_unknown_engine() {
  run_seam '{"engine":"nope"}' engine
  [[ $rc -eq 2 && "$err" == *"unknown engine: nope"* && -z "$out" ]] && expect unknown_engine ok || expect unknown_engine bad "rc=$rc err=$err"
}
case_missing_config() {
  run_seam - engine
  [[ $rc -eq 2 && "$err" == *"no .sdlc-engine.json"* ]] && expect missing_config ok || expect missing_config bad "rc=$rc err=$err"
}
case_invalid_config() {
  run_seam '{not json' engine
  [[ $rc -eq 2 && "$err" == *"invalid .sdlc-engine.json"* ]] && expect invalid_json ok || expect invalid_json bad "rc=$rc err=$err"
  run_seam '{}' engine
  [[ $rc -eq 2 && "$err" == *'missing "engine"'* ]] && expect missing_engine_key ok || expect missing_engine_key bad "rc=$rc err=$err"
}
case_adapter_env_overrides() {
  SEAM_ADAPTER=other run_seam '{"engine":"nope"}' engine
  [[ $rc -eq 2 && "$err" == *"unknown engine: other"* ]] && expect adapter_env ok || expect adapter_env bad "rc=$rc err=$err"
}
case_usage() {
  run_seam - bogus
  [[ $rc -eq 2 && "$err" == *usage* ]] && expect unknown_subcommand ok || expect unknown_subcommand bad "rc=$rc err=$err"
  run_seam -
  [[ $rc -eq 2 && "$err" == *usage* ]] && expect no_subcommand ok || expect no_subcommand bad "rc=$rc err=$err"
}
case_schema_fixtures() {
  local schema="$root/.agents/schema/sdlc-seam.schema.json" d="$here/testdata/seam" ok=ok
  # every required key of each def must be present in its fixture, and schema must be 1
  local def file
  for pair in ChangeStatus:status.json NextAction:next.json; do
    def="${pair%%:*}" file="${pair##*:}"
    jq -e --slurpfile s "$schema" '. as $f | ($s[0]["$defs"]["'"$def"'"].required | all(. as $k | $f | has($k))) and .schema == 1' "$d/$file" > /dev/null || ok=bad
  done
  expect schema_fixtures "$ok" "fixture missing required keys"
  if command -v check-jsonschema > /dev/null; then
    echo '{"schema":2}' > "${TMPDIR:-/tmp}/seam-bad.$$.json"
    check-jsonschema --schemafile "$schema" "${TMPDIR:-/tmp}/seam-bad.$$.json" > /dev/null 2>&1 && expect schema_negative bad "bad doc accepted" || expect schema_negative ok
    rm -f "${TMPDIR:-/tmp}/seam-bad.$$.json"
  else
    echo "  SKIP  schema_negative (check-jsonschema not on PATH; pre-commit runs the positive check)"
  fi
}

CASES=(case_unknown_engine case_missing_config case_invalid_config case_adapter_env_overrides case_usage case_schema_fixtures)
for c in "${CASES[@]}"; do "$c"; done

if [[ $fails -ne 0 ]]; then
  echo "sdlc-seam: $fails failure(s)"
  exit 1
fi
echo "✅ sdlc-seam self-test passed"
