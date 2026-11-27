#!/usr/bin/env bash
# Fail if the AGENTS.md block the engine manages differs from what `sdlc sync` would write (spec R4.1).
# `sync` rewrites that block silently, so drift is invisible without this check.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
ENGINE="$PWD/node_modules/@morsadev/sdlc/dist/sdlc.mjs"
[[ -f $ENGINE ]] || {
  echo "engine morsadev not installed: run npm ci" >&2
  exit 2
}

# blank lines are ignored: markdownlint --fix adds them to the committed copy
block() { sed -n '/<!-- ai-sdlc:start/,/<!-- ai-sdlc:end -->/p' "$1"; }

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
git ls-files -co --exclude-standard -z | xargs -0 tar -cf - | tar -xf - -C "$tmp"
(cd "$tmp" && git init -q && node "$ENGINE" sync > /dev/null)
bash "$PWD/scripts/seam/agents-block-fixup.sh" "$tmp/AGENTS.md"

[[ -n "$(block AGENTS.md)" ]] || {
  echo "AGENTS.md has no ai-sdlc block" >&2
  exit 1
}
if ! diff -B <(block AGENTS.md) <(block "$tmp/AGENTS.md") > "$tmp/drift.diff"; then
  echo "AGENTS.md ai-sdlc block drifted from \`sdlc sync\` (< committed, > expected):" >&2
  cat "$tmp/drift.diff" >&2
  exit 1
fi
echo "sdlc block: in sync"
