---
name: negative-pipeline-scenarios
description: "Validate that pipeline failures stop deployment safely. Use when simulating unit test failures, integration test failures, SAST failures, or validating pipeline abort behavior."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Negative Pipeline Scenarios

> **Load trigger:** `"load negative-pipeline-scenarios skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate that pipeline failures stop deployment safely.

## Responsibilities

- Simulate unit test failures
- Simulate integration test failures
- Simulate SAST failures
- Validate pipeline abort behavior

## Inputs

- Failure scenarios

## Outputs

- `pipeline-failure-report.json`

## Failure Injection

| Stage | Failure Type | Injection Method |
|-------|-------------|------------------|
| unit-test | Test failure | Intentional failing test |
| integration-test | Test failure | Intentional failing test |
| sast | Vulnerability found | Intentional vulnerability |
| build | Build error | Intentional build error |

## Validation Rules

- [ ] Pipeline stops at failure point
- [ ] No GitOps update occurs
- [ ] Error message clear
- [ ] Failure logged correctly
- [ ] No partial artifacts published

## Output Format

```json
{
  "skill": "negative-pipeline-scenarios",
  "status": "pass | fail",
  "scenarios": [
    {"stage": "unit-test", "failure": "test_failure", "stopped": true, "gitops_update": false},
    {"stage": "sast", "failure": "vulnerability", "stopped": true, "gitops_update": false}
  ],
  "all_correct": true
}
```

## Success Criteria

- Pipeline stops correctly
- No GitOps update
