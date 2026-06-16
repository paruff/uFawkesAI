---
name: pipeline-test-stage-validation
description: "Ensure the CI/CD pipeline includes required test stages. Use when validating that pipeline definitions include unit, integration, and E2E test stages."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Test Stage Validation

> **Load trigger:** `"load pipeline-test-stage-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure the CI/CD pipeline includes required test stages.

## Responsibilities

- Validate presence of unit test stage
- Validate presence of integration test stage
- Validate presence of E2E test stage (if required)
- Validate coverage reporting stage
- Validate test result reporting

## Inputs

- `pipeline-spec.yaml`
- Governance rules

## Outputs

- `pipeline-test-stage-report.json`

## Required Stages

### Must Have

| Stage           | Purpose                | Required |
| --------------- | ---------------------- | -------- |
| Unit tests      | Fast correctness check | Yes      |
| Coverage report | Measure coverage       | Yes      |
| Lint/format     | Code quality           | Yes      |

### Should Have

| Stage             | Purpose               | Required    |
| ----------------- | --------------------- | ----------- |
| Integration tests | Component interaction | Recommended |
| Security scan     | Vulnerability check   | Recommended |

### Nice to Have

| Stage             | Purpose                  | Required      |
| ----------------- | ------------------------ | ------------- |
| E2E tests         | Full workflow validation | If applicable |
| Performance smoke | Basic perf check         | Optional      |

## Validation Rules

### Stage Presence

- [ ] Unit test stage exists
- [ ] Coverage reporting stage exists
- [ ] Integration test stage exists (or justified as N/A)
- [ ] E2E test stage exists (if app has UI or API workflows)

### Stage Configuration

- [ ] Test stages run on PR and push to main
- [ ] Test failures block merge
- [ ] Coverage thresholds enforced in CI
- [ ] Test results reported (not just exit code)

### Pipeline Position

- [ ] Tests run before build/deploy stages
- [ ] Tests run after lint/format stages
- [ ] Security scans run alongside tests

## Tools

- `yq` for YAML parsing
- Policy engine (OPA, Kyverno) for validation
- `gh api` for GitHub Actions workflow inspection

## Output Format

```json
{
  "skill": "pipeline-test-stage-validation",
  "status": "pass | fail",
  "stages": {
    "unit_tests": {
      "present": true,
      "runs_on_pr": true,
      "blocks_merge": true
    },
    "integration_tests": {
      "present": true,
      "runs_on_pr": true,
      "blocks_merge": true
    },
    "e2e_tests": {
      "present": false,
      "justified": false
    },
    "coverage_report": {
      "present": true,
      "threshold_enforced": true
    }
  },
  "findings": [
    {
      "severity": "MEDIUM",
      "stage": "e2e_tests",
      "issue": "E2E test stage missing from pipeline",
      "fix": "Add E2E test stage to pipeline-spec.yaml"
    }
  ]
}
```

## Success Criteria

- Pipeline includes all required test stages
- Test failures block merge
- Coverage thresholds enforced
