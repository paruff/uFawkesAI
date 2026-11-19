#!/usr/bin/env bash
# shellcheck disable=SC2016 # literal backticks: markdown fixtures
# Self-test for scripts/check-links.sh: a good link passes, a broken one fails.
set -euo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE # hooks export these; keep the real index untouched
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q
mkdir docs
echo '# b' > docs/B.md
printf '[ok](docs/B.md#x) [web](https://x.io) [anchor](#top)\n```\n[skip](nope.md)\n```\n' > A.md
git add -A
bash "$here/check-links.sh" "$tmp" > /dev/null || {
  echo "FAIL: good links rejected"
  exit 1
}
echo '[bad](./docs/Z.md)' > docs/C.md
git add -A
if out="$(bash "$here/check-links.sh" "$tmp")"; then
  echo "FAIL: broken link passed"
  exit 1
fi
grep -q 'docs/C.md:1: broken link -> ./docs/Z.md' <<< "$out" || {
  echo "FAIL: wrong report: $out"
  exit 1
}
echo "✅ check-links self-test passed"
