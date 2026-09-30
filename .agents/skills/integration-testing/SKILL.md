---
name: integration-testing
description: "Validate the entire OBS + PIPE + GitOps + K8s flow end-to-end, and full system behavior from user's perspective. Implements DORA AI Capabilities 4, 5, 6, 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: integration-testing

> **Load trigger:** "load integration-testing skill" > **DORA:** AI Capabilities 4, 5, 6, 7
> **Token cost:** Medium

## Purpose

Validate the entire OBS + PIPE + GitOps + K8s flow end-to-end AND full system behavior from the user's perspective. Runs full pipeline, validates GitOps update, reconciliation, deployment, and end-to-end tests to verify complete workflows and acceptance criteria. Implements DORA AI Capabilities 4, 5, 6, 7.

## When to Use

- Running full pipeline integration tests
- Validating GitOps update and reconciliation
- Validating deployment and smoke tests
- Running end-to-end tests to verify complete workflows and acceptance criteria

## Sub-skills (now integrated)

### Full Stack

# Skill: Full Stack Integration Testing

> **Load trigger:** `"load full-stack-integration skill"` > **DORA:** Core: CI/CD automation
> **Token cost:** Low

## Purpose

Validate the entire OBS + PIPE + GitOps + K8s flow end-to-end.

## Responsibilities

- Run full pipeline
- Validate GitOps update
- Validate reconciliation
- Validate deployment
- Validate smoke tests

## Inputs

- Full system

## Outputs

- `full-integration-report.json`
- `cluster-state.json`

## Sub-Skills

| Skill                      | Purpose                            |
| -------------------------- | ---------------------------------- |
| `full-stack/cluster-state` | Validate cluster state matches Git |
| `full-stack/smoke-tests`   | Validate deployed application      |

## Full Stack Flow

```
1. Code change triggers PIPE
2. PIPE builds, tests, scans
3. PIPE produces artifacts (image, SBOM, signature)
4. OBS receives artifacts
5. OBS updates GitOps repo
6. Controller reconciles
7. K8s deploys
8. Smoke tests validate
```

## Validation Rules

- [ ] Full pipeline completes
- [ ] GitOps update valid
- [ ] Reconciliation successful
- [ ] Deployment healthy
- [ ] Smoke tests pass

## Output Format

```json
{
  "skill": "full-stack-integration",
  "status": "pass | fail",
  "pipeline": { "status": "pass", "time_s": 300 },
  "gitops_update": { "status": "pass", "commit": "abc123" },
  "reconciliation": { "status": "pass", "time_s": 60 },
  "deployment": { "status": "pass", "replicas": 3 },
  "smoke_tests": { "status": "pass", "tests": 10 }
}
```

## Success Criteria

- End-to-end correctness
- Healthy deployment

### Gitops To Controller

# Skill: GitOps → Controller Integration Testing

> **Load trigger:** `"load gitops-to-controller-integration skill"` > **DORA:** Core: CI/CD automation
> **Token cost:** Low

## Purpose

Validate Flux or ArgoCD reconciliation behavior after GitOps updates.

## Responsibilities

- Trigger reconciliation
- Validate applied manifests
- Validate rollout behavior
- Validate health checks

## Inputs

- GitOps repo
- Cluster

## Outputs

- `controller-integration-report.json`
- `rollout-status.json`

## Sub-Skills

| Skill                       | Purpose                    |
| --------------------------- | -------------------------- |
| `gitops-to-controller/flux` | Flux integration testing   |
| `gitops-to-controller/argo` | ArgoCD integration testing |

## Validation Rules

- [ ] Reconciliation triggered successfully
- [ ] Manifests applied correctly
- [ ] Rollout successful
- [ ] Health checks pass
- [ ] No controller errors

## Output Format

```json
{
  "skill": "gitops-to-controller-integration",
  "status": "pass | fail",
  "controller": "flux",
  "reconciliation": {
    "triggered": true,
    "applied": true,
    "time_s": 30
  },
  "rollout": {
    "status": "successful",
    "time_s": 60
  },
  "health": "healthy"
}
```

