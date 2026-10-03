#!/usr/bin/env bash
# Self-test for benchmark-start.sh with a stub docker: pass with no baseline,
# pass within threshold, fail on a real regression, pass on noise under the
# absolute floor (REGRESSION_MIN_MS). Run: bash images/devsecops/tests/test-benchmark-start.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Stub docker: `run` takes STUB_SLEEP seconds (default 0), everything else is instant.
# shellcheck disable=SC2016 # the stub script is written literally
printf '#!/usr/bin/env bash\n[ "$1" = run ] && sleep "${STUB_SLEEP:-0}"\nexit 0\n' > "$tmp/docker"
chmod +x "$tmp/docker"
export PATH="$tmp:$PATH" RUNS=3

bench() { BASELINE_FILE="$tmp/b.json" bash "$here/benchmark-start.sh" img:1 devcontainer-amd64 2> /dev/null; }

echo '{}' > "$tmp/b.json"
out=$(bench) || {
  echo "FAIL: no baseline should pass"
  exit 1
}
echo "$out" | jq -e '.pass and .baseline_cold_ms == 0 and (.cold_ms | type) == "number"' > /dev/null

echo '{"devcontainer-amd64":{"cold_ms":100000,"warm_ms":100000}}' > "$tmp/b.json"
bench > /dev/null || {
  echo "FAIL: faster than baseline should pass"
  exit 1
}

# Runs take ~300 ms against a 100 ms baseline: +200% and +200 ms, a real regression.
echo '{"devcontainer-amd64":{"cold_ms":100,"warm_ms":100}}' > "$tmp/b.json"
if out=$(STUB_SLEEP=0.3 bench); then
  echo "FAIL: regression over the percentage and the floor should fail"
  exit 1
fi
echo "$out" | jq -e '.pass == false' > /dev/null

# Same slowdown with a floor above it: over the percentage but within noise.
STUB_SLEEP=0.3 REGRESSION_MIN_MS=1000 bench > /dev/null || {
  echo "FAIL: a slowdown under REGRESSION_MIN_MS should pass"
  exit 1
}

echo "✅ benchmark-start.sh self-test passed"
