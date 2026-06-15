---
name: cost-anomaly
description: "Detect unusual cost spikes or inefficient workloads. Use when analyzing cost trends, detecting anomalies, or recommending optimizations."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Cost Anomaly Detection

> **Load trigger:** `"load cost-anomaly skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Detect unusual cost spikes or inefficient workloads.

## Responsibilities

- Analyze cost trends
- Detect anomalies (unexpected increases)
- Recommend optimizations
- Alert on cost threshold breaches

## Inputs

- Cost data (from Kubecost, OpenCost, or cloud billing)
- Metrics (CPU, memory usage)

## Outputs

- `cost-anomaly.json`

## Detection Rules

### Anomaly Thresholds

| Metric | Threshold | Action |
|--------|-----------|--------|
| Daily cost increase | > 50% vs baseline | Alert |
| Weekly cost increase | > 25% vs baseline | Warn |
| Monthly budget | > 80% consumed | Alert |
| Idle resources | > $100/month wasted | Recommend optimization |

### Anomaly Patterns

| Pattern | Likely Cause |
|---------|-------------|
| Sudden CPU spike | Infinite loop, traffic spike |
| Memory leak | Gradual increase over days |
| Idle expensive resources | Forgotten test environment |
| Storage growth | Log accumulation, uncleaned data |

### Optimization Recommendations

| Finding | Recommendation |
|---------|---------------|
| Overprovisioned pods | Right-size resource limits |
| Idle deployments | Scale to 0 or delete |
| Old snapshots | Clean up old EBS/disk snapshots |
| Unused load balancers | Delete unused LBs |

## Output Format

```json
{
  "skill": "cost-anomaly",
  "status": "clean | anomaly_detected",
  "anomalies": [
    {
      "type": "daily_cost_spike",
      "namespace": "production",
      "current_cost_usd": 250,
      "baseline_cost_usd": 100,
      "increase_percent": 150,
      "suspected_cause": "New deployment with overprovisioned resources",
      "recommendation": "Review resource limits for deployment/api-v2"
    }
  ],
  "optimizations": [
    {
      "resource": "deployment/old-worker",
      "current_cost_usd": 150,
      "potential_savings_usd": 120,
      "recommendation": "Scale to 0 (idle for 30 days)"
    }
  ]
}
```

## Success Criteria

- Accurate cost anomaly detection
- Cost spikes identified and alerted
- Optimization recommendations provided
