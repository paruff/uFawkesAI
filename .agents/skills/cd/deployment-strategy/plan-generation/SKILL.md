---
name: strategy-plan-generation
description: "Generate a rollout plan for the selected strategy. Use when defining rollout steps, pause points, validation gates, or rollback triggers."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Strategy Plan Generation

> **Load trigger:** `"load strategy-plan-generation skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Generate a rollout plan for the selected strategy.

## Responsibilities

- Define rollout steps
- Define pause points
- Define validation gates
- Define rollback triggers

## Inputs

- `strategy-selection.json`

## Outputs

- `strategy-plan.json`

## Plan Templates

### Rolling Strategy Plan

```json
{
  "strategy": "rolling",
  "steps": [
    {"action": "update", "max_surge": "25%", "max_unavailable": "0"},
    {"action": "validate", "timeout": "5m"}
  ]
}
```

### Canary Strategy Plan

```json
{
  "strategy": "canary",
  "steps": [
    {"traffic": 10, "duration": "5m", "validation": "health-check"},
    {"traffic": 25, "duration": "5m", "validation": "health-check"},
    {"traffic": 50, "duration": "10m", "validation": "full-metrics"},
    {"traffic": 100, "validation": "final-check"}
  ]
}
```

### Blue-Green Strategy Plan

```json
{
  "strategy": "blue-green",
  "steps": [
    {"action": "deploy-green", "validation": "readiness"},
    {"action": "switch-traffic", "validation": "routing"},
    {"action": "monitor", "duration": "15m"},
    {"action": "decommission-blue"}
  ]
}
```

## Pause Points

| Strategy | Pause Points |
|----------|-------------|
| Rolling | After each surge |
| Canary | After each traffic step |
| Blue-Green | Before traffic switch |

## Rollback Triggers

| Trigger | Action |
|---------|--------|
| Health check failure | Immediate rollback |
| Error rate > 5% | Immediate rollback |
| Latency p99 > 1s | Pause, investigate |
| OOMKilled | Immediate rollback |

## Output Format

```json
{
  "skill": "strategy-plan-generation",
  "strategy": "canary",
  "steps": [
    {"step": 1, "traffic": 10, "duration_seconds": 300, "validation": "health"},
    {"step": 2, "traffic": 25, "duration_seconds": 300, "validation": "health"},
    {"step": 3, "traffic": 50, "duration_seconds": 600, "validation": "metrics"},
    {"step": 4, "traffic": 100, "validation": "final"}
  ],
  "rollback_triggers": ["health_failure", "error_rate_5pct", "oom_killed"]
}
```

## Success Criteria

- Valid rollout plan generated
- Pause points defined
- Rollback triggers specified
