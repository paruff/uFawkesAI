# .agents/ — uFawkesAI Agent Directory

> **Structure:** Flat agent files in `.agents/agents/`, spec-compliant skill folders in `.agents/skills/`.
> Works natively with OpenCode, Claude Code, GitHub Copilot, Cursor, Codex, and Gemini CLI.

---

## Agents — `.agents/agents/`

Invoke by `@name` in OpenCode or any compatible agent host.

| File                  | Trigger             | What It Produces                                                           | DORA Cap  |
| --------------------- | ------------------- | -------------------------------------------------------------------------- | --------- |
| `spec.md`             | `@spec`             | Requirements, acceptance criteria                                          | Cap 3     |
| `design.md`           | `@design`           | Architecture, component design                                             | Cap 3     |
| `build.md`            | `@build`            | Code, manifests, pipelines, overlays                                       | Cap 4     |
| `test.md`             | `@test`             | Tests (failing-first TDD), coverage                                        | Cap 5     |
| `test-execution.md`   | `@test-execution`   | Run tests, validate coverage                                               | Cap 5     |
| `review.md`           | `@review`           | PR review, build validation, security (PR Review + Build Validation modes) | Cap 4 + 6 |
| `cross-validation.md` | `@cross-validation` | Validate pairwise consistency, block pipeline if inconsistencies found     | Cap 4 + 6 |

### Flow & Meta Agents

Orchestrate or wrap the 7 core pipeline agents above; not part of the spec→cross-validation chain itself.

| File                  | Trigger              | What It Produces                                                        |
| --------------------- | --------------------- | --------------------------------------------------------------------------- |
| `discover.md`         | `@discover`          | Pre-spec discovery brief anchoring spec/design/test to real user needs  |
| `discovery-flow.md`   | `@discovery-flow`    | Routes work into the correct software delivery workflow                  |
| `feature-flow.md`     | `@feature-flow`      | Builds, tests, verifies, and reviews an already-planned feature on a branch |
| `repair-flow.md`      | `@repair-flow`       | Diagnoses and repairs CI/CD failures from logs and pipeline evidence     |
| `measure.md`          | scheduled (monthly)  | Queries uFawkesObs for DORA metrics, computes ROI snapshot, flags anomalies |
| `learn.md`            | post-release / sprint end | Product retrospective; maps findings to DORA AI capabilities, feeds `plan` |
| `release.md`          | weekly, on green PR  | Full release checklist: changelog, semver tag, GitHub Release, announce  |

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

| Task                                  | Agent               |
| ------------------------------------- | ------------------- |
| "Write requirements for..."           | `@spec`             |
| "Design architecture for..."          | `@design`           |
| "Implement feature X"                 | `@build`            |
| "Write tests for..."                  | `@test`             |
| "Run tests and check coverage"        | `@test-execution`   |
| "Review this PR"                      | `@review`           |
| "Validate all outputs are consistent" | `@cross-validation` |

---

## Skills — `.agents/skills/`

