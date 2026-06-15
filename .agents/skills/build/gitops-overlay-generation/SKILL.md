---
name: gitops-overlay-generation
description: "Generate GitOps overlays for each environment. Use when creating kustomize overlays with environment-specific configuration."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Overlay Generation

> **Load trigger:** `"load gitops-overlay-generation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Generate GitOps overlays for each environment.

## Responsibilities

- Generate kustomize overlays (dev, staging, production)
- Apply environment-specific configuration
- Apply image tags/digests
- Validate overlay structure

## Inputs

- `tasks.json`
- `version.json`
- Base manifests

## Outputs

- `overlays/dev/`
- `overlays/staging/`
- `overlays/production/`

## Generation Rules

### Directory Structure

```
overlays/
├── dev/
│   ├── kustomization.yaml
│   ├── patches/
│   └── secrets/
├── staging/
│   ├── kustomization.yaml
│   ├── patches/
│   └── secrets/
└── production/
    ├── kustomization.yaml
    ├── patches/
    └── secrets/
```

### Overlay Rules

- [ ] Base manifests referenced, not duplicated
- [ ] Environment-specific values in patches only
- [ ] Image tags immutable in production (digest-pinned)
- [ ] Secrets externalized (ExternalSecrets, SealedSecrets)
- [ ] Resource limits stricter in production than dev

### Environment Differences

| Setting | Dev | Staging | Production |
|---------|-----|---------|------------|
| Replicas | 1 | 2 | 3+ |
| CPU limit | 500m | 1 | 2 |
| Memory limit | 256Mi | 512Mi | 1Gi |
| Log level | debug | info | warn |
| Auto-sync | yes | yes | manual |

### Validation

- [ ] `kustomize build overlays/<env>` succeeds
- [ ] No plaintext secrets in overlays
- [ ] Image references valid
- [ ] Patches apply cleanly

## Tools

- `kustomize build` for validation
- `yq` for YAML manipulation
- ArgoCD for sync validation

## Success Criteria

- Overlays build successfully
- Environment separation enforced
- No plaintext secrets in Git
