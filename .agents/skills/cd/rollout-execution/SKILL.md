---
name: rollout-execution
description: "Execute the rollout and validate its success. Use when triggering GitOps reconciliation, monitoring rollout status, validating health, or triggering rollback."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Rollout Execution & Validation

> **Load trigger:** `"load rollout-execution skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Execute the rollout and validate its success.

## Responsibilities

- Trigger GitOps reconciliation
- Monitor rollout status
- Validate health checks
- Validate logs and metrics
- Trigger rollback if needed

## Inputs

- `strategy-plan.json`
- GitOps repo

## Outputs

- `rollout-report.json`
- `rollout-status.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `rollout-execution/health-validation` | Validate rollout health |
| `rollout-execution/rollback-trigger` | Trigger rollback on failure |

## Execution Flow

```
1. Trigger reconciliation (Flux/ArgoCD)
2. Monitor rollout status
3. At each pause point:
   a. Validate health checks
   b. Validate metrics
   c. If healthy → continue
   d. If unhealthy → rollback
4. Final validation
5. Report results
```

## Rollout Commands

### Flux

```bash
flux reconcile kustomization <name> -n <namespace>
flux get kustomizations --watch
```

### ArgoCD

```bash
argocd app sync <app-name>
argocd app wait <app-name>
```

### Kubectl

```bash
kubectl rollout status deployment/<name> -n <namespace>
kubectl rollout history deployment/<name> -n <namespace>
```

## Rules

- [ ] Rollout monitored continuously
- [ ] Health validated at each pause point
- [ ] Rollback triggered on failure
- [ ] Results logged and reported

## Success Criteria

- Successful rollout or safe rollback
- Health maintained throughout
- Results documented
