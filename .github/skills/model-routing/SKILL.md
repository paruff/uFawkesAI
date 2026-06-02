# Model Routing Skill

> **Load this skill when:** unsure which model or mode to use for a task.
> **Prompt example:** `"Use the model-routing skill before starting this task."`

---

## Decision: Mode First

| Task type | Mode | Why |
|---|---|---|
| Question / explanation | **Ask Mode** | 60–90% cheaper than Agent |
| Single-file targeted edit | **Edit Mode** | 30–50% cheaper than Agent |
| Multi-file feature | **Agent Mode** | Correct choice |
| Architecture / security | **Agent Mode + frontier model** | Worth the cost |

## Decision: Model Second

| Complexity | Model | Examples |
|---|---|---|
| Low | GPT-4o mini / Haiku 4.5 / Flash | Q&A, docs, simple fixes |
| Medium | GPT-4o / Claude Sonnet | Feature implementation |
| High | Claude Opus / GPT-5 | Architecture, security, rework > 20% |

## Scope Check (Required Before Agent Mode)

Before proceeding with any Agent Mode task, state:
1. Files I will READ: [list]
2. Files I will WRITE: [list]
3. My plan: [2 sentences]
4. Estimated complexity: low / medium / high

Then wait for human confirmation.

## Local Model Alternative (Zero Credit Cost)

For docs, changelogs, simple explanations — Ollama + Gemma 4 E4B is sufficient.
Use Copilot credits for tasks requiring frontier model quality.

## Full Guide

See `docs/MODEL_ROUTING_GUIDE.md` for decision tree, cost table, and anti-patterns.
