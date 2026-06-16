---
name: deployment-smoke-tests
description: "Validate that the deployed application is healthy and functional. Use when running API smoke tests, validating health endpoints, or checking rollout status."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Deployment Smoke Tests

> **Load trigger:** `"load deployment-smoke-tests skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that the deployed application is healthy and functional.

## Responsibilities

- Run API smoke tests
- Validate health endpoints
- Validate rollout status

## Inputs

- Deployed environment

## Outputs

- `smoke-tests.json`

## Smoke Test Targets

| Target    | Endpoint         | Expected        |
| --------- | ---------------- | --------------- |
| Health    | `/health`        | 200 OK          |
| Readiness | `/ready`         | 200 OK          |
| Version   | `/version`       | Current version |
| API       | `/api/v1/status` | 200 OK          |

## Validation Rules

- [ ] Health endpoint returns 200
- [ ] Readiness endpoint returns 200
- [ ] Version endpoint returns correct version
- [ ] API endpoints respond correctly
- [ ] Response time < 500ms

## Output Format

```json
{
  "skill": "deployment-smoke-tests",
  "status": "pass | fail",
  "tests": [
    { "endpoint": "/health", "status": 200, "time_ms": 50 },
    { "endpoint": "/ready", "status": 200, "time_ms": 45 },
    { "endpoint": "/version", "status": 200, "body": "1.3.0", "time_ms": 30 }
  ],
  "total_tests": 3,
  "passed": 3,
  "failed": 0
}
```

## Success Criteria

- Healthy deployment
- All smoke tests pass
