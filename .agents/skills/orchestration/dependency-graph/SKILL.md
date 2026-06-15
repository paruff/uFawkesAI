---
name: orchestration/dependency-graph
description: Builds a directed acyclic graph of task dependencies for multi-agent workflows. Use when routing multi-step tasks that require sequencing across multiple agents.
license: MIT
compatibility: OpenCode, Claude Code, GitHub Copilot, Cursor
metadata:
  author: paruff
  suite: uFawkesAI
  dora_cap: "Cap 3 — Context Engineering"
---

# Dependency Graph Skill

Construct a dependency graph for multi-agent task execution and produce an optimal execution order.

## When to Load

- The task requires multiple specialist agents in sequence
- You need to determine which agents can run in parallel vs. serial
- A previous handoff's dependency field is set to something other than "none"

## How It Works

1. Parse the task into sub-tasks
2. For each sub-task, identify the best agent via the routing table or capability-matching skill
3. Look up each agent's `consumes_from` in the capability registry
4. Build a directed graph (agent A → agent B means A must complete before B starts)
5. Topologically sort to produce execution order
6. Validate no circular dependencies

## Graph Rules

```
Rule 1 — consumes_from defines edges
  If agent B.consumes_from includes agent A: A → B (A before B)

Rule 2 — Known sequence (from the lifecycle):
  spec → design → planner → [build | test] →
  [test-execution | review | build-review | security] → pipe → obs → dora

  Note: test (TDD) consumes from spec only and can run in parallel with build.

Rule 3 — Parallel branches:
  After planner, build and test can run in parallel.
  After build, test-execution, review, build-review, and security
  can run in parallel. The slowest path determines total wall time.

Rule 4 — Circular dependency check:
  Before returning, run DFS cycle detection. If a cycle exists,
  report it and ask the human to break it.
```

## Output

An execution plan:

```yaml
execution_order:
  - step: 1
    agent: spec
    parallel_with: []
    depends_on: []
  - step: 2
    agent: design
    parallel_with: []
    depends_on: [spec]
  - step: 3
    agent: planner
    parallel_with: []
    depends_on: [spec, design]
  - step: 4
    agent: build
    parallel_with: [test]
    depends_on: [planner]
  - step: 5
    agent: test
    parallel_with: [build]
    depends_on: [planner]
  - step: 6
    agent: test-execution
    parallel_with: [review, build-review, security]
    depends_on: [build]
  - step: 7
    agent: review
    parallel_with: [test-execution, build-review, security]
    depends_on: [build]
  - step: 8
    agent: build-review
    parallel_with: [test-execution, review, security]
    depends_on: [build]
  - step: 9
    agent: security
    parallel_with: [test-execution, review, build-review]
    depends_on: [build]
  - step: 10
    agent: pipe
    parallel_with: [obs]
    depends_on: [build]
  - step: 11
    agent: obs
    parallel_with: [pipe]
    depends_on: [build]
  - step: 12
    agent: dora
    depends_on: [pipe, obs]
```

## Cycle Detection

If `agent B.consumes_from` references an agent that transitively depends on B, report:

```
⚠ CIRCULAR DEPENDENCY DETECTED: A → B → C → A
Break the cycle by: [specific suggestion]
```
