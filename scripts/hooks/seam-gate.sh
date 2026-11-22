#!/usr/bin/env bash
# Git gate for the SDLC engine seam (spec R6.1): `seam-gate.sh commit|push`.
# Blocks when code paths (.artifact-chain-paths, default src/) are touched while the
# current branch's change has an unapproved plan. All verdict logic is in scripts/sdlc-seam.
set -euo pipefail
unset GIT_INDEX_FILE # pre-commit exports it; the gate reads the real tree
mode="${1:?usage: seam-gate.sh commit|push}"
seam="$(cd "$(dirname "$0")/.." && pwd)/sdlc-seam"
top="$(git rev-parse --show-toplevel)"

paths=(src/)
if [[ -f "$top/.artifact-chain-paths" ]]; then
  mapfile -t paths < <(grep -vE '^\s*(#|$)' "$top/.artifact-chain-paths" || true)
fi

case "$mode" in
  commit) changed="$(git diff --cached --name-only -- "${paths[@]}")" ;;
  push)
    base=""
    for b in origin/main main; do git rev-parse -q --verify "$b" > /dev/null && base="$b" && break; done
    # shortcut: with no main ref to diff against, gate every push; fine for a fresh clone.
    changed="$([[ -n "$base" ]] && git diff --name-only "$base...HEAD" -- "${paths[@]}" || echo all)"
    ;;
  *)
    echo "usage: seam-gate.sh commit|push" >&2
    exit 2
    ;;
esac
[[ -z "$changed" ]] && exit 0

if ! "$seam" gate plan; then
  echo "blocked: $mode touches code paths and the plan is not approved (sdlc-seam gate plan)" >&2
  exit 1
fi
