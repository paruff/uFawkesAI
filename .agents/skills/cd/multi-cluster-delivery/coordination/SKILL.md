---
name: cluster-rollout-coordination
description: "Coordinate rollouts across multiple clusters. Use when executing rollout per cluster, validating cluster health, or aggregating results."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Cluster Rollout Coordination

> **Load trigger:** `"load cluster-rollout-coordination skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Coordinate rollouts across multiple clusters.

## Responsibilities

- Execute rollout per cluster
- Validate cluster-specific health
- Aggregate results across clusters

## Inputs

- `target-clusters.json`
- Rollout plan

## Outputs

- `cluster-rollout.json`

## Coordination Patterns

### Sequential

```
for each cluster in target_clusters:
    deploy(cluster)
    validate(cluster)
    if failed: rollback(cluster)
```

### Parallel

```
for each cluster in target_clusters (concurrent):
    deploy(cluster)
wait for all:
    validate(cluster) for each
    if failed: rollback(cluster)
```

### Canary-First

```
deploy(target_clusters[0])  # canary cluster
validate(target_clusters[0])
if pass:
    deploy(remaining_clusters)
```

## Validation Rules

- [ ] Each cluster validated independently
- [ ] Cluster failure doesn't block others (configurable)
- [ ] Results aggregated with per-cluster status

## Output Format

```json
{
  "skill": "cluster-rollout-coordination",
  "strategy": "sequential",
  "clusters": [
    {
      "name": "us-east-1",
      "status": "success",
      "duration_seconds": 120,
      "health": "healthy"
    },
    {
      "name": "eu-west-1",
      "status": "success",
      "duration_seconds": 135,
      "health": "healthy"
    }
  ],
  "overall_status": "success"
}
```

## Success Criteria

- All clusters rolled out successfully
- Results aggregated
- Per-cluster health validated
