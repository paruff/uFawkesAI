#!/usr/bin/env bash
# Mirror a change's gate state onto its Project #7 item (seam R7, D3). Board-only writes, idempotent.
# usage: board-mirror.sh <status.json> <issue-number> [--pr-open|--merged]
#   plan approved           -> Status "Ready for agent"
#   first unapproved gate   -> Status "Needs human", Gate <stage>
#   --pr-open               -> Status "Needs human", Gate "PR review" (wins over the above)
#   --merged                -> Status "Done", Gate cleared; a goal issue (title starts "goal(") is left to a human
# Env: GH (gh binary, tests stub it), PROJECT (default 7), OWNER (default paruff). Auth comes from the gh CLI environment.
set -euo pipefail
status_json="${1:?usage: board-mirror.sh <status.json> <issue-number> [--pr-open]}"
issue="${2:?issue number required}"
pr_open=0 merged=0
[ "${3:-}" = "--pr-open" ] && pr_open=1
[ "${3:-}" = "--merged" ] && merged=1
gh="${GH:-gh}" project="${PROJECT:-7}" owner="${OWNER:-paruff}"

if [ "$merged" -eq 1 ]; then
  case "$("$gh" issue view "$issue" --json title --jq .title)" in
    "goal("*)
      echo "board-mirror: #$issue is a goal issue; a human closes it"
      exit 0
      ;;
  esac
  want_status="Done" want_gate=""
elif [ "$pr_open" -eq 1 ]; then
  want_status="Needs human" want_gate="PR review"
elif [ "$(jq -r '.gates.plan.state' "$status_json")" = approved ]; then
  want_status="Ready for agent" want_gate=""
else
  want_status="Needs human"
  want_gate="$(jq -r 'first(("intent","spec","plan") as $g | select(.gates[$g].state != "approved") | $g) // empty' "$status_json")"
fi

items="$("$gh" project item-list "$project" --owner "$owner" --limit 300 --format json)"
item="$(jq -c --argjson n "$issue" '[.items[] | select(.content.number == $n)][0] // empty' <<< "$items")"
[ -n "$item" ] || {
  echo "board-mirror: issue #$issue is not on project $project" >&2
  exit 1
}
if [ "$(jq -r '.status // ""' <<< "$item")" = "$want_status" ] && [ "$(jq -r '.gate // ""' <<< "$item")" = "$want_gate" ]; then
  echo "board-mirror: #$issue already $want_status${want_gate:+ / $want_gate}"
  exit 0
fi

fields="$("$gh" project field-list "$project" --owner "$owner" --format json)"
pid="$("$gh" project view "$project" --owner "$owner" --format json --jq .id)"
iid="$(jq -r .id <<< "$item")"
set_field() { # <field name> <option name>
  local fid oid
  fid="$(jq -r --arg f "$1" '.fields[] | select(.name == $f) | .id' <<< "$fields")"
  oid="$(jq -r --arg f "$1" --arg o "$2" '.fields[] | select(.name == $f) | .options[] | select(.name == $o) | .id' <<< "$fields")"
  [ -n "$fid" ] && [ -n "$oid" ] || {
    echo "board-mirror: no option '$2' on field '$1'" >&2
    exit 1
  }
  "$gh" project item-edit --id "$iid" --project-id "$pid" --field-id "$fid" --single-select-option-id "$oid" > /dev/null
}
set_field Status "$want_status"
if [ -n "$want_gate" ]; then set_field Gate "$want_gate"; else
  # no gate applies: clear it so a stale stage name does not linger
  gid="$(jq -r '.fields[] | select(.name == "Gate") | .id' <<< "$fields")"
  "$gh" project item-edit --id "$iid" --project-id "$pid" --field-id "$gid" --clear > /dev/null
fi
echo "board-mirror: #$issue -> $want_status${want_gate:+ / $want_gate}"
