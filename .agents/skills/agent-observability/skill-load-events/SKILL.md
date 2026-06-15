---
name: agent-skill-load-events
description: "Track which skills are loaded during agent invocations. Use when analyzing skill usage patterns, identifying dead skills, or optimizing context loading."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Agent Skill Load Events

> **Load trigger:** `"load agent-skill-load-events skill"` > **DORA:** Cap 3 (Context Engineering)
> **Token cost:** Low

## Purpose

Track which skills are loaded during agent invocations to identify unused, overused, or inefficient skills.

## Span Specification

### `agent.skill.loaded`

Emit each time a skill is loaded for context.

**Attributes:**

| Attribute | Type | Description |
|-----------|------|-------------|
| `skill.name` | string | Skill identifier (e.g. `security/rbac-validation`) |
| `skill.domain` | string | Skill domain (e.g. `security`) |
| `agent.name` | string | Agent that loaded this skill |
| `session_id` | string | Unique invocation identifier |

## Usage

Skills loaded 0 times in 90 days → archive candidates.
Skills loaded in every invocation → consider promoting to always-on context (but watch token budget).

## Integration with Phase 0

The `skills_loaded` array in the Phase 0 invocation log is the source of truth.
Each entry in that array corresponds to one `agent.skill.loaded` span.
