---
name: integration-test-execution
description: "Validate interactions between components. Use when running integration tests to verify data flow and component boundaries."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Integration Test Execution

> **Load trigger:** `"load integration-test-execution skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate interactions between components.

## Responsibilities

- Execute integration test suite
- Validate component interactions
- Validate data flow correctness
- Detect integration failures

## Inputs

- Build output
- Integration test files
- Test configuration

## Outputs

- `integration-test-results.json`
- `integration-test-report.md`

## Execution Rules

### Pre-Run

- [ ] Required services/dependencies available (or mocked)
- [ ] Test database/datastore configured
- [ ] Network dependencies accessible or simulated
- [ ] Environment variables set

### Execution

- [ ] All integration tests executed
- [ ] Service interactions validated
- [ ] Data flow validated
- [ ] Timeout and retry behavior validated

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured
- [ ] Integration points documented
- [ ] External dependency issues flagged

## Integration Points

### Common Integration Boundaries

- API ↔ Database
- API ↔ External Service (payment, email, etc.)
- Service ↔ Service (internal RPC/messaging)
- Frontend ↔ Backend (API calls)
- CLI ↔ Filesystem

### Validation Rules

- [ ] Database queries return expected shapes
- [ ] External service responses handled correctly
- [ ] Error responses propagated correctly
- [ ] Timeouts handled gracefully
- [ ] Retries follow exponential backoff

## Tools

| Language | Runner | Notes |
|----------|--------|-------|
| TypeScript | Jest / Vitest | `--integration` flag or separate config |
| Python | pytest | Markers: `@pytest.mark.integration` |
| Go | `go test` | Build tags: `//go:build integration` |

## Output Format

```json
{
  "skill": "integration-test-execution",
  "status": "pass | fail",
  "total": 8,
  "passed": 8,
  "failed": 0,
  "integration_points_tested": [
    "API ↔ Database",
    "API ↔ External Service"
  ],
  "failures": []
}
```

## Success Criteria

- All integration tests pass
- Component interactions validated
- Data flow correctness confirmed
