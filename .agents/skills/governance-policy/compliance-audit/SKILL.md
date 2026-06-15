---
name: compliance-audit
description: "Automate compliance checks and generate audit artifacts. Use when validating compliance rules (SOC2, ISO27001, internal), encryption, or generating audit logs."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Compliance & Audit Automation

> **Load trigger:** `"load compliance-audit skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Automate compliance checks and generate audit artifacts.

## Responsibilities

- Validate compliance rules (SOC2, ISO27001, internal)
- Validate encryption requirements
- Validate secret management
- Generate audit logs and reports

## Inputs

- Manifests
- Pipeline outputs
- Policy definitions

## Outputs

- `compliance-report.json`
- `audit-log.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `compliance-audit/secret-governance` | Validate secret handling |
| `compliance-audit/audit-artifacts` | Generate audit logs and reports |

## Compliance Frameworks

| Framework | Key Requirements |
|-----------|-----------------|
| SOC2 | Access controls, encryption, audit logging |
| ISO27001 | Risk management, security controls |
| GDPR | Data protection, privacy, consent |
| HIPAA | PHI protection, access controls |
| PCI-DSS | Card data protection, network security |

## Validation Rules

### Encryption

- [ ] Data at rest encrypted (etcd, storage)
- [ ] Data in transit encrypted (TLS)
- [ ] Secrets encrypted (not plaintext)
- [ ] Certificates valid and not expired

### Access Controls

- [ ] Authentication required for all access
- [ ] Authorization enforced (RBAC)
- [ ] Audit logging enabled
- [ ] Access reviews conducted

### Data Protection

- [ ] PII identified and protected
- [ ] Data retention policies enforced
- [ ] Data deletion capabilities available
- [ ] Backup and recovery tested

### Audit Logging

- [ ] API access logged
- [ ] Administrative actions logged
- [ ] Security events logged
- [ ] Logs immutable and retained

## Tools

- OPA/Rego for compliance rules
- Kyverno for policy enforcement
- Audit log generators

## Success Criteria

- All compliance checks passed
- Audit artifacts generated
- Violations remediated
