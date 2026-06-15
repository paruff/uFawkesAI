---
name: gitops-to-controller-integration
description: "Validate Flux or ArgoCD reconciliation behavior after GitOps updates. Use when triggering reconciliation, validating applied manifests, validating rollout behavior, or checking health."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps → Controller Integration Testing

> **Load trigger:** `"load gitops-to-controller-integration skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate Flux or ArgoCD reconciliation behavior after GitOps updates.

## Responsibilities

- Trigger reconciliation
- Validate applied manifests
- Validate rollout behavior
- Validate health checks

## Inputs

- GitOps repo
- Cluster

## Outputs

- `controller-integration-report.json`
- `rollout-status.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `gitops-to-controller/flux` | Flux integration testing |
| `gitops-to-controller/argo` | ArgoCD integration testing |

## Validation Rules

- [ ] Reconciliation triggered successfully
- [ ] Manifests applied correctly
- [ ] Rollout successful
- [ ] Health checks pass
- [ ] No controller errors

## Output Format

```json
{
  "skill": "gitops-to-controller-integration",
  "status": "pass | fail",
  "controller": "flux",
  "reconciliation": {
    "triggered": true,
    "applied": true,
    "time_s": 30
  },
  "rollout": {
    "status": "successful",
    "time_s": 60
  },
  "health": "healthy"
}
```

## Success Criteria

- Successful reconciliation
- Healthy rollout
