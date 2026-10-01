---
name: dojo-navigator
description: "Surface the relevant Fawkes Dojo module for the current task and map it to the DORA capability being worked on. Implements DORA AI Capability 3 and AI Capability 6 by linking internal docs to the learning path."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: dojo-navigator

> **Load trigger:** "load dojo-navigator skill"
> **DORA:** AI Capability 3: AI-accessible internal data + AI Capability 6: User-centric focus
> **Token cost:** Low

## Purpose

When a task is about a specific delivery capability, the agent should surface the most relevant Dojo module before it starts implementing. The goal is to connect the repository workflow to the learning path, not to replace the issue or code plan.

## Capability → Module Map

The full, versioned map lives in `docs/DOJO_MAP.md`. This skill should surface the relevant module from that source of truth rather than maintaining a second copy of the table.

## Recommended response pattern

When invoked, the agent should answer in this shape:

```
Before implementing this capability, complete the relevant Fawkes Dojo module:
- Capability: AI Capability 5 — Working in small batches
- Dojo module: Yellow Belt / Module 05 — CI fundamentals
- URL: https://paruff.github.io/fawkes/dojo/modules/yellow-belt/module-05-ci-fundamentals/
- Why this matters: it teaches the delivery pattern that matches the task and gives a short, testable practice before code changes.
```

## Examples

- Working on CI pipeline? Complete Yellow Belt Module 05 — CI fundamentals.
- Working on DORA metrics / deployment telemetry? Complete White Belt Module 02 — DORA metrics.
- Working on platform architecture or feedback loops? Complete Brown Belt Module 13 — Metrics, logs, and traces.
- Working on user value / stakeholder alignment? Complete Black Belt Module 17 — Platform as product.

## Output contract

The agent must surface:

1. The task’s DORA capability
2. The matching Dojo belt and module name
3. The public module URL
4. A sentence explaining why the module is relevant to the task
5. One concrete implementation checkpoint in this repo after the module is complete
