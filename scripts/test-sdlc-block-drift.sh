#!/usr/bin/env bash
# shellcheck disable=SC2015 # `cond && expect ok || expect bad` is the intended assertion pattern, expect never fails
# Self-test for check-sdlc-block-drift.sh: a line edited inside the block fails and is named; one outside passes.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
fails=0
cp "$root/AGENTS.md" "$root/AGENTS.md.bak"
trap 'mv "$root/AGENTS.md.bak" "$root/AGENTS.md"' EXIT

check() { bash "$here/check-sdlc-block-drift.sh" 2>&1; }
expect() { if [[ "$2" == ok ]]; then echo "  PASS  $1"; else
  echo "  FAIL  $1"
  fails=$((fails + 1))
fi; }

out="$(check)" && expect clean_passes ok || expect clean_passes bad
printf '\nA line outside the block.\n' >> "$root/AGENTS.md"
out="$(check)" && expect outside_edit_passes ok || expect outside_edit_passes bad
cp "$root/AGENTS.md.bak" "$root/AGENTS.md"
sed -i.sed 's/Nothing is implemented without an approved/Anything may be implemented without an approved/' "$root/AGENTS.md" && rm -f "$root/AGENTS.md.sed"
out="$(check)" && expect inside_edit_fails bad || { [[ "$out" == *"Anything may be implemented"* ]] && expect inside_edit_fails ok || expect inside_edit_fails bad; }

# The engine's sentence names agents the repo deletes; the fixup rewrites it and the drift check expects the rewrite.
cp "$root/AGENTS.md.bak" "$root/AGENTS.md"
old='For clean-context reviews (verifier, spec-reviewer, simplifier, researcher), use `.agents/agents/<name>.md`.'
new='For a clean-context review, use `.agents/agents/verifier.md`.'
sed -i.sed "s|${new//|/\\|}|${old//|/\\|}|" "$root/AGENTS.md" && rm -f "$root/AGENTS.md.sed"
out="$(check)" && expect engine_sentence_restored_fails bad || { [[ "$out" == *"clean-context review"* ]] && expect engine_sentence_restored_fails ok || expect engine_sentence_restored_fails bad; }
cp "$root/AGENTS.md.bak" "$root/AGENTS.md"
once="$(mktemp)"
twice="$(mktemp)"
cp "$root/AGENTS.md" "$once"
bash "$here/seam/agents-block-fixup.sh" "$once" && cp "$once" "$twice" && bash "$here/seam/agents-block-fixup.sh" "$twice"
cmp -s "$once" "$twice" && cmp -s "$once" "$root/AGENTS.md" && expect fixup_idempotent_on_committed ok || expect fixup_idempotent_on_committed bad
rm -f "$once" "$twice"

[[ $fails -eq 0 ]] && echo "✅ sdlc block drift self-test passed" || {
  echo "$fails failure(s)"
  exit 1
}
