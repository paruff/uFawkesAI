# REVIEW.md

Rules for any reviewer of a pull request here, human or agent. One page.
The agent reviewer (`agent-review.yml`) comments only; a human approves and
merges.

## Flag

- Secrets, tokens or credentials in any file, log line or fixture.
- Edits to `AGENTS.md` (or edits made through its symlinks).
- A behavior change with no new or updated test, or a deleted or weakened test.
- A claim in docs or a README that the diff doesn't make true.
- A new dependency, workflow permission or action that isn't pinned by SHA.
- Auth, permission, input-handling or file-system changes.
- Agent reports that don't satisfy `.agents/assertions/minimal-report.yaml`.
- A diff that doesn't trace to the linked issue and `docs/ai-sdlc/<feature>/`.

## Skip

- Formatting and style that `pre-commit` already enforces.
- Generated files and lockfiles, except for version or digest changes.
- Rewording of prose that doesn't change a claim.

## Severity

| Level | Meaning |
| --- | --- |
| HIGH | Would break a release, leak a secret or contradict a hard rule. Fix before merge |
| MEDIUM | Likely bug or untested path. Fix or justify |
| LOW | Minor, optional |

## Output

One comment. Each finding: severity, `file:line`, the defect in one sentence,
and the concrete failure it causes. Lead with a one-line verdict: `Clean`,
or the count by severity. Say what you did not check. Never approve, never
request changes through the API, never merge.
