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

Set OTEL exporter variables in the instrumented runtime/service that uses this template:

```bash
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318
OTEL_SERVICE_NAME=my-project
```

This repository is documentation-first and does not emit OTEL spans by itself. With OTEL export enabled in your runtime, uFawkesObs/Grafana can correlate:

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

## Connecting to uFawkesPipe

Use uFawkesPipe's `deliveryd` contract (the CI pipeline contract in uFawkesPipe: <https://github.com/paruff/uFawkesPipe>) alongside this template's Golden Path:

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
│ CI layer: uFawkesPipe (deliveryd contract)                       │
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
