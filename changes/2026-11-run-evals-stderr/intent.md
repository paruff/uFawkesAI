---
change: run-evals-stderr
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-26
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-26
approved_sha: c81c363
---
# Intent: Print the agent's stderr when an eval task fails

## Problem

`scripts/run-evals.sh` keeps each agent's stderr in a temp file and reports only `agent exited N`. When the Agent Config Evals failed on every task (2026-11-23 to 2026-11-25), the real cause, `ProviderModelNotFoundError: Model not found: google/gemini-3.1-flash-lite`, was invisible in the CI log. It looked like a provider key or quota problem and took a diagnostic CI step and several runs to find (#387).

## Proposed outcome

When an agent exits non-zero, the runner prints the first 1500 bytes of its stderr to the log, indented under the task id, so a crash explains itself.

## Affected users and systems

Maintainers reading the Agent Config Evals log; `scripts/run-evals.sh` and its test `scripts/test-run-evals.sh`.

## Constraints

No change to grading, exit codes or the report; nothing printed when the agent exits 0; the output is bounded (1500 bytes) so a noisy agent cannot flood the log. Secrets are masked by GitHub Actions in CI logs.

## How we know it worked

`scripts/test-run-evals.sh` has cases proving stderr is printed on a non-zero exit and absent on a passing run, and all existing cases still pass.

## Out of scope

Retrying failed tasks; changing the eval model, `baseline.json` or the stale `gemini-3.1-flash-lite` default in `run-evals.sh` (separate change).

## Open questions

None.
