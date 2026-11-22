#!/usr/bin/env bash
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

[[ $fails -eq 0 ]] && echo "✅ sdlc block drift self-test passed" || {
  echo "$fails failure(s)"
  exit 1
}
