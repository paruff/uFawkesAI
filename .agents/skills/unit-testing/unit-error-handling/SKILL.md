---
name: unit-error-handling
description: "Ensure predictable and safe error behavior across OBS and PIPE. Use when validating thrown errors, error messages and codes, fallback logic, retry/backoff logic, or invariant enforcement."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Unit Error Handling

> **Load trigger:** `"load unit-error-handling skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Ensure predictable and safe error behavior across OBS and PIPE.

## Responsibilities

- Validate thrown errors
- Validate error messages and codes
- Validate fallback logic
- Validate retry/backoff logic
- Validate invariant enforcement

## Inputs

- Error scenarios
- Unit tests

## Outputs

- `error-report.json`

## Error Categories

| Category          | Test Focus            | Example                           |
| ----------------- | --------------------- | --------------------------------- |
| Validation errors | thrown on bad input   | Invalid YAML, missing fields      |
| Network errors    | retry behavior        | Registry timeout, API failure     |
| State errors      | invariant enforcement | Invalid pipeline state            |
| Resource errors   | fallback logic        | Missing file, unavailable service |

## Error Test Patterns

```typescript
// Validate error thrown
expect(() => parseVersion("invalid")).toThrow("Invalid version format");

// Validate error code
try {
  await pullImage("nonexistent");
} catch (e) {
  expect(e.code).toBe("IMAGE_NOT_FOUND");
}

// Validate retry backoff
const retrySpy = jest.spyOn(client, "retry");
await client.withRetry(() => failingCall());
expect(retrySpy).toHaveBeenCalledTimes(3);
```

## Validation Rules

- [ ] All error paths tested
- [ ] No unhandled exceptions
- [ ] No silent failures
- [ ] Error messages descriptive
- [ ] Retry logic correct

## Output Format

```json
{
  "skill": "unit-error-handling",
  "status": "pass | fail",
  "error_scenarios_tested": 25,
  "unhandled_exceptions": 0,
  "silent_failures": 0,
  "retry_tests": {
    "total": 5,
    "passing": 5
  }
}
```

## Success Criteria

- All error paths tested
- No unhandled exceptions
- No silent failures
