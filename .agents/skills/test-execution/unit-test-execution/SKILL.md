---
name: unit-test-execution
description: "Run unit tests and validate correctness of individual components. Use when executing unit tests, collecting results, and measuring coverage."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Unit Test Execution

> **Load trigger:** `"load unit-test-execution skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Run unit tests and validate correctness of individual components.

## Responsibilities

- Execute unit test suite
- Collect test results and failure details
- Collect coverage data
- Detect flaky or skipped tests

## Inputs

- Source code
- Unit test files
- Test configuration (`jest.config.ts`, `pytest.ini`, etc.)

## Outputs

- `unit-test-results.json`
- `unit-test-report.md`

## Execution Rules

### Pre-Run

- [ ] Test framework installed and configured
- [ ] Test files discovered and counted
- [ ] Dependencies available (no missing modules)

### Execution

- [ ] All unit tests executed
- [ ] No tests skipped without justification
- [ ] Test output captured (stdout, stderr)
- [ ] Exit code checked (non-zero = failure)

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured (test name, assertion, file:line)
- [ ] Coverage data collected (line, branch, function)
- [ ] Flaky tests flagged (if detectable)

## Tools

| Language   | Runner        | Coverage          |
| ---------- | ------------- | ----------------- |
| TypeScript | Jest / Vitest | `--coverage`      |
| Python     | pytest        | `pytest-cov`      |
| Go         | `go test`     | `-coverprofile`   |
| Rust       | `cargo test`  | `cargo-tarpaulin` |

## Output Format

```json
{
  "skill": "unit-test-execution",
  "status": "pass | fail",
  "total": 44,
  "passed": 42,
  "failed": 0,
  "skipped": 2,
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

- All unit tests pass
- Coverage data collected successfully
- No unexplained skips
