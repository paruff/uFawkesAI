---
name: policy-validation
description: "Validate build output against organizational security policies. Use when validating manifests, pipelines, directory structure, and compliance rules."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Policy-as-Code Validation

> **Load trigger:** `"load policy-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate build output against organizational security policies defined as code.

## Responsibilities

- Validate manifests against OPA/Gatekeeper policies
- Validate pipelines against policy rules
- Validate directory structure conventions
- Validate compliance rules (SOC2, HIPAA, PCI-DSS where applicable)

## Inputs

- Build output (code, manifests, pipelines)
- Policy definitions (OPA Rego, Kyverno policies, custom rules)
- Compliance requirements

## Validation Rules

### Manifest Compliance

- [ ] All resources have required labels
- [ ] All resources have owner/team annotations
- [ ] Namespace conventions followed
- [ ] Resource naming conventions followed
- [ ] No resources outside approved namespaces

### Pipeline Compliance

- [ ] Required stages present (lint, test, security-scan)
- [ ] Deployment requires approval
- [ ] Rollback mechanism defined
- [ ] Monitoring/alerting hooks present

### Directory Structure

- [ ] Code organized per project conventions
- [ ] Infrastructure code in designated directories
- [ ] Policy files in designated location
- [ ] Documentation current and complete

### Organizational Policies

- [ ] No resources deployed without cost allocation labels
- [ ] Disaster recovery requirements met
- [ ] Backup policies enforced where required
- [ ] Retention policies applied to data stores

## Tools

- OPA/Rego for policy evaluation
- Kyverno for Kubernetes policy validation
- Custom policy scripts
- Conftest for manifest testing

## Output Format

```json
{
  "skill": "policy-validation",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "resource": "<resource or file name>",
      "policy": "<policy name>",
      "issue": "Description of the violation",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- No policy violations
- All organizational policies enforced
- Compliance requirements met
