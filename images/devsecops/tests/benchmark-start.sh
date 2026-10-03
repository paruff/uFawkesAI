#!/usr/bin/env bash
# images/devsecops/tests/benchmark-start.sh — cold/warm start benchmark for a
# published DevSecOps image (docs/ai-sdlc/image-benchmark/spec.md).
#
# Cold start = docker pull + first run (the image is removed first, so the
#   pull is real). Warm start = median of RUNS further runs.
# Compares against images/devsecops/benchmarks/baseline.json; a key with no
# baseline passes and its numbers become the baseline to record.
#
# Usage: benchmark-start.sh <image-ref> <key>
#   image-ref: e.g. ghcr.io/paruff/fawkes-space:2.0.0-rc.1
#   key:       baseline key, e.g. devcontainer-amd64
#
# Environment:
#   BASELINE_FILE         default: images/devsecops/benchmarks/baseline.json
#   REGRESSION_THRESHOLD  percent allowed (default: 10)
#   RUNS                  warm runs (default: 3)
#   BENCH_PRUNE=1         remove ALL unused images first, so shared layers
#                         don't make a later variant's cold start look warm.
#                         CI only: never set it on a machine with images you keep.
#
# Prints progress on stderr and one JSON line on stdout. Exit 1 on regression.

set -euo pipefail

REF="${1:?usage: $0 <image-ref> <key>}"
KEY="${2:?usage: $0 <image-ref> <key>}"
BASELINE_FILE="${BASELINE_FILE:-images/devsecops/benchmarks/baseline.json}"
THRESHOLD="${REGRESSION_THRESHOLD:-10}"
RUNS="${RUNS:-3}"

now_ms() { perl -MTime::HiRes=time -e 'printf "%d\n", time * 1000'; }
run_once() { docker run --rm --network none "$REF" true > /dev/null; }

echo "== Benchmark: ${REF} (${KEY}) ==" >&2
docker image rm -f "$REF" > /dev/null 2>&1 || true
[ "${BENCH_PRUNE:-0}" = 1 ] && docker image prune -af > /dev/null

start=$(now_ms)
docker pull -q "$REF" > /dev/null || {
  echo "❌ cannot pull ${REF}: is it published, and is the runner logged in?" >&2
  exit 1
}
run_once
cold=$(($(now_ms) - start))

warm_runs=()
for _ in $(seq 1 "$RUNS"); do
  start=$(now_ms)
  run_once
  warm_runs+=($(($(now_ms) - start)))
done
warm=$(printf '%s\n' "${warm_runs[@]}" | sort -n | awk '{a[NR]=$1} END {print a[int((NR+1)/2)]}')

base_cold=$(jq -r --arg k "$KEY" '.[$k].cold_ms // 0' "$BASELINE_FILE")
base_warm=$(jq -r --arg k "$KEY" '.[$k].warm_ms // 0' "$BASELINE_FILE")

pct() { # measured baseline -> integer percent change, 0 when no baseline
  if [ "$2" -gt 0 ]; then awk -v m="$1" -v b="$2" 'BEGIN { printf "%.0f", (m - b) * 100 / b }'; else echo 0; fi
}
reg_cold=$(pct "$cold" "$base_cold")
reg_warm=$(pct "$warm" "$base_warm")

pass=true
[ "$reg_cold" -gt "$THRESHOLD" ] && pass=false
[ "$reg_warm" -gt "$THRESHOLD" ] && pass=false
[ "$base_cold" -eq 0 ] && echo "  no baseline for ${KEY}: record cold=${cold} warm=${warm}" >&2
echo "  cold=${cold}ms (${reg_cold}%) warm=${warm}ms (${reg_warm}%) threshold=${THRESHOLD}% pass=${pass}" >&2

jq -cn --arg key "$KEY" --arg image "$REF" \
  --argjson cold "$cold" --argjson warm "$warm" \
  --argjson base_cold "$base_cold" --argjson base_warm "$base_warm" \
  --argjson reg_cold "$reg_cold" --argjson reg_warm "$reg_warm" \
  --argjson pass "$pass" \
  '{key: $key, image: $image, cold_ms: $cold, warm_ms: $warm,
    baseline_cold_ms: $base_cold, baseline_warm_ms: $base_warm,
    cold_regression_pct: $reg_cold, warm_regression_pct: $reg_warm, pass: $pass}'

[ "$pass" = true ]
