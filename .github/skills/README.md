# Agent Skills — `.github/skills/`

## What are Agent Skills?

Agent Skills are modular, on-demand capability files (`SKILL.md`) that AI agents load
**only when explicitly referenced** in a prompt. Unlike `AGENTS.md` (which is always
in context), Skills are opt-in — this preserves the agent's limited instruction/token
budget for everyday work and loads specialist guidance only when relevant.

Agent Skills are supported by:
- **GitHub Copilot** (agent mode)
- **Claude Code**
- **Codex / OpenAI o-series agents**
- **Cursor**
- **Gemini CLI**

---

## Skills in this repository

| Skill | Directory | Use when… |
|---|---|---|
| DORA Metrics | `dora-metrics/` | Working on metrics collection, dashboards, deployment tracking, or rework rate analysis |
| Security Review | `security-review/` | Reviewing a PR for security issues, auditing service functions, or adding auth logic |
| Test Generation | `test-generation/` | Writing tests, improving coverage, or following TDD for a new feature |

---

## How to invoke a Skill

### GitHub Copilot (agent mode)

Reference the skill file path in your prompt:

```
Use the skill at .github/skills/dora-metrics/SKILL.md to interpret the output
of `npm run metrics` and update the Monthly Metrics Log in docs/METRICS.md
with today's values and a trend note.
```

```
Apply the security review skill (.github/skills/security-review/SKILL.md) to
this service function before I open a PR.
```

### Claude Code

```
Read .github/skills/test-generation/SKILL.md and then generate tests for
src/utils/calculateReworkRate.ts following the TDD pattern described there.
```

### Cursor

Add the skill path to the context panel, or reference it in your prompt:

```
@.github/skills/security-review/SKILL.md — audit this service function.
```

### Gemini CLI / Codex

```
Load .github/skills/dora-metrics/SKILL.md and explain how to calculate
lead time for changes using our git history.
```

---

## How to add a new Skill

1. Create a new directory under `.github/skills/`:
   ```
   .github/skills/your-skill-name/
   ```

2. Create `SKILL.md` inside it. Use this structure:

   ```markdown
   # [Skill Name] Skill

   ## When to activate
   [Describe the situations where this skill should be loaded — be specific]

   ## [Content section 1]
   [Detailed guidance, patterns, checklists, or commands]

   ## [Content section 2]
   [Additional guidance]
   ```

3. Register the skill in `AGENTS.md` Section 10 (Agent Skills):
   ```markdown
   - `.github/skills/your-skill-name/` — [one-line description]
   ```

4. Add example prompts for the new skill to `docs/PROMPT_LIBRARY.md` under
   "Using Agent Skills".

5. Update this README's skills table.

---

## Design principles

- **Load on demand** — Skills are not always in context. They are pulled in when referenced.
- **Single concern** — Each skill covers one domain. Keep them focused.
- **Actionable** — Every skill should contain commands, checklists, or templates an agent can
  use immediately, not just explanations.
- **Maintained** — When a skill produces bad output repeatedly, update it and add a changelog
  entry to `CHANGELOG.md`.
