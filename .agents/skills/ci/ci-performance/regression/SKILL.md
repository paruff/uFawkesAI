---
name: ci-regression
description: "Detect when CI runtime increases unexpectedly. Use when tracking historical durations and alerting on performance regressions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Runtime Regression Detection

> **Load trigger:** `"load ci-regression skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Detect when CI runtime increases unexpectedly.

## Responsibilities

- Track historical CI durations
- Detect regressions (significant increases)
- Alert developers
- Provide regression details

## Inputs

- Historical timing data
- Current run timing

## Outputs

- `regression-report.json`

## Regression Detection Rules

### Thresholds

| Increase | Classification | Action |
|----------|---------------|--------|
| > 50% | Critical regression | BLOCK, investigate immediately |
| 25-50% | Major regression | ALERT, investigate |
| 10-25% | Minor regression | WARN, monitor |
| < 10% | Normal variance | None |

### Detection Methods

- [ ] Compare current run to rolling average (last 10 runs)
- [ ] Compare current run to previous run
- [ ] Compare current run to baseline (main branch)
- [ ] Detect gradual increase over multiple runs

### Regression Causes

| Cause | Symptoms |
|-------|----------|
| New slow test | Test stage duration increase |
| Dependency bloat | Install stage duration increase |
| Missing cache | Install stage duration increase |
| Resource contention | All stages slower |

## Output Format

```json
{
  "regression_detected": true,
  "current_duration_ms": 720000,
  "baseline_duration_ms": 480000,
  "increase_percent": 50,
  "classification": "critical",
  "affected_stages": [
    {
      "stage": "test",
      "current_ms": 360000,
      "baseline_ms": 240000,
      "increase_percent": 50
    }
  ],
  "suspected_cause": "New slow test added in PR #123"
}
```

## Success Criteria

- Accurate regression detection
- Regression cause suspected
- Developers alerted
