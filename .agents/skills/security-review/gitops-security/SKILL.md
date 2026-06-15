---
name: gitops-security
description: "Validate GitOps repository and manifests for security posture. Use when reviewing overlay structure, environment separation, image tags, and secret references in GitOps repos."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Security Validation

> **Load trigger:** `"load gitops-security skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate GitOps repository and manifests for security posture.

## Responsibilities

- Validate overlay structure and organization
- Validate environment separation (dev/staging/prod)
- Validate image tag immutability
- Validate secret references
- Detect configuration drift risks

## Inputs

- GitOps repository structure
- Kustomize overlays (`overlays/`)
- ArgoCD application manifests
- Flux configuration

## Validation Rules

### Repository Structure

- [ ] Base manifests in `base/` directory
- [ ] Environment-specific overlays in `overlays/<env>/`
- [ ] No environment secrets in base manifests
- [ ] Clear separation between configuration and secrets

### Environment Separation

- [ ] Production overlays isolated from dev/staging
- [ ] No development-only configurations leaking to production
- [ ] Resource limits enforced in production overlays
- [ ] Network policies applied per environment

### Image Management

- [ ] Image tags immutable (no `:latest` in production)
- [ ] Images pinned to digests in production
- [ ] Image pull secrets properly referenced
- [ ] No untrusted image registries

### Secret Management

- [ ] Secrets externalized (ExternalSecrets, SealedSecrets, or Vault)
- [ ] No plaintext secrets in Git
- [ ] Secret rotation mechanism in place
- [ ] RBAC restricts secret access

### Drift Detection

- [ ] ArgoCD sync policies defined (auto-sync or manual)
- [ ] Health checks configured for applications
- [ ] Diff tools configured to detect drift
- [ ] Alerts for out-of-sync resources

## Tools

- `kustomize build` for manifest rendering
- `yq` for YAML inspection
- ArgoCD CLI for application status
- Flux CLI for reconciliation status

## Output Format

```json
{
  "skill": "gitops-security",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "resource": "<file or resource name>",
      "issue": "Description of the issue",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- GitOps configuration is secure and compliant
- Environment separation enforced
- No plaintext secrets in repository
- Image immutability maintained
