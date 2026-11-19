# Spec — public release: a repo that holds up on first read

**Traces to:** [`intent.md`](intent.md). Umbrella for goal #310. Release mechanics stay in
[`../v2.3.0/spec.md`](../v2.3.0/spec.md) (AC-230-01 to AC-230-03).

## Acceptance criteria

Each criterion is checked by a command or a read, and the result goes in the PR.

### AC-PR-01: Every relative link resolves
A script walks every tracked `*.md` and fails on a relative link whose target is missing. Today it finds 7, all in
`docs/AGENT_REFERENCE.md` (`./docs/METRICS.md` should be `./METRICS.md`). The script runs in CI.

### AC-PR-02: No invented content
`git grep -nE 'JIRA-[0-9]+|\[PROJECT NAME\]|/users/get|src/auth/'` is empty outside `docs/ai-sdlc/` history notes.
The four filler docs (`docs/API_SURFACE.md`, `docs/CHANGE_IMPACT_MAP.md`, `docs/DEVEX_LOG.md`,
`docs/KNOWN_LIMITATIONS.md`) are deleted, or `KNOWN_LIMITATIONS.md` is kept with only the real rows (L-004, L-005).
Every file that linked to a deleted doc is updated (README, `docs/README.md`, `docs/RUNBOOKS.md`,
`.github/ISSUE_TEMPLATE/feature.yml`, `.github/instructions/feature.instructions.md`).

### AC-PR-03: No orphan files
A script lists tracked files whose basename no running or read file references, minus a short allow-list
(GitHub conventions, slash commands, symlink targets). It prints nothing. The audit candidates are each
deleted or justified in the PR:
`scripts/agent-skill-graph.sh`, `scripts/verify.sh`, `.claude/reviews/prs-179-183-review.md`, `rules/README.md`,
`opencode/commands/review-local.md` (duplicate), `.github/ISSUE_TEMPLATE/bug.yml` or `bug_report.yml` (duplicate),
and the sibling-repo skill files (`suite-audit.md`, `cross-repo-links.md`, `ci-integration.md`, `startup.md`) unless
a public skill needs them.

### AC-PR-04: Overtaken artifacts live only in git history
Delete `docs/ai-sdlc/` chains that shipped or were superseded: `v2.0.0`, `v2.2.0`, `audit-medium-low`,
`remove-aidlc`, `cde-space-rename`, `devsecops-image`, and `open-source-ready` (last, in the release PR). Keep
`v2.3.0`, `dora-events`, `dual-harness-template` and this chain until they ship. `docs/ai-sdlc/README.md` names the
recovery command (`git show <tag>:docs/ai-sdlc/<feature>/spec.md`, as it does for earlier chains) and every link
into a deleted chain is removed. v2.3.0's "don't touch anything another doc links to" is satisfied by removing the
links first.

### AC-PR-05: Slop check
`/ponytail-audit` over the whole repo is re-run at the end. Every Must fix and Should fix is fixed or has a
one-line reason in the PR. A second read of the README, `docs/` and `.agents/skills/` removes filler, restated
rules and invented examples. No new file is added to do this.

### AC-PR-06: The README is verifiable
`scripts/check-readme-claims.sh` passes (it does today). The README shows badges for CI on `main`, the latest
release and the licence, each linking to a live target. Any coverage or test-count claim carries a measured number
or is removed (L-005).

### AC-PR-07: Community profile and security posture
`gh api repos/paruff/uFawkesAI/community/profile` reports every file present, including the security policy.
`SECURITY.md` says how to report, which versions are supported, and how to verify the signed image. Secret scanning,
push protection and Dependabot are on (checked today: they are) and named in `docs/`.

### AC-PR-08: Cold start works
On a clean clone, the documented steps reach a green `pre-commit run --all-files` and a first agent session.
`.github/workflows/live-acceptance.yml` is the evidence; the run link goes in the release PR.

### AC-PR-09: One version everywhere
`CHANGELOG.md`, `.release-please-manifest.json`, `package.json` and the image tag name the same version.
Upgrade notes cover every file the diet removed that downstream repos copy (v2.3.0 interfaces table).

### AC-PR-10: Release path proven, then announce
v2.3.0's AC-230-01 holds (`docker manifest inspect ghcr.io/paruff/fawkes-space:2.3.0` exits 0) and the image
signature verifies. Pipe refs sit on one tagged release (#309). Only then does the `release` skill draft the
LinkedIn and dev.to posts, which link to the tag, not to `main`.

## Interfaces

| Interface | Direction | Contract |
| --- | --- | --- |
| Downstream repos copying template files | Provides | Deleting a copied file is a breaking change and goes in the release notes (v2.3.0 rule) |
| `scripts/check-artifact-chain.sh` | Consumes | Every `spec.md` keeps a sibling `intent.md`; a PR changing `scripts/`, `images/` or `templates/` carries a `plan.md` with `## Verification Strategy` |
| Branch protection (`Pre-flight`, `Tests & Coverage`, `Agent config evals`) | Consumes | Each PR passes them; no admin bypass |

## Decisions made without the owner (change any of these)

- Fake docs are deleted, not rewritten. Adopters who want a starter get it from `templates/`, not from this repo's docs.
- `KNOWN_LIMITATIONS.md` is kept only if L-004 and L-005 are worth a page; otherwise they move into `docs/ARCHITECTURE.md`.
- Link and orphan checks are small bash scripts with a bash self-test, matching the repo's existing suites. No new dependency.
