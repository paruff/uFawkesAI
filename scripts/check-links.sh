#!/usr/bin/env bash
# scripts/check-links.sh — every relative link in a tracked *.md must resolve (AC-PR-01).
#
# Usage: scripts/check-links.sh [repo-dir]   (exit 1 and list each broken link)
# shortcut: inline [text](target) links only, fenced code skipped; reference-style
# links and HTML <a href> are not checked. Upgrade if one breaks unseen.
set -euo pipefail
root="${1:-$(git rev-parse --show-toplevel)}"
cd "$root"

broken=0
while IFS= read -r file; do
  [ -f "$file" ] || continue
  dir="$(dirname "$file")"
  while IFS=$'\t' read -r line target; do
    case "$target" in http://* | https://* | mailto:* | '#'* | '') continue ;; esac
    path="${target%%#*}"
    path="${path%%\?*}"
    [ -n "$path" ] || continue
    case "$path" in /*) resolved=".$path" ;; *) resolved="$dir/$path" ;; esac
    if [ ! -e "$resolved" ]; then
      echo "$file:$line: broken link -> $target"
      broken=$((broken + 1))
    fi
  done < <(awk '/^```/ { f = !f; next } !f {
      s = $0
      while (match(s, /\]\([^) ]+[^)]*\)/)) {
        t = substr(s, RSTART + 2, RLENGTH - 3); sub(/ .*/, "", t)
        print NR "\t" t; s = substr(s, RSTART + RLENGTH)
      }
    }' "$file")
done < <(git ls-files '*.md')

if [ "$broken" -gt 0 ]; then
  echo "❌ $broken broken relative link(s)."
  exit 1
fi
echo "✅ All relative markdown links resolve."
