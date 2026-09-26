---
name: api-design-rules
description: "API design conventions for this repo: naming, explicit interfaces, consistent error handling, backward compatibility, and versioning. Use when designing or changing any public-facing interface, function signature, or API contract."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# API Design Rules

- Use clear, stable names that reflect domain intent.
- Keep interfaces explicit; avoid ambiguous return types and hidden side effects.
- Handle errors consistently with actionable messages and typed/structured error paths.
- Preserve backward compatibility where possible; document breaking changes.
- Version public-facing APIs deliberately and document migration expectations.
