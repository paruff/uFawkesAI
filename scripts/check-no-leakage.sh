#!/usr/bin/env bash
# scripts/check-no-leakage.sh — tracked files must not carry a private LAN IP or a
# developer's home path. Usage: check-no-leakage.sh [file...]  (default: all tracked files)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# 192.168/16, 10/8, 172.16-31/12 literals, and /Users/<name> or /home/<name> (dev is the image user).
pattern='(^|[^0-9.])(192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+|172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+)([^0-9.]|$)|/Users/[A-Za-z0-9._-]+|/home/(runner|[a-z][a-z0-9._-]*)/'
skip='(^|/)(CHANGELOG\.md|package-lock\.json|.*\.lock|.*\.lock\.json|\.secrets\.baseline|scripts/check-no-leakage\.sh|scripts/test-no-leakage\.sh)$'

if [ "$#" -gt 0 ]; then files=("$@"); else mapfile -t files < <(git ls-files); fi
hits=0
for f in "${files[@]}"; do
  [ -f "$f" ] || continue
  [[ "$f" =~ $skip ]] && continue
  # /home/dev and the CI runner's /home/runner are the image's own users, not a person's.
  if out="$(grep -nE "$pattern" "$f" 2> /dev/null | grep -vE '/home/(dev|runner)\b' || true)" && [ -n "$out" ]; then
    printf '%s\n' "$out" | sed "s|^|❌ $f:|"
    hits=$((hits + 1))
  fi
done
[ "$hits" -eq 0 ] || {
  echo "Private address or home path found in ${hits} file(s)."
  exit 1
}
echo "✅ no private IPs or home paths in tracked files"
