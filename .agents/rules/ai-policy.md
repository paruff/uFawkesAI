# Rule: AI policy

> Always loaded (`.claude/rules/` in Claude Code, `instructions` in `opencode.json`).
> Applies when: any change to AI tooling, models, agents, skills, or `AI_STANCE.md`.

- `AI_STANCE.md` must carry all three policy buckets and a `Last reviewed:` date.
- Adopting a new AI tool or model means updating `AI_STANCE.md` in the same PR.
- Enforcement: `scripts/check-ai-stance.sh` (pre-commit and preflight). Use the
  `ai-stance` skill to write or refresh the stance.
