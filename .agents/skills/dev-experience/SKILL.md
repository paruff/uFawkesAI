---
name: dev-experience
description: "Set up local development environment. Implements DORA AI Capabilities 3, 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: dev-experience

> **Load trigger:** "load dev-experience skill" > **DORA:** AI Capabilities 3, 7
> **Token cost:** Low

## Purpose

Set up local development environment. Configures devcontainers, workspace bootstrap, and local simulation. Implements DORA AI Capabilities 3, 7.

## When to Use

- Configuring devcontainers
- Workspace bootstrap
- Local simulation

## Sub-skills (now integrated)

### 1. Core Dev Experience

# Skill: Dev Experience

> **Load trigger:** `"load dev-experience skill"` > **DORA:** AI Capability 3: AI-accessible internal data
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
| `dev-experience/dev-container-setup`      | Configure devcontainers |
| `dev-experience/workspace-bootstrap`       | Bootstrap workspace     |
| `dev-experience/local-environment-simulation` | Set up local simulation |

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

### 2. Sub-skills

### Dev Container Setup

# Skill: Dev Container Setup

> **Load trigger:** `"load dev-container-setup skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low

## Purpose

Provide a reproducible, standardized development environment for all Fawkes projects using devcontainers.

## Responsibilities

- Validate `devcontainer.json`
- Validate `Dockerfile.dev`
- Validate required tools (Node, Python, Fawkes CLI, kubectl, kustomize)
- Validate VS Code extensions
- Validate Coder compatibility

## Inputs

- `.devcontainer/` directory
- Project repo

## Outputs

- `devcontainer-report.json`
- `missing-tools.txt`

## Sub-Skills

| Skill                                      | Purpose                         |
| ------------------------------------------ | ------------------------------- |
| `dev-container-setup/toolchain-validation` | Verify tools and versions       |
| `dev-container-setup/coder-validation`     | Validate Coder workspace config |

## Validation Rules

### devcontainer.json

- [ ] Base image specified
- [ ] Features defined
- [ ] Extensions listed
- [ ] Post-create command defined
- [ ] ForwardPorts configured (if needed)

### Required Tools

| Tool       | Version | Required          |
| ---------- | ------- | ----------------- |
| Node.js    | ≥ 18    | Yes               |
| Python     | ≥ 3.10  | If Python project |
| kubectl    | Latest  | If K8s            |
| kustomize  | Latest  | If GitOps         |
| Fawkes CLI | Latest  | Yes               |
| Docker     | ≥ 20    | Yes               |

## Tools

- Devcontainer CLI
- Docker CLI

## Success Criteria

- Devcontainer builds successfully
- All required tools installed
- Developer can start coding immediately

### Local Environment Simulation

# Skill: Local Environment Simulation

> **Load trigger:** `"load local-environment-simulation skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low

## Purpose

Simulate PIPE, OBS, GitOps, and cluster behavior locally for fast feedback loops.

## Responsibilities

- Run local PIPE simulation
- Run local OBS simulation
- Run local GitOps repo
- Run local kind/k3d cluster
- Validate local → GitOps → cluster flow

## Inputs

- Project repo
- Local simulation config

## Outputs

- `local-sim-report.json`

## Sub-Skills

| Skill                                      | Purpose                         |
| ------------------------------------------ | ------------------------------- |
| `local-environment-simulation/gitops-sim`  | Simulate GitOps updates locally |
| `local-environment-simulation/cluster-sim` | Run local K8s cluster           |

## Simulation Flow

```
1. Code change → local build
2. Build → local image
3. Image → local GitOps update
4. GitOps → local cluster reconcile
5. Cluster → validate deployment
```

## Tools

| Tool      | Purpose                 |
| --------- | ----------------------- |
| kind      | Local K8s cluster       |
| k3d       | Lightweight K8s cluster |
| Kustomize | Overlay rendering       |
| Git CLI   | Local GitOps            |

## Rules

- [ ] Local simulation matches real pipeline behavior
- [ ] Fast feedback (< 5 minutes)
- [ ] No remote dependencies required
- [ ] Idempotent simulation

## Success Criteria

- Local simulation matches real pipeline behavior
- Fast iteration cycles
- No remote dependencies for basic flows

### Workspace Bootstrap

# Skill: Workspace Bootstrap

> **Load trigger:** `"load workspace-bootstrap skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low

## Purpose

Automate initial project setup for developers.

## Responsibilities

- Install dependencies
- Generate environment files
- Configure Git hooks
- Bootstrap local cluster (optional)
- Bootstrap GitOps repo clone

## Inputs

- Project repo
- `bootstrap.sh` or `bootstrap.ts`

## Outputs

- `bootstrap-report.json`

## Sub-Skills

| Skill                                | Purpose                      |
| ------------------------------------ | ---------------------------- |
| `workspace-bootstrap/dependencies`   | Install project dependencies |
| `workspace-bootstrap/env-generation` | Generate `.env.local` files  |

## Bootstrap Steps

| Step | Action                | Required |
| ---- | --------------------- | -------- |
| 1    | Install dependencies  | Yes      |
| 2    | Generate `.env.local` | Yes      |
| 3    | Configure Git hooks   | Yes      |
| 4    | Start local cluster   | Optional |
| 5    | Clone GitOps repo     | Optional |
| 6    | Validate environment  | Yes      |

## Rules

- [ ] Bootstrap completes in < 60 seconds
- [ ] All steps logged
- [ ] Failures reported clearly
- [ ] Idempotent (safe to re-run)

## Tools

- Node / npm
- Python / pip
- Git CLI

## Success Criteria

- Developer can run the project immediately
- No manual steps required

## Usage

```bash
# Dev container setup
load dev-experience/dev-container-setup skill

# Local simulation
load dev-experience/local-environment-simulation skill

# Workspace bootstrap
load dev-experience/workspace-bootstrap skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 3, 7 references
- **AI stance audit** validates relevant clarity dimensions
