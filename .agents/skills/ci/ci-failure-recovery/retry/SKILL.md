---
name: ci-retry
description: "Retry CI steps that fail due to transient issues. Use when handling network errors, registry timeouts, or GitHub API failures."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Transient Failure Retry

> **Load trigger:** `"load ci-retry skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Retry CI steps that fail due to transient issues.

## Responsibilities

- Detect transient errors (network, registry, GitHub API)
- Retry with exponential backoff
- Log retry attempts
- Escalate after max retries

## Inputs

- CI logs
- Error patterns

## Outputs

- `retry-report.json`

## Transient Error Patterns

| Pattern | Category | Retryable |
|---------|----------|-----------|
| `ETIMEDOUT` | Network | Yes |
| `ECONNRESET` | Network | Yes |
| `429 Too Many Requests` | Rate limit | Yes |
| `502 Bad Gateway` | Server | Yes |
| `503 Service Unavailable` | Server | Yes |
| `TLS handshake timeout` | Network | Yes |
| `Connection refused` | Network | Yes |
| `npm ERR! code ENOMEM` | OOM | No (needs bigger runner) |

## Retry Configuration

| Parameter | Default | Range |
|-----------|---------|-------|
| Max retries | 3 | 1-5 |
| Initial backoff | 1s | 0.5-5s |
| Max backoff | 30s | 10-60s |
| Backoff multiplier | 2x | 1.5-3x |

## Retry Logic

```
for attempt in 1..max_retries:
    result = execute_step()
    if result.success:
        return SUCCESS
    if is_transient(result.error):
        sleep(backoff * attempt)
        continue
    return FAILURE
return ESCALATE
```

## Output Format

```json
{
  "step": "npm install",
  "attempts": 3,
  "result": "success",
  "retries": [
    {"attempt": 1, "error": "ETIMEDOUT", "duration_ms": 30000},
    {"attempt": 2, "error": "ETIMEDOUT", "duration_ms": 30000},
    {"attempt": 3, "result": "success", "duration_ms": 15000}
  ]
}
```

## Success Criteria

- Transient failures resolved via retry
- No retries for deterministic failures
- Retry attempts logged
