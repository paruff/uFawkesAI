#!/usr/bin/env bash
# Self-test for scripts/check-orphans.sh: referenced and allow-listed files pass, a lone file is reported.
set -euo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE # hooks export these; keep the real index untouched
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q
echo 'see used.sh' > README.md
echo x > used.sh
echo x > CODEOWNERS
printf '# conventions\nCODEOWNERS\nREADME.md\n^\\.orphan-allowlist$\n' > .orphan-allowlist
git add -A
bash "$here/check-orphans.sh" "$tmp" > /dev/null || {
  echo "FAIL: clean tree rejected"
  exit 1
}
echo x > lonely.sh
git add -A
if out="$(bash "$here/check-orphans.sh" "$tmp")"; then
  echo "FAIL: orphan passed"
  exit 1
fi
grep -q 'orphan: lonely.sh' <<< "$out" || {
  echo "FAIL: wrong report: $out"
  exit 1
}
echo "✅ check-orphans self-test passed"
