---
name: green-validation
description: "Validate the new (green) environment before traffic switch. Use when validating readiness, logs, metrics, or config correctness for the green environment."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Green Environment Validation

> **Load trigger:** `"load green-validation skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Validate the new (green) environment before traffic switch.

## Responsibilities

- Validate pod readiness
- Validate logs (no errors)
- Validate metrics (within thresholds)
- Validate config correctness

## Inputs

- Green environment deployment

## Outputs

- `green-validation.json`

## Validation Checks

### Pod Health

| Check | Required |
|-------|----------|
| All pods Running | Yes |
| All pods Ready | Yes |
| No CrashLoopBackOff | Yes |
| No OOMKilled | Yes |

### Logs

| Check | Required |
|-------|----------|
| No ERROR messages | Yes |
| No stack traces | Yes |
| Startup complete | Yes |

### Metrics

| Metric | Threshold |
|--------|-----------|
| Error rate | < 1% |
| Latency p99 | < 500ms |
| CPU usage | < 70% |

### Config

| Check | Required |
|-------|----------|
| Environment variables set | Yes |
| ConfigMaps mounted | Yes |
| Secrets accessible | Yes |

## Output Format

```json
{
  "skill": "green-validation",
  "status": "pass | fail",
  "checks": {
    "pods_ready": true,
    "logs_clean": true,
    "metrics_healthy": true,
    "config_correct": true
  },
  "pod_count": 3,
  "ready_count": 3
}
```

## Success Criteria

- Green environment healthy
- All checks passed
- Ready for traffic switch
