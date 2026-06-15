---
name: cost-governance
description: "Ensure workloads stay within cost and resource budgets. Use when validating resource requests/limits, detecting cost anomalies, or checking cluster quotas."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Cost & Resource Governance

> **Load trigger:** `"load cost-governance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure workloads stay within cost and resource budgets.

## Responsibilities

- Validate resource requests/limits
- Detect cost anomalies
- Validate cluster resource quotas
- Recommend optimizations

## Inputs

- Manifests
- Cluster metrics
- Cost data

## Outputs

- `cost-report.json`
- `resource-violations.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `cost-governance/resource-limits` | Enforce resource limit requirements |
| `cost-governance/cost-anomaly` | Detect unusual cost spikes |

## Validation Rules

### Resource Limits

- [ ] All workloads have CPU limits
- [ ] All workloads have memory limits
- [ ] Limits reasonable for workload type
- [ ] No unlimited resources

### Cost Controls

- [ ] Namespace quotas defined
- [ ] Cost allocation labels present
- [ ] Expensive resources justified
- [ ] No idle expensive resources

### Quotas

- [ ] ResourceQuota defined per namespace
- [ ] LimitRange defined per namespace
- [ ] Quotas appropriate for environment

## Cost Thresholds

| Environment | Monthly Budget | Alert Threshold |
|-------------|---------------|-----------------|
| Dev | $500 | $400 (80%) |
| Staging | $1,000 | $800 (80%) |
| Production | $5,000 | $4,000 (80%) |

## Tools

- Prometheus for metrics
- Cost analyzer (Kubecost, OpenCost)
- OPA/Kyverno for policy enforcement

## Success Criteria

- No cost or resource violations
- Resource limits enforced
- Cost anomalies detected
