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
- GitHub Copilot users: read `docs/COPILOT_COST_GUIDE.md` to understand token cost before starting.

**Data policy:** No customer PII in AI prompts.

---

## 2. Project Identity

**Product:** uFawkesAI — Agent orchestration framework for platform engineering
**Stack:** TypeScript · Node 20 · GitHub Actions · OpenTelemetry
**Key constraints:** 7 core pipeline agents + 7 flow/meta agents (14 total, see `.agents/README.md`), 31 skill areas, humans = routing layer

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

Invoke the most relevant agent directly:

| Task                                  | Agent               | Example                                          |
| ------------------------------------- | ------------------- | ------------------------------------------------ |
| "Write requirements for..."           | `@spec`             | "Write requirements for user authentication"     |
| "Design architecture for..."          | `@design`           | "Design architecture for payment processing"     |
| "Implement feature X"                 | `@build`            | "Implement the login form component"             |
| "Write tests for..."                  | `@test`             | "Write tests for the auth service"               |
| "Run tests and check coverage"        | `@test-execution`   | "Run all tests and report coverage"              |
| "Review this PR"                      | `@review`           | "Review PR #42 for security and quality"         |
| "Validate all outputs are consistent" | `@cross-validation` | "Cross-validate spec, design, and build outputs" |

### Pipeline Sequence

```
spec → design → build → [test-execution || review] → cross-validation
  │                    ↑
  └──── test ──────────┘
```

7 more flow/meta agents (`discover`, `discovery-flow`, `feature-flow`, `learn`, `measure`, `release`, `repair-flow`) live in `.agents/agents/` — see `.agents/README.md` for the full routing table; omitted here to keep this always-loaded file lean.

---

## 6. On-Demand Skills (Load These Explicitly)

| Skill                                   | When to load                        |
| --------------------------------------- | ----------------------------------- |
| `.agents/skills/model-routing/SKILL.md` | When unsure which model/mode to use |
| `.agents/skills/observability/SKILL.md` | Adding telemetry to any agent       |
| `.agents/skills/token-budget/SKILL.md`  | Checking token costs                |

**Prompt example:** `"Use the model-routing skill before starting this task."`

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
- Command: `.agents/assertions/assertion-runner.sh <report.md> <agent-name>`
- Pre-commit hook auto-validates any staged `*-report.md` files
- Never swallow an exception inside the runner (or any validator template it scaffolds) without logging what broke — a silently-caught exception makes "validation never ran" indistinguishable from "validation ran clean."

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
- `docs/COPILOT_COST_GUIDE.md` — Token billing, model costs
- `docs/MODEL_ROUTING_GUIDE.md` — Which model/mode for which task
