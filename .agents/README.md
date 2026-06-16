# .agents/ — uFawkesAI Agent Directory

> **Structure:** Flat agent files in `.agents/agents/`, spec-compliant skill folders in `.agents/skills/`.
> Works natively with OpenCode, Claude Code, GitHub Copilot, Cursor, Codex, and Gemini CLI.
> Skills are discoverable via `gh skill` (GitHub CLI v2.90.0+).

---

## Agents — `.agents/agents/`

Invoke by `@name` in OpenCode or any compatible agent host.

| File                | Trigger           | What It Produces                                                                    | DORA Cap  |
| ------------------- | ----------------- | ----------------------------------------------------------------------------------- | --------- |
| `onboarding.md`     | `@onboarding`     | Populated AGENTS.md + first issue                                                   | Cap 1 + 3 |
| `planner.md`        | `@planner`        | Sequenced issue backlog ≤400 lines/PR                                               | Cap 3 + 5 |
| `orchestrator.md`   | `@orchestrator`   | Capability-matched routing + dependency graph execution plans + conflict prevention | All       |
| `docs.md`           | `@docs`           | Docs, ADRs, runbooks, inline comments                                               | Cap 3     |
| `spec.md`           | `@spec`           | Requirements, acceptance criteria                                                   | Cap 3     |
| `design.md`         | `@design`         | Architecture, component design                                                      | Cap 3     |
| `test.md`           | `@test`           | Tests (failing-first TDD), coverage                                                 | Cap 5     |
| `test-execution.md` | `@test-execution` | Run tests, validate coverage                                                        | Cap 5     |
| `build.md`          | `@build`          | Code, manifests, pipelines, overlays                                                | Cap 4     |
| `review.md`         | `@review`         | PR review, risk assessment                                                          | Cap 4 + 6 |
| `build-review.md`   | `@build-review`   | Build compliance, spec/design gates                                                 | Cap 4 + 6 |
| `security.md`       | `@security`       | Security findings, remediation (PR Audit + Deep Review)                             | Cap 1 + 6 |
| `cross-validation.md` | `@cross-validation` | Validate pairwise consistency, block pipeline if inconsistencies found           | Cap 4 + 6 |
| `pipe.md`           | `@pipe`           | CI/CD workflows, uFawkesPipe contract                                               | Cap 4 + 6 |
| `obs.md`            | `@obs`            | OTEL instrumentation, uFawkesObs                                                    | Cap 6 + 2 |
| `dora.md`           | `@dora`           | Metric interpretation, coaching                                                     | All       |

---

## Skills — `.agents/skills/`

