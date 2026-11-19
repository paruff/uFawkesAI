#!/usr/bin/env bash
# scripts/check-orphans.sh — list tracked files no other tracked file mentions (AC-PR-03).
#
# A file is an orphan when its basename appears in no other tracked file and its
# path matches no regex in .orphan-allowlist (one ERE per line, # comments).
# Usage: scripts/check-orphans.sh [repo-dir]   (exit 1 and list orphans)
# shortcut: basename match (not preceded by a name character), so two files sharing a name hide each other; fine
# for a repo this size, tighten if it misses a real orphan.
set -euo pipefail
root="${1:-$(git rev-parse --show-toplevel)}"
cd "$root"

allow="$(grep -vE '^\s*(#|$)' .orphan-allowlist 2> /dev/null | paste -sd'|' - || true)"
orphans=0
while IFS= read -r f; do
  [ -L "$f" ] && continue
  [ -n "$allow" ] && grep -qE "$allow" <<< "$f" && continue
  base="$(basename "$f" | sed 's/[.[\*^$+?(){}|]/\\&/g')"
  if ! git grep -qIE -e "(^|[^A-Za-z0-9_.-])$base" -- . ":!$f"; then
    echo "orphan: $f"
    orphans=$((orphans + 1))
  fi
done < <(git ls-files)

[ "$orphans" -eq 0 ] || {
  echo "❌ $orphans orphan file(s)."
  exit 1
}
echo "✅ No orphan files."
