#!/usr/bin/env bash
# Self-test for benchmark-start.sh with a stub docker: pass with no baseline,
# pass within threshold, fail on regression. Run: bash images/devsecops/tests/test-benchmark-start.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

printf '#!/usr/bin/env bash\nexit 0\n' > "$tmp/docker"
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

echo '{"devcontainer-amd64":{"cold_ms":1,"warm_ms":1}}' > "$tmp/b.json"
if out=$(bench); then
  echo "FAIL: regression should fail"
  exit 1
fi
echo "$out" | jq -e '.pass == false' > /dev/null

echo "✅ benchmark-start.sh self-test passed"
