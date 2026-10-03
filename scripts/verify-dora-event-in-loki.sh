#!/usr/bin/env bash
# scripts/verify-dora-event-in-loki.sh — live check that a delivery event
# reaches uFawkesObs's Loki (dora-events-portability REQ-003, AC-AI-06).
#
# Needs a running uFawkesObs (`make up-dora` in that repo). Emits a job-finish
# event whose `step` is a unique marker over OTLP, then polls Loki's
# query_range with the LogQL documented in docs/UFAWKES_INTEGRATION.md.
#
# Env: OTEL_EXPORTER_OTLP_ENDPOINT (default http://localhost:4318)
#      LOKI_URL                    (default http://localhost:3100)
#      OTEL_SERVICE_NAME           (default: the emitter's, the repo name)
#      VERIFY_TIMEOUT_SECONDS      (default 30)
# Exit: 0 found, 1 timed out, 2 stack unreachable (SKIP). Not in the offline
# unit suite: it needs the live stack.

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

otlp="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"
loki="${LOKI_URL:-http://localhost:3100}"
timeout="${VERIFY_TIMEOUT_SECONDS:-30}"

if ! curl -fsS --max-time 5 "${loki%/}/ready" > /dev/null 2>&1; then
  echo "SKIP: Loki not reachable at ${loki}. Start uFawkesObs with 'make up-dora' in that repo."
  exit 2
fi

marker="verify-$(date -u +%Y%m%dT%H%M%SZ)-$$"
event="$(OTEL_EXPORTER_OTLP_ENDPOINT="$otlp" bash scripts/emit-dora-event.sh job-finish \
  --step "$marker" --status success 2> /dev/null)"
service="$(jq -r .service <<< "$event")"

query="{service_name=\"${service}\", exporter=\"OTLP\"} | json | line_format \"{{.body}}\" | json | event=\"job-finish\" | step=\"${marker}\""
start="$(($(date +%s) - 300))000000000"
echo "LogQL: ${query}"

deadline=$(($(date +%s) + timeout))
while :; do
  resp="$(curl -fsSG --max-time 5 "${loki%/}/loki/api/v1/query_range" \
    --data-urlencode "query=${query}" --data-urlencode "start=${start}" || true)"
  line="$(jq -r '.data.result[0].values[0][1] // empty' <<< "$resp" 2> /dev/null || true)"
  if [ -n "$line" ]; then
    echo "✅ Event found in Loki:"
    echo "$line"
    exit 0
  fi
  if [ "$(date +%s)" -ge "$deadline" ]; then
    echo "❌ Event ${marker} not in Loki after ${timeout}s. Is the collector at ${otlp} routing logs to Loki?"
    echo "Last response: ${resp:-<none>}"
    exit 1
  fi
  sleep 2
done
