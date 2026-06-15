---
name: coder-workspace-validation
description: "Ensure devcontainers run correctly inside Coder workspaces. Use when validating Coder template, workspace image, resource limits, or startup scripts."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Coder Workspace Validation

> **Load trigger:** `"load coder-workspace-validation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Ensure devcontainers run correctly inside Coder workspaces.

## Responsibilities

- Validate Coder template
- Validate workspace image
- Validate resource limits
- Validate startup scripts

## Inputs

- Coder workspace config
- `.devcontainer/` directory

## Outputs

- `coder-workspace.json`

## Validation Rules

### Template

- [ ] Base image specified and buildable
- [ ] Resource limits defined (CPU, memory, disk)
- [ ] Startup script defined
- [ ] Extensions auto-installed

### Resources

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 2 cores | 4 cores |
| Memory | 4 GB | 8 GB |
| Disk | 20 GB | 50 GB |

### Startup

- [ ] Dependencies installed on start
- [ ] Git hooks configured
- [ ] Environment variables set
- [ ] Services started (if needed)

## Output Format

```json
{
  "skill": "coder-workspace-validation",
  "status": "pass | fail",
  "template": {
    "base_image": "valid",
    "resources": "sufficient",
    "startup_script": "defined"
  },
  "issues": []
}
```

## Success Criteria

- Workspace boots cleanly
- All tools available
- Startup completes without errors
