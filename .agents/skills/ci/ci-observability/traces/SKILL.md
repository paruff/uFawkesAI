---
name: ci-traces
description: "Emit OpenTelemetry traces for CI execution. Use when instrumenting CI stages with spans and propagating trace IDs across steps."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Trace Propagation

> **Load trigger:** `"load ci-traces skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Emit OpenTelemetry traces for CI execution.

## Responsibilities

- Create spans for each CI stage
- Propagate `trace_id` across steps
- Validate trace completeness
- Export traces to backend

## Inputs

- CI run data

## Outputs

- `ci-traces.json`

## Span Structure

```
Root Span: CI Run (run_id=abc123)
├── Span: Lint (duration=15s)
├── Span: Unit Tests (duration=45s)
│   ├── Span: Shard 1 (duration=20s)
│   ├── Span: Shard 2 (duration=22s)
│   └── Span: Shard 3 (duration=18s)
├── Span: Security Scan (duration=30s)
├── Span: Build (duration=60s)
└── Span: Deploy (duration=25s)
```

## Trace Attributes

| Attribute | Type | Description |
|-----------|------|-------------|
| `ci.run_id` | string | Unique CI run identifier |
| `ci.stage` | string | Stage name |
| `ci.job` | string | Job name |
| `ci.status` | string | pass / fail |
| `ci.commit_sha` | string | Git commit SHA |
| `ci.branch` | string | Git branch |

## Validation Rules

- [ ] Every stage has a span
- [ ] `trace_id` propagated across parallel jobs
- [ ] Error events attached to failed spans
- [ ] Duration calculated correctly

## OpenTelemetry Example

```yaml
- name: Start trace
  run: |
    TRACE_ID=$(otlp-cli start-span --name "ci-run")
    echo "TRACE_ID=$TRACE_ID" >> $GITHUB_ENV

- name: Lint
  run: |
    otlp-cli start-span --parent $TRACE_ID --name "lint"
    npm run lint
    otlp-cli end-span
```

## Success Criteria

- Complete trace coverage
- All stages represented as spans
- Traces exported to backend
