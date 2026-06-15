---
name: ci-pipeline-execution
description: "Execute the pipeline stages defined in pipeline-spec.yaml in the correct order. Use when running unit, component, integration, security tests, or build stages."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Pipeline Execution

> **Load trigger:** `"load ci-pipeline-execution skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Execute the pipeline stages defined in `pipeline-spec.yaml` in the correct order.

## Responsibilities

- Execute unit tests
- Execute component tests
- Execute integration tests
- Execute security tests
- Execute build stage
- Execute artifact validation

## Inputs

- `pipeline-spec.yaml`
- Project repo

## Outputs

- `ci-execution.json`
- `stage-timings.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-pipeline-execution/stage-orchestration` | Ensure correct stage ordering |
| `ci-pipeline-execution/stage-timing` | Measure stage execution time |

## Stage Execution Order

```
1. lint          → Code quality
2. unit-test     → Fast correctness
3. component-test → Component interaction
4. integration-test → System integration
5. security-scan → SAST/SCA
6. build         → Produce artifacts
7. artifact-validate → Verify artifacts
```

## Execution Rules

- [ ] Stages execute in defined order
- [ ] Failed stage blocks subsequent stages
- [ ] Stage results recorded
- [ ] Stage timings captured

## Output Format

```json
{
  "skill": "ci-pipeline-execution",
  "status": "pass | fail",
  "stages": [
    {"name": "lint", "status": "pass", "duration_seconds": 15},
    {"name": "unit-test", "status": "pass", "duration_seconds": 45},
    {"name": "security-scan", "status": "pass", "duration_seconds": 30},
    {"name": "build", "status": "pass", "duration_seconds": 120}
  ],
  "total_duration_seconds": 210
}
```

## Success Criteria

- All stages executed successfully
- No missing or skipped stages
- Timings captured
