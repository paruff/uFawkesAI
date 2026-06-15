---
name: canary-scoring
description: "Compute a weighted score determining canary success. Use when applying scoring rules, weighting metrics, or producing pass/fail decisions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Canary Scoring

> **Load trigger:** `"load canary-scoring skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Compute a weighted score determining canary success.

## Responsibilities

- Apply scoring rules
- Weight metrics
- Produce pass/fail decision

## Inputs

- `metric-comparison.json`

## Outputs

- `canary-score.txt`

## Scoring Weights

| Metric | Weight | Scoring |
|--------|--------|---------|
| Latency p99 | 30% | Inverse of delta |
| Error rate | 30% | Inverse of delta |
| Saturation | 20% | Inverse of delta |
| Success rate | 20% | Direct value |

## Score Calculation

```
score = (latency_score * 0.3) + (error_score * 0.3) + 
        (saturation_score * 0.2) + (success_score * 0.2)
```

### Score Interpretation

| Score | Decision | Action |
|-------|----------|--------|
| ≥ 80 | PASS | Promote |
| 60-79 | WARN | Hold, investigate |
| < 60 | FAIL | Rollback |

### Individual Metric Scores

| Delta | Score |
|-------|-------|
| Canary ≤ baseline | 100 |
| Canary ≤ 1.05x baseline | 80 |
| Canary ≤ 1.1x baseline | 60 |
| Canary ≤ 1.2x baseline | 40 |
| Canary > 1.2x baseline | 0 |

## Output Format

```json
{
  "skill": "canary-scoring",
  "score": 85,
  "decision": "pass",
  "breakdown": {
    "latency_score": 80,
    "error_score": 90,
    "saturation_score": 85,
    "success_score": 95
  },
  "thresholds": {
    "pass": 80,
    "warn": 60,
    "fail": 0
  }
}
```

## Success Criteria

- Deterministic canary score
- Clear pass/fail decision
- Score breakdown provided
