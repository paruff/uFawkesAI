# uFawkes Integration Guide

This document shows how `uFawkesAI` composes with the rest of the uFawkes stack family so agent output is observable, measurable, and deployable.

## The uFawkes stack family

uFawkes is a stack family. This guide focuses on five integration touchpoints around `uFawkesAI`:

| Stack                  | Role                                                                   | Typical outcomes                                                 |
| ---------------------- | ---------------------------------------------------------------------- | ---------------------------------------------------------------- |
| uFawkesAI              | AI plane for agent policy, context, guardrails, and operating workflow | Smaller PRs, clearer instructions, lower rework                  |
| uFawkesPipe            | CI/CD and delivery pipeline plane                                      | Consistent PR gates and automated delivery                       |
| uFawkesObs             | Observability and reliability plane                                    | Traceability for latency, token usage, errors, and deploy impact |
| uFawkesDORA            | Delivery metrics and engineering effectiveness plane                   | Rework, cycle time, review speed, and recovery trends            |
| uFawkesApp/uFawkesData | Product and data plane pair (implementation + analytics)               | Business features and analytics outcomes                         |

## Connecting to uFawkesObs

Set OTEL exporter variables (template: `.env.example`) in the instrumented runtime/service that uses this template:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_SERVICE_NAME=my-project
```

This repository does not emit OTEL spans itself, but it does emit **delivery
events** from CI (see [Delivery events](#delivery-events) below). With OTEL
export enabled in your runtime, uFawkesObs/Grafana can correlate:

- Agent/request latency and failure patterns
- Token usage over time
- Change/deploy markers and post-deploy reliability signals

## Connecting to uFawkesDORA

uFawkesAI and this template's workflow produce the events uFawkesDORA uses:

- PR creation and review activity
- Merge cadence and cycle time signals
- Rework rate inputs from repository history
- CI/runtime signals that support recovery/reliability tracking

In this template, `npm run metrics` executes `scripts/weekly-metrics.sh`, which currently summarizes local git history and optional coverage data. `GITHUB_TOKEN`, `GITHUB_OWNER`, and `GITHUB_REPO` are optional integration variables for external/future GitHub API-backed DORA collection.

## Delivery events

`scripts/emit-dora-event.sh` emits structured JSON delivery events in the
same line format as uFawkesPipe's `scripts/dora-log.sh` (`@timestamp`,
`level`, `logger`, `message`, `pipeline`, `repo`, `step`), so uFawkesObs
ingests them into Loki alongside uFawkesPipe's own pipeline logs:

| Event           | When                                   | Adds                                                                  |
| --------------- | -------------------------------------- | --------------------------------------------------------------------- |
| `job-start`     | a pipeline/job began                   | —                                                                     |
| `job-finish`    | it ended                               | `status`, `duration_ms`, `agent_tokens`, `pr`                         |
| `deploy-marker` | a change was delivered (push to main)  | `environment`, `agent_tokens`, `pr`, `dora_event`                     |

- **`agent_tokens`**: input/output/cache tokens summed from the PR's
  `Agent-Tokens:` commit footers (`scripts/agent-usage.sh` generates them
  from real Claude Code transcripts; see `docs/COMMIT_CONVENTIONS.md`),
  plus the models used and how many commits reported or were AI co-authored.
- **`pr`**: number, `first_commit_at`, `opened_at`, `merged_at`,
  `cycle_time_seconds` (first commit → merge), lines added/deleted.
- **`dora_event`**: a uFawkesDORA deployment event valid against
  uFawkesObs `dora/events/deployment-event.schema.json` (1.0), ready to
  forward to the ingestion API.

Where the events go:

1. **stdout** — every event is one JSON line in the job log.
2. **`dora-events` artifact** — the CI Quality Gate's `📡 Delivery Events`
   job runs on every successful pipeline run (after `✅ CI Complete`) and
   uploads the run's events as `dora-events.jsonl`.
3. **uFawkesObs over OTLP** — set the repo variable
   `OTEL_EXPORTER_OTLP_ENDPOINT` (the collector's OTLP/HTTP port, 4318) and
   optionally `OTEL_SERVICE_NAME`, `DORA_ENVIRONMENT`, and the secret
   `OTEL_EXPORTER_OTLP_HEADERS`. Each event is POSTed to `/v1/logs`, which
   the uFawkesObs collector routes to Loki. A failed export warns and never
   fails the pipeline.

**Prerequisites:** `bash`, `curl`, `jq` and stock `python3` (standard library
only; no pip). Install missing tools with your system package manager.
`scripts/test-emit-dora-event.sh` proves the format, the schema-valid
`dora_event`, and the OTLP payload offline.

**Finding events in Loki.** Through uFawkesObs's collector, each event becomes
a Loki stream labelled `service_name` and `job` (both the service name: the
repo name unless `OTEL_SERVICE_NAME` is set) and `exporter="OTLP"`. The log
line is the OTLP record; the event JSON is its `body`. This LogQL returns the
events with their fields parsed:

```logql
{service_name="uFawkesAI", exporter="OTLP"} | json | line_format "{{.body}}" | json | event="deploy-marker"
```

Verified against uFawkesObs `main` (dfd4fc9, `make up-dora`) on 2026-10-03.
`scripts/verify-dora-event-in-loki.sh` repeats that check against a running
stack: it emits a marked event and polls Loki with this query (exit 0 found,
1 timed out, 2 stack not running).

## Connecting to uFawkesPipe

uFawkesPipe's pipeline contract was called `deliveryd` (file `.deliveryd.yml`);
it is now `.fawkespipe.yml`, and `.deliveryd.yml` support ended 2026-06-14.
This repo runs the contract's gates as the CI Quality Gate (reusable workflows
vendored from uFawkesPipe), and the delivery events above are emitted on that
path. Use the contract (<https://github.com/paruff/uFawkesPipe>) alongside this template's Golden Path:

1. Produce a reviewable PR using `docs/GOLDEN_PATH.md`
2. Let CI gates validate small-batch quality constraints
3. Pass build/test/review metadata through the pipeline contract
4. Promote only validated changes to deployment

This keeps AI-authored changes and delivery automation aligned under one contract.

## The full picture

```text
┌──────────────────────────────────────────────────────────────────┐
│ Dev layer: uFawkesAI                                             │
│ - Agent policy, context files, prompts, PR quality controls      │
└──────────────────────────────────────────────────────────────────┘
                               │ PR + metadata
                               ▼
┌──────────────────────────────────────────────────────────────────┐
│ CI layer: uFawkesPipe (.fawkespipe.yml contract, ex-deliveryd)   │
│ - PR gates, validation, artifact promotion, deployment workflow  │
└──────────────────────────────────────────────────────────────────┘
               │ telemetry/events                  │ delivery events
               ▼                                   ▼
┌──────────────────────────────────┐    ┌──────────────────────────┐
│ Observability: uFawkesObs        │    │ Metrics: uFawkesDORA     │
│ - OTEL traces, latency, tokens   │    │ - DORA and rework trends │
│ - Grafana dashboards + alerts    │    │ - Weekly delivery signals│
└──────────────────────────────────┘    └──────────────────────────┘
```
