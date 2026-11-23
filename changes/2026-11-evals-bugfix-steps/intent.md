---
change: evals-bugfix-steps
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-23
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Raise max_steps for bugfix-first-skill

## Problem

The `bugfix-first-skill` eval, a read-only question, takes 9 to 11 steps against a `max_steps` of 8, so the Agent config evals job fails on PRs that change agent config (#372, and once on #369).

## Proposed outcome

`max_steps` is 12 for that task so the gate stops failing on model noise, with the baseline otherwise untouched.

## Affected users and systems

`.agents/evals/tasks/bugfix-first-skill.json`; the Agent config evals job.

## Constraints

Changing agent configuration goes through the continuous-evals skill. No other task or baseline changes.

## How we know it worked

The Agent config evals job passes on #372 after rebase, with `trajectory` at 1.0.

## Out of scope

Rewriting the eval (phase 3 reviews it when the loop is retired); changing other budgets.

## Open questions

- Is 12 enough? Observed 9, 10, 11.
