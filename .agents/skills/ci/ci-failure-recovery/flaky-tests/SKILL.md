---
name: flaky-tests
description: "Identify tests that fail intermittently. Use when tracking test history, detecting inconsistent results, or flagging flaky tests."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Flaky Test Detection

> **Load trigger:** `"load flaky-tests skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Identify tests that fail intermittently.

## Responsibilities

- Track test history across CI runs
- Detect inconsistent pass/fail results
- Flag flaky tests
- Calculate flakiness score

## Inputs

- Test results (historical and current)
- CI run metadata

## Outputs

- `flaky-tests.json`

## Detection Rules

### Flakiness Score

| Score | Classification | Action |
|-------|---------------|--------|
| > 20% failure rate | Flaky | Flag for fix |
| 10-20% failure rate | Potentially flaky | Monitor |
| < 10% failure rate | Stable | No action |

### Detection Signals

- [ ] Test passes on retry after failure
- [ ] Test fails without code changes
- [ ] Test result varies across runs
- [ ] Test timing out intermittently

### Common Flakiness Causes

- Race conditions
- Time-dependent tests
- External service dependencies
- Shared test state
- Non-deterministic data

## Output Format

```json
{
  "flaky_tests": [
    {
      "test_name": "test/user-api.test.ts:42",
      "failure_rate": 0.25,
      "runs_analyzed": 20,
      "recent_failures": [
        {"run_id": "1234", "error": "Timeout"},
        {"run_id": "1230", "error": "Timeout"}
      ],
      "suspected_cause": "External API timeout"
    }
  ],
  "summary": {
    "total_tests": 150,
    "flaky_count": 3,
    "flaky_rate": 0.02
  }
}
```

## Success Criteria

- Accurate flaky test detection
- Root cause suspected
- Flakiness score calculated
