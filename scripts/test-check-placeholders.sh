#!/usr/bin/env bash
# Self-test for scripts/check-placeholders.sh in a scratch git repo.
# Run: bash scripts/test-check-placeholders.sh
set -euo pipefail
script="$(cd "$(dirname "$0")" && pwd)/check-placeholders.sh"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q .
mkdir scripts
# shellcheck disable=SC2016 # literal backticks
printf 'ok\nmention: `[PLACEHOLDER]` is the marker\n' > a.md
echo 'echo "[PLACEHOLDER — in a script]"' > scripts/x.sh
git add -A

bash "$script" > /dev/null || {
  echo "FAIL: clean repo should pass"
  exit 1
}

echo '**Date:** [PLACEHOLDER — date]' > b.md
git add -A
if bash "$script" > /dev/null; then
  echo "FAIL: marker without .template should fail"
  exit 1
fi

touch .template
bash "$script" > /dev/null || {
  echo "FAIL: template mode should pass"
  exit 1
}
if PLACEHOLDER_ENFORCE=1 bash "$script" > /dev/null; then
  echo "FAIL: PLACEHOLDER_ENFORCE=1 should fail"
  exit 1
fi

out="$(PLACEHOLDER_ENFORCE=1 bash "$script" || true)"
grep -q '^b.md:1:' <<< "$out" || {
  echo "FAIL: should report file:line"
  exit 1
}
! grep -q 'a.md\|x.sh' <<< "$out" || {
  echo "FAIL: mentions and scripts must be skipped"
  exit 1
}

echo "✅ check-placeholders.sh self-test passed"
