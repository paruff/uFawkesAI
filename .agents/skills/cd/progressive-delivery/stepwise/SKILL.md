---
name: stepwise-rollout
description: "Execute rollout in discrete steps with pause points. Use when applying step N of rollout, validating health, or deciding continue/pause/rollback."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Stepwise Rollout Execution

> **Load trigger:** `"load stepwise-rollout skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Execute rollout in discrete steps with pause points.

## Responsibilities

- Apply step N of rollout
- Validate health after each step
- Decide continue/pause/rollback

## Inputs

- Rollout plan
- Current step number

## Outputs

- `step-status.json`

## Step Execution

### Execution Steps

```
1. Apply traffic shift for step N
2. Wait for step duration
3. Collect metrics
4. Evaluate health criteria
5. If healthy → proceed to step N+1
6. If degraded → pause rollout
7. If failing → rollback
```

### Health Criteria Per Step

| Step | Max Latency | Max Error Rate | Max Saturation |
|------|------------|----------------|----------------|
| 1 (10%) | 500ms | 1% | 70% |
| 2 (25%) | 500ms | 1% | 70% |
| 3 (50%) | 400ms | 0.5% | 65% |
| 4 (75%) | 400ms | 0.5% | 65% |
| 5 (100%) | 350ms | 0.1% | 60% |

## Output Format

```json
{
  "skill": "stepwise-rollout",
  "current_step": 3,
  "traffic_percent": 50,
  "duration_seconds": 600,
  "health_check": {
    "latency_p99_ms": 350,
    "error_rate": 0.3,
    "status": "healthy"
  },
  "decision": "continue",
  "next_step": 4
}
```

## Success Criteria

- Each step validated before proceeding
- Health criteria met at each step
