---
name: flux-integration-testing
description: "Validate Flux reconciliation behavior. Use when triggering flux reconcile, validating applied manifests, or checking health."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Flux Integration Testing

> **Load trigger:** `"load flux-integration-testing skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate Flux reconciliation behavior.

## Responsibilities

- Trigger flux reconcile
- Validate applied manifests
- Validate health

## Inputs

- GitOps repo

## Outputs

- `flux-integration.json`

## Commands

```bash
# Reconcile source
flux reconcile source git flux-system

# Reconcile kustomization
flux reconcile kustomization apps

# Get status
flux get kustomizations
```

## Validation Rules

- [ ] Reconcile triggered successfully
- [ ] Source synced
- [ ] Kustomization applied
- [ ] Health checks pass
- [ ] No errors in flux logs

## Output Format

```json
{
  "skill": "flux-integration-testing",
  "status": "pass | fail",
  "source_synced": true,
  "kustomization_applied": true,
  "time_s": 30,
  "health": "healthy",
  "errors": []
}
```

## Success Criteria

- Successful reconciliation
- All resources healthy
