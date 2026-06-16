---
name: e2e-deployment-validation
description: "Validate that the deployed application behaves correctly after reconciliation. Use when validating rollout status, health checks, logs, metrics, or trace propagation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: E2E Deployment Validation

> **Load trigger:** `"load e2e-deployment-validation skill"` > **DORA:** Cap 4 (CI/CD Automation) + Cap 6 (Operational Visibility)
> **Token cost:** Low

## Purpose

Validate that the deployed application behaves correctly after reconciliation.

## Responsibilities

- Validate rollout status
- Validate health checks
- Validate logs
- Validate metrics
- Validate trace propagation

## Inputs

- Deployed environment

## Outputs

- `deployment-validation.json`
- `rollout-status.json`

## Sub-Skills

| Skill                                 | Purpose                        |
| ------------------------------------- | ------------------------------ |
| `e2e-deployment-validation/rollout`   | Validate rollout behavior      |
| `e2e-deployment-validation/telemetry` | Validate logs, metrics, traces |

## Validation Rules

- [ ] Healthy rollout
- [ ] No errors in logs
- [ ] Valid metrics
- [ ] Valid traces

## Output Format

```json
{
  "skill": "e2e-deployment-validation",
  "status": "pass | fail",
  "rollout": { "status": "pass", "replicas": 3, "ready": 3 },
  "health": { "liveness": "pass", "readiness": "pass" },
  "logs": { "errors": 0, "warnings": 0 },
  "metrics": { "present": true, "golden_signals": "complete" },
  "traces": { "propagating": true }
}
```

## Success Criteria

- Healthy rollout
- No errors in logs
- Valid metrics and traces
