---
name: drift-diff-engine
description: "Compute differences between Git and cluster state. Use when comparing normalized manifests, highlighting missing/extra/changed fields, or producing machine-readable diff."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Drift Diff Engine

> **Load trigger:** `"load drift-diff-engine skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Compute differences between Git and cluster state.

## Responsibilities

- Compare normalized manifests
- Highlight missing, extra, or changed fields
- Produce machine-readable diff

## Inputs

- `cluster-snapshot.yaml`
- `git-manifests/`

## Outputs

- `drift-diff.txt`
- `drift.json`

## Diff Process

```
1. Normalize Git manifests (remove volatile fields)
2. Normalize cluster snapshot (remove volatile fields)
3. Compare resource by resource
4. Highlight differences
5. Produce diff output
```

## Validation Rules

- [ ] All resources compared
- [ ] Diff accurate
- [ ] No false positives
- [ ] Machine-readable output

## Output Format

```json
{
  "skill": "drift-diff-engine",
  "status": "clean | drift",
  "resources_compared": 50,
  "drifts": [
    {
      "resource": "deployment/my-app",
      "type": "modified",
      "changes": [
        {"field": "spec.replicas", "git": "3", "cluster": "5"}
      ]
    },
    {
      "resource": "configmap/my-config",
      "type": "missing_in_cluster",
      "changes": []
    }
  ]
}
```

## Success Criteria

- Accurate diff output
- No false positives
