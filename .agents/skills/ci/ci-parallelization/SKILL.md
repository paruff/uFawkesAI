---
name: ci-parallelization
description: "Run CI stages concurrently to reduce total pipeline duration. Use when identifying parallelizable stages, splitting tests, or parallelizing builds."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Parallelization

> **Load trigger:** `"load ci-parallelization skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Run CI stages concurrently to reduce total pipeline duration.

## Responsibilities

- Identify parallelizable stages
- Split tests into shards
- Parallelize builds
- Validate concurrency safety

## Inputs

- `pipeline-spec.yaml`
- Dependency graph

## Outputs

- `parallelization-plan.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-parallelization/test-sharding` | Split tests across CI workers |
| `ci-parallelization/parallel-builds` | Build multiple components concurrently |

## Parallelization Rules

### Identify Parallelizable Stages

- [ ] Stages with no data dependencies can run in parallel
- [ ] Independent services can build concurrently
- [ ] Tests for different modules can run in parallel
- [ ] Lint and test can run in parallel

### Concurrency Safety

- [ ] No shared mutable state between parallel jobs
- [ ] No race conditions in test execution
- [ ] Artifact uploads are atomic
- [ ] Result aggregation is idempotent

## GitHub Actions Matrix Example

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - run: npm test -- --shard=${{ matrix.shard }}/4
```

## Success Criteria

- Reduced CI runtime
- No concurrency issues
- Results correctly aggregated