Each skill is a folder containing `SKILL.md` per the [Agent Skills spec](https://agentskills.io).
Skills are loaded on demand — they do not add to always-on context.
31 skill folders exist today (verify with `ls .agents/skills/`); the tables
below are grouped by purpose.

### Core Pipeline Skills

| Folder             | Load Trigger                    | Purpose                                                        |
| ------------------- | -------------------------------- | ---------------------------------------------------------------- |
| `spec/`            | `@spec` requirements extraction | Requirements, acceptance criteria, policy gates                |
| `design/`          | `@design` architecture          | Architecture decomposition, K8s design validation              |
| `plan/`            | `@build` task planning          | Task decomposition, dependency mapping, risk ID                |
| `build/`           | `@build` code generation        | Code, manifests, pipelines, overlays, governance                |
| `test/`            | `@test` TDD patterns            | Failing tests, coverage priorities, language-specific examples |
| `test-execution/`  | `@test-execution` run tests     | Unit, integration, E2E, coverage, smoke tests                  |
| `review/`          | `@review` compliance gates      | PR review, build validation, spec/design compliance            |

### Testing Skills

| Folder                 | Load Trigger              | Purpose                                         |
| ------------------------ | --------------------------- | -------------------------------------------------- |
| `unit-testing/`        | unit test patterns        | Core logic, mocking, error handling, contracts  |
| `integration-testing/` | integration test patterns | PIPE→OBS, OBS→GitOps, controller, full-stack    |
| `e2e-testing/`         | end-to-end test patterns  | Happy path, failure paths, deployment, rollback |

### Security Skills

| Folder              | Load Trigger                  | Purpose                                                |
| --------------------- | -------------------------------- | ---------------------------------------------------------- |
| `security-testing/` | security scanning & integrity | SAST, dependency scanning, container security, secrets |

### Discovery & Requirements Skills

| Folder                 | Load Trigger                    | Purpose                                                          |
| ------------------------ | ---------------------------------- | ------------------------------------------------------------------- |
| `discovery/`           | before any `@spec` session       | 15-min JTBD + acceptance-criterion exercise (DORA AI Cap 6)       |
| `discovery-advanced/`  | 15-min discovery is insufficient  | Full user research methods for major/ambiguous capabilities      |

### AI Policy & Governance Skills

| Folder                  | Load Trigger                        | Purpose                                                         |
| -------------------------- | -------------------------------------- | -------------------------------------------------------------------- |
| `ai-stance/`            | onboarding a repo, AI policy review | Generate/maintain `AI_STANCE.md` (DORA AI Cap 1)                |
| `AI-policy-lifecycle/`  | quarterly or on new AI tool adoption | Maintain `AI_STANCE.md` as a living doc; review triggers, socialization |

### Documentation & Context Skills

| Folder                  | Load Trigger                          | Purpose                                                          |
| -------------------------- | ---------------------------------------- | --------------------------------------------------------------------- |
| `documentation/`        | pre-release audit, repo onboarding    | Enforce minimum documentation standard across uFawkes* repos (DORA AI Cap 3) |
| `context-engineering/`  | session startup                       | Ensure graphify corpus is current before each agent session (DORA AI Cap 3) |

### DORA Measurement & Reporting Skills

| Folder                    | Load Trigger                            | Purpose                                                              |
| ---------------------------- | ------------------------------------------ | --------------------------------------------------------------------------- |
| `dora-measurement/`       | monthly DORA snapshot                   | Compute the four DORA delivery metrics from uFawkesObs (DORA AI Cap 2 + 7) |
| `ROI-reporting/`          | board/quarterly ROI evidence            | Monthly DORA ROI snapshot using the 2026 DORA ROI five-dimension framework |
| `value-stream-mapping/`   | metrics plateau, high lead time         | Map the value stream to find bottlenecks consuming AI productivity gains |
| `platform-feedback/`      | quarterly                                | Developer feedback collection — measures IDP cognitive-load reduction (DORA AI Cap 7) |

### Release Skills

| Folder     | Load Trigger              | Purpose                                                        |
| ------------ | ---------------------------- | ------------------------------------------------------------------- |
| `release/` | increment ready to ship   | Weekly release checklist: README → CHANGELOG → GitHub Release → announce |

### Education Skills

| Folder          | Load Trigger              | Purpose                                                  |
| ------------------ | ---------------------------- | --------------------------------------------------------------- |
| `DOJO-content/` | platform engineering training | Create/manage DOJO content for platform engineering education |

### Cross-Cutting Skills

| Folder                  | Load Trigger                      | Purpose                                               |
| -------------------------- | ------------------------------------ | ------------------------------------------------------ |
| `agent-observability/`  | agent telemetry                   | Invocation tracking, skill load, finding quality      |
| `cross-validation/`     | cross-validation                  | Pairwise consistency validation between agent outputs |
| `dev-experience/`       | dev environment setup             | Devcontainers, bootstrap, local sim, CLI tools        |
| `model-routing/`        | route tasks to models             | Optimal model/mode selection, scope check             |
| `token-budget/`         | ask about token costs             | Context footprint audit and cost control              |

### Language Skills

| Folder             | Load Trigger               | Purpose                                  |
| --------------------- | ----------------------------- | -------------------------------------------- |
| `lang-typescript/` | TypeScript project context | ESLint, tsc, Jest, npm toolchain         |
| `lang-python/`     | Python project context     | ruff, mypy, pytest, uv toolchain         |
| `lang-go/`         | Go project context         | golangci-lint, go test, go mod toolchain |

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
