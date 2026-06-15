---
name: multi-cluster-delivery
description: "Deliver artifacts across multiple clusters and regions. Use when identifying target clusters, validating health, applying rollout strategy per cluster, or aggregating results."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Multi-Cluster Delivery

> **Load trigger:** `"load multi-cluster-delivery skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Deliver artifacts across multiple clusters and regions.

## Responsibilities

- Identify target clusters
- Validate cluster health
- Apply rollout strategy per cluster
- Aggregate results

## Inputs

- Cluster list
- Rollout plan

## Outputs

- `multi-cluster-report.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `multi-cluster-delivery/target-selection` | Determine target clusters |
| `multi-cluster-delivery/coordination` | Coordinate rollouts across clusters |

## Delivery Strategies

| Strategy | Description | Risk |
|----------|-------------|------|
| Sequential | One cluster at a time | Low |
| Parallel | All clusters simultaneously | Medium |
| Canary-then-all | Canary one, then all | Low |
| Regional | By region, one at a time | Low |

## Cluster Health Checks

| Check | Required |
|-------|----------|
| API server reachable | Yes |
| Nodes ready | Yes |
| System pods healthy | Yes |
| Sufficient resources | Yes |

## Rules

- [ ] Clusters validated before deployment
- [ ] Failed cluster doesn't block others (configurable)
- [ ] Results aggregated per cluster
- [ ] Rollback per cluster on failure

## Success Criteria

- Successful multi-cluster delivery
- All target clusters updated
- Results aggregated
