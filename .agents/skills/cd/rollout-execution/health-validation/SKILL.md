---
name: health-validation
description: "Validate the health of the application during rollout. Use when checking readiness/liveness, error rates, latency, or logs."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Rollout Health Validation

> **Load trigger:** `"load health-validation skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Validate the health of the application during rollout.

## Responsibilities

- Validate readiness/liveness probes
- Validate error rates
- Validate latency
- Validate logs

## Inputs

- Cluster state
- Metrics

## Outputs

- `rollout-health.json`

## Health Checks

### Pod Health

| Check | Healthy | Unhealthy |
|-------|---------|-----------|
| Ready | All pods ready | Any pod not ready |
| Running | All pods running | Any pod failing |
| No restarts | Restart count = 0 | Restart count > 0 |

### Probe Health

| Probe | Healthy | Unhealthy |
|-------|---------|-----------|
| Readiness | Passing | Failing |
| Liveness | Passing | Failing |
| Startup | Started | Failed |

### Metric Health

| Metric | Healthy | Warning | Critical |
|--------|---------|---------|----------|
| Error rate | < 1% | 1-5% | > 5% |
| Latency p99 | < 500ms | 500-1000ms | > 1000ms |
| CPU usage | < 70% | 70-85% | > 85% |

### Log Health

| Check | Healthy | Unhealthy |
|-------|---------|-----------|
| No ERROR messages | Clean logs | Error messages present |
| No stack traces | Clean logs | Stack traces present |

## Validation Rules

- [ ] All pod health checks passing
- [ ] All probe health checks passing
- [ ] Metrics within thresholds
- [ ] No error logs

## Output Format

```json
{
  "skill": "health-validation",
  "status": "healthy | unhealthy",
  "pods": {"total": 3, "ready": 3, "running": 3},
  "probes": {"readiness": "passing", "liveness": "passing"},
  "metrics": {
    "error_rate": 0.5,
    "latency_p99_ms": 250,
    "status": "healthy"
  },
  "logs": {"errors": 0, "status": "clean"}
}
```

## Success Criteria

- Healthy rollout
- All health checks passing
- Metrics within thresholds
