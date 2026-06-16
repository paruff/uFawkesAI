# .agents/ — uFawkesAI Agent Directory

> **Structure:** Flat agent files in `.agents/agents/`, spec-compliant skill folders in `.agents/skills/`.
> Works natively with OpenCode, Claude Code, GitHub Copilot, Cursor, Codex, and Gemini CLI.

---

## Agents — `.agents/agents/`

Invoke by `@name` in OpenCode or any compatible agent host.

| File                | Trigger           | What It Produces                                          | DORA Cap  |
| ------------------- | ----------------- | --------------------------------------------------------- | --------- |
| `spec.md`           | `@spec`           | Requirements, acceptance criteria                         | Cap 3     |
| `design.md`         | `@design`         | Architecture, component design                            | Cap 3     |
| `build.md`          | `@build`          | Code, manifests, pipelines, overlays                      | Cap 4     |
| `test.md`           | `@test`           | Tests (failing-first TDD), coverage                       | Cap 5     |
| `test-execution.md` | `@test-execution` | Run tests, validate coverage                              | Cap 5     |
| `review.md`         | `@review`         | PR review, build validation, security (PR Review + Build Validation modes) | Cap 4 + 6 |
| `cross-validation.md` | `@cross-validation` | Validate pairwise consistency, block pipeline if inconsistencies found | Cap 4 + 6 |

### Agent Pipeline

```
spec → design → build → [test-execution || review] → cross-validation
  │                    ↑
  └──── test ──────────┘
```

- **spec**: Extract requirements and acceptance criteria
- **design**: Architecture decomposition and component design
- **build**: Code generation, manifests, pipelines (loads `plan` skill for task decomposition)
- **test**: Write failing tests before implementation (TDD)
- **test-execution**: Execute tests and validate coverage
- **review**: PR review + build validation (consolidated, two modes)
- **cross-validation**: Final gate — validates 4 pairwise consistency rules

### Routing Guide

Invoke the most relevant agent directly:

| Task | Agent |
|------|-------|
| "Write requirements for..." | `@spec` |
| "Design architecture for..." | `@design` |
| "Implement feature X" | `@build` |
| "Write tests for..." | `@test` |
| "Run tests and check coverage" | `@test-execution` |
| "Review this PR" | `@review` |
| "Validate all outputs are consistent" | `@cross-validation` |

---

## Skills — `.agents/skills/`

Each skill is a folder containing `SKILL.md` per the [Agent Skills spec](https://agentskills.io).
Skills are loaded on demand — they do not add to always-on context.

### Core Pipeline Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `spec/`                  | `@spec` requirements extraction     | Requirements, acceptance criteria, policy gates                   |
| `design/`                | `@design` architecture              | Architecture decomposition, K8s design validation                 |
| `plan/`                  | `@build` task planning              | Task decomposition, dependency mapping, risk ID                   |
| `build/`                 | `@build` code generation            | Code, manifests, pipelines, overlays, governance                  |
| `test/`                  | `@test` TDD patterns                | Failing tests, coverage priorities, language-specific examples    |
| `test-execution/`        | `@test-execution` run tests         | Unit, integration, E2E, coverage, smoke tests                     |
| `review/`                | `@review` compliance gates          | PR review, build validation, spec/design compliance               |
| `delivery/`              | deployment validation               | Manifest validation, drift detection, environment promotion       |

### Testing Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `unit-testing/`          | unit test patterns                  | Core logic, mocking, error handling, contracts                    |
| `integration-testing/`   | integration test patterns           | PIPE→OBS, OBS→GitOps, controller, full-stack                      |
| `e2e-testing/`           | end-to-end test patterns            | Happy path, failure paths, deployment, rollback                   |
| `observability-testing/` | telemetry validation                | Log schema, metrics, traces, dashboards, alerts                   |

### Security & Compliance Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `security-testing/`      | security scanning & integrity       | SAST, dependency scanning, container security, secrets            |

### Runtime Operations Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `runtime-operations/`    | runtime ops                         | Incidents, health, drift, SLO, remediation                        |

### Resilience Testing Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `chaos-testing/`         | resilience & failure injection      | Chaos injection, failure modes, drift chaos, cluster chaos        |
| `load-testing/`          | performance & stress testing        | Pipeline throughput, GitOps load, registry load, system stress    |

### Cross-Cutting Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `observability/`         | agent telemetry                     | Invocation tracking, skill load, finding quality                  |
| `agent-observability/`   | agent telemetry and observability   | Invocation tracking, skill load, finding quality                  |
| `golden-paths/`          | validate conventions                | Testing, security, observability, release patterns                |
| `dev-experience/`        | dev environment setup               | Devcontainers, bootstrap, local sim, CLI tools                    |
| `model-routing/`         | route tasks to models               | Optimal model/mode selection, scope check                         |
| `token-budget/`          | ask about token costs               | Context footprint audit and cost control                          |
| `cross-validation/`      | cross-validation                    | Pairwise consistency validation between agent outputs             |

### Language Skills

| Folder                   | Load Trigger                        | Purpose                                                           |
| ------------------------ | ----------------------------------- | ----------------------------------------------------------------- |
| `lang-typescript/`       | TypeScript project context          | ESLint, tsc, Jest, npm toolchain                                  |
| `lang-python/`           | Python project context              | ruff, mypy, pytest, uv toolchain                                  |
| `lang-go/`               | Go project context                  | golangci-lint, go test, go mod toolchain                          |

---

## Skill Lifecycle

Every skill has a lifecycle status tracked in `.agents/registry/skill-lifecycle.yaml` (schema: `.agents/schema/skill-lifecycle.json`). Statuses: `active`, `stable`, `beta`, `draft`, `deprecated`, `experimental`.

**Before loading a skill**, check the registry. If a skill is `deprecated`, use `replaced_by` instead. If it has `dependencies`, ensure those skills are loaded first.

### Cross-Validation

The `cross-validation` skill validates 4 pairwise consistency rules between agent outputs:

1. **Spec ↔ Build Consistency** — All spec requirements are addressed in build output
2. **Spec ↔ Test Coverage** — All spec acceptance criteria have corresponding tests
3. **Design ↔ Build Compliance** — Build follows architecture decisions from design
4. **Test ↔ Test-Execution Viability** — All tests are viable and passing in test-execution

---

## Concurrency Rule

Maximum **3 concurrent agent tasks** at any time. Each runs on a separate branch.
No agent merges another agent's PR.

## Human Accountability Loop

Agents surface metrics. Humans decide what to do about them.

---

## Suite Integration

```
uFawkesAI (.agents/)
    ↓ @build + delivery skill
uFawkesPipe (CI/CD delivery contract)
    ↓ observability
uFawkesObs (Prometheus / Loki / Tempo / Grafana)
```
