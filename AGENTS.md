# Agent Instructions — uFawkesAI

> **TOKEN COST NOTICE:** This file loads on EVERY Copilot/Claude Code/Cursor request.
> Every line here is billed on every interaction. Keep it lean.
> Full details live in `.agents/skills/` — load them on demand only.

---

## 1. AI Policy

- AI agents implement. Humans decide.
- No AI-generated code merges without human review and approval.
- Use your agent's read-only/question mode for questions; reserve multi-file/agentic mode for multi-file tasks.
- Read `docs/MODEL_ROUTING_GUIDE.md` before choosing a model or mode.
- GitHub Copilot users: run `npm run token-audit` to see your token footprint before starting.

**Data policy:** No customer PII in AI prompts.

---

## 2. Project Identity

**Product:** uFawkesAI — an agent orchestration framework for platform engineering, packaged as a template so its patterns (agents, skills, hooks, rules, multi-harness config) are directly reusable by other projects.
**Stack:** TypeScript · Node 20 · GitHub Actions · OpenTelemetry
**Harnesses:** OpenCode and Claude Code are first-class; Codex and Gemini CLI are compatibility harnesses. All four are verified by `scripts/multi-harness-smoke.sh` in CI (see `docs/ai-sdlc/spec.md` R1) and ship in the shared devcontainer image `ghcr.io/paruff/ufawkesai-devcontainer`; Cursor/Copilot/Gemini instruction files are kept in sync via symlink to this file.
**Key constraints:** 4 execution-boundary agents + 3 workflows + 9 commands + 10 repo skills (see `.agents/README.md`); development methodology = Superpowers (15 skills) + Flux GitOps skills (3), both baked into the shared image; humans = routing layer

---

## 3. Five Hard Rules (Never Violate)

1. No secrets, API keys, or credentials in any file.
2. No merging your own PR.
3. No modifying `AGENTS.md` — the source file. Its symlinked aliases (`CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md`, `.cursor/rules/AGENTS.md`) always mirror it; edit the source only.
4. Run pre-commit hooks before committing (`pre-commit run --all-files`).
5. All agent outputs must satisfy contracts in `.agents/assertions/minimal-report.yaml`.

---

## 4. Token Budget Protocol

Before starting any task touching > 3 files:

1. State scope in one sentence.
2. List files you plan to read.
3. Say: "Confirm I should proceed? (moderate/high credit cost)"

For questions → use your agent's read-only/question mode (60–90% cheaper than agentic mode).

---

## 5. Agent Routing

There are only **4 agents**, because an agent is a boundary that can block, write,
or change repo state. Everything else is a skill (loaded by relevance), a
command (run on a cadence), or a workflow (a fixed sequence).

| Task                          | Agent       | Owns                                        |
| ----------------------------- | ----------- | ------------------------------------------- |
| "Plan how to build X"         | `@planner`  | scope, tasks, dependency order              |
| "Implement feature X"         | `@builder`  | code, tests, manifests — the working tree   |
| "Prove it works" / "Review"   | `@verifier` | the verdict; the only agent that can block  |
| "Ship / release / tag"        | `@operator` | commit, PR, tag, publish — never merges     |

Within an agent, load the Superpowers skill for the stage: `brainstorming`
(spec + design), `writing-plans`, `executing-plans`, `test-driven-development`,
`verification-before-completion`, `requesting-code-review`,
`systematic-debugging`. Repo skills cover what Superpowers does not:
`discovery`, `learn`, `continuous-evals`; cross-validation is
`.agents/assertions/cross-validation-runner.sh`. Always-on rules live in
`.agents/rules/`.

### Pipeline Sequence

```
@planner → @builder → @verifier → @operator → human merges
```

`@verifier` returning REQUEST CHANGES is the gate. `@operator` never merges —
rule 2.

### Workflows and Commands

- Workflows (fixed order, not model-selected): `.agents/workflows/discovery.md`,
  `feature.md`, `bugfix.md`.
- Commands (cadence): `/release` weekly, `/measure` monthly, plus
  `/plan`, `/implement`, `/tdd`, `/verify`, `/review-agents`, `/ship`,
  `/oc-health`.

See `.agents/README.md` for the full routing table; omitted here to keep this
always-loaded file lean.

---

## 6. On-Demand Skills (Load These Explicitly)

| Load                                       | When                                      |
| ------------------------------------------ | ----------------------------------------- |
| `docs/MODEL_ROUTING_GUIDE.md`              | When unsure which model/mode to use       |
| `scripts/token-audit.sh`                   | Checking token costs                      |
| `.agents/skills/continuous-evals/SKILL.md` | Changing any agent configuration          |
| `.agents/skills/context-engineering/SKILL.md` | Session startup context check          |

**Prompt example:** `"Read docs/MODEL_ROUTING_GUIDE.md before starting this task."`

---

## 7. CI/CD Context

### Commit Format

- Conventional Commits required: `type(scope): description` (max 120 chars)
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

## 8. Context Files

| File | Why |
|---|---|
| `docs/PR_STANDARD.md` | PR naming rules, CI requirements, branch discipline |

---

## 9. See Also

- `.agents/README.md` — Full agent and skill documentation
- `.agents/registry/` — Agent capabilities, cross-validation rules, skill lifecycle
- `.agents/assertions/` — Report contracts, assertion runner, pre-commit hooks
- `scripts/token-audit.sh` — Token footprint audit (run it before the bill arrives)
- `docs/MODEL_ROUTING_GUIDE.md` — Which model/mode for which task
