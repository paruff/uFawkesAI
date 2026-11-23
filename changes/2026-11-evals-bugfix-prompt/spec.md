---
change: evals-bugfix-prompt
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Make bugfix-first-skill cheap to answer: spec

## Requirements

- R1 The `prompt` in `.agents/evals/tasks/bugfix-first-skill.json` tells the agent the workflow definitions are in `.agents/workflows/`. The `expect`, `rubric` and `max_steps` stay as they are.

## Verification Strategy

| Req | Proof | Command |
| --- | --- | --- |
| R1 | ci | the Agent config evals job passes on the PR, repeated |
