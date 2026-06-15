---
name: deployment-policy
description: "Ensure all deployments comply with organizational policies. Use when validating resource limits, security policies, network policies, or compliance rules."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Deployment Policy Enforcement

> **Load trigger:** `"load deployment-policy skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure all deployments comply with organizational policies.

## Responsibilities

- Validate resource limits
- Validate security policies
- Validate network policies
- Validate compliance rules

## Inputs

- Manifests
- Policy definitions

## Outputs

- `policy-enforcement.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `deployment-policy/opa-validation` | Validate against OPA/Kyverno policies |
| `deployment-policy/freeze-window` | Block deployments during freeze windows |

## Policy Categories

| Category | Rules |
|----------|-------|
| Resource | Limits defined, reasonable values |
| Security | Non-root, read-only fs, no privilege |
| Network | Network policies present |
| Compliance | Labels, annotations, naming |

## Enforcement Rules

- [ ] All manifests validated before deployment
- [ ] Violations block deployment
- [ ] Critical violations require human review
- [ ] Audit trail for all enforcement decisions

## Output Format

```json
{
  "skill": "deployment-policy",
  "status": "pass | fail",
  "policies_checked": 12,
  "violations": [
    {
      "policy": "require-resource-limits",
      "resource": "deployment/my-app",
      "severity": "critical",
      "issue": "No memory limit defined"
    }
  ]
}
```

## Success Criteria

- All policies satisfied
- Violations block deployment
- Audit trail maintained
