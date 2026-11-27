---
change: eval-flake-retries
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-27
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Evals: retry flakes, never wrong answers

## Problem

The Agent Config Evals gate fails PRs and `main` pushes on noise from the model, not on regressions. Since the model fix on 2026-11-26, four of about fourteen real-model runs failed, each on a single task of six: `bugfix-first-skill` took 12 steps against a cap of 8; `commit-format` took 5 and later 7 against 4; `branch-rules` took 7 against 6 (a failed run on `main` itself); and once `verifier-blocks-unproven` hit an agent exit 1 with empty stderr. The answers were right in the step-count cases. The baseline is 1.0 on every dimension, so one noisy task out of six fails the gate, and a rerun passes. Each failure costs a rerun and trains people to ignore a red gate.

## Proposed outcome

`run-evals.sh` retries, once, the two kinds of failure that are not a verdict on the configuration: an agent crash with no output, and a task whose answer and tool use are right but whose step count is over the cap. A wrong answer, a forbidden tool, or a file that should or should not exist is never retried (the script already holds that rule for timeouts). Retried tasks are shown in the log and the report. The baseline stays 1.0 and the step caps are unchanged.

## Affected users and systems

Anyone whose PR touches agent config; maintainers watching `main`; `scripts/run-evals.sh`, `scripts/test-run-evals.sh`.

## Constraints

No weakening of what the gate asserts: baseline rates and caps stay put, and a regression that consistently breaks a task still fails every attempt. A retry must run in a fresh copy of the tree. Extra CI time only on the runs that flake (one more agent call per flaky task, tens of seconds).

## How we know it worked

New cases in `scripts/test-run-evals.sh`: a crash then a pass, and a step overrun then a pass, both end green with the task marked as retried; a task that overruns every time, a wrong answer, and a forbidden tool each still fail with no retry for the last two. Over the next weeks the gate stops failing on single-task step variance.

## Out of scope

Raising the step caps or lowering the baseline; making the agent's raw stdout visible when stderr is empty (the crash on 2026-11-26 printed an empty stderr block; separate follow-up); a pass-at-k or median scheme.

## Open questions

None.
