---
name: unit-core-logic-testing
description: "Validate pure functions, deterministic logic, and core algorithms in OBS and PIPE. Use when testing DAG evaluation, GitOps parsing, error propagation, or ensuring deterministic outputs."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Unit Core Logic Testing

> **Load trigger:** `"load unit-core-logic-testing skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate pure functions, deterministic logic, and core algorithms in OBS and PIPE.

## Responsibilities

- Test DAG evaluation logic
- Validate GitOps parsing and schema validation
- Test error propagation and branching logic
- Ensure deterministic outputs for identical inputs

## Inputs

- Source code
- Unit test files

## Outputs

- `junit.xml`
- `coverage.xml`

## Test Categories

| Category | Focus | Example |
|----------|-------|---------|
| Pure functions | Input → Output | Version parser, schema validator |
| DAG logic | Ordering, cycles | Pipeline stage ordering |
| Parsing | Format conversion | YAML/JSON parsing, manifest normalization |
| Branching | Conditional logic | Environment-specific behavior |

## Performance Thresholds

| Metric | Threshold |
|--------|-----------|
| Test execution | < 200ms per test |
| Coverage | ≥ 80% line coverage |
| Flakiness | 0% (deterministic) |

## Validation Rules

- [ ] All core logic functions tested
- [ ] Deterministic outputs
- [ ] No external side effects
- [ ] Coverage ≥ 80%
- [ ] No tests > 200ms

## Tools

- Vitest / Jest
- Pytest (if Python components exist)
- ts-mockito / sinon

## Output Format

```json
{
  "skill": "unit-core-logic-testing",
  "status": "pass | fail",
  "total_tests": 150,
  "passed": 150,
  "failed": 0,
  "coverage": {
    "line": 85,
    "branch": 80,
    "function": 90
  },
  "slow_tests": []
}
```

## Success Criteria

- < 200ms per test
- 80%+ coverage
- No external side effects
