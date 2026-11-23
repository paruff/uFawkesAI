#!/usr/bin/env bash
# shellcheck disable=SC2015 # `cond && expect ok || expect bad` is the intended assertion pattern, expect never fails
# Self-test for scripts/board-mirror.sh (seam R7): status transitions against fixture status JSON and a stub gh.
set -uo pipefail # no -e: expect() counts failures instead of aborting
root="$(cd "$(dirname "$0")/.." && pwd)"
fails=0
expect() { if [[ "$2" == ok ]]; then echo "  PASS  $1"; else
  echo "  FAIL  $1 ($3)"
  fails=$((fails + 1))
fi; }

t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
# Stub gh: item-list/field-list/view read fixtures; item-edit is logged and applied to the item fixture.
cat > "$t/gh" << 'STUB'
#!/usr/bin/env bash
echo "$*" >> "$STUB_DIR/calls"
case "$2" in
  item-list) cat "$STUB_DIR/items.json" ;;
  field-list) cat "$STUB_DIR/fields.json" ;;
  view) echo PVT_proj ;;
  item-edit)
    f="" o=""
    while [ $# -gt 0 ]; do case "$1" in --field-id) f="$2" ;; --single-select-option-id) o="$2" ;; --clear) o="" ;; esac; shift; done
    key="$(jq -r --arg f "$f" '.fields[]|select(.id==$f)|.name|ascii_downcase' "$STUB_DIR/fields.json")"
    val="$(jq -r --arg o "$o" '[.fields[].options[]?|select(.id==$o)|.name][0] // ""' "$STUB_DIR/fields.json")"
    jq --arg k "$key" --arg v "$val" '.items[0][$k]=$v' "$STUB_DIR/items.json" > "$STUB_DIR/items.tmp" && mv "$STUB_DIR/items.tmp" "$STUB_DIR/items.json" ;;
esac
STUB
chmod +x "$t/gh"
cat > "$t/fields.json" << 'J'
{"fields":[
 {"id":"F_S","name":"Status","options":[{"id":"o1","name":"Ready for agent"},{"id":"o2","name":"Needs human"}]},
 {"id":"F_G","name":"Gate","options":[{"id":"g1","name":"intent"},{"id":"g2","name":"spec"},{"id":"g3","name":"plan"},{"id":"g4","name":"PR review"}]}]}
J
st() { # <intent> <spec> <plan> -> status json path
  jq -n --arg a "$1" --arg b "$2" --arg c "$3" '{schema:1,change:"c",stage:"plan",artifactsDir:"x",gates:{intent:{state:$a},spec:{state:$b},plan:{state:$c}}}' > "$t/status.json"
}
reset() {
  echo '{"items":[{"id":"I1","content":{"number":356},"status":"Backlog"}]}' > "$t/items.json"
  : > "$t/calls"
}
run() { STUB_DIR="$t" GH="$t/gh" bash "$root/scripts/board-mirror.sh" "$t/status.json" 356 "$@" > "$t/out" 2>&1; }
cur() { jq -r ".items[0].status + \"|\" + (.items[0].gate // \"\")" "$t/items.json"; }
edits() { grep -c item-edit "$t/calls" || true; }

reset
st approved approved approved
run && [ "$(cur)" = "Ready for agent|" ] && expect "plan approved -> Ready for agent" ok || expect "plan approved -> Ready for agent" bad "$(cur)"
n="$(edits)"
run && [ "$(edits)" = "$n" ] && expect "second run makes no edits" ok || expect "second run makes no edits" bad "edits $n -> $(edits)"

reset
st approved pending pending
run && [ "$(cur)" = "Needs human|spec" ] && expect "awaiting spec -> Needs human, Gate spec" ok || expect "awaiting spec" bad "$(cur)"

reset
echo '{"items":[{"id":"I1","content":{"number":356},"status":"Needs human","gate":"PR review"}]}' > "$t/items.json"
st approved approved approved
run && [ "$(cur)" = "Ready for agent|" ] && expect "stale Gate is cleared when plan approved" ok || expect "stale Gate cleared" bad "$(cur)"

reset
st approved approved approved
run --pr-open && [ "$(cur)" = "Needs human|PR review" ] && expect "open PR -> Needs human, Gate PR review" ok || expect "open PR" bad "$(cur)"

reset
echo '{"items":[]}' > "$t/items.json"
run && expect "issue not on board fails" bad "exit 0" || expect "issue not on board fails" ok

echo
[ "$fails" -eq 0 ] && echo "ALL PASS" || echo "$fails FAILED"
exit $((fails > 0))
