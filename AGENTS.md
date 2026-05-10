# Agent Instructions — [PROJECT NAME]

> **Who reads this:** Every agent — GitHub Copilot coding agent, VS Code agent mode,
> Claude, Codex, and any third-party AI. This is the single authoritative source for
> how agents behave in this repository.
>
> **DORA basis:** DORA AI Capabilities Model Cap 3 (Context Engineering) + Cap 1 (AI Policy).
> Google's six "where to start" recommendations place "Connect AI to internal context"
> as the second step, immediately after clarifying AI policies.
>
> Customise every section marked **[PLACEHOLDER]** before assigning any issue to an agent.

---

## 1. AI Policy (DORA Cap 1 — Clarify AI Policies)

> DORA finding: "A clear AI stance provides psychological safety for experimentation.
> Ambiguity around AI use creates friction, reduces adoption, and harms team morale."

This policy applies to all agents: GitHub Copilot, Claude Code, Cursor, Codex, Gemini CLI,
Windsurf, and any agentic tool with access to this repository.

**Our AI stance:**
- AI agents implement. Humans decide.
- No AI-generated code merges without human review and approval.
- AI is used for: code generation, test writing, documentation, code review assistance.
- AI is NOT used for: architectural decisions, security-sensitive config, dependency additions without PM sign-off.
- Team members may decline AI on any task without justification. Human judgment overrides agent output always.

**Data policy:** [PLACEHOLDER — e.g. "No customer PII is pasted into AI prompts. Internal docs and code are acceptable context."]

---

## 2. Project Identity

**Product:** [PLACEHOLDER — e.g. "A React Native savings app for iOS and Android"]
**Stack:** [PLACEHOLDER — e.g. "TypeScript · React Native · Expo 52 · Firebase Auth + Firestore"]
**Key constraints:** [PLACEHOLDER — e.g. "Must support iOS 15+ and Android 12+. No native modules without PM approval."]

---

## 3. Context Files — Read Before Generating Any Code

> DORA Cap 3 finding: "Teams that connect AI to internal documentation and codebases
> produce architecturally correct output in fewer iterations."

Read these in order before writing code:

| Priority | File | What You Learn |
|---|---|---|
| 1 | `src/types/index.ts` | All data shapes, field constraints, valid ranges |
| 2 | `docs/ARCHITECTURE.md` | Layer boundaries — what can import from what |
| 3 | `docs/API_SURFACE.md` | Every public service and utility function |
| 4 | `docs/KNOWN_LIMITATIONS.md` | Known issues — do not make these worse |
| 5 | `docs/DATA_MODEL.md` | Database/collection structure |
| 6 | `docs/CHANGE_IMPACT_MAP.md` | Which files change when core types change |

If any of these files do not exist: note it in your PR description and do not invent their contents.

---

## 4. Architecture Rules (DORA 2025 — Loosely Coupled Architecture)

> DORA 2025 finding: "Teams working in loosely coupled architectures with fast feedback
> loops see AI gains. Those in tightly coupled systems see little or no benefit."
> ESLint enforces these boundaries. CI fails on violations.

[PLACEHOLDER — replace with your actual layer structure. Example:]

```
screens/     → UI composition only. No Firebase calls. No business logic.
components/  → Reusable UI primitives. No navigation. No services.
hooks/       → React state. Calls services. Never calls Firebase directly.
services/    → All Firestore reads/writes. All Firebase Auth calls.
utils/       → Pure functions. Stateless. No imports from any other layer.
types/       → Shared TypeScript types only. No imports.
config/      → Environment vars, feature flags. No business logic.
```

**Dependency direction:** `screens → hooks → services → (SDK)`

**NEVER violate:**
1. No Firebase SDK calls in `screens/` or `components/` — ever.
2. No business logic in screens — that belongs in `utils/`.
3. No type definitions inline — all types go in `src/types/index.ts`.
4. No `any` in catch blocks — use the typed error pattern from `src/utils/errors.ts`.
5. `utils/` is stateless — no React hooks, no imports from `services/`.

---

## 5. The PM–Agent Contract

**The workflow:**
1. PM writes a GitHub issue using the **feature issue template**
2. Issue is assigned to Copilot (or another agent)
3. Agent implements, tests, opens a **draft PR**
4. Human reviews against the PR review checklist
5. Human approves and merges — no agent merges its own PR

### What Agents MAY Do Without Asking
- Read any file in the repository
- Write to `src/`, `tests/`, `docs/`
- Create new files that follow the established file structure
- Run: `npm test`, `npm run lint`, `npm run typecheck`, `npm run build`, `npm run preflight`
- Open draft PRs
- Add or update JSDoc comments and doc files

### What Agents MUST Ask Before Doing
- Adding any new dependency (`package.json` changes)
- Changing database schema or collection structure
- Modifying `.github/workflows/` files
- Changing environment variable names
- Modifying authentication flows
- Any change touching more than 5 files simultaneously
- Any change to feature flags in production config

