---
name: ci-coverage-gate
description: "Enforce minimum test coverage thresholds. Use when parsing coverage reports, validating thresholds, or failing pipeline if below threshold."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Coverage Gate

> **Load trigger:** `"load ci-coverage-gate skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Enforce minimum test coverage thresholds.

## Responsibilities

- Parse coverage reports
- Validate thresholds
- Fail pipeline if below threshold

## Inputs

- Coverage reports (`coverage.xml`, `lcov.info`, etc.)

## Outputs

- `coverage-gate.json`

## Thresholds

| Metric | Minimum | Target |
|--------|---------|--------|
| Line coverage | 80% | 90% |
| Branch coverage | 75% | 85% |
| Function coverage | 85% | 95% |

## Validation Rules

- [ ] Coverage report parsed correctly
- [ ] Per-file and overall coverage computed
- [ ] Threshold check applied
- [ ] Gap details provided if failing

## Output Format

```json
{
  "skill": "ci-coverage-gate",
  "status": "pass | fail",
  "overall": {
    "line": 87,
    "branch": 79,
    "function": 92
  },
  "thresholds": {
    "line": 80,
    "branch": 75,
    "function": 85
  },
  "gaps": [
    {"file": "src/payment.ts", "line_coverage": 45, "status": "below_threshold"}
  ]
}
```

## Success Criteria

- Coverage meets threshold
- Gaps identified if failing
- Pipeline fails if below threshold
