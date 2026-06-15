---
name: canary-analysis
description: "Compare canary vs baseline performance using metrics and statistical tests. Use when collecting metrics, running statistical comparison, or producing canary scores."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Canary Analysis

> **Load trigger:** `"load canary-analysis skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Compare canary vs baseline performance using metrics and statistical tests.

## Responsibilities

- Collect baseline metrics
- Collect canary metrics
- Run statistical comparison
- Produce canary score

## Inputs

- Metrics (latency, errors, saturation)
- Rollout plan

## Outputs

- `canary-analysis.json`
- `canary-score.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `canary-analysis/metric-comparison` | Compare metrics between baseline and canary |
| `canary-analysis/scoring` | Compute weighted canary score |

## Analysis Rules

### Metrics to Compare

| Metric | Weight | Pass Criteria |
|--------|--------|---------------|
| Latency p99 | 30% | Canary ≤ baseline |
| Error rate | 30% | Canary ≤ baseline |
| Saturation | 20% | Canary ≤ baseline |
| Traffic success | 20% | Canary ≥ baseline |

### Statistical Requirements

- [ ] Minimum 5 minutes of data per version
- [ ] Statistical significance p < 0.05
- [ ] Sample size sufficient for confidence

## Output Format

```json
{
  "skill": "canary-analysis",
  "baseline_version": "v1.2.2",
  "canary_version": "v1.2.3",
  "analysis_duration_minutes": 5,
  "results": {
    "latency": {"baseline_ms": 250, "canary_ms": 260, "status": "pass"},
    "error_rate": {"baseline": 0.1, "canary": 0.12, "status": "pass"},
    "saturation": {"baseline": 45, "canary": 48, "status": "pass"}
  },
  "canary_score": 85,
  "decision": "promote"
}
```

## Success Criteria

- Accurate canary scoring
- Statistical significance validated
- Clear promote/rollback decision
