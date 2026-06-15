---
name: automated-promotion
description: "Promote artifacts automatically when health, metrics, and policies allow. Use when validating promotion criteria, canary score, or policy compliance before promoting."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Automated Promotion

> **Load trigger:** `"load automated-promotion skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Promote artifacts automatically when health, metrics, and policies allow.

## Responsibilities

- Validate promotion criteria
- Validate canary score
- Validate policy compliance
- Promote to next environment

## Inputs

- `canary-score.txt`
- Promotion policy

## Outputs

- `automated-promotion.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `automated-promotion/criteria` | Evaluate promotion conditions |
| `automated-promotion/environment` | Promote to next environment |

## Promotion Flow

```
1. Canary deployed and validated
2. Canary score ≥ 80
3. Policy compliance verified
4. Promotion criteria met
5. GitOps overlay updated
6. Reconciliation triggered
7. Next environment validated
```

## Promotion Criteria

| Criterion | Required | Value |
|-----------|----------|-------|
| Canary score | Yes | ≥ 80 |
| Health checks | Yes | All passing |
| Error rate | Yes | < 1% |
| Policy compliance | Yes | No violations |
| Manual approval | Optional | Configurable |

## Rules

- [ ] All criteria must pass
- [ ] Policy violations block promotion
- [ ] Promotion logged and auditable
- [ ] Rollback possible after promotion

## Success Criteria

- Safe automated promotion
- All criteria validated
- Policy compliance ensured
