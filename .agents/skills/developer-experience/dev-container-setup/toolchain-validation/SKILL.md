---
name: toolchain-validation
description: "Ensure all required tools for Fawkes development are installed and correct versions. Use when validating Node, Python, kubectl, kustomize, or Fawkes CLI versions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Toolchain Validation

> **Load trigger:** `"load toolchain-validation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Ensure all required tools for Fawkes development are installed and correct versions.

## Responsibilities

- Validate Node version
- Validate Python version
- Validate kubectl, kustomize, helm
- Validate Fawkes CLI

## Inputs

- Devcontainer environment

## Outputs

- `toolchain.json`

## Tool Requirements

| Tool | Min Version | Check Command |
|------|-------------|---------------|
| Node.js | 18 | `node --version` |
| Python | 3.10 | `python3 --version` |
| kubectl | 1.28 | `kubectl version --client` |
| kustomize | 5.0 | `kustomize version` |
| helm | 3.12 | `helm version` |
| Fawkes CLI | 1.0 | `fawkes --version` |
| Docker | 20 | `docker --version` |
| Git | 2.40 | `git --version` |

## Validation Rules

- [ ] All required tools installed
- [ ] Versions meet minimum requirements
- [ ] Tools in PATH
- [ ] No conflicting versions

## Output Format

```json
{
  "skill": "toolchain-validation",
  "status": "pass | fail",
  "tools": [
    {"name": "node", "installed": true, "version": "20.11.0", "min_version": "18", "status": "pass"},
    {"name": "kubectl", "installed": true, "version": "1.29.0", "min_version": "1.28", "status": "pass"}
  ],
  "missing": [],
  "version_mismatches": []
}
```

## Success Criteria

- All tools present and correct versions
- No missing tools
- No version conflicts