Each skill is a folder containing `SKILL.md` per the [Agent Skills spec](https://agentskills.io).
Skills are loaded on demand — they do not add to always-on context.

Install a skill via GitHub CLI:

```sh
gh skill install paruff/uFawkesAI dora-metrics
gh skill install paruff/uFawkesAI lang-python --agent claude-code
```

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `spec/`                  | `@spec` requirements extraction     | Requirements, acceptance criteria, policy gates                   |
| `design/`                | `@design` architecture              | Architecture decomposition, K8s design validation                 |
| `plan/`                  | `@planner` task planning            | Task decomposition, dependency mapping, risk ID                   |
| `build/`                 | `@build` code generation            | Code, manifests, pipelines, overlays, governance                  |
| `test-execution/`        | `@test-execution` run tests         | Unit, integration, E2E, coverage, smoke tests                     |
| `unit-testing/`          | unit test patterns                  | Core logic, mocking, error handling, contracts                    |
| `integration-testing/`   | integration test patterns           | PIPE→OBS, OBS→GitOps, controller, full-stack                      |
| `e2e-testing/`           | end-to-end test patterns            | Happy path, failure paths, deployment, rollback                   |
| `review/`                | `@build-review` compliance gates    | Spec/design compliance, K8s policy, code quality                  |
| `security/`              | `@security` security gates          | RBAC, secrets, container, SAST, SCA, pipeline                     |
| `ci/`                    | `@pipe` CI execution                | Environment, pipeline, caching, parallelization                   |
| `cd/`                    | `@pipe` CD execution                | Orchestration, progressive delivery, rollback                     |
| `gitops/`                | GitOps operations                   | Manifest validation, drift detection, promotion, reconciliation   |
| `runtime-operations/`    | `@obs` runtime ops                  | Incidents, health, drift, SLO, remediation                        |
| `governance-policy/`     | `@orchestrator` policy gates        | Policy-as-code, RBAC, cost, compliance audit                      |
| `release-engineering/`   | release versioning & publishing     | Semver, changelog, provenance, SBOM, tagging                      |
| `platform-engineering/`  | golden paths & pipeline enforcement | Pipeline-spec, template compliance, drift detection               |
| `observability-testing/` | telemetry validation                | Log schema, metrics, traces, dashboards, alerts                   |
| `security-testing/`      | security scanning & integrity       | SAST, dependency scanning, container security, secrets            |
| `chaos-testing/`         | resilience & failure injection      | Chaos injection, failure modes, drift chaos, cluster chaos        |
| `load-testing/`          | performance & stress testing        | Pipeline throughput, GitOps load, registry load, system stress    |
| `developer-experience/`  | dev environment setup               | Devcontainers, bootstrap, local sim, CLI tools                    |
| `orchestration/`         | `@orchestrator` v2 task routing     | Capability matching, dependency graphs, handoff validation        |
| `agent-observability/`   | agent telemetry and observability   | Invocation tracking, skill load, finding quality                  |
| `adr-writer/`            | ask to write an ADR                 | ADR template with DORA capability linkage                         |
| `dora-metrics/`          | ask about DORA metrics              | Metric calculation and interpretation patterns                    |
| `lang-typescript/`       | TypeScript project context          | ESLint, tsc, Jest, npm toolchain                                  |
| `lang-python/`           | Python project context              | ruff, mypy, pytest, uv toolchain                                  |
| `lang-go/`               | Go project context                  | golangci-lint, go test, go mod toolchain                          |
| `pipeline-bootstrap/`    | ask to setup pipeline               | uFawkesPipe + ArgoCD integration steps                            |
| `obs-bootstrap/`         | ask to add observability            | OTEL SDK init, Grafana dashboard spec                             |
| `test-generation/`       | ask to write tests                  | TDD patterns for TS, Python, Go                                   |
| `skill-lifecycle/`       | `@orchestrator` skill lifecycle     | Deprecation, versioning, status transitions, dep graph validation |
| `cross-validation/`      | `@orchestrator` cross-validation    | Pairwise consistency validation between agent outputs            |
| `token-budget/`          | ask about token costs               | Context footprint audit and cost control                          |

---

## Skill Lifecycle

Every skill has a lifecycle status tracked in `.agents/registry/skill-lifecycle.yaml` (schema: `.agents/schema/skill-lifecycle.json`). Statuses: `active`, `stable`, `beta`, `draft`, `deprecated`, `experimental`.

**Before loading a skill**, check the registry. If a skill is `deprecated`, use `replaced_by` instead. If it has `dependencies`, ensure those skills are loaded first.

The dependency graph is generated by `scripts/agent-skill-graph.sh` and written to:

- `.agents/skills/platform-engineering/skill-dependency-graph/skill-graph.json`
- `.agents/skills/platform-engineering/skill-dependency-graph/graph-validation.json`

Regenerate after any lifecycle change: `bash scripts/agent-skill-graph.sh`

### Cross-Validation Skill

The `cross-validation` skill is part of Phase 5 (Cross-Validation). It validates pairwise consistency between agent outputs and blocks the pipeline if any inconsistency is found.

**Status:** active
**Version:** 1.0.0
**Dependencies:** spec, design, build, test, test-execution, review, build-review, security
**Load Trigger:** `@orchestrator cross-validation`
**Purpose:** Validates 6 pairwise consistency rules between agent outputs

### Deprecated Skills

| Skill      | Replaced By     | Reason                         |
| ---------- | --------------- | ------------------------------ |
| `metrics/` | `dora-metrics/` | Merged into dora-metrics skill |

### Phase 5 — Cross-Validation

Cross-validation is the final gate in the agent pipeline. It validates pairwise consistency between agent outputs:

1. **Spec ↔ Build Consistency** — All spec requirements are addressed in build output
2. **Spec ↔ Test Coverage** — All spec acceptance criteria have corresponding tests
3. **Design ↔ Build Compliance** — Build follows architecture decisions from design
4. **Review ↔ Build Resolution** — All review findings are resolved in build
5. **Security ↔ Build Resolution** — All security findings are resolved or acknowledged in build
6. **Test ↔ Test-Execution Viability** — All tests are viable and passing in test-execution

The cross-validation agent runs after the parallel block of `test-execution`, `review`, `build-review`, and `security` and before `pipe` and `obs`. If any validation rule fails, it blocks the pipeline and reports the specific inconsistencies.

**Skill:** `.agents/skills/cross-validation/`
**Agent:** `@cross-validation`
**Registry:** `.agents/registry/cross-validation.yaml`
**Runner:** `.agents/assertions/cross-validation-runner.sh`

**Status:** active
**Version:** 1.0.0
**Dependencies:** spec, design, build, test, test-execution, review, build-review, security

---

## Concurrency Rule

Maximum **3 concurrent agent tasks** at any time. Each runs on a separate branch.
No agent merges another agent's PR. See `orchestrator.md` for the full conflict protocol.

## Human Accountability Loop

Agents surface metrics. Humans decide what to do about them.
After every `@dora` metrics review, file a `docs/MONTHLY_REVIEW_TEMPLATE.md` issue
with a named owner and due date for at least one action item.

## Suite Integration

```
uFawkesAI (.agents/)
    ↓ @pipe + pipeline-bootstrap skill
uFawkesPipe (CI/CD delivery contract)
    ↓ @obs + obs-bootstrap skill
uFawkesObs (Prometheus / Loki / Tempo / Grafana)
    ↓ @dora
fawkes IDP (Backstage / ArgoCD / k3d / Jenkins)
    ↓ dora coaching
paruff.github.io/fawkes/dojo/ (5 belts, learning platform)
```