### What Agents Must NEVER Do
- Commit secrets, API keys, or credentials
- Modify `AGENTS.md` or `.github/copilot-instructions.md`
- Delete existing tests — even failing ones — without explicit PM instruction
- Push directly to `main` or `develop`
- Make architectural decisions (which pattern, where code lives)
- Merge their own PRs
- Apply the `large-pr-approved` label (humans only)

---

## 6. Coding Standards

[PLACEHOLDER — replace with your actual standards]

- **TypeScript strict mode.** Return types on all exported functions.
- **Naming:** PascalCase components, camelCase functions/variables, UPPER_SNAKE_CASE constants
- **Tests:** Write failing test first. Commit the failing test before writing implementation.
- **Commits:** Conventional commits — `feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`
- **Coverage target:** 80% on `src/utils/` and `src/services/`

---

## 7. PR Requirements (DORA 2025 — Code Review Speed)

> DORA finding: "Teams with shorter code review times have 50% better delivery performance."
> Every PR must include a completed AI-Assisted Review Block.

Every PR opened by an agent must include in the description:

```markdown
## AI-Assisted Review Block

**What does this PR do?**
[One sentence]

**What could go wrong?**
[Top 2–3 failure modes]

**What tests cover this change?**
[List test files. If none: explain why.]

**Architecture check:**
[Confirm no layer boundary violations — or list any that exist]

**What I was NOT sure about:**
[Any judgment call. Flag for human review.]
```

---

## 8. Instability Safeguards (DORA 2025 — Control Systems)

> DORA 2025: "AI consistently increases PR size. Larger PRs = more surface area for bugs.
> Control systems must be proportionally stronger."
>
> 2026 empirical finding (Faros AI, 22,000 developers): AI coding tools boost individual
> PR output by 98% but increase median PR review time by 441%. 31% more PRs are merging
> with zero review. This template's PR size limit and review requirements directly
> counteract these measured failure modes.

- **PR size limit:** 400 changed lines before CI blocks (not warns). Override requires `large-pr-approved` label from a human.
- **Feature flags:** New features go behind a feature flag in `src/config/featureFlags.ts`.
- **Rollback:** See `docs/RUNBOOKS.md` — Emergency Rollback procedure.
- **Rework rate > 10%:** Stop adding features. Update `AGENTS.md` / `copilot-instructions.md` first.
- **Multi-agent cognitive load:** When running multiple agents in parallel, the oversight burden scales non-linearly. Limit concurrent agent tasks to 3. Each parallel agent task must have a separate branch. No agent merges another agent's PR.

---

## 9. Metrics That Matter (DORA 2025/2026)

> DORA 2025 added rework rate as a sixth metric and replaced the old performance tiers
> with seven team archetypes. Use `docs/TEAM_ARCHETYPE.md` for the current model.

Track monthly using `npm run metrics`:
- **Rework rate** — target < 10%. DORA 2025 definition: % of work that is unplanned fixes to work previously completed — not just bug fixes, but any re-do. > 20% = stop features, fix instructions.
- **Failed Deployment Recovery Time (FDRT)** — track time to restore service after a failed deployment.
- **Reliability** — DORA 2025 quasi-metric: system stability under AI-accelerated delivery cadence. Monitor the change failure rate trend over 90 days of AI adoption.
- **PR revision rate** — target < 25%.
- **CI cycle time** — target < 4 min.
- **Review turnaround** — target < 24h.
- **Archetype review** — use `docs/TEAM_ARCHETYPE.md`; do not use elite/high/medium/low tier labels.

---

## 11. Agent Skills (On-Demand Capabilities)

This template supports the Agent Skills standard (`.github/skills/`).
Skills are modular `SKILL.md` files that load on demand — not always in context.
Available skills in this template:
- `.github/skills/dora-metrics/` — DORA metric calculation and interpretation
- `.github/skills/security-review/` — Security checklist for PRs
- `.github/skills/test-generation/` — TDD patterns for this stack

To use a skill: reference it explicitly in your prompt.
Example prompt: `"Use the dora-metrics skill to add rework rate tracking to this service."`

---

## 12. See Also

- `.github/copilot-instructions.md` — symlink to `AGENTS.md` for Copilot path compatibility
- `.github/agents/` — Specialist agent profiles (`@docs-agent`, `@test-agent`, `@review-agent`, `@security-agent`)
- `.github/skills/` — On-demand skills for metrics, security review, and test generation
- `docs/GOLDEN_PATH.md` — The 10-step idea→deploy workflow (use this for every feature)
- `docs/PROMPT_LIBRARY.md` — Tested, versioned prompts for every repeating task
- `docs/AI_POLICY.md` — Full AI policy and psychological safety norms
- `docs/TEAM_ARCHETYPE.md` — DORA archetype self-assessment (run before Phase 1)
