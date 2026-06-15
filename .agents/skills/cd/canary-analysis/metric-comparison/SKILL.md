---
name: metric-comparison
description: "Compare key metrics between baseline and canary. Use when comparing latency, error rate, saturation, or traffic between versions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Metric Comparison

> **Load trigger:** `"load metric-comparison skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Compare key metrics between baseline and canary.

## Responsibilities

- Compare latency (p50, p95, p99)
- Compare error rate
- Compare saturation (CPU, memory)
- Compare traffic success rate

## Inputs

- Baseline metrics
- Canary metrics

## Outputs

- `metric-comparison.json`

## Comparison Rules

### Latency

| Metric | Pass | Warn | Fail |
|--------|------|------|------|
| p50 | Canary ≤ baseline | Canary ≤ 1.1x baseline | Canary > 1.1x baseline |
| p95 | Canary ≤ baseline | Canary ≤ 1.1x baseline | Canary > 1.1x baseline |
| p99 | Canary ≤ baseline | Canary ≤ 1.2x baseline | Canary > 1.2x baseline |

### Error Rate

| Comparison | Result |
|-----------|--------|
| Canary < baseline | PASS |
| Canary = baseline | PASS |
| Canary > baseline | FAIL |

### Saturation

| Metric | Pass | Fail |
|--------|------|------|
| CPU | Canary ≤ baseline + 5% | Canary > baseline + 5% |
| Memory | Canary ≤ baseline + 5% | Canary > baseline + 5% |

## Output Format

```json
{
  "skill": "metric-comparison",
  "metrics": [
    {
      "name": "latency_p99",
      "baseline": 250,
      "canary": 260,
      "delta_percent": 4,
      "status": "pass"
    },
    {
      "name": "error_rate",
      "baseline": 0.1,
      "canary": 0.12,
      "delta_percent": 20,
      "status": "pass"
    }
  ]
}
```

## Success Criteria

- Accurate metric comparison
- Delta percentages calculated
- Status correctly determined
