# Design: Delivery events for uFawkesObs

Implements `docs/ai-sdlc/dora-events/spec.md`.

## Architecture Overview

A bash emitter builds each event with `jq`, resolves PR data through the
GitHub API (`gh`), and writes to stdout / a file / OTLP. uFawkesObs's OTel
collector routes OTLP logs to Loki (`config/otel/collector.yaml`), and
Alloy picks up JSON lines from job logs, the same path as dora-log.sh.

## Components

### Component: emit-dora-event.sh

- **Purpose:** emit delivery events
- **Runtime/deployed:** no — runs in CI jobs
- **Exercised by live-system AC:** AC-05

### Component: agent-usage.sh

- **Purpose:** turn real Claude Code transcript usage into an `Agent-Tokens:` footer
- **Runtime/deployed:** no — developer workstation
- **Exercised by live-system AC:** none

## Tradeoffs

| Decision            | Chosen                 | Rejected                    | Rationale                                                   |
| ------------------- | ---------------------- | --------------------------- | ----------------------------------------------------------- |
| Token usage carrier | Commit footer          | Gitignored agent logs       | Footers are committed, reviewable, and visible to CI        |
| DORA schema fields  | Embedded `dora_event`  | Extra fields on the schema  | Schemas are `additionalProperties: false`                   |
| Delivery trigger    | Push to main           | Every PR run                | A merge to main is this template's delivery                 |

## Governance Alignment

| Requirement | Design Decision                             | Status  |
| ----------- | ------------------------------------------- | ------- |
| Security    | OTLP headers from a CI secret, never files  | COVERED |
| Pipeline    | Job after `✅ CI Complete`; artifact upload | COVERED |

## Implementation Sequence

1. `.env.example`, protected-path pattern narrowed to allow it
2. `scripts/emit-dora-event.sh`, `scripts/agent-usage.sh`
3. `scripts/test-emit-dora-event.sh` + vendored schema
4. `📡 Delivery Events` job in `ci-quality.yml`; docs

Steps 1 to 4 are merged. What the 2026-11-13 suite audit added is the
sub-issues of #291: the schema source and the `warn` ordering (#287), and
the six older copies (#288).

## Verification Strategy

| AC    | How it is proven                                         | test_type   | Command / CI job                          |
| ----- | -------------------------------------------------------- | ----------- | ----------------------------------------- |
| AC-01 | shape checks on all three events                         | unit        | `scripts/test-emit-dora-event.sh`         |
| AC-02 | fixture PR with two footers and a known cycle time       | unit        | `scripts/test-emit-dora-event.sh`         |
| AC-03 | schema checks in stdlib `python3` + `jq` (no pip)        | unit        | `scripts/test-emit-dora-event.sh`         |
| AC-04 | local listener captures the POST; port 9 must only warn  | integration | `scripts/test-emit-dora-event.sh`         |
| AC-05 | download the run's `dora-events` artifact and inspect it | live-system | `ci-quality.yml` › `📡 Delivery Events`   |
| AC-06 | emitter works outside CI with inferred/explicit `--repo` | unit        | `scripts/test-emit-dora-event.sh`         |
| AC-07 | run in a repo with no remote and no `--repo`             | unit        | `scripts/test-emit-dora-event.sh`         |
| AC-08 | the decision in `spec.md`, and a link per repo           | review      | #288                                      |

AC-03 changes with REQ-005: the schema is uFawkesObs's file at a named
release, so the test fails when the two differ. The suite checks the same
thing from outside (AC-SUITE-04, paruff/uFawkes.dev#232).

Prerequisites for local verification: `bash`, `jq`, `python3` (stdlib only — no `pip install` needed). The embedded validator uses only `datetime`, `json`, `re`, `sys`, `urllib.parse`.
