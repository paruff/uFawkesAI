---
name: skill-matching
description: "Map tasks to the skills required by the Build agent. Use when assigning capabilities to each task in the plan."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Skill Matching

> **Load trigger:** `"load skill-matching skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Map tasks to the skills required by the Build agent.

## Responsibilities

- Identify required skills per task
- Validate skill availability in the skill registry
- Produce skill-task mapping
- Flag tasks requiring skills not yet implemented

## Inputs

- `tasks.json`
- `dependency-graph.json`

## Outputs

- `skill-map.json`

## Available Skills Registry

| Skill | Agent | Use When |
|-------|-------|----------|
| `code-generation` | Build | Writing new source code |
| `manifest-generation` | Build | Creating K8s manifests |
| `pipeline-generation` | Build | Creating/updating pipeline-spec.yaml |
| `gitops-overlay-generation` | Build | Creating environment overlays |
| `refactoring` | Build | Modifying existing code |
| `template-application` | Build | Applying golden-path templates |
| `governance-enforcement` | Build | Validating compliance |
| `test-generation` | Test | Writing tests |
| `security-review/*` | Security | Security validation |
| `adr-writer` | Any | Documenting architectural decisions |

## Matching Rules

### Task Type → Skill Mapping

| Task Type | Primary Skill | Secondary Skills |
|-----------|--------------|-----------------|
| New feature code | `code-generation` | `template-application` |
| K8s manifests | `manifest-generation` | `governance-enforcement` |
| Pipeline changes | `pipeline-generation` | `governance-enforcement` |
| GitOps overlays | `gitops-overlay-generation` | `governance-enforcement` |
| Code refactor | `refactoring` | `test-generation` |
| New component | `template-application` | `code-generation` |

### Validation

- [ ] Every task has at least one primary skill assigned
- [ ] All assigned skills exist in the registry
- [ ] Tasks requiring unavailable skills are flagged

## Output Format

```json
{
  "task_id": "TASK-001",
  "title": "Task title",
  "primary_skill": "code-generation",
  "secondary_skills": ["template-application"],
  "agent": "build",
  "skill_available": true
}
```

## Success Criteria

- Each task has correct skill assignments
- All assigned skills are available
- No gaps in skill coverage
