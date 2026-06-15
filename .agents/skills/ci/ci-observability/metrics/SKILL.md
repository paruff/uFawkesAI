---
name: ci-metrics
description: "Emit Prometheus metrics for CI runs. Use when instrumenting CI pipelines with duration metrics, failure counters, or retry counters."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Metrics Emission

> **Load trigger:** `"load ci-metrics skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Emit Prometheus metrics for CI runs.

## Responsibilities

- Emit duration metrics per stage
- Emit failure counters
- Emit retry counters
- Emit cache hit/miss counters

## Inputs

- CI run data

## Outputs

- `ci-metrics.json`

## Metrics Definition

### Counters

| Metric | Labels | Description |
|--------|--------|-------------|
| `ci_runs_total` | `status` | Total CI runs |
| `ci_stage_failures_total` | `stage` | Failures per stage |
| `ci_retries_total` | `stage` | Retries per stage |
| `ci_cache_hits_total` | `cache_type` | Cache hits |
| `ci_cache_misses_total` | `cache_type` | Cache misses |

### Histograms

| Metric | Labels | Description |
|--------|--------|-------------|
| `ci_run_duration_seconds` | `status` | Total run duration |
| `ci_stage_duration_seconds` | `stage` | Per-stage duration |
| `ci_test_duration_seconds` | `suite` | Per-suite test duration |

### Gauges

| Metric | Description |
|--------|-------------|
| `ci_cache_hit_ratio` | Current cache hit rate |
| `ci_running_jobs` | Currently running jobs |

## GitHub Actions Example

```yaml
- name: Emit metrics
  if: always()
  run: |
    curl -X POST $PROMETHEUS_PUSHGATEWAY \
      --data-binary @- <<EOF
    ci_run_duration_seconds{status="${{ job.status }}"} ${{ steps.timer.outputs.duration }}
    ci_stage_failures_total{stage="${{ github.job }}"} ${{ steps.test.outputs.failures }}
    EOF
```

## Success Criteria

- Metrics emitted successfully
- Metrics queryable via Prometheus
