---
name: ci-version-file
description: "Generate version.json for downstream OBS and GitOps stages. Use when computing version, embedding commit SHA, build timestamp, or image digest."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Version File Generation

> **Load trigger:** `"load ci-version-file skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Generate `version.json` for downstream OBS and GitOps stages.

## Responsibilities

- Compute version (from tag, branch, or commit)
- Embed commit SHA
- Embed build timestamp
- Embed image digest

## Inputs

- Git metadata
- Image digest

## Outputs

- `version.json`

## Version Computation

| Source | Version Format | Example |
|--------|---------------|---------|
| Git tag | `v1.2.3` | `v1.2.3` |
| Branch `main` | `main-<sha>-<timestamp>` | `main-abc123-20250115` |
| Branch `feature/*` | `feature-<sha>-<timestamp>` | `feature-abc123-20250115` |
| PR | `pr-<number>-<sha>` | `pr-42-abc123` |

## version.json Schema

```json
{
  "version": "v1.2.3",
  "commit_sha": "abc123def456",
  "branch": "main",
  "build_timestamp": "2025-01-15T10:30:00Z",
  "image": {
    "registry": "ghcr.io",
    "repository": "myorg/myapp",
    "tag": "v1.2.3",
    "digest": "sha256:...",
    "full": "ghcr.io/myorg/myapp:v1.2.3@sha256:..."
  }
}
```

## Validation Rules

- [ ] Valid semver or branch-based version
- [ ] Commit SHA is full 40-char SHA
- [ ] Timestamp is ISO 8601 UTC
- [ ] Image digest matches built image

## Output Format

```json
{
  "skill": "ci-version-file",
  "status": "success",
  "version": "v1.2.3",
  "version_file": "version.json"
}
```

## Success Criteria

- Valid `version.json` produced
- All fields populated correctly
- Downstream stages can consume
