# PR Standard

## Conventional Commits

All PR titles and commits **must** follow the Conventional Commits format:

```
type(scope): description
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`, `revert`

**Rules:**
- Max 120 characters
- First word after `type(scope):` must be lowercase
- Scope is optional but encouraged (e.g., `feat(agents):`, `fix(skills):`)

## Branch Naming

All work happens on feature branches off `main`:

```
feat/<slug>
fix/<slug>
chore/<slug>
docs/<slug>
```

- Trunk-based development with short-lived branches
- Never commit directly to `main`
- Every branch opens a PR before merge

## CI Requirements

Before a PR can merge to `main`:

1. **All CI gates must pass** — preflight, lint, symlinks, typecheck, tests, architecture
2. **Secret scan** must pass — gitleaks + .env.example check
3. **Dependency review** must pass (or be explicitly N/A)
4. **Main CI Guard** must pass — blocks merge if the main workflow fails
5. **Pre-commit hooks** must pass locally before push

## PR Lifecycle

1. Create feature branch (`feat/<slug>`)
2. Make changes, run pre-commit hooks locally
3. Push, open PR with Conventional Commits title
4. CI runs all gates automatically
5. Human review required before merge
6. Squash-merge to `main` (clean history)

## Observability

Every workflow job logs `job-start` / `job-finish` timestamps for traceability.
Build times, test results, and deploy status are always observable.
