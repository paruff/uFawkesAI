---
name: cluster-state-validation
description: "Validate that the cluster matches the desired GitOps state. Use when exporting cluster state, normalizing manifests, or comparing with GitOps repo."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Cluster State Validation

> **Load trigger:** `"load cluster-state-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that the cluster matches the desired GitOps state.

## Responsibilities

- Export cluster state
- Normalize manifests
- Compare with GitOps repo

## Inputs

- Cluster
- GitOps repo

## Outputs

- `cluster-state.json`
- `cluster-diff.txt`

## Export Command

```bash
kubectl get all,configmap,secret,ingress -n fawkes -o yaml > cluster-state.yaml
```

## Validation Rules

- [ ] Cluster state exported
- [ ] Manifests normalized
- [ ] No drift detected
- [ ] All resources match Git

## Output Format

```json
{
  "skill": "cluster-state-validation",
  "status": "pass | fail",
  "resources_compared": 50,
  "in_sync": 50,
  "drift": {
    "missing": 0,
    "extra": 0,
    "modified": 0
  }
}
```

## Success Criteria

- No drift
- Cluster matches GitOps state
