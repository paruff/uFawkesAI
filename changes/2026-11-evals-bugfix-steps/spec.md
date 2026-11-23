---
change: evals-bugfix-steps
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: cfc3db5
---
# Raise max_steps for bugfix-first-skill: spec

## Requirements

- R1 `.agents/evals/tasks/bugfix-first-skill.json` has `trajectory.max_steps` 12 and nothing else changes.

## Verification Strategy

| Req | Proof | Command |
| --- | --- | --- |
| R1 | ci | the Agent config evals job passes |
