---
name: agent-invocation-tracking
description: "Emit OTEL spans when an agent starts and completes its task. Use when instrumenting an agent to measure duration, success rate, and invocation patterns."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Agent Invocation Tracking

> **Load trigger:** `"load agent-invocation-tracking skill"` > **DORA:** Cap 2 (Observability)
> **Token cost:** Low

## Purpose

Track when agents start, complete, and how long they take. Enables answering: "Which agents are used most? Which take longest? Which fail most often?"

## Span Specification

### `agent.invocation.started`

Emit when the agent begins processing.

**Attributes:**

| Attribute     | Type     | Description                                                           |
| ------------- | -------- | --------------------------------------------------------------------- |
| `agent.name`  | string   | Agent identifier (matches filename without .md)                       |
| `session_id`  | string   | Unique invocation identifier                                          |
| `mode`        | string   | Operational mode (if agent supports multiple)                         |
| `trigger`     | string   | What triggered this invocation (human request, CI, direct invocation) |
| `input_files` | string[] | Files read as context for this invocation                             |

### `agent.invocation.completed`

Emit when the agent finishes.

**Attributes (all from started, plus):**

| Attribute             | Type    | Description                                                         |
| --------------------- | ------- | ------------------------------------------------------------------- |
| `duration_ms`         | integer | Wall-clock duration in milliseconds                                 |
| `total_skills_loaded` | integer | Count of skills loaded during invocation                            |
| `total_findings`      | integer | Count of findings produced                                          |
| `decision`            | string  | Final decision (PASS/FAIL/BLOCKED/APPROVE/REQUEST_CHANGES/ESCALATE) |

### `agent.invocation.failed`

Emit when the agent encounters an error it cannot recover from.

**Attributes (all from started, plus):**

| Attribute | Type   | Description                                              |
| --------- | ------ | -------------------------------------------------------- |
| `error`   | string | Error message or summary                                 |
| `stage`   | string | Stage where failure occurred (validate, execute, report) |

## Implementation

After completing the task, write the Phase 0 log entry (`.agents/logs/YYYY-MM-DD.jsonl`).
The telemetry spans can be derived from the log data by the aggregation script.
