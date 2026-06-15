---
name: dependency-mapping
description: "Determine correct ordering and dependencies between tasks. Use when building a dependency graph for sequenced execution."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dependency Mapping

> **Load trigger:** `"load dependency-mapping skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Determine the correct ordering and dependencies between tasks.

## Responsibilities

- Identify task prerequisites
- Identify parallelizable tasks
- Build dependency graph
- Detect circular dependencies

## Inputs

- `tasks.json`

## Outputs

- `dependency-graph.json`

## Mapping Rules

### Prerequisite Detection

- [ ] Task B cannot start until Task A completes if B uses A's output
- [ ] Shared files imply ordering (last-writer-wins)
- [ ] Tests depend on implementation tasks
- [ ] Deployment depends on build and test tasks

### Parallelism Detection

- [ ] Tasks with no shared dependencies can run in parallel
- [ ] Independent modules can be built concurrently
- [ ] Tests for different features can run in parallel

### Circular Dependency Detection

- [ ] No task depends on itself (directly or transitively)
- [ ] No circular chains exist in the dependency graph
- [ ] If cycles detected, flag for human resolution

## Graph Format

```json
{
  "nodes": [
    {
      "task_id": "TASK-001",
      "title": "Task title",
      "estimated_lines": 150
    }
  ],
  "edges": [
    {
      "from": "TASK-001",
      "to": "TASK-002",
      "reason": "TASK-002 uses output from TASK-001"
    }
  ],
  "parallel_groups": [
    ["TASK-003", "TASK-004"]
  ],
  "critical_path": ["TASK-001", "TASK-002", "TASK-005"]
}
```

## Success Criteria

- Dependency graph is valid and complete
- No circular dependencies
- Critical path identified
- Parallelizable tasks identified
