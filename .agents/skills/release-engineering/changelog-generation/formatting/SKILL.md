---
name: changelog-formatting
description: "Format grouped commits into a clean, readable changelog. Use when generating CHANGELOG.md markdown or applying changelog templates."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Changelog Formatting

> **Load trigger:** `"load changelog-formatting skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Format grouped commits into a clean, readable changelog.

## Responsibilities

- Apply markdown formatting
- Insert version header
- Insert date
- Insert breaking change section

## Inputs

- `grouped-commits.json`

## Outputs

- `CHANGELOG.md`

## Markdown Format

```markdown
# Changelog

## [1.3.0] - 2025-01-15

### Breaking Changes
- None

### Features
- Add user authentication (#123)
- Add rate limiting (#124)
- Add audit logging (#125)

### Bug Fixes
- Resolve login timeout (#120)
- Fix token refresh (#121)

### Performance
- Optimize database queries (#122)

### Documentation
- Update API docs (#118)
- Add architecture guide (#119)
```

## Validation Rules

- [ ] Version header present
- [ ] Date formatted YYYY-MM-DD
- [ ] Sections in correct order
- [ ] Empty sections omitted or marked "None"
- [ ] Links to PRs/issues included

## Output Format

```json
{
  "skill": "changelog-formatting",
  "status": "success",
  "output_file": "CHANGELOG.md",
  "sections": 6,
  "entries": 12
}
```

## Success Criteria

- Clean, readable changelog
- Follows Keep a Changelog format
