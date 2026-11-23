---
change: evals-bugfix-prompt
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: aee7f80
---
# Make bugfix-first-skill cheap to answer: spec

## Requirements

- R1 The `prompt` in `.agents/evals/tasks/bugfix-first-skill.json` tells the agent the workflow definitions are in `.agents/workflows/`. The `expect`, `rubric` and `max_steps` stay as they are.

## Verification Strategy

| Req | Proof | Command |
| --- | --- | --- |
| R1 | ci | the Agent config evals job passes on the PR, repeated |
