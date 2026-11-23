---
change: evals-bugfix-steps
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Raise max_steps for bugfix-first-skill: spec

## Requirements

- R1 `.agents/evals/tasks/bugfix-first-skill.json` has `trajectory.max_steps` 12 and nothing else changes.

## Verification Strategy

| Req | Proof | Command |
| --- | --- | --- |
| R1 | ci | the Agent config evals job passes |
