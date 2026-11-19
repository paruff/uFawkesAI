# Specification: Delivery events for uFawkesObs

## Functional Requirements

### REQ-001: Environment template

`.env.example` carries `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_SERVICE_NAME`
(from `docs/UFAWKES_INTEGRATION.md`) plus the optional emitter variables.

### REQ-002: Event emitter

`scripts/emit-dora-event.sh` emits `job-start`, `job-finish` and
`deploy-marker` as single JSON lines with dora-log.sh's fields, to stdout,
an optional file, and OTLP/HTTP `/v1/logs` when an endpoint is set.

The emitter reads its context from GitHub Actions (`GITHUB_*`) or Woodpecker
(`CI_*`) variables. Missing context yields `unknown` or `null` fields and a
warning on stderr, never an error, except that `deploy-marker` exits 1 without
a commit SHA or pipeline URL, because uFawkesObs would reject the event.

### REQ-003: Agent token usage and PR cycle time

`job-finish` and `deploy-marker` include `agent_tokens` (summed
`Agent-Tokens:` commit trailers across the PR, see `scripts/agent-usage.sh`) and
`pr` (number, first_commit_at, opened_at, merged_at, cycle_time_seconds,
cycle_time_measured_to, lines_added, lines_deleted, commits).
`deploy-marker` embeds a uFawkesObs deployment event (the former uFawkesDORA merged into
uFawkesObs).

### REQ-004: CI on the pipeline-contract path

The CI Quality Gate emits the events after every successful run.

### REQ-005: The schema comes from uFawkesObs

The test validates `dora_event` against uFawkesObs's
`dora/events/deployment-event.schema.json`, vendored byte for byte in
`scripts/testdata/` at uFawkesObs `v1.0.1` (named in the `.release` file beside
it). When the network is reachable the test also compares the copy with that
release. The emitter sends no field that schema doesn't define, so it sends no
`deployment_intent` (paruff/uFawkesObs#717 closed without adding it). Tracked in #287.

### REQ-006: One emitter across the suite

Decision (2026-11-19, #288): this repo's script is the only emitter. The
older, byte-identical copies in fawkes, uFawkes.dev, uFawkesDojo, uFawkesObs,
uFawkesPipe and uFawkesDevX are deleted; no workflow in them calls the script.
The emitter posts `dora_event` to uFawkesObs's `/event` when
`DORA_INGESTION_URL` is set, so it is a producer of the ingestion contract.
Each of the six repos has an issue for the deletion (listed under AC-08).

## Acceptance Criteria

AC-01 to AC-04, AC-06 and AC-07 run in `scripts/test-emit-dora-event.sh` (25 checks). AC-05 needs a pipeline run and has not been checked.

- [x] AC-01: Events are single-line JSON with dora-log.sh's fields — `test_type: unit`
- [x] AC-02: `agent_tokens` sums footers; `pr.cycle_time_seconds` = first commit → merge — `test_type: unit`
- [x] AC-03: `dora_event` validates against uFawkesObs's `deployment-event.schema.json` at the pinned release (checked against it when online) (REQ-005) — `test_type: unit`
- [x] AC-04: OTLP export POSTs a valid logs payload; an unreachable endpoint never fails the run — `test_type: integration`
- [ ] AC-05: A real pipeline run produces a `dora-events` artifact whose event has agent token usage and PR cycle time — `test_type: live-system`
- [x] AC-06: Emitter works outside CI — `test_type: unit`
- [x] AC-07: With no repo variable, the emitter still emits the event with `repo: unknown` — `test_type: unit`
- [x] AC-08: The decision in REQ-006 is recorded here, and each of the six repos has an issue for it (fawkes#2344, uFawkes.dev#256, uFawkesDojo#134, uFawkesObs#734, uFawkesPipe#265, uFawkesDevX#166) — `test_type: review`

## Governance Alignment

| Requirement | Status  | Notes                                                                 |
| ----------- | ------- | --------------------------------------------------------------------- |
| Security    | COVERED | No secrets in files; OTLP headers only via CI secret; hook narrowed to allow `.env.example` only |
| Pipeline    | COVERED | Runs after `✅ CI Complete`; read-only token; pinned actions           |
