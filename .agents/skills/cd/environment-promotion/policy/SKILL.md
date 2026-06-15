---
name: promotion-policy
description: "Ensure promotions follow defined rules and constraints. Use when validating required approvals, test results, freeze windows, or compliance rules."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Promotion Policy Enforcement

> **Load trigger:** `"load promotion-policy skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure promotions follow defined rules and constraints.

## Responsibilities

- Validate required approvals
- Validate required test results
- Validate freeze windows
- Validate compliance rules

## Inputs

- Promotion policy
- CI results
- Environment config

## Outputs

- `promotion-policy.json`

## Policy Rules

### Approval Requirements

| Environment | Approval Required |
|-------------|-------------------|
| dev | No |
| staging | No |
| production | Yes |

### Test Requirements

| Environment | Required Tests |
|-------------|---------------|
| dev | Unit tests |
| staging | Unit + Integration |
| production | Unit + Integration + E2E |

### Freeze Windows

| Window | Effect |
|--------|--------|
| Hard freeze | Block all promotions |
| Soft freeze | Require extra approval |
| Business hours only | Block outside hours |

### Compliance Rules

| Rule | Effect |
|------|--------|
| Security scan passed | Block if failed |
| SBOM present | Block if missing |
| Image signed | Block if unsigned |

## Evaluation Logic

```
for each rule in promotion_rules:
    if rule.type == "approval" and not rule.satisfied:
        return BLOCKED
    if rule.type == "test" and not rule.satisfied:
        return BLOCKED
    if rule.type == "freeze" and rule.active:
        return BLOCKED
return APPROVED
```

## Output Format

```json
{
  "skill": "promotion-policy",
  "status": "approved | blocked",
  "environment": "production",
  "rules": [
    {"type": "approval", "satisfied": true},
    {"type": "test", "satisfied": true},
    {"type": "freeze", "active": false}
  ],
  "blockers": []
}
```

## Success Criteria

- All promotion policies satisfied
- Blockers clearly identified
- Audit trail maintained
