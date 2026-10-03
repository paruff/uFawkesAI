#!/usr/bin/env bash
# shellcheck disable=SC2016 # literal backticks: markdown code spans
# Self-test for scripts/check-readme-claims.sh: the real README passes; a map
# naming a missing file or npm script fails. Run: bash scripts/test-check-readme-claims.sh
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

bash scripts/check-readme-claims.sh > /dev/null || {
  echo "FAIL: README should pass"
  exit 1
}

printf '## DORA AI Capabilities implemented\n| x | `docs/NOPE.md` |\n## Container images\n' > "$tmp"
if bash scripts/check-readme-claims.sh "$tmp" > /dev/null; then
  echo "FAIL: missing file should fail"
  exit 1
fi

printf '## DORA AI Capabilities implemented\n| x | `npm run no-such-script` |\n## Container images\n' > "$tmp"
if bash scripts/check-readme-claims.sh "$tmp" > /dev/null; then
  echo "FAIL: missing npm script should fail"
  exit 1
fi

printf '## DORA AI Capabilities implemented\n| x | `ci-quality.yml`, `npm run preflight` |\n## Container images\n' > "$tmp"
bash scripts/check-readme-claims.sh "$tmp" > /dev/null || {
  echo "FAIL: workflow name + real script should pass"
  exit 1
}

echo "✅ check-readme-claims.sh self-test passed"
