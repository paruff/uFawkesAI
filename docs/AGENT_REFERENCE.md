# Agent Reference — uFawkesAI

On-demand detail moved out of the always-loaded `AGENTS.md` (2026-10-03) so
that file stays one page (AC-AI-08, the playbook's static rule file). Read
this when a task touches what it covers; nothing here is loaded by default.

**Token budget:** before any task touching more than 3 files, state the scope
in one sentence, list the files you plan to read, and ask
"Confirm I should proceed? (moderate/high credit cost)". For questions, use
your agent's read-only/question mode (60–90% cheaper than agentic mode).

## Moved from AGENTS.md §1–5 (verbatim)

- GitHub Copilot users: run `npm run token-audit` to see your token footprint before starting.
- **Key constraints:** 4 execution-boundary agents + 3 workflows + 9 commands + 12 repo skills (see `.agents/README.md`); development methodology = Superpowers (15 skills), baked into the shared image; humans = routing layer
- Within an agent, load the Superpowers skill for the stage: `brainstorming`
  (spec + design), `writing-plans`, `executing-plans`, `test-driven-development`,
  `verification-before-completion`, `requesting-code-review`,
  `systematic-debugging`. Repo skills cover what Superpowers does not:
  `discovery`, `learn`, `continuous-evals`; cross-validation is
  `.agents/assertions/cross-validation-runner.sh`.
- `@verifier` returning REQUEST CHANGES is the gate. `@operator` never merges — rule 2.
- Workflows (fixed order, not model-selected): `.agents/workflows/discovery.md`,
  `feature.md`, `bugfix.md`.
- Commands (cadence): `/release` weekly, `/measure` monthly, plus
  `/plan`, `/implement`, `/tdd`, `/verify`, `/review-agents`, `/ship`,
  `/oc-health`.

## On-Demand Skills (Load These Explicitly)

| Load                                       | When                                      |
| ------------------------------------------ | ----------------------------------------- |
| `docs/MODEL_ROUTING_GUIDE.md`              | When unsure which model/mode to use       |
| `scripts/token-audit.sh`                   | Checking token costs                      |
| `.agents/skills/continuous-evals/SKILL.md` | Changing any agent configuration          |
| `.agents/skills/context-engineering/SKILL.md` | Session startup context check          |

**Prompt example:** `"Read docs/MODEL_ROUTING_GUIDE.md before starting this task."`

---

## CI/CD Context

### Commit Format

- Conventional Commits required: `type(scope): description` (description max 72 chars)
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`, `revert`

### Pre-commit Hooks

- `pre-commit run --all-files` must pass before pushing
- Gitleaks and detect-secrets scan for secrets — use `# pragma: allowlist secret` for false positives
- If updating `.secrets.baseline`, run `detect-secrets scan > .secrets.baseline`

### Cross-Validation

- Runner: `.agents/assertions/cross-validation-runner.sh`
- Output: `.agents/logs/cross-validation-report.md`
- Validates 4 rules: spec-build, spec-test, design-build, test-test-execution

### Assertion Runner

- Validates agent reports against contracts in `minimal-report.yaml`
- Command: `.agents/assertions/assertion-runner.sh <report.md> <contract-key>`
- Contract keys are report *kinds* (`build`, `design`, `review`, `spec`, `test`, `test-execution`, `cross-validation`), not agent names
- **Enforced** — the `agent-report-contracts` pre-commit hook validates staged `*-report.md` files; it is a `repo: local` hook, not a symlink in `.git/hooks/`
- An unknown contract key is a hard failure. A runner that reports "nothing to validate" and exits 0 is not a gate — never swallow an exception without logging what broke, or "validation never ran" becomes indistinguishable from "validation ran clean"

### Deployment Lifecycle Gates

- **Main CI guard** — `.github/workflows/main-ci-guard.yml` blocks PR merges to `main` until the `ci-quality.yml` workflow passes
- **Observability built-in** — every workflow job logs `job-start` / `job-finish` timestamps for traceability of build times, test results, and deploy status

---

## Context Files

| File | Why |
|---|---|
| `docs/PR_STANDARD.md` | PR naming rules, CI requirements, branch discipline |

---

## Delivery Metrics

Use these baselines before optimizing delivery flow. The authoritative formulas and worked examples live in [`docs/METRICS.md`](./docs/METRICS.md).

- [Rework rate](./docs/METRICS.md#1-rework-rate) — target: < 10% green, 10–20% amber, > 20% red
- [PR revision rate](./docs/METRICS.md#2-pr-revision-rate) — target: < 25% green, 25–40% amber, > 40% red
- [CI cycle time](./docs/METRICS.md#3-ci-cycle-time) — target: < 4 min green, 4–10 min amber, > 10 min red
- [Review turnaround](./docs/METRICS.md#4-review-turnaround) — target: < 24h green, 24–72h amber, > 72h red
- [Failed deployment recovery time](./docs/METRICS.md#5-failed-deployment-recovery-time-fdrt) — target: < 1h green, 1–4h amber, > 4h red
- [Reliability / change failure rate](./docs/METRICS.md#6-reliability--change-failure-rate) — target: improving trend green, flat amber, rising red

---

## See Also

- `.agents/README.md` — Full agent and skill documentation
- `.agents/registry/` — Agent capabilities, cross-validation rules, skill lifecycle
- `.agents/assertions/` — Report contracts, assertion runner, pre-commit hooks
- `scripts/token-audit.sh` — Token footprint audit (run it before the bill arrives)
- `docs/MODEL_ROUTING_GUIDE.md` — Which model/mode for which task
- `docs/METRICS.md` — Baseline targets, formulas, data sources, and worked examples
