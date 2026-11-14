# Specification: Delivery events for uFawkesObs

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
`pr` (number, first_commit_at, opened_at, merged_at, cycle_time_seconds,
cycle_time_measured_to, lines_added, lines_deleted, commits).
`deploy-marker` embeds a uFawkesObs deployment event (uFawkesDORA merged into
uFawkesObs).

### REQ-004: CI on the pipeline-contract path

The CI Quality Gate emits the events after every successful run.

### REQ-005: The schema comes from uFawkesObs

The test validates `dora_event` against uFawkesObs's
`dora/events/deployment-event.schema.json` at the uFawkesObs release this repo
names, fetched or vendored byte for byte with the release recorded beside it.
The emitter sends no field that schema doesn't define.

Read on 2026-11-13: the vendored copy
(`scripts/testdata/ufawkesobs-deployment-event.schema.json`) requires
`deployment_intent`. uFawkesObs's schema doesn't define it and sets
`additionalProperties: false`, so the event this emitter builds would be
rejected with 422. `deployment_intent` stays or goes with uFawkesObs's
decision (paruff/uFawkesObs#717); tracked in #287.

### REQ-006: One emitter across the suite, or none

The emitter writes a log line that reaches Loki. It doesn't post to
uFawkesObs's `/event`, so it isn't a producer of the DORA ingestion contract
(the suite spec says so from its revision 6). Six other suite repos carry an
older copy of the script that no workflow calls. Whether they get this
version and a CI job, or lose the file, is an open decision (#288).

## Acceptance Criteria

AC-01, AC-02, AC-04 and AC-06 were run on 2026-11-13 at `901767c`
(`scripts/test-emit-dora-event.sh`, 23 checks passed). AC-03 passed as
first written, against the local copy; as reworded it isn't met. AC-05
needs a pipeline run and wasn't checked.

- [x] AC-01: Events are single-line JSON with dora-log.sh's fields — `test_type: unit`
- [x] AC-02: `agent_tokens` sums footers; `pr.cycle_time_seconds` = first commit → merge — `test_type: unit`
- [ ] AC-03: `dora_event` validates against uFawkesObs's `deployment-event.schema.json` at the named uFawkesObs release, not a local copy that differs from it (REQ-005) — `test_type: unit`
- [x] AC-04: OTLP export POSTs a valid logs payload; an unreachable endpoint never fails the run — `test_type: integration`
- [ ] AC-05: A real pipeline run produces a `dora-events` artifact whose event has agent token usage and PR cycle time — `test_type: live-system`
- [x] AC-06: Emitter works outside CI with inferred or explicit `--repo` — `test_type: unit`
- [ ] AC-07: With no `origin` remote and no `--repo`, the emitter warns and still emits the event (today `warn` is called at line 116, before it is defined at line 121) — `test_type: unit`
- [ ] AC-08: The decision in REQ-006 is recorded here, and each of the six repos has a PR or an issue for it — `test_type: review`

## Governance Alignment

| Requirement | Status  | Notes                                                                 |
| ----------- | ------- | --------------------------------------------------------------------- |
| Security    | COVERED | No secrets in files; OTLP headers only via CI secret; hook narrowed to allow `.env.example` only |
| Pipeline    | COVERED | Runs after `✅ CI Complete`; read-only token; pinned actions           |
