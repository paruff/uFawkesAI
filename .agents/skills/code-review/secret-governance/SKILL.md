---
name: secret-governance
description: "Validate secret usage and governance. Use when reviewing secret storage, rotation policies, and access patterns."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Secret Governance Validation

> **Load trigger:** `"load secret-governance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate secret usage and governance.

## Responsibilities

- Validate secret storage location and encryption
- Validate secret rotation policies
- Validate secret access patterns
- Detect plaintext secrets

## Inputs

- Secret manifests
- Secret metadata

## Outputs

- `secret-governance.json`

## Validation Rules

### Storage

- [ ] No plaintext secrets in Git
- [ ] Secrets encrypted at rest
- [ ] External secret management used where available
- [ ] No `.env` files committed

### Access

- [ ] Secret access restricted via RBAC
- [ ] Service accounts have minimal secret access
- [ ] Secret access audited

### Rotation

- [ ] Rotation policy defined for each secret type
- [ ] No expired certificates or tokens
- [ ] Automated rotation configured

### Patterns

- [ ] No hardcoded secrets in source code
- [ ] No secrets in environment variables exposed to logs
- [ ] Secret references use `secretKeyRef`
- [ ] No secrets in ConfigMaps unless clearly non-sensitive

## Tools

- `kubectl get secrets -o yaml`
- Secret scanning (gitleaks, truffleHog)
- `grep` for plaintext patterns

## Output Format

```json
{
  "skill": "secret-governance",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Storage",
      "status": "pass | fail",
      "details": "Description"
    },
    {
      "area": "Rotation",
      "status": "pass | fail",
      "details": "Description"
    }
  ],
  "violations": []
}
```

## Success Criteria

- No secret governance violations
- No plaintext secrets detected
- Rotation policies defined
