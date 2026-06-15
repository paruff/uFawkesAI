---
name: promotion-criteria
description: "Evaluate whether promotion conditions are satisfied. Use when checking health, metrics, canary score, or policy rules before promotion."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Promotion Criteria Evaluation

> **Load trigger:** `"load promotion-criteria skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Evaluate whether promotion conditions are satisfied.

## Responsibilities

- Check health status
- Check metrics
- Check canary score
- Check policy rules

## Inputs

- Rollout data
- Policy definitions

## Outputs

- `promotion-criteria.json`

## Criteria Matrix

| Criterion | Source | Threshold | Weight |
|-----------|--------|-----------|--------|
| Canary score | canary-analysis | ≥ 80 | Required |
| Health probes | health-monitoring | All passing | Required |
| Error rate | metrics | < 1% | Required |
| Latency p99 | metrics | < 500ms | Required |
| Policy compliance | policy-validation | No violations | Required |
| Approval | manual | Approved | Optional |

## Evaluation Logic

```
for each criterion in required_criteria:
    if criterion.status != "pass":
        return BLOCKED
return APPROVED
```

## Output Format

```json
{
  "skill": "promotion-criteria",
  "status": "approved | blocked",
  "criteria": [
    {
      "name": "canary_score",
      "value": 85,
      "threshold": 80,
      "status": "pass"
    },
    {
      "name": "health",
      "value": "all_passing",
      "status": "pass"
    },
    {
      "name": "policy_compliance",
      "violations": 0,
      "status": "pass"
    }
  ],
  "blockers": []
}
```

## Success Criteria

- Accurate criteria evaluation
- All required criteria checked
- Blockers clearly identified
