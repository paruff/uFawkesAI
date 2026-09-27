# Specification: Delivery events for uFawkesObs / uFawkesDORA

## Functional Requirements

### REQ-001: Environment template

`.env.example` carries `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_SERVICE_NAME`
(from `docs/UFAWKES_INTEGRATION.md`) plus the optional emitter variables.

### REQ-002: Event emitter

`scripts/emit-dora-event.sh` emits `job-start`, `job-finish` and
`deploy-marker` as single JSON lines with dora-log.sh's fields, to stdout,
an optional file, and OTLP/HTTP `/v1/logs` when an endpoint is set.

### REQ-003: Agent token usage and PR cycle time

`job-finish` and `deploy-marker` include `agent_tokens` (summed
`Agent-Tokens:` commit footers) and `pr` (first commit, opened, merged,
cycle time, size). `deploy-marker` embeds a uFawkesDORA deployment event.

### REQ-004: CI on the pipeline-contract path

The CI Quality Gate emits the events after every successful run.

## Acceptance Criteria

- [ ] AC-01: Events are single-line JSON with dora-log.sh's fields — `test_type: unit`
- [ ] AC-02: `agent_tokens` sums footers; `pr.cycle_time_seconds` = first commit → merge — `test_type: unit`
- [ ] AC-03: `dora_event` validates against uFawkesObs `deployment-event.schema.json` — `test_type: unit`
- [ ] AC-04: OTLP export POSTs a valid logs payload; an unreachable endpoint never fails the run — `test_type: integration`
- [ ] AC-05: A real pipeline run produces a `dora-events` artifact whose event has agent token usage and PR cycle time — `test_type: live-system`

## Governance Alignment

| Requirement | Status  | Notes                                                                 |
| ----------- | ------- | --------------------------------------------------------------------- |
| Security    | COVERED | No secrets in files; OTLP headers only via CI secret; hook narrowed to allow `.env.example` only |
| Pipeline    | COVERED | Runs after `✅ CI Complete`; read-only token; pinned actions           |
