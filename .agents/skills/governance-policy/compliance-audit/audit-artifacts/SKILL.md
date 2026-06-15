---
name: audit-artifacts
description: "Generate audit logs and compliance artifacts for external review. Use when producing audit logs, compliance reports, or validating artifact completeness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Audit Artifact Generation

> **Load trigger:** `"load audit-artifacts skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Generate audit logs and compliance artifacts for external review.

## Responsibilities

- Generate audit logs
- Generate compliance reports
- Validate artifact completeness

## Inputs

- Compliance data
- CI/CD run data
- Deployment records

## Outputs

- `audit-log.json`
- `audit-report.json`

## Audit Log Requirements

### Log Entry Format

```json
{
  "timestamp": "2025-01-15T10:30:00Z",
  "event_type": "deployment",
  "actor": "github-actions",
  "resource": "deployment/my-app",
  "namespace": "production",
  "action": "update",
  "result": "success",
  "metadata": {
    "commit_sha": "abc123",
    "image_tag": "v1.2.3"
  }
}
```

### Required Events

| Event Type | Required Fields |
|-----------|----------------|
| Code change | commit_sha, author, branch, files |
| Deployment | resource, namespace, image, actor |
| Secret access | secret_name, namespace, actor, action |
| RBAC change | role, binding, actor, action |
| Config change | resource, namespace, field, old_value, new_value |

## Compliance Report Sections

| Section | Content |
|---------|---------|
| Executive Summary | Overall compliance status |
| Access Controls | RBAC, token, secret governance |
| Data Protection | Encryption, retention, PII handling |
| Infrastructure | K8s security, network policies |
| CI/CD | Pipeline security, artifact integrity |
| Findings | Violations and remediations |

## Validation Rules

- [ ] Audit logs are immutable
- [ ] Audit logs retained for required period
- [ ] Compliance report covers all required areas
- [ ] All findings include remediation

## Output Format

### Audit Log

```json
{
  "audit_log": [
    {
      "timestamp": "2025-01-15T10:30:00Z",
      "event_type": "deployment",
      "actor": "github-actions",
      "resource": "deployment/my-app",
      "action": "update",
      "result": "success"
    }
  ]
}
```

### Audit Report

```json
{
  "audit_report": {
    "generated_at": "2025-01-15T12:00:00Z",
    "period": "2024-Q4",
    "compliance_status": "compliant | non-compliant",
    "sections": {
      "access_controls": { "status": "pass", "findings": 0 },
      "data_protection": { "status": "pass", "findings": 0 },
      "infrastructure": { "status": "fail", "findings": 2 }
    },
    "findings": []
  }
}
```

## Success Criteria

- Complete audit logs generated
- Compliance report covers all required areas
- Artifacts ready for external review
