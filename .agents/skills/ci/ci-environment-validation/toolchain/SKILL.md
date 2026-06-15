---
name: ci-toolchain
description: "Ensure all required tools for CI are installed and correct versions. Use when validating Node, Python, Docker, kubectl, kustomize, Cosign, Syft, or Trivy."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Toolchain Verification

> **Load trigger:** `"load ci-toolchain skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure all required tools for CI are installed and correct versions.

## Responsibilities

- Validate Node, Python, Docker
- Validate kubectl, kustomize, helm
- Validate Fawkes CLI
- Validate Cosign, Syft, Trivy

## Inputs

- CI environment
- `pipeline-spec.yaml` (tool version requirements)

## Outputs

- `toolchain.json`

## Tool Requirements

| Tool | Required | Version Check |
|------|----------|---------------|
| Node.js | If JS project | `node --version` |
| Python | If Python project | `python --version` |
| Docker | If container build | `docker --version` |
| kubectl | If K8s deploy | `kubectl version --client` |
| kustomize | If GitOps | `kustomize version` |
| Cosign | If signing | `cosign version` |
| Syft | If SBOM | `syft version` |
| Trivy | If vuln scan | `trivy --version` |

## Validation Rules

- [ ] All required tools installed
- [ ] Versions match pipeline-spec requirements
- [ ] Tools in PATH
- [ ] No conflicting versions

## Output Format

```json
{
  "skill": "ci-toolchain",
  "status": "pass | fail",
  "tools": [
    {"name": "node", "installed": true, "version": "20.11.0", "required": ">=18"},
    {"name": "docker", "installed": true, "version": "24.0.7", "required": ">=20"},
    {"name": "cosign", "installed": true, "version": "2.2.0", "required": ">=2.0"}
  ],
  "missing": [],
  "version_mismatches": []
}
```

## Success Criteria

- All tools present and correct versions
- No missing tools
- No version conflicts
