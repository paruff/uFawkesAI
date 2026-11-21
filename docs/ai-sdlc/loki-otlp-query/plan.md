# Plan: verify-dora-event-in-loki.sh queries Loki's native OTLP shape

**Traces to:** paruff/uFawkesObs#739

## Changes

1. `scripts/verify-dora-event-in-loki.sh`: drop `exporter="OTLP"` and the
   `line_format "{{.body}}"` unwrap. The Collector sends logs to Loki's native
   OTLP endpoint, which adds no `exporter` label and stores the event JSON as
   the log line.
2. `docs/UFAWKES_INTEGRATION.md` and `scripts/test-emit-dora-event.sh`: the
   documented LogQL matches.

## Verification Strategy

| Criterion                     | Evidence                                   | How                                                                 |
| ----------------------------- | ------------------------------------------ | ------------------------------------------------------------------- |
| Marker event is found in Loki | "Event found in Loki", exit 0              | `make up-dora` in uFawkesObs, then `bash scripts/verify-dora-event-in-loki.sh` |
| Docs and query stay in step   | 25 offline checks pass                     | `bash scripts/test-emit-dora-event.sh`                              |
