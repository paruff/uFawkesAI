---
name: dev-experience
description: "Set up local development environment. Use when configuring devcontainers, workspace bootstrap, or local simulation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dev Experience

> **Load trigger:** `"load dev-experience skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Set up local development environment for fast feedback loops.

## Responsibilities

- Configure devcontainers
- Bootstrap workspace
- Set up local simulation
- Configure CLI tools
- Validate environment

## Sub-Skills

| Skill                         | Purpose                 |
| ----------------------------- | ----------------------- |
| `dev-experience/devcontainer` | Configure devcontainers |
| `dev-experience/workspace`    | Bootstrap workspace     |
| `dev-experience/local-sim`    | Set up local simulation |

## Dependencies

| Skill  | Relationship                      |
| ------ | --------------------------------- |
| (none) | Foundation skill, no dependencies |

## Inputs

- Project requirements
- Language/framework
- Tool requirements

## Outputs

- `.devcontainer/devcontainer.json`
- `Makefile` or `justfile`
- `.env.example`

## Setup Rules

### Devcontainer

- [ ] Base image defined
- [ ] Extensions configured
- [ ] Ports forwarded
- [ ] Volume mounts set
- [ ] Post-create command defined

### Workspace

- [ ] Dependencies installed
- [ ] Environment variables set
- [ ] Git hooks configured
- [ ] IDE settings configured

### Local Simulation

- [ ] Local cluster configured (kind/k3d)
- [ ] Services deployed locally
- [ ] Observability stack running
- [ ] Development workflow documented

## Output Format

```json
{
  "skill": "dev-experience",
  "status": "pass | fail",
  "artifacts": {
    "devcontainer": ".devcontainer/devcontainer.json",
    "makefile": "Makefile",
    "env_example": ".env.example"
  },
  "validation": {
    "devcontainer_valid": true,
    "workspace_ready": true,
    "local_sim_running": false
  }
}
```

## Success Criteria

- Devcontainer configured
- Workspace bootstrapped
- Local simulation available (optional)
- Development workflow documented
