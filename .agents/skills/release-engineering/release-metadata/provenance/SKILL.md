---
name: provenance-generation
description: "Generate provenance metadata for supply-chain security. Use when capturing build environment, commit SHA, artifact digests, or generating provenance.json."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Provenance Generation

> **Load trigger:** `"load provenance generation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Generate provenance metadata for supply-chain security.

## Responsibilities

- Capture build environment
- Capture commit SHA
- Capture artifact digests
- Generate provenance.json

## Inputs

- Build artifacts
- Git metadata
- CI environment info

## Outputs

- `provenance.json`

## Provenance Fields

| Field | Source | Description |
|-------|--------|-------------|
| `build_type` | CI | e.g. `github-actions` |
| `builder_id` | CI | Builder identifier |
| `commit_sha` | Git | Exact commit built |
| `source_uri` | Git | Repository URL |
| `build_config` | CI | Pipeline definition |
| `materials` | Registry | Input artifacts |
| `metadata` | CI | Build timestamp, invocation |

## SLSA Levels

| Level | Requirements |
|-------|-------------|
| SLSA 1 | Provenance exists |
| SLSA 2 | Provenance signed, build service |
| SLSA 3 | Hardened build, hermetic, non-falsifiable |

## Validation Rules

- [ ] All required fields present
- [ ] Commit SHA matches Git
- [ ] Build config documented
- [ ] Materials listed
- [ ] Provenance signed

## Output Format

```json
{
  "skill": "provenance-generation",
  "status": "success",
  "slsa_level": 2,
  "build_type": "github-actions",
  "commit_sha": "abc1234",
  "builder": "https://github.com/actions/runner",
  "materials": ["my-app:v1.3.0"],
  "signed": true
}
```

## Success Criteria

- Valid provenance metadata
- Signed and verifiable
