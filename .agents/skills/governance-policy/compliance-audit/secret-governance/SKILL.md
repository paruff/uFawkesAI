---
name: compliance-secret-governance
description: "Ensure secrets are stored, rotated, and used securely. Use when validating secret storage, rotation policies, and access patterns."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Secret Governance

> **Load trigger:** `"load compliance-secret-governance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure secrets are stored, rotated, and used securely.

## Responsibilities

- Validate secret storage location and encryption
- Validate secret rotation policies
- Validate secret access patterns

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

### Rotation

- [ ] Rotation policy defined for each secret type
- [ ] No expired certificates or tokens
- [ ] Automated rotation configured

### Access

- [ ] Secret access restricted via RBAC
- [ ] Service accounts have minimal secret access
- [ ] Secret access audited

### Patterns

- [ ] No hardcoded secrets in source code
- [ ] Secret references use `secretKeyRef`
- [ ] No secrets in ConfigMaps unless clearly non-sensitive

## Secret Rotation Schedules

| Secret Type | Rotation Period | Max Age |
|------------|----------------|---------|
| API Keys | 90 days | 90 days |
| TLS Certs | 365 days | 365 days |
| Database Passwords | 30 days | 30 days |
| JWT Signing Keys | 180 days | 180 days |

## Output Format

```json
{
  "skill": "compliance-secret-governance",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Storage",
      "status": "pass | fail",
      "details": "Description"
    }
  ],
  "violations": []
}
```

## Success Criteria

- No secret governance violations
- Rotation policies enforced
- Access patterns auditable
