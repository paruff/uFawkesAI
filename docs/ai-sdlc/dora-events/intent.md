# Intent — Delivery events for uFawkesObs / uFawkesDORA

Status: ACCEPTED (owner goal, 2026-09-27)

## Problem

`docs/UFAWKES_INTEGRATION.md` describes uFawkesAI feeding uFawkesObs and
uFawkesDORA, but the repo emitted nothing: no delivery events, no record of
agent token usage, no PR cycle-time signal leaving CI.

## Desired outcome

Every successful pipeline run produces a JSON delivery event that
uFawkesObs can ingest, in the same line format as uFawkesPipe's
`scripts/dora-log.sh`, including agent token usage and PR cycle-time
metadata.

## Out of scope

- OTEL spans for agent invocations (`docs/AGENT_TELEMETRY.md`).
- Posting to the uFawkesDORA ingestion API (the event carries a
  schema-valid `dora_event` ready for it).
