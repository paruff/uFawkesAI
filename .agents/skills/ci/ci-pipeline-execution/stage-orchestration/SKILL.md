---
name: ci-stage-orchestration
description: "Ensure pipeline stages run in the correct order with correct dependencies. Use when validating stage ordering, dependencies, or artifact passing."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Stage Orchestration

> **Load trigger:** `"load ci-stage-orchestration skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure pipeline stages run in the correct order with correct dependencies.

## Responsibilities

- Validate stage ordering
- Validate stage dependencies
- Validate artifact passing between stages

## Inputs

- `pipeline-spec.yaml`

## Outputs

- `stage-orchestration.json`

## Dependency Rules

### Required Order

| Stage | Depends On |
|-------|-----------|
| lint | (none) |
| unit-test | (none) |
| component-test | unit-test |
| integration-test | component-test |
| security-scan | (none) |
| build | lint, unit-test |
| artifact-validate | build |

### Parallel Groups

| Group | Stages |
|-------|--------|
| 1 | lint, unit-test, security-scan |
| 2 | component-test |
| 3 | integration-test |
| 4 | build |
| 5 | artifact-validate |

## Validation Rules

- [ ] No circular dependencies
- [ ] All dependencies satisfied before stage starts
- [ ] Artifacts passed correctly between stages
- [ ] No orphaned stages

## Output Format

```json
{
  "skill": "ci-stage-orchestration",
  "status": "valid | invalid",
  "stages": [
    {"name": "lint", "depends_on": [], "parallel_group": 1},
    {"name": "unit-test", "depends_on": [], "parallel_group": 1},
    {"name": "build", "depends_on": ["lint", "unit-test"], "parallel_group": 4}
  ],
  "issues": []
}
```

## Success Criteria

- No invalid stage ordering
- All dependencies satisfied
- Artifacts passed correctly
