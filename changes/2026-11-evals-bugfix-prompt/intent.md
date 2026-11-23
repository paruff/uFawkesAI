---
change: evals-bugfix-prompt
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-23
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: 2d5fd4d
---
# Intent: Make bugfix-first-skill cheap to answer

## Problem

The `bugfix-first-skill` eval, a read-only question, now takes 13 to 15 steps against a budget of 8, and raising the budget does not hold (9, 10, 11, 13, 15 seen). It fails the Agent config evals job on PRs that change agent config, and blocks #372. The agent wanders because the prompt does not say where the workflow definitions are.

## Proposed outcome

The prompt names `.agents/workflows/`, so the answer takes a few steps, and the budget of 8 holds without being raised.

## Affected users and systems

`.agents/evals/tasks/bugfix-first-skill.json`; the Agent config evals job.

## Constraints

Changing agent configuration goes through the continuous-evals skill. The expected answer (`systematic-debugging`), the rubric and the baseline do not change.

## How we know it worked

The Agent config evals job passes on #372 after rebase, with `trajectory` at 1.0 across repeated runs.

## Out of scope

Changing other tasks or budgets; phase 3 may rewrite this eval when the hand-built loop is retired.

## Open questions

- Does naming the directory make the eval too easy? It still checks that the agent reads the right file.
