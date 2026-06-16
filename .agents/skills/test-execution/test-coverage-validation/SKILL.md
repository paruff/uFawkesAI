---
name: test-coverage-validation
description: "Validate that test coverage meets platform thresholds. Use when analyzing coverage data and checking against governance requirements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Test Coverage Validation

> **Load trigger:** `"load test-coverage-validation skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate that test coverage meets platform thresholds.

## Responsibilities

- Analyze coverage data from test runs
- Validate coverage against thresholds
- Identify untested or under-tested areas
- Produce coverage report

## Inputs

- Coverage data (from unit/integration test runs)
- Governance rules (threshold requirements)

## Outputs

- `coverage-report.json`
- `coverage-summary.md`

## Thresholds

### Default Thresholds

| Metric             | Minimum | Target |
| ------------------ | ------- | ------ |
| Line coverage      | 80%     | 90%    |
| Branch coverage    | 75%     | 85%    |
| Function coverage  | 85%     | 95%    |
| Statement coverage | 80%     | 90%    |

### Severity Classification

| Gap                           | Severity |
| ----------------------------- | -------- |
| Critical module below 60%     | HIGH     |
| Module below threshold        | MEDIUM   |
| New code below threshold      | HIGH     |
| Existing code below threshold | LOW      |

## Validation Rules

### Coverage Analysis

- [ ] Coverage data parsed and normalized
- [ ] Per-file coverage calculated
- [ ] Per-module coverage calculated
- [ ] Overall coverage calculated

### Threshold Check

- [ ] Line coverage ≥ threshold
- [ ] Branch coverage ≥ threshold
- [ ] Function coverage ≥ threshold
- [ ] No critical module below 60%

### Gap Identification

- [ ] Files with 0% coverage flagged
- [ ] Files below threshold flagged
- [ ] Critical paths with low coverage flagged
- [ ] Untested error paths flagged

## Output Format

```json
{
  "skill": "test-coverage-validation",
  "status": "pass | fail",
  "overall": {
    "line": 87.5,
    "branch": 79.2,
    "function": 92.1,
    "statement": 86.3
  },
  "thresholds": {
    "line": 80,
    "branch": 75,
    "function": 85,
    "statement": 80
  },
  "gaps": [
    {
      "file": "src/services/payment.ts",
      "line_coverage": 45.2,
      "severity": "HIGH",
      "reason": "Critical module below 60%"
    }
  ]
}
```

## Success Criteria

- Coverage meets or exceeds required thresholds
- All gaps identified and classified
- Critical paths have adequate coverage
