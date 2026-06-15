---
name: agent-observability
description: "Emit and consume telemetry spans for agent invocations, skill loads, findings, and decisions. Use when instrumenting the agent system itself or when analyzing agent behavior patterns."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Agent Observability

> **Load trigger:** `"load agent-observability skill"` > **DORA:** Cap 2 (Observability) + Cap 6 (Reliability)
> **Token cost:** Low

## Purpose

Instrument the agent system itself with the same observability standards applied to application code. Agent actions become observable, measurable, and improvable.

## Agent Telemetry Span Types

| Span Name | When to Emit | Attributes |
|-----------|-------------|------------|
| `agent.invocation.started` | Agent begins its task | `agent.name`, `session_id`, `mode` |
| `agent.skill.loaded` | Skill file is loaded for context | `skill.name`, `skill.domain` |
| `agent.finding.produced` | A finding is identified | `severity`, `category`, `actionable`, `manual_review_needed` |
| `agent.decision.made` | Agent produces its final decision | `decision`, `blocker_count`, `finding_count` |
| `agent.invocation.completed` | Agent finishes its task | `duration_ms`, `total_skills_loaded`, `total_findings` |
| `agent.invocation.failed` | Agent encounters an error | `error`, `stage` |

## Relation to Phase 0 Logging

Phase 0 logs (`.agents/logs/YYYY-MM-DD.jsonl`) are the data source. Agent telemetry spans are the OTEL representation of the same events. 

Mapping:
- `agent.invocation.started` + `agent.invocation.completed` → one log entry
- `agent.skill.loaded` → `skills_loaded[]` array in log entry
- `agent.finding.produced` → each item in `findings[]` array
- `agent.decision.made` → `decision` and `blockers` fields

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `agent-observability/invocation-tracking` | Track agent start, completion, and duration |
| `agent-observability/skill-load-events` | Track which skills are loaded and how often |
| `agent-observability/finding-quality` | Measure finding actionability and accuracy |
| `agent-observability/decision-logging` | Log agent decisions for post-hoc analysis |
