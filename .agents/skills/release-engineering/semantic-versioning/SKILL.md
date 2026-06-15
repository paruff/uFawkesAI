---
name: semantic-versioning
description: "Generate and validate semantic versions for all Fawkes releases (OBS, PIPE, CLI, templates). Use when computing next version, validating version.json, or checking version consistency."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Semantic Versioning

> **Load trigger:** `"load semantic-versioning skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Generate and validate semantic versions for all Fawkes releases (OBS, PIPE, CLI, templates).

## Responsibilities

- Parse commit history
- Detect breaking changes
- Compute next version (major/minor/patch)
- Validate version.json
- Validate version consistency across artifacts

## Inputs

- Git commit history
- `version.json`

## Outputs

- `next-version.json`
- `version-report.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `semantic-versioning/commit-parsing` | Parse commits for version bumps |
| `semantic-versioning/version-consistency` | Validate version alignment across artifacts |

## Tools

- Conventional Commits parser
- Git CLI

## Validation Rules

- [ ] version.json exists and is valid
- [ ] Next version follows semver
- [ ] No version drift between version.json and Git tags
- [ ] Breaking changes trigger major bump
- [ ] Features trigger minor bump
- [ ] Fixes trigger patch bump

## Output Format

```json
{
  "skill": "semantic-versioning",
  "current_version": "1.2.3",
  "next_version": "1.3.0",
  "bump_type": "minor",
  "breaking_changes": 0,
  "features": 3,
  "fixes": 5,
  "consistency": "pass"
}
```

## Success Criteria

- Correct semantic version computed
- No version drift
