---
name: task-decomposition
description: "Break specifications and designs into clear, actionable tasks and subtasks. Use when decomposing work into agent-assignable units."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Task Decomposition

> **Load trigger:** `"load task-decomposition skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Break the specification and design into clear, actionable tasks and subtasks.

## Responsibilities

- Identify major work units from spec and design
- Break work into atomic, buildable subtasks
- Ensure each task maps to acceptance criteria
- Produce a structured task list

## Inputs

- `specification.md`
- `design.md`

## Outputs

- `tasks.json`

## Decomposition Rules

### Atomicity

- [ ] Each task is independently completable
- [ ] Each task produces a verifiable output
- [ ] Each task can be implemented in a single PR (≤ 400 lines)
- [ ] No task depends on work from multiple other tasks simultaneously

### Completeness

- [ ] All spec requirements covered by tasks
- [ ] All design decisions reflected in tasks
- [ ] No orphaned requirements (requirement → task mapping clear)
- [ ] Edge cases and error handling included as tasks

### Clarity

- [ ] Each task has a single, unambiguous goal
- [ ] Acceptance criteria are testable
- [ ] File paths and components are named explicitly
- [ ] Constraints and out-of-scope items documented

## Task Format

```json
{
  "task_id": "TASK-NNN",
  "title": "Short imperative title",
  "description": "What this task accomplishes",
  "acceptance_criteria": ["Specific, testable assertion"],
  "context_files": ["path/to/file — reason"],
  "estimated_lines": 150,
  "assigned_agent": "build | test | docs | security",
  "depends_on": ["TASK-NNN"],
  "dora_capability": "Cap N — Name"
}
```

## Success Criteria

- Tasks are complete, atomic, and unambiguous
- Every spec requirement maps to at least one task
- No task exceeds 400 changed lines
