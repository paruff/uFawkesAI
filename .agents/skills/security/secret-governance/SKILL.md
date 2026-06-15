---
name: secret-governance
description: "Validate secret usage, storage, and rotation policies. Use when reviewing secret manifests, metadata, or secret management patterns."
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

Validate secret usage, storage, and rotation policies.

## Responsibilities

- Validate secret storage location and encryption
- Validate secret rotation policies
- Validate secret access patterns
- Detect plaintext secrets in manifests or code
- Validate external secret management (Vault, AWS Secrets Manager, etc.)

## Inputs

- Secret manifests (Kubernetes Secrets, external secret references)
- Secret metadata (creation timestamps, labels)
- Source code referencing secrets

## Validation Rules

### Storage

- [ ] Secrets not stored in plaintext in Git repositories
- [ ] Secrets encrypted at rest (etcd encryption or external secret store)
- [ ] External secret operators used where available (Externalsecret, SealedSecret)
- [ ] No `.env` files committed to version control

### Access

- [ ] Secret access restricted via RBAC
- [ ] Service accounts do not have unnecessary secret access
- [ ] Secret access logged/audited where required

### Rotation

- [ ] Rotation policy defined for each secret type
- [ ] No expired certificates or tokens
- [ ] Automated rotation configured where possible

### Patterns

- [ ] No hardcoded secrets in source code
- [ ] No secrets in environment variables exposed to logs
- [ ] Secret references use `secretKeyRef` not inline values
- [ ] No secrets in ConfigMaps unless clearly marked as non-sensitive

## Tools

- `kubectl get secrets -o yaml`
- `grep -r` for plaintext patterns
- Secret scanning tools (gitleaks, truffleHog)

## Output Format

```json
{
  "skill": "secret-governance",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "resource": "<secret name or file>",
      "issue": "Description of the issue",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- No secret governance violations
- No plaintext secrets detected
- Rotation policies defined and enforced
