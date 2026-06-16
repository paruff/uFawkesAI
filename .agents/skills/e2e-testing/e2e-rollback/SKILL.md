---
name: e2e-rollback
description: "Validate rollback behavior under deployment failure. Use when triggering failed deployment, validating rollback, validating GitOps state consistency, or checking cluster state consistency."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: E2E Rollback Testing

> **Load trigger:** `"load e2e-rollback skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate rollback behavior under deployment failure.

## Responsibilities

- Trigger failed deployment
- Validate rollback
- Validate GitOps state consistency
- Validate cluster state consistency

## Inputs

- Failure scenario

## Outputs

- `rollback-report.json`
- `cluster-diff.txt`

## Sub-Skills

| Skill                           | Purpose                    |
| ------------------------------- | -------------------------- |
| `e2e-rollback/trigger`          | Trigger controlled failure |
| `e2e-rollback/state-validation` | Validate rollback state    |

## Rollback Flow

```
1. Deploy invalid manifest
2. Controller detects failure
3. Controller triggers rollback
4. Previous version restored
5. GitOps state consistent
6. Cluster state consistent
```

## Validation Rules

- [ ] Rollback triggered correctly
- [ ] Previous version restored
- [ ] GitOps state consistent
- [ ] Cluster state consistent
- [ ] No drift

## Output Format

```json
{
  "skill": "e2e-rollback",
  "status": "pass | fail",
  "trigger": { "invalid_manifest_injected": true },
  "rollback": { "triggered": true, "version": "v1.2.3", "time_s": 30 },
  "gitops_state": "consistent",
  "cluster_state": "consistent",
  "drift": "none"
}
```

## Success Criteria

- Successful rollback
- No drift
