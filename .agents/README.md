# .agents/ — uFawkesAI Agent Directory

> **Structure:** execution-boundary agents in `.agents/agents/`, stage skills in
> `.agents/skills/`, multi-agent sequences in `.agents/workflows/`.
> Works natively with OpenCode, Claude Code, GitHub Copilot, Cursor, Codex, and Gemini CLI.

> **Why so few agents?** An agent is a *permission and accountability boundary* —
> it can block the pipeline, write files, or change repo state. Everything else is
> a skill (loaded by relevance), a command (run on a cadence), or a workflow (a
> fixed sequence of skills). Four agents cover every capability; the other nine
> stages did not need their own model, tools, or memory.

---

## Agents — `.agents/agents/`

The four execution boundaries. Invoke by `@name` in OpenCode or any compatible agent host.

| File          | Trigger           | Owns                                              | May Block | DORA Cap      |
| ------------- | ----------------- | ------------------------------------------------- | --------- | ------------- |
| `planner.md`  | `@planner`        | `plan.md` — scope, tasks, dependency order        | no        | Cap 3         |
| `builder.md`  | `@builder`        | The working tree — code, tests, manifests         | no        | Cap 4         |
| `verifier.md` | `@verifier`       | The verdict — evidence vs. claims                 | **yes**   | Cap 4 + 5 + 6 |
| `operator.md` | `@operator`       | Repo and release state — commit, PR, tag, publish | **yes**   | Cap 2 + 7     |

- **planner** — plans; hands off to builder.
- **builder** — implements against a committed `plan.md`; hands off to verifier.
- **verifier** — the only agent that can say *REQUEST CHANGES*. Never fixes what
  it is verifying, because a verifier that patches is no longer independent.
- **operator** — the only agent permitted to commit, tag, publish, or open a PR.
  Never merges: that stays a human decision (AGENTS.md rule 2).

### Pipeline

```
plan(@planner) → build(@builder) → verify(@verifier) → ship(@operator) → human merges
```

The plan/build/verify steps load the `spec`, `design`, `build`, `test`,
`test-execution`, `code-review`, and `cross-validation` skills as needed.

### Routing Guide

| Task                                        | Go to                    |
| ------------------------------------------- | ------------------------ |
| "Plan how to build X"                       | `@planner`               |
| "Implement feature X"                       | `@builder`               |
| "Implement / TDD / ship the planned work"   | `/implement`, `/tdd`, `/ship` |
| "Prove it works; run tests and review"      | `@verifier`              |
| "Review this PR" / "Check coverage"         | `/review-agents`, `/verify` |
| "Is uFawkesAI healthy?"                     | `/oc-health`             |
| "Ship the release" / "Monthly DORA snapshot" | `/release`, `/measure`   |

---

## Workflows — `.agents/workflows/`

A workflow is a **fixed sequence** of stages. Unlike a skill (chosen by
relevance) or a command (run on a cadence), the order is the point, so it is
declared in frontmatter as `kind: workflow` and is not model-selected.

| File             | Stage sequence                                             |
| ---------------- | ---------------------------------------------------------- |
| `discovery.md`   | discover → spec → design → plan → feature                 |
| `feature.md`     | plan → build → test → verify → review                     |
| `bugfix.md`      | diagnose → repair → test → verify → report                 |

Stages are skills. Read the workflow to get the order, then load the skill for
the stage you are on.

---

## Rules — `.agents/skills/*-rules/`

A rule is a constraint that is always true, not a task to perform. Same file
format as a skill, but it states obligations rather than giving a procedure —
so it applies whether or not anyone remembers to load it.

| Rule                  | Applies when                                    |
| --------------------- | ------------------------------------------------- |
| `api-design-rules/`   | changing any public interface or API contract     |
| `gitops-rules/`       | branching, committing, opening or reviewing a PR  |
| `security-rules/`     | auth, permissions, data, dependencies, credentials |
| `testing-rules/`      | writing, changing, or reviewing tests             |
| `ai-policy-lifecycle/`| any change to AI tooling or `AI_STANCE.md`        |

---

## Skills — `.agents/skills/`

