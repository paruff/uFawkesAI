---
name: release-publishing
description: "Publish GitHub releases with artifacts. Use when creating GitHub releases, attaching SBOM, provenance, or changelog to releases."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Release Publishing

> **Load trigger:** `"load release-publishing skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Publish GitHub releases with artifacts.

## Responsibilities

- Create GitHub release
- Attach SBOM
- Attach provenance
- Attach changelog

## Inputs

- `release.json`
- `CHANGELOG.md`
- `sbom.json`
- `provenance.json`

## Outputs

- `release-url.txt`

## Publish Command

```bash
gh release create v1.3.0 \
  --title "Release v1.3.0" \
  --notes-file CHANGELOG.md \
  sbom.json \
  provenance.json
```

## Artifacts

| Artifact | File | Description |
|----------|------|-------------|
| SBOM | `sbom.json` | Software bill of materials |
| Provenance | `provenance.json` | Build provenance |
| Changelog | `CHANGELOG.md` | Human-readable changes |

## Validation Rules

- [ ] Release created successfully
- [ ] All artifacts attached
- [ ] Release notes include changelog
- [ ] Release URL accessible

## Output Format

```json
{
  "skill": "release-publishing",
  "status": "success",
  "release_url": "https://github.com/paruff/uFawkesAI/releases/tag/v1.3.0",
  "tag": "v1.3.0",
  "artifacts": [
    {"name": "sbom.json", "size_bytes": 52000},
    {"name": "provenance.json", "size_bytes": 1200},
    {"name": "CHANGELOG.md", "size_bytes": 3400}
  ]
}
```

## Success Criteria

- Release published successfully
- All artifacts attached
- Release accessible at URL
