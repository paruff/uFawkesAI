---
name: governance-enforcement
description: "Ensure build output complies with platform governance. Use when validating manifests, pipelines, directory structure, and naming conventions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Governance Enforcement

> **Load trigger:** `"load governance-enforcement skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure build output complies with platform governance.

## Responsibilities

- Validate manifests against policies
- Validate pipelines against requirements
- Validate directory structure
- Validate naming conventions

## Inputs

- Build output (code, manifests, pipelines)
- Governance rules

## Outputs

- `governance-report.json`

## Enforcement Rules

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

### Naming Conventions

- [ ] File names follow kebab-case or camelCase
- [ ] Resource names follow DNS naming rules
- [ ] Label values follow naming conventions
- [ ] No special characters in resource names

## Tools

- OPA/Rego for policy evaluation
- Kyverno for Kubernetes policy validation
- Custom policy scripts
- `conftest` for manifest testing

## Output Format

```json
{
  "skill": "governance-enforcement",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "resource": "<resource or file name>",
      "rule": "<rule name>",
      "issue": "Description of the violation",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- No governance violations
- All organizational policies enforced
- Naming conventions followed
