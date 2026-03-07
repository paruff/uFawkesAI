# Copilot Instructions — [PROJECT NAME]

> Loaded automatically for every Copilot Chat and agent session in this repository.
> For full rules and rationale see `AGENTS.md`.
> VS Code auto-loads this via `.vscode/settings.json`.

---

## Context Files — Read These First

Before writing any code, read:

1. `src/types/index.ts` — all data shapes and constraints
2. `docs/ARCHITECTURE.md` — what can import from what (ESLint-enforced)
3. `docs/API_SURFACE.md` — all public service and utility functions
4. `docs/KNOWN_LIMITATIONS.md` — do not make these worse
5. `docs/DATA_MODEL.md` — database/collection structure

If these files don't exist yet, note that in your PR rather than inventing their contents.

---

## Architecture Rules — Never Violate These

[PLACEHOLDER — replace with your layers. Example:]

1. **Screens only orchestrate UI.** No Firebase SDK calls in screen files. Ever.
2. **All Firestore operations go through `src/services/`.**
3. **All business logic in `src/utils/` as pure functions.** No side effects.
4. **Shared types only in `src/types/index.ts`.** No inline type definitions in components.
5. **Hooks manage React state and call services.** Never call Firebase SDKs in hooks directly.

ESLint enforces these. CI fails on violations.

---

## Coding Standards

- TypeScript strict. Return types on all exported functions.
- No `any` in catch blocks — use `unknown` and type-narrow.
- Conventional commits: `feat:`, `fix:`, `test:`, `docs:`, `chore:`
- Write the failing test first. Commit it. Then implement.

---

## What Requires Human Approval Before Proceeding

- New `package.json` dependencies
- Database schema changes
- `.github/workflows/` modifications
- Authentication flow changes
- More than 5 files changed in one task

---

## Golden Path for Every Feature

See `docs/GOLDEN_PATH.md`. In short:
```
Spec → Branch → Failing Test (commit) → Implement → npm run preflight → Draft PR
```

Never open a PR without running `npm run preflight` (lint + typecheck + tests).

---

## PR Requirement

Every PR must include the AI-Assisted Review Block:
what it does, how it was tested, architecture check, top failure modes, any judgment calls flagged.

---

## Prompt Templates

For common task types (security review, refactoring, debugging, architecture check),
use the templates in `docs/PROMPT_LIBRARY.md` rather than writing prompts from scratch.

---

## Instability Guard

If you find yourself changing more than 5 files or more than 400 lines: stop.
Break the task into smaller PRs. Ask the PM to split the issue.
`large-pr-approved` label is required to override the CI block — a human must apply it.
