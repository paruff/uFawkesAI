---
name: performance-smoke-testing
description: "Validate basic performance characteristics to detect regressions. Use when running lightweight load tests to measure latency, throughput, and error rates."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Performance Smoke Testing

> **Load trigger:** `"load performance-smoke-testing skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate basic performance characteristics to detect regressions.

## Responsibilities

- Run lightweight load tests
- Measure latency, throughput, error rate
- Detect performance regressions
- Produce performance summary

## Inputs

- Build output
- Performance test configuration
- Baseline metrics (if available)

## Outputs

- `performance-smoke.json`
- `performance-summary.md`

## Metrics

### Core Metrics

| Metric        | Description                   | Unit  |
| ------------- | ----------------------------- | ----- |
| Latency (p50) | Median response time          | ms    |
| Latency (p95) | 95th percentile response time | ms    |
| Latency (p99) | 99th percentile response time | ms    |
| Throughput    | Requests per second           | req/s |
| Error rate    | Percentage of failed requests | %     |
| Saturation    | Resource utilization at peak  | %     |

### Regression Thresholds

| Metric        | Regression If...             |
| ------------- | ---------------------------- |
| Latency (p50) | > 20% increase from baseline |
| Latency (p95) | > 30% increase from baseline |
| Throughput    | > 15% decrease from baseline |
| Error rate    | > 1% increase from baseline  |

## Test Configuration

### Light Smoke Test

- Duration: 30 seconds
- Concurrent users: 10
- Requests per user: 50
- Think time: 100ms

### Standard Smoke Test

- Duration: 60 seconds
- Concurrent users: 50
- Requests per user: 100
- Think time: 200ms

## Validation Rules

### Pre-Test

- [ ] Application accessible
- [ ] Baseline metrics available (or first run noted)
- [ ] Test parameters configured

### During Test

- [ ] No errors exceeding threshold
- [ ] No timeouts exceeding threshold
- [ ] Resource utilization within bounds

### Post-Test

- [ ] Results collected and formatted
- [ ] Regression assessment made
- [ ] Comparison with baseline (if available)

## Tools

| Tool              | Language   | Notes                        |
| ----------------- | ---------- | ---------------------------- |
| k6                | JavaScript | Lightweight, cloud-ready     |
| wrk               | C          | High performance             |
| ab (Apache Bench) | CLI        | Simple, available everywhere |
| locust            | Python     | Scriptable, distributed      |
| vegeta            | Go         | Fixed-rate load testing      |

## Output Format

```json
{
  "skill": "performance-smoke-testing",
  "status": "pass | fail",
  "config": {
    "duration_seconds": 30,
    "concurrent_users": 10,
    "total_requests": 500
  },
  "results": {
    "latency_p50_ms": 45,
    "latency_p95_ms": 120,
    "latency_p99_ms": 250,
    "throughput_rps": 85,
    "error_rate_percent": 0.2,
    "total_requests": 500,
    "successful_requests": 499
  },
  "baseline": {
    "latency_p50_ms": 42,
    "latency_p95_ms": 110,
    "throughput_rps": 90
  },
  "regression": {
    "detected": false,
    "details": []
  }
}
```

## Success Criteria

- No major performance regressions detected
- Latency within acceptable bounds
- Error rate below threshold
