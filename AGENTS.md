# Agent Instructions — [PROJECT NAME]

> **TOKEN COST NOTICE:** This file loads on EVERY Copilot/Claude Code/Cursor request.
> Every line here is billed on every interaction. Keep it lean.
> Full details live in `.agents/skills/` — load them on demand only.
>
> **DORA basis:** Cap 3 (Context Engineering) + Cap 1 (AI Policy)

---

## 1. AI Policy

- AI agents implement. Humans decide.
- No AI-generated code merges without human review and approval.
- Use **Ask Mode** for questions. **Agent Mode** only for multi-file tasks.
- Read `docs/MODEL_ROUTING_GUIDE.md` before choosing a model or mode.
- Read `docs/COPILOT_COST_GUIDE.md` to understand token cost before starting.

**Data policy:** [PLACEHOLDER — e.g. "No customer PII in AI prompts."]

---

## 2. Project Identity

**Product:** [PLACEHOLDER — e.g. "A React Native savings app"]
**Stack:** [PLACEHOLDER — e.g. "TypeScript · React Native · Expo 52 · Firebase"]
**Key constraints:** [PLACEHOLDER — e.g. "Must support iOS 15+ and Android 12+"]

---

## 3. Five Hard Rules (Never Violate)

1. No Firebase/DB SDK calls in UI layer — ever.
2. No `any` in catch blocks — use typed error pattern.
3. No secrets, API keys, or credentials in any file.
4. No merging your own PR.
5. No modifying `AGENTS.md` or `.github/copilot-instructions.md`.

---

## 4. Token Budget Protocol

Before starting any task touching > 3 files:

1. State scope in one sentence.
2. List files you plan to read.
3. Say: "Confirm I should proceed? (moderate/high credit cost)"

For questions → use Ask Mode (60–90% cheaper than Agent Mode).

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

---

## 6. On-Demand Skills (Load These Explicitly)

Reference a skill in your prompt to load its full instructions:

| Skill                                   | When to load                        |
| --------------------------------------- | ----------------------------------- |
| `.agents/skills/model-routing/SKILL.md` | When unsure which model/mode to use |
| `.agents/skills/observability/SKILL.md` | Adding telemetry to any agent       |
| `.agents/skills/token-budget/SKILL.md`  | Checking token costs                |

**Prompt example:** `"Use the model-routing skill before starting this task."`

---

## 7. Context Files (Read Before Generating Code)

| Priority | File                        | What You Learn           |
| -------- | --------------------------- | ------------------------ |
| 1        | `src/types/index.ts`        | All data shapes          |
| 2        | `docs/ARCHITECTURE.md`      | Layer boundaries         |
| 3        | `docs/API_SURFACE.md`       | Public service functions |
| 4        | `docs/KNOWN_LIMITATIONS.md` | Do not make these worse  |

---

## 8. See Also

- `docs/COPILOT_COST_GUIDE.md` — Token billing, model costs, how to stay in budget
- `docs/MODEL_ROUTING_GUIDE.md` — Which model/mode for which task
- `docs/GOLDEN_PATH.md` — 10-step idea→deploy workflow
- `docs/METRICS.md` — DORA metrics + AI credit burn tracking
- `.agents/README.md` — Full agent and skill documentation
- `docs/PROMPT_LIBRARY.md` — Tested prompts for every repeating task
