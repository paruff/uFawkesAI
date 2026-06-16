---
name: load-testing
description: "Load and stress testing covering GitOps commit throughput, pipeline throughput, registry load, and system-level stress scenarios."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Load Testing

> **Load trigger:** `"load load-testing skill"`
> **DORA:** Cap 6 (Reliability)
> **Token cost:** High

## Purpose

Validate system behavior under load including GitOps commit throughput, pipeline throughput, registry load, and system-level stress scenarios.

## Responsibilities

- Measure GitOps commit rate and repo growth
- Test pipeline throughput under concurrency
- Stress registry with concurrent pushes/pulls
- Profile resource usage under load
- Identify degradation patterns

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `load-testing/obs-gitops-load` | Measure OBS GitOps update behavior |
| `load-testing/pipeline-throughput` | Measure pipeline execution under load |
| `load-testing/registry-load` | Stress registry with concurrent operations |
| `load-testing/system-stress` | Push system to and beyond limits |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `build` | Tests build system under load |
| `delivery` | Tests deployment under load |

## Output Format

```json
{
  "skill": "load-testing",
  "status": "pass | fail",
  "metrics": {
    "gitops_commits_per_min": 45,
    "pipeline_throughput": 12,
    "registry_push_p99_ms": 2500,
    "system_saturation": 0.72
  },
  "degradation_point": {
    "concurrency": 50,
    "latency_spike": true
  }
}
```
