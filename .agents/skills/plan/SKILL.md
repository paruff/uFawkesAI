---
name: plan
description: "Decompose intent into sequenced, bounded tasks. Use when creating task lists, dependency graphs, and effort estimates."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Plan

> **Load trigger:** `"load plan skill"` 
> **DORA:** Cap 3 + 5 (AI-Accessible Internal Data + Small Batches)
> **Token cost:** Low

## Purpose

Decompose intent into sequenced, bounded tasks.

## Responsibilities

- Decompose requirements into tasks
- Map dependencies between tasks
- Estimate effort
- Identify risks
- Match skills to tasks
- Align with governance

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `plan/task-decomposition` | Break down requirements into tasks |
| `plan/dependency-mapping` | Map task dependencies |
| `plan/effort-estimation` | Estimate task effort |
| `plan/risk-identification` | Identify risks early |
| `plan/skill-matching` | Match skills to tasks |
| `plan/governance-alignment` | Ensure governance compliance |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `spec` | Consumes specification |
| `design` | Consumes architecture |

## Inputs

- `specification.md` (from spec)
- `design.md` (from design)
- Existing task patterns

## Outputs

- `tasks.json`
- `dependency-graph.json`
- `effort-estimates.json`

## Planning Rules

### Task Sizing

- [ ] Each task is implementable in a single PR
- [ ] Each task is ≤ 400 changed lines
- [ ] Each task is independently mergeable
- [ ] Dependencies are explicit

### Sequencing

- [ ] Tasks are ordered by dependency
- [ ] Critical path identified
- [ ] Parallel opportunities noted
- [ ] Bottlenecks documented

### Risk Assessment

- [ ] Technical risks identified
- [ ] Dependencies documented
- [ ] Mitigation strategies defined
- [ ] Fallback plans noted

### Skill Matching

- [ ] Each task has a designated agent
- [ ] Skills are loaded on demand
- [ ] No skill conflicts
- [ ] Token budget considered

## Output Format

```json
{
  "skill": "plan",
  "status": "pass | fail",
  "tasks": [
    {
      "id": "TASK-1",
      "title": "Implement auth service",
      "agent": "build",
      "estimated_lines": 150,
      "dependencies": [],
      "skills": ["build", "security"]
    }
  ],
  "dependency_graph": {
    "nodes": ["TASK-1", "TASK-2"],
    "edges": [["TASK-1", "TASK-2"]]
  },
  "summary": {
    "total_tasks": 5,
    "total_estimated_lines": 800,
    "critical_path": ["TASK-1", "TASK-3", "TASK-5"]
  }
}
```

## Success Criteria

- All requirements decomposed into tasks
- Dependencies are clear
- Effort estimates provided
- Risks identified and mitigated
