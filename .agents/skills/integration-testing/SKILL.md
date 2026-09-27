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

### 1. Integration Testing (OBS + PIPE + GitOps + K8s)

# Skill: integration-testing

> **Load trigger:** "load integration-testing skill" > **DORA:** AI Capabilities 4, 7
> **Token cost:** Medium

## Purpose

Validate the entire OBS + PIPE + GitOps + K8s flow end-to-end. Runs full pipeline, validates GitOps update, reconciliation, deployment, and smoke tests. Implements DORA AI Capabilities 4, 7.

## When to Use

- Running full pipeline integration tests
- Validating GitOps update and reconciliation
- Validating deployment and smoke tests

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
# Run full stack integration
load integration-testing/full-stack skill

# Validate GitOps to controller
load integration-testing/gitops-to-controller skill

# Validate OBS to GitOps
load integration-testing/obs-to-gitops skill

# Validate PIPE to OBS
load integration-testing/pipe-to-obs skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 4, 7 references
- **AI stance audit** validates relevant clarity dimensions

### 2. End-to-End Testing (User Perspective)

# Skill: e2e-testing

> **Load trigger:** "load e2e-testing skill" > **DORA:** AI Capabilities 4, 5, 6, 7
> **Token cost:** Medium

## Purpose

Validate full system behavior from the user's perspective. Runs end-to-end tests to verify complete workflows and acceptance criteria. Implements DORA AI Capabilities 4, 5, 6, 7.

## When to Use

- Running end-to-end tests to verify complete workflows
- Validating deployment validation, failure paths, happy path, rollback

## Sub-skills (now integrated)

### E2E Deployment Validation

# Skill: E2E Deployment Validation

> **Load trigger:** `"load e2e-deployment-validation skill"` > **DORA:** Core: CI/CD automation + Core: Operational visibility
> **Token cost:** Low

## Purpose

Validate that the deployed application behaves correctly after reconciliation.

## Responsibilities

- Validate rollout status
- Validate health checks
- Validate logs
- Validate metrics
- Validate trace propagation

## Inputs

- Deployed environment

## Outputs

- `deployment-validation.json`
- `rollout-status.json`

## Sub-Skills

| Skill                                 | Purpose                        |
| ------------------------------------- | ------------------------------ |
| `e2e-deployment-validation/rollout`   | Validate rollout behavior      |
| `e2e-deployment-validation/telemetry` | Validate logs, metrics, traces |

## Validation Rules

- [ ] Healthy rollout
- [ ] No errors in logs
- [ ] Valid metrics
- [ ] Valid traces

## Output Format

```json
{
  "skill": "e2e-deployment-validation",
  "status": "pass | fail",
  "rollout": { "status": "pass", "replicas": 3, "ready": 3 },
  "health": { "liveness": "pass", "readiness": "pass" },
  "logs": { "errors": 0, "warnings": 0 },
  "metrics": { "present": true, "golden_signals": "complete" },
  "traces": { "propagating": true }
}
```

## Success Criteria

- Healthy rollout
- No errors in logs
- Valid metrics and traces

### E2E Failure Paths

# Skill: E2E Failure Path Testing

> **Load trigger:** `"load e2e-failure-paths skill"` > **DORA:** Core: Operational resilience
> **Token cost:** Low

## Purpose

Validate pipeline behavior under failure conditions.

## Responsibilities

- Simulate test failures
- Simulate SAST failures
- Simulate build failures
- Validate no GitOps update occurs
- Validate correct error propagation

## Inputs

- Failure scenarios

## Outputs

- `e2e-failure.json`

## Sub-Skills

| Skill                                   | Purpose                     |
| --------------------------------------- | --------------------------- |
| `e2e-failure-paths/pipeline-failures`   | Negative pipeline scenarios |
| `e2e-failure-paths/manifest-protection` | Invalid manifest protection |

## Failure Scenarios

