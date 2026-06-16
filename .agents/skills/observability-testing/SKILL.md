---
name: observability-testing
description: "Observability validation ensuring structured log schemas, metrics correctness, trace propagation, and overall observability health."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Observability Testing

> **Load trigger:** `"load observability-testing skill"`
> **DORA:** Cap 2 (Observability)
> **Token cost:** Low

## Purpose

Validate observability including structured log schemas, metrics correctness, trace propagation, and overall observability health.

## Responsibilities

- Validate log schema structure and required fields
- Ensure metrics follow golden signal patterns
- Verify trace propagation across services
- Validate dashboard coverage
- Check alert rule completeness

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `observability-testing/log-schema-validation` | Ensure structured, consistent logs |
| `observability-testing/metrics-validation` | Ensure correct, meaningful metrics |
| `observability-testing/observability-health` | Validate telemetry stack health |
| `observability-testing/trace-propagation` | Ensure trace_id propagates across services |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `observability` | Uses observability patterns |

## Output Format

```json
{
  "skill": "observability-testing",
  "status": "pass | fail",
  "logs": {
    "schema_valid": true,
    "required_fields": "present",
    "no_plaintext_secrets": true
  },
  "metrics": {
    "golden_signals": "present",
    "cardinality": "acceptable"
  },
  "traces": {
    "propagation": "complete",
    "span_structure": "valid"
  }
}
```