## Success Criteria

- Successful reconciliation
- Healthy rollout

### Obs To Gitops

# Skill: OBS → GitOps Integration Testing

> **Load trigger:** `"load obs-to-gitops-integration skill"` > **DORA:** Core: CI/CD automation
> **Token cost:** Low

## Purpose

Validate that OBS writes correct manifests to the GitOps repo.

## Responsibilities

- Validate commit structure
- Validate overlays
- Validate environment resolution
- Validate manifest correctness

## Inputs

- OBS output
- GitOps repo

## Outputs

- `obs-gitops-report.json`
- `manifest-diff.txt`

## Sub-Skills

| Skill                              | Purpose                       |
| ---------------------------------- | ----------------------------- |
| `obs-to-gitops/overlay-resolution` | Validate overlay resolution   |
| `obs-to-gitops/commit-validation`  | Validate Git commit structure |

## Validation Rules

- [ ] Valid GitOps commits
- [ ] Correct overlays
- [ ] No schema violations
- [ ] Commit message follows convention
- [ ] Files changed correctly

## Output Format

```json
{
  "skill": "obs-to-gitops-integration",
  "status": "pass | fail",
  "commit": {
    "sha": "abc123",
    "message": "chore: update image to v1.3.0",
    "files_changed": 3
  },
  "overlays": {
    "dev": "pass",
    "staging": "pass",
    "prod": "pass"
  },
  "manifests_valid": true
}
```

## Success Criteria

- Valid GitOps commits
- Correct overlays
- No schema violations

### Pipe To Obs

# Skill: PIPE → OBS Integration Testing

> **Load trigger:** `"load pipe-to-obs-integration skill"` > **DORA:** Core: CI/CD automation
> **Token cost:** Low

## Purpose

Validate artifact flow and GitOps updates triggered by PIPE.

## Responsibilities

- Execute a full PIPE build
- Validate that OBS receives correct artifacts
- Validate that OBS updates GitOps manifests correctly
- Validate version.json, SBOM, signatures, and image digests

## Inputs

- Pipeline run
- `version.json`
- GitOps repo

## Outputs

- `pipe-obs-report.json`
- `manifest-diff.txt`

## Sub-Skills

| Skill                         | Purpose                                      |
| ----------------------------- | -------------------------------------------- |
| `pipe-to-obs/artifact-flow`   | Validate artifact production and consumption |
| `pipe-to-obs/manifest-update` | Validate manifest updates                    |

## Integration Flow

```
PIPE build → artifacts → OBS receives → OBS updates GitOps → manifests validated
```

## Validation Rules

- [ ] Correct image tag passed to OBS
- [ ] Correct image digest passed to OBS
- [ ] OBS creates valid Git commit
- [ ] Manifests valid YAML
- [ ] No schema violations

## Output Format

```json
{
  "skill": "pipe-to-obs-integration",
  "status": "pass | fail",
  "pipeline_run": "123",
  "artifacts": {
    "version_json": "present",
    "sbom": "present",
    "signature": "present",
    "image_digest": "present"
  },
  "obs_update": {
    "commit": "abc123",
    "files_changed": 3,
    "manifests_valid": true
  }
}
```

## Success Criteria

- Correct image tag and digest passed to OBS
- Correct GitOps update created
- No invalid manifests

## Usage

```bash
# Full stack integration
load integration-testing/full-stack skill

# GitOps to controller
load integration-testing/gitops-to-controller skill

# OBS to GitOps
load integration-testing/obs-to-gitops skill

# PIPE to OBS
load integration-testing/pipe-to-obs skill

# Deployment validation
load integration-testing/e2e-deployment-validation skill

# Failure paths
load integration-testing/e2e-failure-paths skill

# Happy path
load integration-testing/e2e-happy-path skill

# Rollback
load integration-testing/e2e-rollback skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 4, 5, 6, 7 references
- **AI stance audit** validates relevant clarity dimensions
