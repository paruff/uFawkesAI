---
name: ci-environment-validation
description: "Ensure the CI environment is reproducible, secure, and aligned with pipeline-spec.yaml. Use when validating runner OS, tools, environment variables, secrets, or workspace."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Environment Validation

> **Load trigger:** `"load ci-environment-validation skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure the CI environment is reproducible, secure, and aligned with `pipeline-spec.yaml`.

## Responsibilities

- Validate runner OS and architecture
- Validate required tools (Node, Python, Docker, kubectl, kustomize)
- Validate environment variables
- Validate secrets availability
- Validate workspace cleanliness

## Inputs

- CI runner environment
- `pipeline-spec.yaml`

## Outputs

- `ci-env-report.json`
- `missing-tools.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-environment-validation/toolchain` | Verify required tools and versions |
| `ci-environment-validation/secrets` | Validate secrets and tokens |

## Validation Rules

### Runner Environment

| Check | Required |
|-------|----------|
| OS matches pipeline-spec | Yes |
| Architecture matches pipeline-spec | Yes |
| Sufficient disk space | Yes |
| Sufficient memory | Yes |

### Workspace

| Check | Required |
|-------|----------|
| Clean workspace (or explicit cache) | Yes |
| Git repo cloned | Yes |
| Branch checked out | Yes |

## Tools

- CLI version checks
- `yq` for pipeline-spec parsing

## Success Criteria

- All required tools present
- No environment drift
- Workspace ready for CI
