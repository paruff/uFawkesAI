# Rule: API design

> Always loaded (`.claude/rules/` in Claude Code, `instructions` in `opencode.json`).
> Applies when: changing any public interface or API contract.

- Use clear, stable names that reflect domain intent.
- Keep interfaces explicit; avoid ambiguous return types and hidden side effects.
- Handle errors consistently with actionable messages and typed/structured error paths.
- Preserve backward compatibility where possible; document breaking changes.
- Version public-facing APIs deliberately and document migration expectations.
