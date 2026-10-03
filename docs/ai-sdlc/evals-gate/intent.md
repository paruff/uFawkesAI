# Intent — Evals gate merges (AC-AI-07)

Status: ACCEPTED (originator: repo owner; v2.0.0 AC-AI-07, issue #148)

## Problem

The agent evals graded only the final answer, ran only on PRs that touched
`.agents/`, and weren't a required check. A config change could make an agent
take a forbidden action, wander, or stall, and still merge.

## Desired Outcome

Per the playbook: evals are a required check, run on every rule, skill or
hook change and on a schedule, and each task has an explicit rubric scoring
task success, tool use and trajectory against `baseline.json`. A template
repo inherits all of it.

## Decisions Already Made

- Extend `scripts/run-evals.sh`; no new framework.
- Branch protection is the owner's action; this change makes the job safe to
  require (it always runs on PRs).
