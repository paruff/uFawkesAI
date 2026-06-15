---
name: gitops-environment-promotion
description: "Promote artifacts (images, manifests, versions) across environments (dev → stage → prod). Use when updating image tags, version metadata, environment overlays, or creating PRs for promotion."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Environment Promotion

> **Load trigger:** `"load gitops-environment-promotion skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Promote artifacts (images, manifests, versions) across environments (dev → stage → prod).

## Responsibilities

- Update image tags
- Update version metadata
- Update environment overlays
- Create PRs for promotion

## Inputs

- `version.json`
- GitOps repo

## Outputs

- `promotion-pr.md`
- Updated manifests

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `gitops-environment-promotion/image-tag` | Update image tags across overlays |
| `gitops-environment-promotion/overlay` | Promote environment-specific overlays |

## Promotion Flow

```
dev → staging → prod

1. Artifact passes dev gates
2. PR created for staging promotion
3. Artifact passes staging gates
4. PR created for prod promotion
5. Artifact deployed to prod
```

## Promotion Rules

| Environment | Gates Required | Approval |
|-------------|----------------|----------|
| dev | unit tests, lint | Auto |
| staging | integration tests, security scan | Auto |
| prod | e2e tests, manual review | Human |

## Validation Rules

- [ ] Correct version promoted
- [ ] PR created successfully
- [ ] All gates passed
- [ ] Overlay updated correctly

## Output Format

```json
{
  "skill": "gitops-environment-promotion",
  "status": "success",
  "from_env": "dev",
  "to_env": "staging",
  "version": "1.3.0",
  "pr_url": "https://github.com/paruff/uFawkesGitOps/pull/42",
  "gates_passed": ["unit_test", "lint", "security_scan"]
}
```

## Success Criteria

- Correct version promoted
- PR created successfully
