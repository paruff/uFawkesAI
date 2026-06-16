---
name: e2e-testing
description: "End-to-end testing validating full deployment lifecycle including happy paths, failure scenarios, rollback behavior, and deployment health."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: E2E Testing

> **Load trigger:** `"load e2e-testing skill"`
> **DORA:** Cap 5 (Small Batches)
> **Token cost:** Medium

## Purpose

Validate the full deployment lifecycle from happy paths through failure scenarios, rollback behavior, and deployment health.

## Responsibilities

- Validate happy path deployments
- Test failure scenarios and recovery
- Validate rollback behavior
- Check deployment health and readiness
- Verify telemetry propagation

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `e2e-testing/e2e-deployment-validation` | Validate deployed application behavior |
| `e2e-testing/e2e-failure-paths` | Test pipeline behavior under failures |
| `e2e-testing/e2e-happy-path` | Validate full pipeline success path |
| `e2e-testing/e2e-rollback` | Validate rollback behavior |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `build` | Tests build output |
| `test-execution` | Depends on test results |
| `delivery` | Validates deployment |

## Output Format

```json
{
  "skill": "e2e-testing",
  "status": "pass | fail",
  "scenarios": {
    "happy_path": "pass",
    "failure_recovery": "pass",
    "rollback": "pass",
    "health_check": "pass"
  },
  "telemetry": {
    "traces_propagated": true,
    "metrics_emitted": true
  }
}
```
