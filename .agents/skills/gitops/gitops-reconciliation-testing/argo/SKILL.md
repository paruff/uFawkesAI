---
name: argo-reconciliation
description: "Validate ArgoCD reconciliation behavior. Use when triggering sync, validating manifests, or checking rollout status."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Argo Reconciliation

> **Load trigger:** `"load argo-reconciliation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate ArgoCD reconciliation behavior.

## Responsibilities

- Trigger sync
- Validate manifests
- Validate rollout

## Inputs

- GitOps repo

## Outputs

- `argo-reconcile.json`

## Sync Commands

```bash
# Sync application
argocd app sync my-app

# Wait for sync
argocd app wait my-app --health

# Get status
argocd app get my-app
```

## Validation Rules

- [ ] Sync triggered successfully
- [ ] Manifests applied
- [ ] Rollout successful
- [ ] Health status: Healthy
- [ ] No sync errors

## Output Format

```json
{
  "skill": "argo-reconciliation",
  "status": "success",
  "app": "my-app",
  "sync_status": "Synced",
  "health_status": "Healthy",
  "time_s": 45,
  "resources_synced": 12,
  "errors": []
}
```

## Success Criteria

- Successful sync
- Application healthy
