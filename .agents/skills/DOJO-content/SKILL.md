---
name: dojo-content
description: "Create and manage DOJO content for platform engineering education and knowledge sharing."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: DOJO Content

> **Load trigger:** `"load dojo-content skill"` > **DORA:** AI Capability 3 (AI-assisted development)
> **Token cost:** Low

## Purpose

Create educational content for DOJO sessions focused on platform engineering best practices, DORA metrics, and developer experience.

## When to Run

| Situation                                  | Run DOJO content? |
| ------------------------------------------ | ----------------- |
| New platform capability launched           | Yes               |
| DORA metrics show regression               | Yes               |
| Developer feedback indicates knowledge gap | Yes               |
| Quarterly DOJO session scheduled           | Yes               |

## Content Structure

```markdown
## Title

[One-line description]

## Learning Objective

[What developers will know/do after this session]

## Prerequisites

- [Required knowledge]

## Content

[Main material - 500-1000 words]

## Hands-on Exercise

[Practical activity]

## Key Takeaways

- [3-5 bullet points]
```

## Output Format

```json
{
  "skill": "dojo-content",
  "topic": "string",
  "target_audience": "string",
  "content_path": "dojo/YYYY-MM-DD-topic.md",
  "slides_path": "dojo/slides/YYYY-MM-DD-topic.md",
  "exercise_path": "dojo/exercises/YYYY-MM-DD-topic.md"
}
```
