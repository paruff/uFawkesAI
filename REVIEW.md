# REVIEW.md

Suite review rules for any reviewer of a pull request, human or agent. Each
uFawkes repo's `REVIEW.md` links here and adds only its own commands and paths.
The agent reviewer (`agent-review.yml`) comments only; a human approves and merges.

## Severity

| Level | Meaning | Merge |
| --- | --- | --- |
| Critical | Leaks a secret, loses data, or breaks a release, deploy or hard rule | Blocks |
| Important | A bug, a missing or weakened test, a check not run, or the change contradicts its issue, `docs/ai-sdlc/<feature>/` or `DESIGN.md` | Blocks |
| Minor | Clarity, naming, small simplifications | Author decides |

## Flag

### Verification: did it run?

- The PR pastes the output of the repo's checks (its `REVIEW.md` names them) and CI is green.
- A behavior change with no new or updated test, or a deleted or weakened test.
- A claim in docs, a README or the PR body that the diff doesn't make true.

### Validation: is it the right change?

- The PR says `Closes #n`; the diff does what that issue's exit criterion says, no more.
- The diff traces to `intent.md` → `spec.md` → `plan.md` in `docs/ai-sdlc/<feature>/`; a behavior change updates the spec in the same PR.
- UI changes cite the `DESIGN.md` section they follow and use its tokens, not raw values.
- Edits to `AGENTS.md` (or through its symlinks) or to `intent.md` need the owner.

### Security

- Secrets, tokens or credentials in any file, log line or fixture.
- Auth, permission, input-handling or file-system changes.
- A new dependency, workflow permission or action that isn't pinned by SHA.
- Security work routed to OpenCode (free tiers may retain prompts).
- Agent reports that don't satisfy `.agents/assertions/minimal-report.yaml`.

## Skip

- Formatting and style that `pre-commit` already enforces.
- Generated files and lockfiles, except for version or digest changes.
- Rewording of prose that doesn't change a claim.

## Output

One PR comment. Lead with a one-line verdict: `Clean`, or the count by
severity. Each finding: severity, `file:line`, the defect in one sentence, and
the concrete failure it causes. Say what you did not check. Agents never
approve, request changes through the API, or merge.

### Board

Author: before review, move the issue to _Needs human_ with Gate
`PR review` on [Project #7](https://github.com/users/paruff/projects/7). Any
Critical or Important open: the author moves it back to _In Progress_. Clean:
it stays for the owner, who merges (the board sets _Done_). This repo's
checks: `make validate`.
