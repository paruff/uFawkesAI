---
name: telemetry-validation
description: "Validate logs, metrics, and traces emitted by the deployed application. Use when validating log schema, Prometheus metrics, or OpenTelemetry traces."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Telemetry Validation

> **Load trigger:** `"load telemetry-validation skill"` > **DORA:** Cap 6 (Operational Visibility)
> **Token cost:** Low

## Purpose

Validate logs, metrics, and traces emitted by the deployed application.

## Responsibilities

- Validate log schema
- Validate Prometheus metrics
- Validate OpenTelemetry traces

## Inputs

- Observability stack

## Outputs

- `telemetry-report.json`

## Validation Rules

- [ ] Logs structured and valid JSON
- [ ] Required log fields present
- [ ] Prometheus metrics scraped
- [ ] Golden signals present
- [ ] Traces propagating across services

## Output Format

```json
{
  "skill": "telemetry-validation",
  "status": "pass | fail",
  "logs": {"structured": true, "fields_valid": true, "errors": 0},
  "metrics": {"scraped": true, "golden_signals": "complete"},
  "traces": {"propagating": true, "services": 4}
}
```

## Success Criteria

- Valid logs, metrics, and traces
