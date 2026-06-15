---
name: tag-creation
description: "Create annotated Git tags for releases. Use when creating version tags, validating tag uniqueness, or pushing tags to remote."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Tag Creation

> **Load trigger:** `"load tag-creation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Create annotated Git tags for releases.

## Responsibilities

- Create tag with version and changelog summary
- Validate tag uniqueness
- Push tag

## Inputs

- `next-version.json`
- `CHANGELOG.md`

## Outputs

- `git-tag.txt`

## Tag Command

```bash
git tag -a v1.3.0 -m "Release v1.3.0

Features:
- Add user authentication
- Add rate limiting
- Add audit logging

Bug Fixes:
- Resolve login timeout
- Fix token refresh"
```

## Validation Rules

- [ ] Tag follows `v<semver>` format
- [ ] Tag does not already exist
- [ ] Tag message includes summary
- [ ] Tag pushed to remote

## Output Format

```json
{
  "skill": "tag-creation",
  "status": "success",
  "tag": "v1.3.0",
  "tag_sha": "abc1234",
  "message_lines": 8,
  "pushed": true
}
```

## Success Criteria

- Tag created and pushed
- Unique tag name
