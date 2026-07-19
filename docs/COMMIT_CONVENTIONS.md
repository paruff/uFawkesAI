# Commit & branch conventions

## Commit format — Conventional Commits v1.0.0

Source: https://www.conventionalcommits.org/en/v1.0.0/

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Allowed types:**

| Type       | Use for                                                 |
| ---------- | ------------------------------------------------------- |
| `feat`     | a new feature (mandatory type per spec)                 |
| `fix`      | a bug fix (mandatory type per spec)                     |
| `docs`     | documentation only                                      |
| `style`    | formatting, no logic change                             |
| `refactor` | code change that neither fixes a bug nor adds a feature |
| `test`     | adding or correcting tests                              |
| `chore`    | tooling, dependency bumps, maintenance                  |
| `build`    | build system or external dependency changes             |
| `ci`       | CI configuration changes                                |
| `perf`     | performance improvements                                |
| `revert`   | reverting a previous commit                             |

Only `feat` and `fix` are mandated by the spec itself; the rest come from the
widely-adopted Angular convention and are optional extensions — adopt the
ones that are useful to you.

**Scope** (optional): `feat(auth): add token refresh`

**Breaking changes:** either `!` before the colon (`feat(api)!: ...`) or a
`BREAKING CHANGE:` footer — or both, per spec.

## TDD commit order (per `test.md`)

```
1. test: add failing tests for [feature]
2. feat: implement [feature] to pass tests
3. refactor: clean up [feature] if needed
```

Never combine a failing-test commit with an implementation commit — this is
enforced by `test.md`'s Output Contract.

## Branching — trunk-based development

DORA's _AI Capabilities Model_ (2025) names trunk-based development explicitly
under "Strong version control practices": minimize long-lived branches,
integrate frequently, commit to trunk at least once per day as part of
working in small batches.

**Branch prefixes**, aligned to commit types:

| Prefix     | Use for                            | Handled by (from `discovery-flow.md`) |
| ---------- | ---------------------------------- | ------------------------------------- |
| `feature/` | new functionality                  | Workflow A → B                        |
| `fix/`     | bug fixes                          | Workflow C / D                        |
| `chore/`   | maintenance, non-functional change | Workflow C                            |
| `hotfix/`  | urgent production repair           | Workflow D                            |

**Discipline:**

- Branches should be short-lived — DORA's guidance is oriented around daily
  trunk integration, not a specific hard "max age" number. Pick a threshold
  that fits your team and enforce it consistently rather than adopting a
  number without discussing it as a team first.
- No direct commits to trunk — `feature-flow.md` Phase 0 enforces this.
- Merge to trunk is always human-gated — never automated, per every agent
  file's "Do not merge" rule.

## Enforcement (not yet implemented — see plan issue #2)

Documenting a convention doesn't enforce it. Add a `commit-msg` git hook or CI
check that validates the format before allowing a commit/PR to proceed. Check
your existing `package.json`/`pyproject.toml`/etc. for an existing linter
before adding a new dependency — don't assume commitlint or an equivalent
isn't already present.
