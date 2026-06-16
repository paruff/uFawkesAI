---
name: dev-container-setup
description: "Provide a reproducible, standardized development environment for all Fawkes projects using devcontainers. Use when validating devcontainer.json, Dockerfile.dev, required tools, or Coder compatibility."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dev Container Setup

> **Load trigger:** `"load dev-container-setup skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Provide a reproducible, standardized development environment for all Fawkes projects using devcontainers.

## Responsibilities

- Validate `devcontainer.json`
- Validate `Dockerfile.dev`
- Validate required tools (Node, Python, Fawkes CLI, kubectl, kustomize)
- Validate VS Code extensions
- Validate Coder compatibility

## Inputs

- `.devcontainer/` directory
- Project repo

## Outputs

- `devcontainer-report.json`
- `missing-tools.txt`

## Sub-Skills

| Skill                                      | Purpose                         |
| ------------------------------------------ | ------------------------------- |
| `dev-container-setup/toolchain-validation` | Verify tools and versions       |
| `dev-container-setup/coder-validation`     | Validate Coder workspace config |

## Validation Rules

### devcontainer.json

- [ ] Base image specified
- [ ] Features defined
- [ ] Extensions listed
- [ ] Post-create command defined
- [ ] ForwardPorts configured (if needed)

### Required Tools

| Tool       | Version | Required          |
| ---------- | ------- | ----------------- |
| Node.js    | ≥ 18    | Yes               |
| Python     | ≥ 3.10  | If Python project |
| kubectl    | Latest  | If K8s            |
| kustomize  | Latest  | If GitOps         |
| Fawkes CLI | Latest  | Yes               |
| Docker     | ≥ 20    | Yes               |

## Tools

- Devcontainer CLI
- Docker CLI

## Success Criteria

- Devcontainer builds successfully
- All required tools installed
- Developer can start coding immediately
