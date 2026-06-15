---
name: ci-stage-timing
description: "Measure execution time for each CI stage. Use when capturing timestamps, computing duration, or identifying slow stages."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Stage Timing & Performance

> **Load trigger:** `"load ci-stage-timing skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Measure execution time for each CI stage.

## Responsibilities

- Capture start/end timestamps
- Compute duration
- Identify slow stages

## Inputs

- CI logs

## Outputs

- `stage-timings.json`

## Timing Rules

### Measurement

- [ ] Start timestamp captured at stage begin
- [ ] End timestamp captured at stage complete
- [ ] Duration computed in seconds
- [ ] Timestamps in UTC

### Performance Thresholds

| Stage | Expected | Warning | Critical |
|-------|----------|---------|----------|
| lint | < 30s | > 60s | > 120s |
| unit-test | < 120s | > 300s | > 600s |
| integration-test | < 300s | > 600s | > 1200s |
| security-scan | < 120s | > 300s | > 600s |
| build | < 300s | > 600s | > 1200s |

## Output Format

```json
{
  "skill": "ci-stage-timing",
  "timings": [
    {
      "stage": "lint",
      "start": "2025-01-15T10:00:00Z",
      "end": "2025-01-15T10:00:15Z",
      "duration_seconds": 15,
      "status": "normal"
    },
    {
      "stage": "build",
      "start": "2025-01-15T10:01:00Z",
      "end": "2025-01-15T10:03:00Z",
      "duration_seconds": 120,
      "status": "normal"
    }
  ],
  "total_duration_seconds": 195,
  "slow_stages": []
}
```

## Success Criteria

- Accurate timing data
- Slow stages identified
- Performance baseline established