| Scenario                 | Expected Behavior                |
| ------------------------ | -------------------------------- |
| Unit test failure        | Pipeline stops, no GitOps update |
| Integration test failure | Pipeline stops, no GitOps update |
| SAST failure             | Pipeline stops, no GitOps update |
| Build failure            | Pipeline stops, no GitOps update |
| Invalid manifest         | Pipeline stops, no GitOps update |

## Validation Rules

- [ ] No invalid GitOps updates
- [ ] Correct failure behavior
- [ ] Error propagation correct
- [ ] Pipeline stops cleanly

## Output Format

```json
{
  "skill": "e2e-failure-paths",
  "status": "pass | fail",
  "scenarios": {
    "unit_test_failure": { "stopped": true, "gitops_update": false },
    "sast_failure": { "stopped": true, "gitops_update": false },
    "build_failure": { "stopped": true, "gitops_update": false },
    "invalid_manifest": { "stopped": true, "gitops_update": false }
  },
  "total_scenarios": 4,
  "all_correct": true
}
```

## Success Criteria

- No invalid GitOps updates
- Correct failure behavior

### E2E Happy Path

# Skill: E2E Happy Path Testing

> **Load trigger:** `"load e2e-happy-path skill"` > **DORA:** Core: CI/CD automation + Core: Operational resilience
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

| Skill                               | Purpose                       |
| ----------------------------------- | ----------------------------- |
| `e2e-happy-path/pipeline-execution` | Validate CI pipeline stages   |
| `e2e-happy-path/smoke-tests`        | Validate deployed application |

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
  "pipeline": { "status": "pass", "time_s": 300 },
  "artifacts": { "image": "pass", "sbom": "pass", "signature": "pass" },
  "gitops_update": { "status": "pass", "commit": "abc123" },
  "reconciliation": { "status": "pass", "time_s": 60 },
  "deployment": { "status": "pass", "replicas": 3 },
  "smoke_tests": { "status": "pass", "tests": 10 }
}
```

## Success Criteria

- Full pipeline success
- Healthy deployment

### E2E Rollback

# Skill: E2E Rollback Testing

> **Load trigger:** `"load e2e-rollback skill"` > **DORA:** Core: Operational resilience
> **Token cost:** Low

## Purpose

Validate rollback behavior under deployment failure.

## Responsibilities

- Trigger failed deployment
- Validate rollback
- Validate GitOps state consistency
- Validate cluster state consistency

## Inputs

- Failure scenario

## Outputs

- `rollback-report.json`
- `cluster-diff.txt`

## Sub-Skills

| Skill                           | Purpose                    |
| ------------------------------- | -------------------------- |
| `e2e-rollback/trigger`          | Trigger controlled failure |
| `e2e-rollback/state-validation` | Validate rollback state    |

## Rollback Flow

```
1. Deploy invalid manifest
2. Controller detects failure
3. Controller triggers rollback
4. Previous version restored
5. GitOps state consistent
6. Cluster state consistent
```

## Validation Rules

- [ ] Rollback triggered correctly
- [ ] Previous version restored
- [ ] GitOps state consistent
- [ ] Cluster state consistent
- [ ] No drift

## Output Format

```json
{
  "skill": "e2e-rollback",
  "status": "pass | fail",
  "trigger": { "invalid_manifest_injected": true },
  "rollback": { "triggered": true, "version": "v1.2.3", "time_s": 30 },
  "gitops_state": "consistent",
  "cluster_state": "consistent",
  "drift": "none"
}
```

## Success Criteria

- Successful rollback
- No drift

## Usage

```bash
# Validate deployment
load e2e-testing/e2e-deployment-validation skill

# Test failure paths
load e2e-testing/e2e-failure-paths skill

# Test happy path
load e2e-testing/e2e-happy-path skill

# Test rollback
load e2e-testing/e2e-rollback skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 4, 5, 6, 7 references
- **AI stance audit** validates relevant clarity dimensions

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
