---
name: gitops-overlay
description: "Validate GitOps overlays for correctness and compliance. Use when reviewing kustomize builds, environment overlays, image tags, and secrets."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Overlay Validation

> **Load trigger:** `"load gitops-overlay skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate GitOps overlays for correctness and compliance.

## Responsibilities

- Validate kustomize builds succeed
- Validate environment overlays
- Validate image tags and digests
- Validate configmaps and secrets

## Inputs

- `overlays/` directory
- `version.json`

## Outputs

- `gitops-overlay.json`

## Validation Rules

### Kustomize Build

- [ ] `kustomize build overlays/dev` succeeds
- [ ] `kustomize build overlays/staging` succeeds
- [ ] `kustomize build overlays/production` succeeds
- [ ] No broken references or patches

### Environment Separation

- [ ] Dev, staging, production overlays present
- [ ] Environment-specific values in patches only
- [ ] Base manifests referenced, not duplicated
- [ ] No dev-only configs leaking to production

### Image Management

- [ ] Image tags immutable in production (digest-pinned)
- [ ] No `:latest` tag in production
- [ ] Image pull secrets referenced correctly

### Secrets

- [ ] No plaintext secrets in overlays
- [ ] Secrets externalized (ExternalSecrets, SealedSecrets)
- [ ] Secret references valid

### Configuration

- [ ] ConfigMaps contain non-sensitive config only
- [ ] Environment-specific values correct
- [ ] Resource limits appropriate per environment

## Tools

- `kustomize build` for validation
- `yq` for YAML inspection
- ArgoCD for sync validation

## Output Format

```json
{
  "skill": "gitops-overlay",
  "status": "pass | fail",
  "overlays": {
    "dev": { "build": "pass", "issues": [] },
    "staging": { "build": "pass", "issues": [] },
    "production": { "build": "fail", "issues": ["Image tag uses :latest"] }
  },
  "violations": []
}
```

## Success Criteria

- All overlays build successfully
- Environment separation enforced
- No plaintext secrets in Git
