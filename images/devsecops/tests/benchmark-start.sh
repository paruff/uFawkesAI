#!/usr/bin/env bash
# images/devsecops/tests/benchmark-start.sh — cold/warm start benchmark for DevSecOps images
#
# Measures container startup latency for cold (first run after pull) and warm (cached) starts.
# Compares against a baseline stored in images/devsecops/benchmarks/baseline.json.
# Fails if any variant/arch regresses > 10%.
# Outputs a markdown table for release notes.
#
# Usage: /tests/benchmark-start.sh <image> <tag> <variant> <arch>
#   image:  base image name (e.g. fawkes-space-ai)
#   tag:    tag to test (e.g. ci, 1.0.0)
#   variant: core|ai|devcontainer|devcontainer-polyglot
#   arch:   amd64|arm64
#
# Environment:
#   REGISTRY: ghcr.io/paruff (default)
#   BASELINE_FILE: path to baseline JSON (default: /devsecops/benchmarks/baseline.json)
#   REGRESSION_THRESHOLD: percent regression allowed (default: 10)
#   RUNS: number of warm runs to average (default: 3)

set -euo pipefail

IMAGE="${1:?usage: $0 <image> <tag> <variant> <arch>}"
TAG="${2:?}"
VARIANT="${3:?core|ai|devcontainer|devcontainer-polyglot}"
ARCH="${4:?amd64|arm64}"

REGISTRY="${REGISTRY:-ghcr.io/paruff}"
BASELINE_FILE="${BASELINE_FILE:-/devsecops/benchmarks/baseline.json}"
THRESHOLD="${REGRESSION_THRESHOLD:-10}"
RUNS="${RUNS:-3}"

FULL_IMAGE="${REGISTRY}/${IMAGE}:${TAG}-${ARCH}"
KEY="${VARIANT}-${ARCH}"

echo "== Benchmark: ${FULL_IMAGE} (${KEY}) =="

# Ensure baseline file exists
if [[ ! -f "${BASELINE_FILE}" ]]; then
  echo "No baseline found at ${BASELINE_FILE}; creating empty baseline"
  mkdir -p "$(dirname "${BASELINE_FILE}")"
  echo '{}' > "${BASELINE_FILE}"
fi

# Helper: run container and measure startup time in milliseconds
# Uses a minimal command that exits immediately after shell starts
measure_startup() {
  local img="$1"
  local start end ms
  start=$(date +%s%3N)
  docker run --rm --network none "${img}" bash -c 'exit 0' > /dev/null 2>&1
  end=$(date +%s%3N)
  ms=$((end - start))
  echo "${ms}"
}

# Cold start: pull image first, then measure
echo "  Cold start (pull + first run)..."
docker pull "${FULL_IMAGE}" > /dev/null 2>&1
cold_ms=$(measure_startup "${FULL_IMAGE}")
echo "    Cold: ${cold_ms} ms"

# Warm starts: average of RUNS runs
warm_sum=0
echo "  Warm starts (${RUNS} runs)..."
for i in $(seq 1 "${RUNS}"); do
  w=$(measure_startup "${FULL_IMAGE}")
  warm_sum=$((warm_sum + w))
  echo "    Run ${i}: ${w} ms"
done
warm_avg=$((warm_sum / RUNS))
echo "    Warm avg: ${warm_avg} ms"

# Read baseline
baseline_cold=$(jq -r ".${KEY}.cold_ms // 0" "${BASELINE_FILE}")
baseline_warm=$(jq -r ".${KEY}.warm_ms // 0" "${BASELINE_FILE}")

echo "  Baseline: cold=${baseline_cold} ms, warm=${baseline_warm} ms"

# Compute regression
regress_cold=0
regress_warm=0
if [[ "${baseline_cold}" -gt 0 ]]; then
  regress_cold=$((((cold_ms - baseline_cold) * 100) / baseline_cold))
fi
if [[ "${baseline_warm}" -gt 0 ]]; then
  regress_warm=$((((warm_avg - baseline_warm) * 100) / baseline_warm))
fi

echo "  Regression: cold=${regress_cold}%, warm=${regress_warm}% (threshold: ${THRESHOLD}%)"

# Determine pass/fail
fail=0
if [[ "${regress_cold}" -gt "${THRESHOLD}" ]]; then
  echo "  ❌ COLD START REGRESSION: ${regress_cold}% > ${THRESHOLD}%"
  fail=1
fi
if [[ "${regress_warm}" -gt "${THRESHOLD}" ]]; then
  echo "  ❌ WARM START REGRESSION: ${regress_warm}% > ${THRESHOLD}%"
  fail=1
fi

if [[ "${fail}" -eq 0 ]]; then
  echo "  ✅ Within threshold"
fi

# Output JSON for aggregation
jq -n \
  --arg key "${KEY}" \
  --arg variant "${VARIANT}" \
  --arg arch "${ARCH}" \
  --arg image "${FULL_IMAGE}" \
  --argjson cold "${cold_ms}" \
  --argjson warm "${warm_avg}" \
  --argjson baseline_cold "${baseline_cold}" \
  --argjson baseline_warm "${baseline_warm}" \
  --argjson regress_cold "${regress_cold}" \
  --argjson regress_warm "${regress_warm}" \
  --argjson threshold "${THRESHOLD}" \
  --arg pass "$([[ ${fail} -eq 0 ]] && echo true || echo false)" \
  '{
    key: $key,
    variant: $variant,
    arch: $arch,
    image: $image,
    cold_ms: $cold,
    warm_ms: $warm,
    baseline_cold_ms: $baseline_cold,
    baseline_warm_ms: $baseline_warm,
    cold_regression_pct: $regress_cold,
    warm_regression_pct: $regress_warm,
    threshold_pct: $threshold,
    pass: ($pass == "true")
  }'

exit "${fail}"
