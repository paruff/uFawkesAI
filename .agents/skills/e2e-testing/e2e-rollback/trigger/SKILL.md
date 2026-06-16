---
name: rollback-triggering
description: "Trigger a controlled deployment failure to test rollback behavior. Use when injecting invalid manifests, injecting failing health checks, or validating rollback trigger."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Rollback Triggering

> **Load trigger:** `"load rollback-triggering skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Trigger a controlled deployment failure to test rollback behavior.

## Responsibilities

- Inject invalid manifests
- Inject failing health checks
- Validate rollback trigger

## Inputs

- Failure scenario

## Outputs

- `rollback-trigger.json`

## Failure Injection Methods

| Method               | Description                        |
| -------------------- | ---------------------------------- |
| Invalid manifest     | Deploy manifest with invalid YAML  |
| Wrong image          | Deploy non-existent image tag      |
| Failing health check | Configure failing liveness probe   |
| Resource exhaustion  | Deploy with insufficient resources |

## Validation Rules

- [ ] Failure injected successfully
- [ ] Rollback triggered by controller
- [ ] Previous version restored

## Output Format

```json
{
  "skill": "rollback-triggering",
  "status": "success",
  "injection_method": "invalid_manifest",
  "rollback_triggered": true,
  "time_s": 30
}
```

## Success Criteria

- Rollback triggered correctly
