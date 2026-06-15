---
name: ci-bottlenecks
description: "Identify slowest CI stages and steps. Use when analyzing timing data to rank bottlenecks and recommend fixes."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Bottleneck Detection

> **Load trigger:** `"load ci-bottlenecks skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Identify slowest CI stages and steps.

## Responsibilities

- Analyze timing data
- Rank slowest steps
- Recommend fixes

## Inputs

- `stage-timings.json`
- Step-level timing data

## Outputs

- `bottlenecks.json`

## Detection Rules

### Bottleneck Thresholds

| Duration | Classification | Priority |
|----------|---------------|----------|
| > 5 min | Critical bottleneck | HIGH |
| 3-5 min | Major bottleneck | MEDIUM |
| 1-3 min | Minor bottleneck | LOW |
| < 1 min | Acceptable | NONE |

### Analysis

- [ ] Rank stages by duration (descending)
- [ ] Identify stages > 5 minutes
- [ ] Identify stages with high variance
- [ ] Identify stages with high failure rates

### Fix Recommendations

| Bottleneck | Recommendation |
|-----------|----------------|
| Slow tests | Shard across workers |
| Slow builds | Docker layer caching |
| Slow installs | Cache dependencies |
| Slow deploys | Parallelize |

## Output Format

```json
{
  "bottlenecks": [
    {
      "stage": "test",
      "duration_ms": 240000,
      "rank": 1,
      "percentage_of_total": 50,
      "recommendation": "Shard across 4 workers to reduce to ~60s"
    },
    {
      "stage": "build",
      "duration_ms": 120000,
      "rank": 2,
      "percentage_of_total": 25,
      "recommendation": "Enable Docker layer caching"
    }
  ]
}
```

## Success Criteria

- Bottlenecks identified and ranked
- Recommendations provided
