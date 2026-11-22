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

# ---- Conformance: the same scenarios against any adapter (SEAM_ADAPTER, default fake) ----
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 # throwaway repos must not inherit signing or hooks
HUMAN=human@example.invalid
BOT=bot@example.invalid
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
repo=""
VALID_STATUS='.schema == 1 and (.gates | keys) == ["intent","plan","spec"] and ([.gates[] | keys == ["approver","commit","state"]] | all)'
VALID_NEXT='.schema == 1 and (keys == ["action","change","schema","stage"]) and (.action | type == "string")'

# as <email> <cmd...>: run with that git identity (how agent sessions are told apart)
as() {
  local who="$1"
  shift
  GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL="$who" GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL="$who" "$@"
}
# sx <email> <seam args...> -> $out $err $rc (in $repo)
sx() {
  local who="$1"
  shift
  out="$(cd "$repo" && env -u SEAM_CONFIG GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL="$who" GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL="$who" "$seam" "$@" 2> "$work/err")"
  rc=$?
  err="$(cat "$work/err")"
}
gcommit() { (cd "$repo" && git add -A && as "$1" git commit -q -m "$2"); } # <email> <msg>
new_repo() {
  repo="$(mktemp -d "$work/repo.XXXXXX")"
  (
    cd "$repo" || exit 1
    git init -q -b main
    printf '{"engine":"%s","botIdentities":["%s"]}\n' "${SEAM_ADAPTER:-fake}" "$BOT" > .sdlc-engine.json
    echo 'src/' > .artifact-chain-paths
    echo app > README.md
    git add -A
    as "$HUMAN" git commit -q -m "chore: init"
    git switch -qc change/demo
  )
}
# mkchange <slug>: the bot drafts the artifacts and commits them
mkchange() {
  sx "$BOT" new "$1" --title "$1"
  gcommit "$BOT" "docs: draft $1"
}
approve_all() { # <slug>: the human approves every gate
  local g
  for g in intent spec plan; do sx "$HUMAN" approve "$1" "$g"; done
}

