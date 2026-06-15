---
name: pipeline-security
description: "Validate that the CI/CD pipeline includes required security gates. Use when reviewing pipeline definitions for SAST, SCA, signing, and SBOM generation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Security Gate Validation

> **Load trigger:** `"load pipeline-security skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate that the CI/CD pipeline includes required security gates.

## Responsibilities

- Validate SAST stage presence and configuration
- Validate SCA stage presence and configuration
- Validate image/container signing stage
- Validate SBOM generation
- Validate artifact verification and provenance

## Inputs

- Pipeline definitions (`.github/workflows/`, `Jenkinsfile`, `.gitlab-ci.yml`, etc.)
- Pipeline configuration files

## Validation Rules

### Required Stages

- [ ] SAST scan runs on every PR/push
- [ ] SCA/dependency scan runs on every PR/push
- [ ] Container image scanning before push to registry
- [ ] Image signing (Cosign) after successful build
- [ ] SBOM generation (Syft) for each release artifact
- [ ] Artifact attestation for supply chain integrity

### Pipeline Hardening

- [ ] Actions pinned to commit SHAs, not floating tags
- [ ] Secrets accessed only via `${{ secrets.NAME }}` or equivalent
- [ ] No secrets echoed or logged in pipeline steps
- [ ] Least privilege permissions for workflow jobs
- [ ] Branch protection rules enforced

### Gating

- [ ] Security scans are required (not optional) for merge
- [ ] Build fails on critical/high findings
- [ ] Manual approval gate for security-sensitive changes
- [ ] Deployment blocked until security review passes

## Tools

- `yq` for YAML parsing
- Policy engine (OPA, Kyverno) for pipeline validation
- `gh api` for GitHub Actions workflow inspection

## Output Format

```json
{
  "skill": "pipeline-security",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "pipeline": "<pipeline name>",
      "stage": "<stage name or 'missing'>",
      "issue": "Description of the issue",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- Pipeline includes all required security gates
- Security scans are mandatory for merge
- No secrets exposed in pipeline logs
