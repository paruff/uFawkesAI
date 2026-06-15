---
name: ci-performance
description: "Continuously optimize CI runtime and resource usage. Use when analyzing stage timings, identifying bottlenecks, or tracking CI performance over time."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Performance Optimization

> **Load trigger:** `"load ci-performance skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Continuously optimize CI runtime and resource usage.

## Responsibilities

- Analyze stage timings
- Identify bottlenecks
- Recommend optimizations
- Track performance over time

## Inputs

- `stage-timings.json`
- Historical timing data

## Outputs

- `ci-performance.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-performance/bottlenecks` | Identify slowest CI stages |
| `ci-performance/regression` | Detect runtime regressions |

## Performance Targets

| Metric | Target | Action If Exceeded |
|--------|--------|-------------------|
| Total CI time | < 10 min | Investigate bottlenecks |
| Lint stage | < 2 min | Optimize rules |
| Test stage | < 5 min | Shard or parallelize |
| Build stage | < 3 min | Optimize layers/cache |

## Optimization Strategies

| Bottleneck | Strategy |
|-----------|----------|
| Slow tests | Shard across workers |
| Slow builds | Docker layer caching |
| Sequential stages | Parallelize independent stages |
| Dependency install | Cache dependencies |
| Large artifacts | Compress, reduce scope |

## Performance Report

```json
{
  "run_id": "abc123",
  "total_duration_ms": 480000,
  "stages": [
    {"name": "lint", "duration_ms": 15000, "status": "pass"},
    {"name": "test", "duration_ms": 240000, "status": "pass"},
    {"name": "build", "duration_ms": 120000, "status": "pass"},
    {"name": "deploy", "duration_ms": 60000, "status": "pass"}
  ],
  "bottlenecks": ["test"],
  "recommendations": ["Shard test stage across 4 workers"]
}
```

## Success Criteria

- CI duration within targets
- Bottlenecks identified
- Optimizations recommended
