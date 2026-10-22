# Contributing to uFawkesAI

Thanks for helping improve this repository. We are building an AI-ready project template that emphasizes disciplined workflow, clear guardrails, and reviewable changes.

## Before you start

- Use Git and a clean branch for every change.
- Install Node.js 22 or newer (see `.nvmrc`) and a recent Bash environment.
- Run `pre-commit run --all-files` before pushing.
- Keep secrets and credentials out of the repository. Do not commit `.env` files or tokens.
- Read `AGENTS.md`, `README.md`, and the relevant docs for the area you are editing before making a change.

## Local setup

1. Fork and clone the repository.
2. Run:

```bash
./scripts/setup.sh
npm install
npm run preflight
```

3. If the repo is missing expected symlinks or hooks, rerun `./scripts/setup.sh`.
4. Use `npm test` or `npm run verify` for repository-level validation when your change affects project behavior.

## Contribution workflow

```text
fork -> branch -> edit -> validate -> commit -> push -> PR -> CI -> review -> merge
```

Keep changes focused. If a task grows beyond one theme, split it into smaller PRs.

## Branches and commit messages

Use short-lived feature branches off `main`:

- `feat/<slug>`
- `fix/<slug>`
- `docs/<slug>`
- `chore/<slug>`

Use Conventional Commits for commit titles and PR titles:

```text
type(scope): description
```

Examples:

- `docs(contrib): expand contributor guide`
- `fix(agents): correct setup instructions`
- `feat(ci): add quality gate validation`

## Pull request expectations

Before opening a PR:

- Keep the scope narrow and reviewable.
- Check the affected behavior with the smallest relevant command.
- Include a short summary of the change and the validation you ran.
- If you used an AI coding agent, state which one and what was checked.

For this repository, the expected checks are:

```bash
npm run preflight
npm test
npm run verify
pre-commit run --all-files
```

If the change is documentation-only, keep the scope to the relevant docs and confirm the content stays accurate.

## CI workflows

Every pull request runs the gates below. Required checks are Pre-flight, Artifact Chain and CI Complete.

| Workflow | What it checks |
| --- | --- |
| `ci-quality.yml` | Pre-flight (pre-commit hooks), tests, PR size, multi-harness smoke test; reports **CI Complete** |
| `artifact-chain.yml` | `intent.md` → `spec.md` → `plan.md` chain and a Verification Strategy for code changes |
| `agent-config-ci.yml` | Replays recorded tasks against the agent configuration; blocks if behaviour regresses |
| `agent-ci.yml` | Agent skill and agent-file validity |
| `agent-review.yml` | Applies `REVIEW.md` with a model when `ANTHROPIC_API_KEY` is set; otherwise warns and passes |
| `doc-freshness.yml` | Documentation freshness |
| `secret-scan.yml`, `dependency-review.yml` | Secrets and dependency changes |
| `main-ci-guard.yml` | Main's CI must be green before a PR can merge |
| `build-cde-space-image.yml` | Builds, verifies, signs and publishes the images on a `v*` tag |
| `image-lock-bump.yml`, `pre-commit-autoupdate.yml` | Weekly bumps of pinned tools and hook versions |
| `image-reproducibility.yml`, `live-acceptance.yml` | Weekly rebuild comparison; acceptance tests inside the published image |
| `release-please.yml` | Release PRs and changelog |

## Review and maintenance

- Keep code, docs, and agent instructions consistent with one another.
- Do not modify `AGENTS.md` indirectly through a generated alias; update the source file and refresh symlinks if needed.
- Prefer small, understandable changes over broad refactors.
- If something is unclear, document the assumption or flag it in the PR instead of guessing.

## Code of conduct

We expect respectful collaboration. Please treat contributors, maintainers, and users with professionalism, and keep the project safe, readable, and welcoming for everyone.
