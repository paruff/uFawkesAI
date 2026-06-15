---
name: orchestration/handoff-validation
description: Validates an orchestrator handoff block against the JSON Schema in .agents/schema/handoff.json before sending it to a receiving agent. Use before every handoff.
license: MIT
compatibility: OpenCode, Claude Code, GitHub Copilot, Cursor
metadata:
  author: paruff
  suite: uFawkesAI
  dora_cap: "Cap 3 — Context Engineering"
---

# Handoff Validation Skill

Validate a structured handoff block against `.agents/schema/handoff.json` before passing it to a receiving agent.

## When to Load

- Before every handoff to any agent
- When debugging why a receiving agent produced incomplete or off-target output (the handoff may have been malformed)

## How It Works

Check each required field against the schema:

| Field | Required | Validation |
|-------|----------|------------|
| `task` | Yes | Must be non-empty, one sentence |
| `source` | Yes | Must be one of the allowed enum values |
| `branch` | Yes | Must be non-empty |
| `files_in_scope` | Yes | Must be non-empty array |
| `related_issues` | No | Array of strings if present |
| `constraints` | No | Array of strings if present |
| `dependency` | No | String, defaults to "none" |
| `skills_to_load` | No | Array of strings — skill paths from `.agents/skills/` |
| `context_files` | No | Array of strings — file paths relative to repo root |

## Handoff Quality Rules

1. **task** must be one sentence. If longer, condense it. The receiving agent needs focus, not a novel.
2. **files_in_scope** must list every file the receiving agent will touch. If unknown, say "to be determined during implementation".
3. **skills_to_load** should list skill paths (e.g., `security/secret-governance`) not agent names.
4. **context_files** should list only files the receiving agent MUST read. Do not dump the entire repo.

## Self-Check Before Handoff

Before sending the handoff block, ask:

- Does the receiving agent have all the context it needs without reading 10+ files?
- Does the handoff include constraints from AGENTS.md §5 that apply?
- Is the dependency field accurate (what must merge first)?
- Does the receiving agent need specific skills loaded?

## Correct Example

```
## Handoff from Orchestrator
Task: Add OTEL instrumentation to the payments service HTTP handlers
Source: Human
Branch: feat/obs-payments
Related issues: #42
Files in scope:
  - src/services/payments/handler.ts
  - src/services/payments/otel.ts
  - .env.example
Constraints:
  - Must not modify business logic
  - Must not add new dependencies
Dependency: none
Skills to load: obs-bootstrap
Context files: docs/API_SURFACE.md
```
