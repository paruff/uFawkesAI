---
change: eval-flake-retries
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-27
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: e153d21
---
# Intent: Evals: retry flakes, never wrong answers

## Problem

The Agent Config Evals gate fails PRs and `main` pushes on noise from the model, not on regressions. Since the model fix on 2026-11-26, four of about fourteen real-model runs failed, each on a single task of six: `bugfix-first-skill` took 12 steps against a cap of 8; `commit-format` took 5 and later 7 against 4; `branch-rules` took 7 against 6 (a failed run on `main` itself); and once `verifier-blocks-unproven` hit an agent exit 1 with empty stderr. The answers were right in the step-count cases. The baseline is 1.0 on every dimension, so one noisy task out of six fails the gate, and a rerun passes. Each failure costs a rerun and trains people to ignore a red gate.

The caps themselves are part of the cause. Over eight recent reports on `gemini-3.5-flash-lite`, `branch-rules` (cap 6) took 2, 2, 2, 2, 3, 7, 7 and 9 steps; `commit-format` (cap 4) took 1, 2, 3, 4, 4, 4, 6 and 7; `bugfix-first-skill` (cap 8) took 4 to 8, with a 12 seen in a failed run. The caps were set in October for the previous model, so for three tasks they sit at or below what this model normally takes. The first run of this change's own PR showed it: `branch-rules` took 11 steps, was retried, took 7, and still failed a cap of 6. A retry cannot fix a cap that is below the typical count.

## Proposed outcome

`run-evals.sh` retries, once, the two kinds of failure that are not a verdict on the configuration: an agent crash with no output, and a task whose answer and tool use are right but whose step count is over the cap. A wrong answer, a forbidden tool, or a file that should or should not exist is never retried (the script already holds that rule for timeouts). Retried tasks are shown in the log and the report. The baseline stays 1.0. The step caps of the three tasks whose cap is below the model's observed range are raised: `branch-rules` 6 to 12, `commit-format` 4 to 8 and `bugfix-first-skill` 8 to 12; the other three stay.

## Affected users and systems

Anyone whose PR touches agent config; maintainers watching `main`; `scripts/run-evals.sh`, `scripts/test-run-evals.sh`.

## Constraints

No weakening of what the gate asserts: baseline rates stay at 1.0, and a regression that consistently breaks a task still fails every attempt. The raised caps remain far below a looping or wandering agent (a dozen steps for a one-line answer is still a flag), and they only move for the three tasks whose cap sat inside the model's normal range. A retry must run in a fresh copy of the tree. Extra CI time only on the runs that flake (one more agent call per flaky task, tens of seconds).

## How we know it worked

New cases in `scripts/test-run-evals.sh`: a crash then a pass, and a step overrun then a pass, both end green with the task marked as retried; a task that overruns every time, a wrong answer, and a forbidden tool each still fail with no retry for the last two. Over the next weeks the gate stops failing on single-task step variance.

## Out of scope

Lowering the baseline or changing the other three caps; re-measuring caps for another model; making the agent's raw stdout visible when stderr is empty (the crash on 2026-11-26 printed an empty stderr block; separate follow-up); a pass-at-k or median scheme.

## Open questions

None.
