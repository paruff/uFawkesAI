---
name: changelog-generation
description: "Generate human-readable changelogs for each release. Use when generating CHANGELOG.md, parsing commits since last tag, or grouping changes by type."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Changelog Generation

> **Load trigger:** `"load changelog-generation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Generate human-readable changelogs for each release.

## Responsibilities

- Parse commits since last tag
- Group changes by type
- Generate CHANGELOG.md entries
- Validate formatting

## Inputs

- Git commit history
- Previous tags

## Outputs

- `CHANGELOG.md`
- `changelog.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `changelog-generation/commit-grouping` | Group commits into categories |
| `changelog-generation/formatting` | Format grouped commits into markdown |

## Changelog Sections

| Section | Commit Types |
|---------|-------------|
| Breaking Changes | `feat!:`, `BREAKING CHANGE:` |
| Features | `feat:` |
| Bug Fixes | `fix:` |
| Performance | `perf:` |
| Documentation | `docs:` |
| Refactoring | `refactor:` |
| Chores | `chore:` |

## Validation Rules

- [ ] All commits since last tag included
- [ ] Changes grouped correctly
- [ ] Breaking changes at top
- [ ] Markdown formatting valid
- [ ] Date included

## Output Format

```json
{
  "skill": "changelog-generation",
  "status": "success",
  "version": "1.3.0",
  "previous_tag": "1.2.3",
  "commits_since": 25,
  "sections": {
    "breaking": 0,
    "features": 3,
    "fixes": 5,
    "performance": 1,
    "other": 16
  }
}
```

## Success Criteria

- Accurate, readable changelog
- All changes captured
