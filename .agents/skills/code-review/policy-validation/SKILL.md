---
name: policy-validation
description: "Validate build output against organizational policies. Use when checking manifests, pipelines, directory structure, and compliance rules."
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

Validate build output against organizational policies defined as code.

## Responsibilities

- Validate manifests against OPA/Gatekeeper policies
- Validate pipelines against policy rules
- Validate directory structure conventions
- Validate compliance rules

## Inputs

- Build output
- Policy definitions (OPA Rego, Kyverno policies)

## Outputs

- `policy-report.json`

## Validation Rules

### Manifest Compliance

- [ ] All resources have required labels
- [ ] All resources have owner annotations
- [ ] Namespace conventions followed
- [ ] Resource naming conventions followed

### Pipeline Compliance

- [ ] Required stages present
- [ ] Deployment requires approval
- [ ] Rollback mechanism defined

### Directory Structure

- [ ] Code organized per conventions
- [ ] Infrastructure code in designated directories
- [ ] Policy files in designated location

### Organizational Policies

- [ ] Cost allocation labels present
- [ ] Disaster recovery requirements met
- [ ] Backup policies enforced
- [ ] Retention policies applied

## Tools

- OPA/Rego for policy evaluation
- Kyverno for Kubernetes policies
- Conftest for manifest testing

## Output Format

```json
{
  "skill": "policy-validation",
  "status": "pass | fail",
  "policies_checked": 12,
  "violations": [
    {
      "severity": "medium",
      "policy": "required-labels",
      "resource": "deployment/my-app",
      "issue": "Missing 'team' label",
      "fix": "Add label team: <team-name>"
    }
  ]
}
```

## Success Criteria

- No policy violations
- All organizational policies enforced
- Compliance requirements met
