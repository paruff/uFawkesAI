---
name: git-tagging
description: "Create Git tags, GitHub releases, and attach artifacts. Use when tagging releases, pushing tags, creating GitHub releases, or attaching SBOM/provenance/changelog."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Git Tagging & Release Publishing

> **Load trigger:** `"load git-tagging skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Create Git tags, GitHub releases, and attach artifacts.

## Responsibilities

- Create annotated Git tags
- Push tags
- Create GitHub release
- Attach artifacts (SBOM, provenance, changelog)

## Inputs

- `next-version.json`
- `release.json`
- `CHANGELOG.md`

## Outputs

- `git-tag.txt`
- `release-url.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `git-tagging/tag-creation` | Create annotated Git tags |
| `git-tagging/release-publishing` | Publish GitHub releases with artifacts |

## Tag Format

```
v<version>
```

Example: `v1.3.0`

## Release Flow

```
1. Validate version.json
2. Create annotated Git tag
3. Push tag to remote
4. Create GitHub release
5. Attach SBOM
6. Attach provenance
7. Attach CHANGELOG.md
```

## Validation Rules

- [ ] Tag format valid
- [ ] Tag unique (not already exists)
- [ ] Tag pushed to remote
- [ ] GitHub release created
- [ ] All artifacts attached

## Output Format

```json
{
  "skill": "git-tagging",
  "status": "success",
  "tag": "v1.3.0",
  "tag_sha": "abc1234",
  "release_url": "https://github.com/paruff/uFawkesAI/releases/tag/v1.3.0",
  "artifacts_attached": 3
}
```

## Success Criteria

- Tag created and pushed
- Release published successfully
- All artifacts attached