Each skill is a folder containing `SKILL.md` per the [Agent Skills spec](https://agentskills.io).

Skills are loaded on demand — they do not add to always-on context. Verify the
current count with `ls .agents/skills/`; the tables below are grouped by purpose.

These are the nine stage skills that used to be agents. Same procedures, no
separate model or memory: an agent is only worth its cost when it *owns* a
boundary.

### Core Pipeline Skills

| Folder              | Loaded by        | Purpose                                                        |
| ------------------- | ---------------- | ---------------------------------------------------------------- |
| `discover/`         | `@planner`, workflows | JTBD + acceptance-criteria discovery brief (DORA AI Cap 6) |
| `spec/`             | `@planner`       | Requirements, acceptance criteria, policy gates                |
| `design/`           | `@planner`       | Architecture decomposition, K8s design validation              |
| `plan/`             | `@planner`       | Task decomposition, dependency mapping, risk ID                |
| `build/`            | `@builder`       | Code, manifests, pipelines, overlays, governance                |
| `test/`             | `@builder`       | Failing tests, coverage priorities, language-specific examples |
| `test-execution/`   | `@verifier`      | Unit, integration, E2E, coverage, smoke tests                  |
| `code-review/`      | `@verifier`      | PR review, build validation, spec/design compliance            |
| `cross-validation/` | `@verifier`      | Final gate — 4 pairwise consistency rules                      |
| `learn/`            | after release    | Retrospective; maps findings to DORA AI capabilities, feeds `plan` |

### Testing Skills

| Folder                 | Load Trigger              | Purpose                                         |
| ------------------------ | --------------------------- | -------------------------------------------------- |
| `integration-testing/` | integration test patterns | PIPE→OBS, OBS→GitOps, controller, full-stack    |
| `e2e-testing/`         | end-to-end test patterns  | Happy path, failure paths, deployment, rollback |

### Security Skills

| Folder              | Load Trigger                  | Purpose                                                |
| --------------------- | -------------------------------- | ---------------------------------------------------------- |
| `security-testing/` | security scanning & integrity | SAST, dependency scanning, container security, secrets |

### Discovery & Requirements Skills

| Folder                 | Load Trigger                    | Purpose                                                          |
| ------------------------ | ---------------------------------- | ------------------------------------------------------------------- |
| `discovery/`           | before any `spec` stage          | 15-min JTBD + acceptance-criterion exercise (DORA AI Cap 6)       |
| `discovery-advanced/`  | 15-min discovery is insufficient  | Full user research methods for major/ambiguous capabilities      |

### AI Policy & Governance Skills

| Folder                  | Load Trigger                        | Purpose                                                         |
| -------------------------- | -------------------------------------- | -------------------------------------------------------------------- |
| `ai-stance/`            | onboarding a repo, AI policy review | Generate/maintain `AI_STANCE.md` (DORA AI Cap 1)                |
| `ai-policy-lifecycle/`  | always-on, re-reviewed quarterly | **Rule:** `AI_STANCE.md` must carry all three buckets and a `Last reviewed:` date; enforce with `ai-stance/audit.md` |

### Documentation & Context Skills

| Folder                  | Load Trigger                          | Purpose                                                          |
| -------------------------- | ---------------------------------------- | --------------------------------------------------------------------- |
| `documentation/`        | pre-release audit, repo onboarding    | Enforce minimum documentation standard across uFawkes* repos (DORA AI Cap 3) |
| `context-engineering/`  | session startup                       | Verify internal context is complete and placeholder-free before each agent session (DORA AI Cap 3) |

### DORA Measurement & Reporting Skills

| Folder                    | Load Trigger                            | Purpose                                                              |
| ---------------------------- | ------------------------------------------ | --------------------------------------------------------------------------- |
| `dora-measurement/`       | monthly DORA snapshot                   | Compute the four DORA delivery metrics from uFawkesObs (DORA AI Cap 2 + 7) |
| `ROI-reporting/`          | board/quarterly ROI evidence            | Monthly DORA ROI snapshot using the 2026 DORA ROI five-dimension framework |
| `value-stream-mapping/`   | metrics plateau, high lead time         | Map the value stream to find bottlenecks consuming AI productivity gains |
| `platform-feedback/`      | quarterly                                | Developer feedback collection — measures IDP cognitive-load reduction (DORA AI Cap 7) |

### Education Skills

| Folder          | Load Trigger              | Purpose                                                  |
| ------------------ | ---------------------------- | --------------------------------------------------------------- |
| `DOJO-content/` | platform engineering training | Create/manage DOJO content for platform engineering education |
| `dojo-feedback/` | after a Dojo lab built from a feature completes | Turn lab results into `dojo-feedback.md` (gaps in guardrails/prompts/spec/plan) that CI converts into an `intent` issue — see `docs/ai-sdlc/dojo-handoff.md` |

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
    ↓ @builder (CI/CD delivery contract)
uFawkesPipe (CI/CD delivery contract)
    ↓ observability
uFawkesObs (Prometheus / Loki / Tempo / Grafana)
```
