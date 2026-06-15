---
name: pause-resume
description: "Pause rollout automatically when metrics degrade and resume when healthy. Use when detecting degradation, pausing rollout, or resuming after recovery."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Automated Pause & Resume

> **Load trigger:** `"load pause-resume skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Pause rollout automatically when metrics degrade and resume when healthy.

## Responsibilities

- Detect metric degradation
- Pause rollout
- Re-check metrics periodically
- Resume or rollback based on recovery

## Inputs

- Metrics
- Rollout state

## Outputs

- `pause-resume.json`

## Pause Rules

### Degradation Triggers

| Metric | Threshold | Action |
|--------|-----------|--------|
| Latency p99 | > 500ms | Pause |
| Error rate | > 1% | Pause |
| CPU saturation | > 85% | Pause |
| Memory saturation | > 85% | Pause |

### Resume Rules

| Condition | Action |
|-----------|--------|
| All metrics healthy for 2 min | Resume |
| Metrics still degraded after 5 min | Rollback |
| Manual override | Resume/Rollback |

### Pause Behavior

- [ ] Rollout paused immediately on degradation
- [ ] Metrics re-checked every 30 seconds
- [ ] Resume if metrics recover within 5 minutes
- [ ] Rollback if metrics don't recover within 5 minutes

## Output Format

```json
{
  "skill": "pause-resume",
  "status": "paused",
  "pause_reason": "Latency p99 exceeded 500ms",
  "paused_at": "2025-01-15T10:30:00Z",
  "metrics_at_pause": {
    "latency_p99_ms": 650,
    "error_rate": 0.5
  },
  "recheck_interval_seconds": 30,
  "rollback_timeout_seconds": 300
}
```

## Success Criteria

- Safe automated pause/resume behavior
- Rollback on sustained degradation
