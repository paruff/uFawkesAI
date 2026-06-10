# .agents/ — uFawkesAI Agent Directory

> **Structure:** Flat agent files in `.agents/agents/`, spec-compliant skill folders in `.agents/skills/`.
> Works natively with OpenCode, Claude Code, GitHub Copilot, Cursor, Codex, and Gemini CLI.
> Skills are discoverable via `gh skill` (GitHub CLI v2.90.0+).

---

## Agents — `.agents/agents/`

Invoke by `@name` in OpenCode or any compatible agent host.

| File              | Trigger         | What It Produces                      | DORA Cap  |
| ----------------- | --------------- | ------------------------------------- | --------- |
| `onboarding.md`   | `@onboarding`   | Populated AGENTS.md + first issue     | Cap 1 + 3 |
| `planner.md`      | `@planner`      | Sequenced issue backlog ≤400 lines/PR | Cap 3 + 5 |
| `orchestrator.md` | `@orchestrator` | Task routing + conflict prevention    | All       |
| `docs.md`         | `@docs`         | Docs, ADRs, runbooks, inline comments | Cap 3     |
| `test.md`         | `@test`         | Tests (failing-first TDD), coverage   | Cap 5     |
| `review.md`       | `@review`       | PR review, risk assessment            | Cap 4 + 6 |
| `security.md`     | `@security`     | Security findings, remediation        | Cap 1     |
| `pipe.md`         | `@pipe`         | CI/CD workflows, uFawkesPipe contract | Cap 4 + 6 |
| `obs.md`          | `@obs`          | OTEL instrumentation, uFawkesObs      | Cap 6 + 2 |
| `dora.md`         | `@dora`         | Metric interpretation, coaching       | All       |

---

## Skills — `.agents/skills/`

Each skill is a folder containing `SKILL.md` per the [Agent Skills spec](https://agentskills.io).
Skills are loaded on demand — they do not add to always-on context.

Install a skill via GitHub CLI:

```sh
gh skill install paruff/uFawkesAI dora-metrics
gh skill install paruff/uFawkesAI lang-python --agent claude-code
```

| Folder                | Load Trigger               | Purpose                                        |
| --------------------- | -------------------------- | ---------------------------------------------- |
| `dora-metrics/`       | ask about DORA metrics     | Metric calculation and interpretation patterns |
| `security-review/`    | ask for security checklist | Pre-merge security gate checklist              |
| `test-generation/`    | ask to write tests         | TDD patterns for TS, Python, Go                |
| `lang-typescript/`    | TypeScript project context | ESLint, tsc, Jest, npm toolchain               |
| `lang-python/`        | Python project context     | ruff, mypy, pytest, uv toolchain               |
| `lang-go/`            | Go project context         | golangci-lint, go test, go mod toolchain       |
| `pipeline-bootstrap/` | ask to setup pipeline      | uFawkesPipe + ArgoCD integration steps         |
| `obs-bootstrap/`      | ask to add observability   | OTEL SDK init, Grafana dashboard spec          |
| `token-budget/`       | ask about token costs      | Context footprint audit and cost control       |
| `adr-writer/`         | ask to write an ADR        | ADR template with DORA capability linkage      |

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
