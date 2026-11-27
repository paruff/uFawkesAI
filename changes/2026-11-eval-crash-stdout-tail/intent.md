---
change: eval-crash-stdout-tail
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-27
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 0dd3481
---
# Intent: Evals: show the agent's stdout tail on a silent crash

## Problem

When an eval agent exits non-zero, `run-evals.sh` prints the first 1500 bytes of its stderr (#388). On 2026-11-26 `verifier-blocks-unproven` crashed with exit 1 on `main` and the block was empty: `opencode run --format json` reports its errors as events on stdout, so stderr had nothing. The log said "agent exited 1; stderr (first 1500 bytes):" followed by nothing, and the cause of the only non-step-count flake in the last two weeks stayed unknown. The runner already holds the stdout in `raw`.

## Proposed outcome

When the agent exits non-zero and its stderr is empty, the runner prints the last 1500 bytes of its stdout, indented under the task id, so a crash that reports on stdout explains itself. When both are empty it says so.

## Affected users and systems

Maintainers reading the Agent Config Evals log; `scripts/run-evals.sh` and `scripts/test-run-evals.sh`.

## Constraints

No change to grading, retries, the report or exit codes; nothing extra printed when the agent exits 0, or when stderr already has content; output stays bounded (1500 bytes) so a long transcript cannot flood the log. Secrets are masked by GitHub Actions in CI logs.

## How we know it worked

`scripts/test-run-evals.sh` has cases for: non-zero exit with empty stderr prints the stdout tail; non-zero exit with stderr content prints stderr only; a passing run prints neither; empty stdout and stderr prints the "no output" line. All existing cases still pass.

## Out of scope

Parsing opencode's error events into a one-line reason; changing the 1500-byte bounds; persisting the raw transcript as a CI artifact.

## Open questions

None.
