---
name: conventional-commit-parsing
description: "Parse commit messages to determine semantic version increments. Use when analyzing commit history for version bumps or validating commit format."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Conventional Commit Parsing

> **Load trigger:** `"load conventional-commit-parsing skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Parse commit messages to determine semantic version increments.

## Responsibilities

- Detect feat/fix/breaking changes
- Compute version bump type
- Validate commit format

## Inputs

- Git commit history

## Outputs

- `commit-analysis.json`

## Commit Types

| Type | Bump | Example |
|------|------|---------|
| `feat:` | minor | `feat: add user auth` |
| `fix:` | patch | `fix: resolve login bug` |
| `feat!:` or `BREAKING CHANGE:` | major | `feat!: redesign API` |
| `docs:` | none | `docs: update README` |
| `refactor:` | none | `refactor: extract utils` |
| `perf:` | patch | `perf: optimize queries` |
| `chore:` | none | `chore: update deps` |

## Validation Rules

- [ ] All commits parsed
- [ ] Bump type correctly determined
- [ ] Breaking changes detected
- [ ] Invalid commits flagged

## Output Format

```json
{
  "skill": "conventional-commit-parsing",
  "total_commits": 25,
  "breaking": 0,
  "features": 3,
  "fixes": 5,
  "other": 17,
  "bump_type": "minor",
  "commits": [
    {"sha": "abc1234", "type": "feat", "message": "add user auth", "bump": "minor"}
  ]
}
```

## Success Criteria

- Accurate version bump detection
- All commits accounted for
