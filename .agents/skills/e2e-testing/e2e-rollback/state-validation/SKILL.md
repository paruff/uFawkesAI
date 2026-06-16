---
name: rollback-state-validation
description: "Validate that the cluster and GitOps repo return to a consistent state after rollback. Use when validating GitOps commit history, cluster state, or checking no drift."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Rollback State Validation

> **Load trigger:** `"load rollback-state-validation skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate that the cluster and GitOps repo return to a consistent state after rollback.

## Responsibilities

- Validate GitOps commit history
- Validate cluster state
- Validate no drift

## Inputs

- GitOps repo
- Cluster

## Outputs

- `rollback-state.json`
- `cluster-diff.txt`

## Validation Rules

- [ ] GitOps commit history shows rollback
- [ ] Cluster state matches previous version
- [ ] No drift detected
- [ ] All pods running previous version

## Output Format

```json
{
  "skill": "rollback-state-validation",
  "status": "pass | fail",
  "gitops_commits": {
    "total": 10,
    "rollback_commit": "def456",
    "latest_version": "v1.2.3"
  },
  "cluster_state": {
    "deployment_version": "v1.2.3",
    "pods_running": 3,
    "pods_ready": 3
  },
  "drift": "none"
}
```

## Success Criteria

- No drift
- Correct rollback state
