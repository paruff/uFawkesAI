---
name: commit-grouping
description: "Group commits into categories for changelog generation. Use when categorizing commits by type or detecting breaking changes."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Commit Grouping

> **Load trigger:** `"load commit-grouping skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Group commits into categories for changelog generation.

## Responsibilities

- Group by feat/fix/docs/refactor/perf
- Detect breaking changes
- Format entries

## Inputs

- Commit list (from commit-parsing)

## Outputs

- `grouped-commits.json`

## Grouping Rules

| Group | Pattern | Priority |
|-------|---------|----------|
| Breaking | `feat!:`, `BREAKING CHANGE:` | 1 (top) |
| Features | `feat:` | 2 |
| Bug Fixes | `fix:` | 3 |
| Performance | `perf:` | 4 |
| Documentation | `docs:` | 5 |
| Refactoring | `refactor:` | 6 |
| Chores | `chore:` | 7 (bottom) |

## Validation Rules

- [ ] All commits grouped
- [ ] No commits in multiple groups
- [ ] Breaking changes isolated
- [ ] Group order correct

## Output Format

```json
{
  "skill": "commit-grouping",
  "groups": {
    "breaking": [],
    "features": [
      {"sha": "abc1234", "message": "add user auth"}
    ],
    "fixes": [
      {"sha": "def5678", "message": "resolve login bug"}
    ],
    "performance": [],
    "documentation": [],
    "refactoring": [],
    "chores": []
  }
}
```

## Success Criteria

- Correct grouping
- All commits categorized
