---
name: gitops-reconciliation-testing
description: "Validate that Flux or ArgoCD correctly reconciles manifests after a GitOps update. Use when triggering reconciliation, validating applied manifests, validating rollout status, or checking health."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Reconciliation Testing

> **Load trigger:** `"load gitops-reconciliation-testing skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that Flux or ArgoCD correctly reconciles manifests after a GitOps update.

## Responsibilities

- Trigger reconciliation
- Validate applied manifests
- Validate rollout status
- Validate health checks

## Inputs

- GitOps repo
- Cluster

## Outputs

- `reconciliation-report.json`
- `rollout-status.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `gitops-reconciliation-testing/flux` | Flux reconciliation |
| `gitops-reconciliation-testing/argo` | ArgoCD reconciliation |

## Reconciliation Flow

```
1. Git push to GitOps repo
2. GitOps controller detects change
3. Controller reconciles manifests
4. Kubernetes applies manifests
5. Rollout completes
6. Health checks pass
```

## Validation Rules

- [ ] Reconciliation triggered
- [ ] Manifests applied correctly
- [ ] Rollout successful
- [ ] Health checks pass
- [ ] No errors in controller logs

## Output Format

```json
{
  "skill": "gitops-reconciliation-testing",
  "status": "success",
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
