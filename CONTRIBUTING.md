# Contributing to uFawkesAI

Thank you for helping improve uFawkesAI.

## Who this template is for

This template is for PMs, tech leads, and contributors who want AI agents (Copilot, Claude Code, Cursor, Codex, and others) to produce reliable, reviewable output aligned with DORA AI Capabilities.

## How to contribute

1. Fork this repository.
2. Customize placeholders in your fork, starting with `AGENTS.md`.
3. Test your change with at least one real agent in a realistic workflow.
4. Run `npm run preflight` (currently a placeholder gate in this template until real lint/typecheck/test tooling is configured).
5. Open a PR with a clear description of what changed and what agent testing you performed.

## What makes a good contribution

A good contribution:

- References at least one DORA AI Capability and explains why it matters.
- Is tested with at least one real agent, and states:
  - which agent you used, and
  - what you tested.
- Does not increase `AGENTS.md` line count unless equivalent content is moved to `docs/`.
- Keeps changes small, reviewable, and aligned with existing structure.

## How to add a prompt to the Prompt Library

Update `docs/PROMPT_LIBRARY.md` using the existing category structure and style.

For each prompt, include:

- Task type (for example: code review, debugging, security review).
- Target agent(s).
- Required context files to open.
- Prompt template with placeholders.
- Expected output.
- Red flags / failure signals.
- DORA AI Capability addressed.

Testing and versioning requirements:

1. Test the prompt with at least one real agent and a real task.
2. Record what you tested and whether output matched expectations.
3. Update the Prompt Library changelog table with date, change, and reason.

## How to add an Agent Skill

Place new skills in:

`.github/skills/<skill-name>/SKILL.md`

Use the `SKILL.md` format already present in `.github/skills/`:

```md
# <skill-name>

Use this skill for <purpose>.

Status: <state>.
```

Keep skill instructions concise, specific, and reusable.

## Code of conduct

This project follows the Contributor Covenant Code of Conduct:
https://www.contributor-covenant.org/version/2/1/code_of_conduct/
