---
name: rollout-validation
description: "Validate Kubernetes rollout behavior. Use when validating Deployment/StatefulSet rollout, readiness and liveness probes, or autoscaling behavior."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Rollout Validation

> **Load trigger:** `"load rollout-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate Kubernetes rollout behavior.

## Responsibilities

- Validate Deployment/StatefulSet rollout
- Validate readiness and liveness probes
- Validate autoscaling behavior

## Inputs

- Cluster

## Outputs

- `rollout-status.json`

## Validation Rules

- [ ] Rollout completed successfully
- [ ] All pods ready
- [ ] Liveness probes passing
- [ ] Readiness probes passing
- [ ] Autoscaling configured (if expected)

## Output Format

```json
{
  "skill": "rollout-validation",
  "status": "pass | fail",
  "deployment": "my-app",
  "replicas": { "desired": 3, "ready": 3, "available": 3 },
  "probes": { "liveness": "pass", "readiness": "pass" },
  "rollout_time_s": 60,
  "autoscaling": { "enabled": false }
}
```

## Success Criteria

- Successful rollout
- All pods ready and healthy
