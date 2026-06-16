---
name: effort-estimation
description: "Estimate complexity and effort for each task. Use when planning capacity and identifying high-risk or long-pole tasks."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Effort Estimation

> **Load trigger:** `"load effort-estimation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Estimate complexity and effort for each task.

## Responsibilities

- Estimate time to complete each task
- Estimate complexity (simple / moderate / complex)
- Identify high-risk tasks
- Identify long-pole tasks on the critical path

## Inputs

- `tasks.json`

## Outputs

- `effort-estimates.json`

## Estimation Factors

### Complexity Levels

| Level    | Description                               | Typical Lines | Typical Time |
| -------- | ----------------------------------------- | ------------- | ------------ |
| Simple   | Single file, clear pattern                | < 100         | < 1 hour     |
| Moderate | Multiple files, some decisions            | 100–300       | 1–3 hours    |
| Complex  | Multiple systems, architectural decisions | 300–400       | 3–6 hours    |

### Risk Factors

- [ ] New technology or library usage → +1 complexity level
- [ ] Multiple integration points → +1 complexity level
- [ ] Security-sensitive code → flag for review
- [ ] No existing tests in area → flag for test generation
- [ ] External API dependency → flag for mock/stub

### Long-Pole Detection

- [ ] Tasks on the critical path are flagged
- [ ] Tasks with most downstream dependencies are flagged
- [ ] Tasks requiring external approval are flagged

## Output Format

```json
{
  "task_id": "TASK-001",
  "title": "Task title",
  "complexity": "simple | moderate | complex",
  "estimated_lines": 150,
  "estimated_hours": 2,
  "risk_factors": ["multiple integration points"],
  "is_long_pole": false,
  "is_on_critical_path": true
}
```

## Success Criteria

- Estimates are consistent and reasonable
- High-risk tasks identified
- Long-pole tasks identified
- No task estimated above 400 lines
