#!/usr/bin/env bash
# Self-test for scripts/check-review-md.sh: the real files pass; each failure
# mode goes red. Run: bash scripts/test-check-review-md.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
chk() { bash scripts/check-review-md.sh "$@" > /dev/null 2>&1; }
expect_fail() {
  if chk "${@:2}"; then
    echo "FAIL: $1 should fail"
    exit 1
  fi
}

chk || {
  echo "FAIL: real files should pass"
  exit 1
}

wf=.github/workflows/agent-review.yml
seq 1 61 > "$tmp/long.md"
expect_fail "too long / no sections" "$tmp/long.md" "$wf"
grep -v '^## Skip$' REVIEW.md > "$tmp/nosec.md"
expect_fail "missing section" "$tmp/nosec.md" "$wf"
expect_fail "missing file" "$tmp/none.md" "$wf"
grep -v 'REVIEW\.md' "$wf" > "$tmp/wf.yml"
expect_fail "workflow ignoring REVIEW.md" REVIEW.md "$tmp/wf.yml"
{
  cat "$wf"
  echo '      - run: gh pr merge --squash'
} > "$tmp/wf2.yml"
expect_fail "workflow that merges" REVIEW.md "$tmp/wf2.yml"

echo "✅ check-review-md.sh self-test passed"
