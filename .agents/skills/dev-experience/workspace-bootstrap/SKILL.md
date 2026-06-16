---
name: workspace-bootstrap
description: "Automate initial project setup for developers. Use when installing dependencies, generating environment files, configuring Git hooks, or bootstrapping local clusters."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Workspace Bootstrap

> **Load trigger:** `"load workspace-bootstrap skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Automate initial project setup for developers.

## Responsibilities

- Install dependencies
- Generate environment files
- Configure Git hooks
- Bootstrap local cluster (optional)
- Bootstrap GitOps repo clone

## Inputs

- Project repo
- `bootstrap.sh` or `bootstrap.ts`

## Outputs

- `bootstrap-report.json`

## Sub-Skills

| Skill                                | Purpose                      |
| ------------------------------------ | ---------------------------- |
| `workspace-bootstrap/dependencies`   | Install project dependencies |
| `workspace-bootstrap/env-generation` | Generate `.env.local` files  |

## Bootstrap Steps

| Step | Action                | Required |
| ---- | --------------------- | -------- |
| 1    | Install dependencies  | Yes      |
| 2    | Generate `.env.local` | Yes      |
| 3    | Configure Git hooks   | Yes      |
| 4    | Start local cluster   | Optional |
| 5    | Clone GitOps repo     | Optional |
| 6    | Validate environment  | Yes      |

## Rules

- [ ] Bootstrap completes in < 60 seconds
- [ ] All steps logged
- [ ] Failures reported clearly
- [ ] Idempotent (safe to re-run)

## Tools

- Node / npm
- Python / pip
- Git CLI

## Success Criteria

- Developer can run the project immediately
- No manual steps required
