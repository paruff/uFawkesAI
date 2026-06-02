# PR Contract Skill

> **Load this skill when:** opening any PR or preparing a draft.
> **Prompt example:** `"Use the pr-contract skill to prepare this PR."`

---

## PM–Agent Contract

1. PM writes issue using the feature issue template
2. Issue assigned to Copilot / Claude Code / Cursor
3. Agent implements, tests, opens a **draft PR**
4. Human reviews — agent never merges its own PR

## PR Size Limit

**400 changed lines** maximum. CI blocks on violation.
Override requires `large-pr-approved` label from a human.

## Required PR Description Block

Every agent-opened PR must include:

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

**Token cost note:**
[Approximate credit cost of this agent session, if known]
```

## What Agents MAY Do Without Asking

- Read any file in the repository
- Write to `src/`, `tests/`, `docs/`
- Run: `npm test`, `npm run lint`, `npm run typecheck`, `npm run build`, `npm run preflight`, `npm run token-audit`
- Open draft PRs
- Add or update JSDoc comments and doc files

## What Agents MUST Ask Before Doing

- Adding any new dependency (`package.json` changes)
- Changing database schema or collection structure
- Modifying `.github/workflows/` files
- Changing environment variable names
- Modifying authentication flows
- Any change touching more than 5 files simultaneously
- Any change to feature flags in production config

## What Agents Must NEVER Do

- Commit secrets, API keys, or credentials
- Modify `AGENTS.md` or `.github/copilot-instructions.md`
- Delete existing tests without explicit PM instruction
- Push directly to `main` or `develop`
- Make architectural decisions
- Merge their own PRs
- Apply the `large-pr-approved` label (humans only)

## Coding Standards

[PLACEHOLDER — replace with your actual standards]

- TypeScript strict mode. Return types on all exported functions.
- Naming: PascalCase components, camelCase functions, UPPER_SNAKE_CASE constants
- Tests: Write failing test first. Commit before writing implementation.
- Commits: `feat:`, `fix:`, `test:`, `docs:`, `chore:`, `refactor:`
- Coverage target: 80% on `src/utils/` and `src/services/`

## DORA Basis

"Teams with shorter code review times have 50% better delivery performance."
PR size limit and AI-Assisted Review Block directly enable faster, safer reviews.
