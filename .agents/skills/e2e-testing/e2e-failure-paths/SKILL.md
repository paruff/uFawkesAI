---
name: e2e-failure-paths
description: "Validate pipeline behavior under failure conditions. Use when simulating test failures, SAST failures, build failures, validating no GitOps update occurs, or checking error propagation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: E2E Failure Path Testing

> **Load trigger:** `"load e2e-failure-paths skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate pipeline behavior under failure conditions.

## Responsibilities

- Simulate test failures
- Simulate SAST failures
- Simulate build failures
- Validate no GitOps update occurs
- Validate correct error propagation

## Inputs

- Failure scenarios

## Outputs

- `e2e-failure.json`

## Sub-Skills

| Skill                                   | Purpose                     |
| --------------------------------------- | --------------------------- |
| `e2e-failure-paths/pipeline-failures`   | Negative pipeline scenarios |
| `e2e-failure-paths/manifest-protection` | Invalid manifest protection |

## Failure Scenarios

| Scenario                 | Expected Behavior                |
| ------------------------ | -------------------------------- |
| Unit test failure        | Pipeline stops, no GitOps update |
| Integration test failure | Pipeline stops, no GitOps update |
| SAST failure             | Pipeline stops, no GitOps update |
| Build failure            | Pipeline stops, no GitOps update |
| Invalid manifest         | Pipeline stops, no GitOps update |

## Validation Rules

- [ ] No invalid GitOps updates
- [ ] Correct failure behavior
- [ ] Error propagation correct
- [ ] Pipeline stops cleanly

## Output Format

```json
{
  "skill": "e2e-failure-paths",
  "status": "pass | fail",
  "scenarios": {
    "unit_test_failure": { "stopped": true, "gitops_update": false },
    "sast_failure": { "stopped": true, "gitops_update": false },
    "build_failure": { "stopped": true, "gitops_update": false },
    "invalid_manifest": { "stopped": true, "gitops_update": false }
  },
  "total_scenarios": 4,
  "all_correct": true
}
```

## Success Criteria

- No invalid GitOps updates
- Correct failure behavior
