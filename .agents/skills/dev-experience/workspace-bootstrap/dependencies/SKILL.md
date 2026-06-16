---
name: dependency-installation
description: "Install all project dependencies in a reproducible way. Use when installing Node/Python dependencies, validating lockfiles, or checking reproducibility."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dependency Installation

> **Load trigger:** `"load dependency-installation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Install all project dependencies in a reproducible way.

## Responsibilities

- Install Node dependencies (`npm ci` / `yarn --frozen-lockfile`)
- Install Python dependencies (`pip install -r requirements.txt`)
- Validate lockfiles present
- Validate reproducibility

## Inputs

- `package.json` / `yarn.lock` / `pnpm-lock.yaml`
- `requirements.txt` / `poetry.lock` / `Pipfile.lock`

## Outputs

- `dependency-install.json`

## Installation Rules

### Node

| Lock File           | Command                          |
| ------------------- | -------------------------------- |
| `package-lock.json` | `npm ci`                         |
| `yarn.lock`         | `yarn install --frozen-lockfile` |
| `pnpm-lock.yaml`    | `pnpm install --frozen-lockfile` |

### Python

| Lock File          | Command                           |
| ------------------ | --------------------------------- |
| `requirements.txt` | `pip install -r requirements.txt` |
| `poetry.lock`      | `poetry install --no-root`        |
| `Pipfile.lock`     | `pipenv install --deploy`         |

## Validation Rules

- [ ] Lock file exists
- [ ] Dependencies install without errors
- [ ] No unexpected version changes
- [ ] Dev dependencies included

## Output Format

```json
{
  "skill": "dependency-installation",
  "status": "success | failed",
  "runtime": "node",
  "lock_file": "package-lock.json",
  "dependencies_installed": 450,
  "dev_dependencies_installed": 120,
  "duration_seconds": 30
}
```

## Success Criteria

- All dependencies installed successfully
- Reproducible build
- No lockfile modifications
