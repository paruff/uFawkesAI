# Rules (moved)

The rule files that used to live here (`testing.md`, `security.md`,
`api-design.md`, `gitops.md`) are now skills, loaded on-demand by both
OpenCode and Claude Code instead of being static reference docs:

- `.opencode/skills/testing-rules/SKILL.md`
- `.opencode/skills/security-rules/SKILL.md`
- `.opencode/skills/api-design-rules/SKILL.md`
- `.opencode/skills/gitops-rules/SKILL.md`

(Also visible at `.claude/skills/<name>/SKILL.md` — `.claude/skills` is a
symlink to `.opencode/skills`, so there is exactly one copy of each file.)
