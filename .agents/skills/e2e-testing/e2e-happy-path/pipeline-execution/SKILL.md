---
name: pipeline-execution-validation
description: "Validate that the CI pipeline executes all required stages correctly. Use when validating type-check, lint, SAST, build, test, and release stages, or validating artifact generation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Execution Validation

> **Load trigger:** `"load pipeline-execution-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that the CI pipeline executes all required stages correctly.

## Responsibilities

- Validate type-check, lint, SAST, build, test, and release stages
- Validate artifact generation
- Validate version.json correctness

## Inputs

- CI logs
- `version.json`

## Outputs

- `pipeline-execution.json`

## Required Stages

| Stage            | Expected Status | Artifacts               |
| ---------------- | --------------- | ----------------------- |
| type-check       | pass            | -                       |
| lint             | pass            | -                       |
| sast             | pass            | sast.sarif              |
| build            | pass            | container image         |
| unit-test        | pass            | junit.xml, coverage.xml |
| integration-test | pass            | junit.xml               |
| security-scan    | pass            | dependency.json         |
| publish          | pass            | image in registry       |
| release          | pass            | version.json            |

## Validation Rules

- [ ] All required stages executed
- [ ] All stages passed
- [ ] All artifacts generated
- [ ] version.json correct

## Output Format

```json
{
  "skill": "pipeline-execution-validation",
  "status": "pass | fail",
  "stages": {
    "type-check": { "status": "pass", "time_s": 30 },
    "lint": { "status": "pass", "time_s": 20 },
    "sast": { "status": "pass", "time_s": 60 },
    "build": { "status": "pass", "time_s": 120 },
    "unit-test": { "status": "pass", "time_s": 60 },
    "integration-test": { "status": "pass", "time_s": 90 },
    "security-scan": { "status": "pass", "time_s": 45 },
    "publish": { "status": "pass", "time_s": 30 },
    "release": { "status": "pass", "time_s": 10 }
  },
  "total_time_s": 465,
  "artifacts": { "image": true, "sbom": true, "signature": true }
}
```

## Success Criteria

- All stages executed successfully
- All artifacts generated
