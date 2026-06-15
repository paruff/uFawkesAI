---
name: agent-decision-logging
description: "Record agent decisions for post-hoc analysis and audit. Use when reviewing agent behavior patterns or tracking decision trends over time."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Agent Decision Logging

> **Load trigger:** `"load agent-decision-logging skill"` > **DORA:** Cap 6 (Reliability)
> **Token cost:** Low

## Purpose

Record what agents decided and why. Enables post-hoc analysis of agent behavior patterns, decision trends, and identification of systematic biases.

## Span Specification

### `agent.decision.made`

Emit when the agent produces its final decision.

**Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `decision` | string | Final decision (PASS/FAIL/BLOCKED/APPROVE/REQUEST_CHANGES/ESCALATE) |
| `blocker_count` | integer | Number of CRITICAL or blocking findings |
| `finding_count` | integer | Total number of findings |
| `agent.name` | string | Agent that made this decision |
| `session_id` | string | Unique invocation identifier |

## Decision Trend Analysis

| Trend | Meaning | Action |
|-------|---------|--------|
| Increasing FAIL rate | Agents are stricter or quality is dropping | Investigate root cause |
| Decreasing FAIL rate | Agents are looser or quality is improving | Review if standards are slipping |
| Constant APPROVE rate | Agent may not be thorough | Review findings per invocation |

## Integration

The `decision` and `blockers` fields in the Phase 0 invocation log are the source of truth.
The `agent.decision.made` span is the OTEL representation of those fields.
