---
name: test-sharding
description: "Split tests across multiple CI workers. Use when partitioning test suites, balancing shard sizes, or aggregating shard results."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Test Sharding

> **Load trigger:** `"load test-sharding skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Split tests across multiple CI workers.

## Responsibilities

- Partition test suite into balanced shards
- Balance shard sizes (equal test count)
- Aggregate results from all shards
- Detect missing tests after sharding

## Inputs

- Test files
- Test configuration

## Outputs

- `shard-plan.json`

## Sharding Strategies

| Strategy | When to Use |
|----------|-------------|
| File-based | Tests in separate files, equal sizes |
| Time-based | Tests have varied durations |
| Name-based | Consistent shard assignment |

## Sharding Rules

### Balance

- [ ] Each shard has roughly equal test count
- [ ] Each shard has roughly equal estimated duration
- [ ] No shard exceeds time limit
- [ ] Minimum 2 shards for parallelization

### Completeness

- [ ] All tests assigned to exactly one shard
- [ ] No tests duplicated across shards
- [ ] No tests missed after sharding

### Aggregation

- [ ] All shard results collected
- [ ] Pass/fail counts aggregated
- [ ] Failure details merged
- [ ] Coverage merged across shards

## Tool Examples

| Tool | Sharding Support |
|------|-----------------|
| Vitest | `--shard=1/4` |
| Jest | `--shard=1/4` |
| Pytest | `pytest-xdist -n auto` |
| Go test | Manual file splitting |

## Success Criteria

- Balanced shards across workers
- All tests accounted for
- Results correctly aggregated
