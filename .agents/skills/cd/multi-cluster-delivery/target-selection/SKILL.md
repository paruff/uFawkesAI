---
name: cluster-target-selection
description: "Determine which clusters receive the deployment. Use when reading cluster config, validating readiness, or selecting eligible clusters."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Cluster Target Selection

> **Load trigger:** `"load cluster-target-selection skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Determine which clusters receive the deployment.

## Responsibilities

- Read cluster configuration
- Validate cluster readiness
- Select eligible clusters

## Inputs

- Cluster configuration
- Deployment scope

## Outputs

- `target-clusters.json`

## Selection Rules

### Inclusion Criteria

| Criterion | Required |
|-----------|----------|
| Cluster in scope | Yes |
| Cluster healthy | Yes |
| Sufficient resources | Yes |
| Network accessible | Yes |

### Exclusion Criteria

| Criterion | Effect |
|-----------|--------|
| Cluster in freeze window | Excluded |
| Cluster maintenance mode | Excluded |
| Cluster unhealthy | Excluded |
| Insufficient resources | Excluded |

### Scope Definitions

| Scope | Clusters |
|-------|----------|
| All | Every cluster in config |
| Region | Clusters in specified region |
| Environment | Clusters for specified env |
| Custom | Explicitly listed clusters |

## Output Format

```json
{
  "skill": "cluster-target-selection",
  "scope": "all",
  "total_clusters": 5,
  "eligible_clusters": [
    {"name": "us-east-1", "status": "healthy", "resources": "sufficient"},
    {"name": "eu-west-1", "status": "healthy", "resources": "sufficient"}
  ],
  "excluded_clusters": [
    {"name": "ap-south-1", "reason": "in freeze window"}
  ]
}
```

## Success Criteria

- Correct cluster selection
- Health validated
- Exclusions documented
