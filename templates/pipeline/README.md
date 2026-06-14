# Pipeline Templates

Golden path pipeline templates for all uFawkes repositories.

## Quick Start

1. Copy `.pipeline.yml.golden` to your repo root as `.pipeline.yml`
2. Set `repo-type` to match your repository type
3. Enable/disable stages based on your repo contents
4. Customize thresholds for your project's needs

## Template Files

| File | Purpose |
|------|---------|
| `.pipeline.yml.golden` | Full pipeline template with all stages |
| `stack.yml` | Pre-configured for Docker Compose stacks |
| `core.yml` | Pre-configured for Kubernetes repos |
| `site.yml` | Pre-configured for static sites |
| `template.yml` | Pre-configured for config-only repos |

## Pipeline Architecture

```
GATE 0: Preflight → GATE 1: Static Analysis → GATE 2: Build → GATE 3: Tests → GATE 5: Deploy
                          (parallel)
```

### Stages

| Stage | Purpose | Runs on |
|-------|---------|---------|
| Preflight | Process validation | All repos |
| Lint | Code quality | All repos |
| SAST | Security vulnerabilities | App code only |
| SCA | Dependency CVEs | All repos |
| Secrets | Leaked credentials | All repos |
| Policy | K8s compliance | K8s repos only |
| Build | Artifact production | Repos with build step |
| Tests | Correctness verification | Repos with tests |
| Quality | Accessibility, performance | Sites |
| Deploy | Artifact delivery | All repos with deploy target |

## Coverage Thresholds

Dual thresholds with ratchet effect:

| Tier | Total | Diff | Behavior |
|------|-------|------|----------|
| Unit | 60% | 80% | Block merge if diff <80% OR total regresses |
| Acceptance | 50% | 70% | Block merge if diff <70% OR total regresses |

## Supply Chain Security

| Check | Tool | Purpose |
|-------|------|---------|
| SBOM | Syft | Generate SPDX + CycloneDX per image |
| Signing | Cosign | Sign images with keyless OIDC |
| Container scan | Trivy | Find CVEs in built images |
| SLSA | SLSA Generator | Provenance attestation |

## References

- [CI Pipeline Master Plan](../docs/ci-pipeline-master-plan.md)
- [Pipeline Schema v2](../docs/pipeline-schema.md)
- [Pipeline Status](../docs/ci-pipeline-status.md)
