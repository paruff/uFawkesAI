---
name: ci-observability
description: "Provide metrics, logs, and traces for CI execution. Use when instrumenting CI pipelines with Prometheus metrics, structured logs, or OpenTelemetry traces."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Observability

> **Load trigger:** `"load ci-observability skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Provide metrics, logs, and traces for CI execution.

## Responsibilities

- Emit CI metrics (duration, failures, retries)
- Emit structured logs
- Emit OpenTelemetry traces

## Inputs

- CI run data

## Outputs

- `ci-metrics.json`
- `ci-traces.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-observability/metrics` | Emit Prometheus metrics for CI runs |
| `ci-observability/traces` | Emit OpenTelemetry traces for CI stages |

## Core Metrics

| Metric | Type | Description |
|--------|------|-------------|
| `ci_run_duration_seconds` | Histogram | Total CI run duration |
| `ci_stage_duration_seconds` | Histogram | Per-stage duration |
| `ci_test_count` | Counter | Total tests run |
| `ci_test_failure_count` | Counter | Total test failures |
| `ci_retry_count` | Counter | Total retries |
| `ci_cache_hit_ratio` | Gauge | Cache hit rate |

## Structured Log Format

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "level": "info",
  "stage": "test",
  "job": "unit-tests",
  "message": "Stage completed",
  "duration_ms": 45000,
  "tests_passed": 42,
  "tests_failed": 0
}
```

## Observability Rules

- [ ] Every CI stage emits start/end events
- [ ] Every failure emits structured error log
- [ ] Every retry emits retry event
- [ ] Metrics exported to Prometheus endpoint

## Success Criteria

- Complete CI observability
- Metrics, logs, and traces available
