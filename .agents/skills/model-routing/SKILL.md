---
name: model-routing
description: "Route tasks to the optimal model and mode. Use when unsure which model or mode to use for a task."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Model Routing

> **Load trigger:** `"load model-routing skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Route tasks to the optimal model and mode based on complexity, cost, and requirements.

## Responsibilities

- Determine optimal mode (Ask/Edit/Agent)
- Select appropriate model tier (Low/Medium/High)
- Validate scope before Agent Mode
- Estimate complexity and cost
- Provide local model alternatives

## Decision: Mode First

| Task type                 | Mode                            | Why                       |
| ------------------------- | ------------------------------- | ------------------------- |
| Question / explanation    | **Ask Mode**                    | 60–90% cheaper than Agent |
| Single-file targeted edit | **Edit Mode**                   | 30–50% cheaper than Agent |
| Multi-file feature        | **Agent Mode**                  | Correct choice            |
| Architecture / security   | **Agent Mode + frontier model** | Worth the cost            |

## Decision: Model Second

| Complexity | Model tier             | Examples                             |
| ---------- | ------------------------ | ------------------------------------- |
| Low        | Fast/cheap tier        | Q&A, docs, simple fixes              |
| Medium     | Mid tier               | Feature implementation               |
| High       | Frontier/premium tier  | Architecture, security, rework > 20% |

## Scope Check (Required Before Agent Mode)

Before proceeding with any Agent Mode task, state:

1. Files I will READ: [list]
2. Files I will WRITE: [list]
3. My plan: [2 sentences]
4. Estimated complexity: low / medium / high

Then wait for human confirmation.

## Local Model Alternative (Zero Credit Cost)

For docs, changelogs, simple explanations — a small local model via Ollama is
sufficient. Use hosted credits for tasks requiring frontier/premium tier quality.

## Full Guide

See `docs/MODEL_ROUTING_GUIDE.md` for decision tree, cost table, and anti-patterns.
