---
name: test-execution
description: "Execute all relevant tests and quality gates to validate build output. Use when running tests, collecting results, and measuring coverage."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Test Execution

> **Load trigger:** `"load test-execution skill"` 
> **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Execute all relevant tests and quality gates to validate build output.

## Responsibilities

- Execute unit, integration, and E2E tests
- Collect test results and failure details
- Measure code coverage
- Validate test viability
- Run quality gates (lint, typecheck)

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `test-execution/unit-test-execution` | Run unit tests and measure coverage |
| `test-execution/integration-test-execution` | Run integration tests |
| `test-execution/e2e-test-execution` | Run end-to-end tests |
| `test-execution/test-coverage-validation` | Validate coverage thresholds |
| `test-execution/pipeline-test-stage-validation` | Validate CI test stages |
| `test-execution/runtime-simulation-validation` | Simulate runtime environment |
| `test-execution/performance-smoke-testing` | Basic performance validation |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `build` | Consumes source code and test files |
| `test` | Validates tests written by test agent |

## Inputs

- Source code (from build)
- Test files (from test agent)
- Test configuration

## Outputs

- `test-results.json`
- `test-report.md`
- `coverage-report.json`

## Execution Rules

### Pre-Run

- [ ] Test framework installed and configured
- [ ] Test files discovered and counted
- [ ] Dependencies available

### Execution

- [ ] All tests executed
- [ ] No tests skipped without justification
- [ ] Test output captured
- [ ] Exit code checked (non-zero = failure)

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured
- [ ] Coverage data collected
- [ ] Flaky tests flagged

## Tools

| Language | Runner | Coverage |
|----------|--------|----------|
| TypeScript | Jest / Vitest | `--coverage` |
| Python | pytest | `pytest-cov` |
| Go | `go test` | `-coverprofile` |

## Output Format

```json
{
  "skill": "test-execution",
  "status": "pass | fail",
  "summary": {
    "total": 44,
    "passed": 42,
    "failed": 0,
    "skipped": 2
  },
  "coverage": {
    "line": 87.5,
    "branch": 79.2,
    "function": 92.1
  },
  "failures": [],
  "skipped_tests": ["test name 1"]
}
```

## Success Criteria

- All tests pass
- Coverage thresholds met
- No unexplained skips
- Quality gates pass
