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

> **Load trigger:** `"load plan skill"` > **DORA:** AI Capability 3: AI-accessible internal data + AI Capability 5: Working in small batches
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

| Skill                       | Purpose                            |
| --------------------------- | ---------------------------------- |
| `plan/task-decomposition`   | Break down requirements into tasks |
| `plan/dependency-mapping`   | Map task dependencies              |
| `plan/effort-estimation`    | Estimate task effort               |
| `plan/risk-identification`  | Identify risks early               |
| `plan/governance-alignment` | Ensure governance compliance       |

## Dependencies

| Skill    | Relationship           |
| -------- | ---------------------- |
| `spec`   | Consumes specification |
| `design` | Consumes architecture  |

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

### 6. Model Routing (from model-routing skill)

# Skill: Model Routing

> **Load trigger:** `"load model-routing skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low

## Purpose

Route tasks to the optimal model and mode based on complexity, cost, and requirements.

## Responsibilities

- Determine optimal mode (Ask/Edit/Agent)
- Select appropriate model tier (Low/Medium/High)
- Validate scope before Agent Mode
- Estimate complexity and cost
- Provide local model alternatives

## Decision: Mode First

| Task type                 | Mode                            | Why                       |
| ------------------------- | ------------------------------- | ------------------------- |
| Question / explanation    | **Ask Mode**                    | 60–90% cheaper than Agent |
| Single-file targeted edit | **Edit Mode**                   | 30–50% cheaper than Agent |
| Multi-file feature        | **Agent Mode**                  | Correct choice            |
| Architecture / security   | **Agent Mode + frontier model** | Worth the cost            |

## Decision: Model Second

| Complexity | Model tier             | Examples                             |
| ---------- | ------------------------ | ------------------------------------- |
| Low        | Fast/cheap tier        | Q&A, docs, simple fixes              |
| Medium     | Mid tier               | Feature implementation               |
| High       | Frontier/premium tier  | Architecture, security, rework > 20% |

## Scope Check (Required Before Agent Mode)

Before proceeding with any Agent Mode task, state:

1. Files I will READ: [list]
2. Files I will WRITE: [list]
3. My plan: [2 sentences]
4. Estimated complexity: low / medium / high

Then wait for human confirmation.

## Local Model Alternative (Zero Credit Cost)

For docs, changelogs, simple explanations — a small local model via Ollama is
sufficient. Use hosted credits for tasks requiring frontier/premium tier quality.

## Full Guide

See `docs/MODEL_ROUTING_GUIDE.md` for decision tree, cost table, and anti-patterns.
