---
name: environment-promotion
description: "Promote to next environment without human intervention. Use when updating GitOps overlays, committing changes, or triggering reconciliation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Automated Environment Promotion

> **Load trigger:** `"load environment-promotion skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Promote to next environment without human intervention.

## Responsibilities

- Update GitOps overlays
- Commit and push changes
- Trigger reconciliation
- Validate promotion

## Inputs

- `promotion-criteria.json`

## Outputs

- `automated-promotion.json`

## Promotion Steps

### 1. Update GitOps Overlay

```bash
# Update image tag in overlay
yq -i '.spec.template.spec.containers[0].image = "my-app:v1.2.3" \
  overlays/staging/deployment.yaml'
```

### 2. Commit and Push

```bash
git add overlays/staging/
git commit -m "chore: promote my-app v1.2.3 to staging"
git push origin main
```

### 3. Trigger Reconciliation

```bash
# Flux
flux reconcile kustomization staging -n flux-system

# ArgoCD
argocd app sync staging-my-app
```

### 4. Validate

```bash
kubectl rollout status deployment/my-app -n staging
```

## Environment Order

| Order | Environment | Approval |
|-------|-------------|----------|
| 1 | dev | Automated |
| 2 | staging | Automated |
| 3 | production | Manual (configurable) |

## Rules

- [ ] GitOps overlay updated atomically
- [ ] Commit message includes version and target
- [ ] Reconciliation triggered
- [ ] Post-promotion validation performed

## Output Format

```json
{
  "skill": "environment-promotion",
  "from_environment": "dev",
  "to_environment": "staging",
  "version": "v1.2.3",
  "commit_sha": "abc123",
  "reconciliation_triggered": true,
  "validation": "success"
}
```

## Success Criteria

- Successful automated promotion
- GitOps state updated
- Next environment healthy
