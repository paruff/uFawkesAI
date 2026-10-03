# Specification: Delivery events for uFawkesObs / uFawkesDORA

## Functional Requirements

### REQ-001: Environment template

`.env.example` carries `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_SERVICE_NAME`
(from `docs/UFAWKES_INTEGRATION.md`) plus the optional emitter variables.

### REQ-002: Event emitter

`scripts/emit-dora-event.sh` emits `job-start`, `job-finish` and
`deploy-marker` as single JSON lines with dora-log.sh's fields, to stdout,
an optional file, and OTLP/HTTP `/v1/logs` when an endpoint is set.

The emitter works both inside CI (using `GITHUB_REPOSITORY`, `GITHUB_RUN_NUMBER`,
etc.) and outside CI:
- Repository is inferred from `git remote get-url origin` when `GITHUB_REPOSITORY`
  and `CI_REPO` are not set
- A `--repo OWNER/REPO` flag can override the inferred repository
- Missing context yields warnings on stderr and `null`/`unknown` fields, never an error

### REQ-003: Agent token usage and PR cycle time

`job-finish` and `deploy-marker` include `agent_tokens` (summed
`Agent-Tokens:` commit trailers across the PR, see `scripts/agent-usage.sh`) and
`pr` (number, first_commit_at, opened_at, merged_at, cycle_time_seconds, size).
`deploy-marker` embeds a uFawkesDORA deployment event.

### REQ-004: CI on the pipeline-contract path

The CI Quality Gate emits the events after every successful run.

## Acceptance Criteria

- [ ] AC-01: Events are single-line JSON with dora-log.sh's fields — `test_type: unit`
- [ ] AC-02: `agent_tokens` sums footers; `pr.cycle_time_seconds` = first commit → merge — `test_type: unit`
- [ ] AC-03: `dora_event` validates against uFawkesObs `deployment-event.schema.json` — `test_type: unit`
- [ ] AC-04: OTLP export POSTs a valid logs payload; an unreachable endpoint never fails the run — `test_type: integration`
- [ ] AC-05: A real pipeline run produces a `dora-events` artifact whose event has agent token usage and PR cycle time — `test_type: live-system`
- [ ] AC-06: Emitter works outside CI with inferred or explicit `--repo` — `test_type: unit`

## Governance Alignment

| Requirement | Status  | Notes                                                                 |
| ----------- | ------- | --------------------------------------------------------------------- |
| Security    | COVERED | No secrets in files; OTLP headers only via CI secret; hook narrowed to allow `.env.example` only |
| Pipeline    | COVERED | Runs after `✅ CI Complete`; read-only token; pinned actions           |
