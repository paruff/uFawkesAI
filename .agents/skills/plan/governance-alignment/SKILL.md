---
name: governance-alignment
description: "Ensure the plan aligns with platform governance rules. Use when validating tasks against pipeline, manifest, security, and compliance requirements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Governance Alignment

> **Load trigger:** `"load governance-alignment skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure the plan aligns with platform governance rules.

## Responsibilities

- Validate tasks against governance rules
- Validate pipeline requirements are covered
- Validate manifest requirements are covered
- Validate security requirements are covered

## Inputs

- `tasks.json`
- Governance rules (from `AGENTS.md`, policy files)

## Outputs

- `governance-alignment.json`

## Validation Rules

### Pipeline Governance

- [ ] Tasks include pipeline generation when new services are added
- [ ] Security gate stages included in pipeline tasks
- [ ] SBOM generation included for release artifacts
- [ ] Image signing included for container builds

### Manifest Governance

- [ ] Tasks include resource limits for all containers
- [ ] Tasks include securityContext for all pods
- [ ] Tasks include network policies for new namespaces
- [ ] Tasks include proper labeling and annotations

### Security Governance

- [ ] No tasks introduce hardcoded secrets
- [ ] Authentication changes flagged for security review
- [ ] Dependency changes noted for PM sign-off
- [ ] RBAC changes included as explicit tasks

### Compliance Governance

- [ ] Audit logging requirements included
- [ ] Data retention requirements included
- [ ] Access control requirements included

## Output Format

```json
{
  "task_id": "TASK-001",
  "governance_checks": [
    {
      "rule": "pipeline-generation-required",
      "status": "pass | fail | na",
      "details": "Explanation"
    }
  ],
  "violations": [],
  "warnings": []
}
```

## Success Criteria

- No governance violations in the plan
- All required governance tasks included
- Security-sensitive changes flagged for review