case_conf_new_status() {
  new_repo
  sx "$HUMAN" new demo --title Demo
  [[ $rc -eq 0 && -d "$repo/$out" ]] && expect new_prints_dir ok || expect new_prints_dir bad "rc=$rc out=$out"
  sx "$HUMAN" status demo --json
  [[ $rc -eq 0 ]] && jq -e "$VALID_STATUS and ([.gates[].state] | all(. == \"pending\"))" <<< "$out" > /dev/null && expect status_pending ok || expect status_pending bad "rc=$rc out=$out"
  sx "$HUMAN" status unknown --json
  [[ $rc -eq 2 ]] && expect status_unknown ok || expect status_unknown bad "rc=$rc"
  sx "$HUMAN" new ../evil --title x
  [[ $rc -eq 2 ]] && expect new_rejects_bad_slug ok || expect new_rejects_bad_slug bad "rc=$rc"
}
case_conf_approve_reject() {
  new_repo
  mkchange demo
  sx "$HUMAN" approve demo intent
  [[ $rc -eq 0 ]] && expect human_approves ok || expect human_approves bad "rc=$rc err=$err"
  sx "$HUMAN" gate demo intent
  [[ $rc -eq 0 && -z "$out" ]] && expect gate_passes_after_approve ok || expect gate_passes_after_approve bad "rc=$rc"
  sx "$HUMAN" status demo --json
  local head
  head="$(git -C "$repo" rev-parse HEAD)"
  jq -e --arg h "$head" --arg a "$HUMAN" '.gates.intent.approver == $a and .gates.intent.commit == $h and .stage == "spec"' <<< "$out" > /dev/null && expect approver_and_commit_recorded ok || expect approver_and_commit_recorded bad "out=$out"
  sx "$HUMAN" reject demo intent
  sx "$HUMAN" gate demo intent
  [[ $rc -eq 1 ]] && expect reject_moves_gate_back ok || expect reject_moves_gate_back bad "rc=$rc"
}
case_conf_identity() {
  new_repo
  mkchange demo
  sx "$BOT" approve demo intent
  [[ $rc -eq 1 && "$err" == *"approver is a bot"* ]] && expect bot_approve_refused ok || expect bot_approve_refused bad "rc=$rc err=$err"
  sx "$HUMAN" gate demo intent
  [[ $rc -eq 1 ]] && expect bot_approve_left_gate_closed ok || expect bot_approve_left_gate_closed bad "rc=$rc"
  new_repo
  sx "$HUMAN" new demo --title Demo
  gcommit "$HUMAN" "docs: human draft"
  sx "$HUMAN" approve demo intent
  [[ $rc -eq 1 && "$err" == *"self-approval is off"* ]] && expect self_approve_refused ok || expect self_approve_refused bad "rc=$rc err=$err"
}
case_conf_squash() {
  new_repo
  mkchange demo
  sx "$HUMAN" approve demo intent
  (cd "$repo" && git switch -q main && git merge -q --squash change/demo 2> /dev/null && as "$HUMAN" git commit -q -m "feat: demo (squash)")
  sx "$HUMAN" gate demo intent
  [[ $rc -eq 0 ]] && expect gate_survives_squash ok || expect gate_survives_squash bad "rc=$rc err=$err"
}
case_conf_gate_branch() {
  new_repo
  mkchange demo
  sx "$HUMAN" gate plan
  [[ $rc -eq 1 ]] && expect gate_branch_form_pending ok || expect gate_branch_form_pending bad "rc=$rc"
  approve_all demo
  sx "$HUMAN" gate plan
  [[ $rc -eq 0 ]] && expect gate_branch_form_approved ok || expect gate_branch_form_approved bad "rc=$rc err=$err"
  (cd "$repo" && git switch -q -c scratch/xyz)
  sx "$HUMAN" gate plan
  [[ $rc -eq 2 && "$err" == *"no change for branch scratch/xyz"* ]] && expect gate_no_change_for_branch ok || expect gate_no_change_for_branch bad "rc=$rc err=$err"
}
case_conf_next() {
  new_repo
  mkchange demo
  sx "$HUMAN" next --json
  [[ $rc -eq 0 ]] && jq -e "$VALID_NEXT and .change == \"demo\" and .stage == \"intent\"" <<< "$out" > /dev/null && expect next_on_change ok || expect next_on_change bad "rc=$rc out=$out"
  (cd "$repo" && git switch -q -c scratch/xyz)
  sx "$HUMAN" next --json
  [[ $rc -eq 0 ]] && jq -e "$VALID_NEXT and .change == null and .stage == null" <<< "$out" > /dev/null && expect next_without_change ok || expect next_without_change bad "rc=$rc out=$out"
}
case_conf_ci() {
  new_repo
  echo more >> "$repo/README.md"
  gcommit "$HUMAN" "docs: readme"
  sx "$HUMAN" ci --base main
  [[ $rc -eq 0 ]] && expect ci_no_code_paths ok || expect ci_no_code_paths bad "rc=$rc err=$err"

  new_repo
  mkdir "$repo/src" && echo x > "$repo/src/app.ts"
  gcommit "$HUMAN" "feat: app"
  sx "$HUMAN" ci --base main
  [[ $rc -eq 1 && "$err" == *src/app.ts* ]] && expect ci_code_without_change ok || expect ci_code_without_change bad "rc=$rc err=$err"

  new_repo
  mkchange demo
  sx "$HUMAN" approve demo intent
  sx "$HUMAN" approve demo spec
  mkdir "$repo/src" && echo x > "$repo/src/app.ts"
  gcommit "$HUMAN" "feat: app"
  sx "$HUMAN" ci --base main
  [[ $rc -eq 1 && "$err" == *demo/plan* ]] && expect ci_unapproved_plan ok || expect ci_unapproved_plan bad "rc=$rc err=$err"
  sx "$HUMAN" approve demo plan
  sx "$HUMAN" ci --base main
  [[ $rc -eq 0 ]] && expect ci_all_approved ok || expect ci_all_approved bad "rc=$rc err=$err"

  mkchange other
  sx "$HUMAN" ci --base main
  [[ $rc -eq 1 && "$err" == *other/intent* && "$err" != *demo/* ]] && expect ci_two_changes_one_unapproved ok || expect ci_two_changes_one_unapproved bad "rc=$rc err=$err"
}

CASES=(case_unknown_engine case_missing_config case_invalid_config case_adapter_env_overrides case_usage case_schema_fixtures case_conf_new_status case_conf_approve_reject case_conf_identity case_conf_squash case_conf_gate_branch case_conf_next case_conf_ci)
for c in "${CASES[@]}"; do "$c"; done

if [[ $fails -ne 0 ]]; then
  echo "sdlc-seam: $fails failure(s)"
  exit 1
fi
echo "✅ sdlc-seam self-test passed"
