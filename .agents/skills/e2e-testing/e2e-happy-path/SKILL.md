---
name: e2e-happy-path
description: "Validate the full pipeline success path from commit to deployment. Use when triggering a full CI pipeline run, validating build artifacts, GitOps update, reconciliation, deployment, or running smoke tests."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: E2E Happy Path Testing

> **Load trigger:** `"load e2e-happy-path skill"` > **DORA:** Cap 4 (CI/CD Automation) + Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate the full pipeline success path from commit to deployment.

## Responsibilities

- Trigger a full CI pipeline run
- Validate build artifacts (image, SBOM, signature)
- Validate GitOps update
- Validate reconciliation
- Validate deployment
- Run smoke tests

## Inputs

- Full system
- `version.json`
- GitOps repo

## Outputs

- `e2e-happy.json`
- `screenshots/`
- `videos/`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `e2e-happy-path/pipeline-execution` | Validate CI pipeline stages |
| `e2e-happy-path/smoke-tests` | Validate deployed application |

## Happy Path Flow

```
1. Code commit triggers CI
2. CI: type-check, lint, SAST, build, test
3. CI: publish artifacts (image, SBOM, signature)
4. OBS: update GitOps repo
5. Controller: reconcile manifests
6. K8s: deploy application
7. Smoke tests: validate health
```

## Validation Rules

- [ ] Full pipeline success
- [ ] All artifacts produced
- [ ] GitOps update valid
- [ ] Reconciliation successful
- [ ] Deployment healthy
- [ ] Smoke tests pass

## Output Format

```json
{
  "skill": "e2e-happy-path",
  "status": "pass | fail",
  "pipeline": {"status": "pass", "time_s": 300},
  "artifacts": {"image": "pass", "sbom": "pass", "signature": "pass"},
  "gitops_update": {"status": "pass", "commit": "abc123"},
  "reconciliation": {"status": "pass", "time_s": 60},
  "deployment": {"status": "pass", "replicas": 3},
  "smoke_tests": {"status": "pass", "tests": 10}
}
```

## Success Criteria

- Full pipeline success
- Healthy deployment
