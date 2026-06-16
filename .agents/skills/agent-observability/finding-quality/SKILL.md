---
name: agent-finding-quality
description: "Measure whether agent findings are actionable, accurate, and useful. Use when evaluating agent effectiveness or tuning agent prompts to reduce noise."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Agent Finding Quality

> **Load trigger:** `"load agent-finding-quality skill"` > **DORA:** Cap 6 (Reliability)
> **Token cost:** Low

## Purpose

Measure whether findings produced by agents are actually useful. A finding that is never acted on is noise. A finding that prevents a bug is gold.

## Span Specification

### `agent.finding.produced`

Emit for each finding the agent identifies.

**Attributes:**

| Attribute              | Type    | Description                                        |
| ---------------------- | ------- | -------------------------------------------------- |
| `severity`             | string  | CRITICAL, HIGH, MEDIUM, LOW, INFO                  |
| `category`             | string  | Skill or check category that produced this finding |
| `actionable`           | boolean | Whether this finding requires a specific action    |
| `manual_review_needed` | boolean | Whether human judgment is required                 |
| `agent.name`           | string  | Agent that produced this finding                   |
| `session_id`           | string  | Unique invocation identifier                       |

## Quality Metrics

| Metric               | Formula                                        | Target                          |
| -------------------- | ---------------------------------------------- | ------------------------------- |
| Actionability rate   | actionable findings / total findings           | > 60%                           |
| Manual review burden | manual_review_needed findings / total findings | < 30%                           |
| Blocker density      | CRITICAL+HIGH findings / total invocations     | < 50%                           |
| False positive rate  | findings rejected by human / total findings    | < 20% (requires human feedback) |

## Usage

- Low actionability → agent protocol is too loose. Tighten required fields and forbidden patterns.
- High manual review burden → agent lacks specific rules. Add more concrete checks.
- High blocker density → either quality is dropping or agents are too strict. Investigate.
