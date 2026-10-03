---
description: Research and produce intent.md, spec.md, and plan.md for a feature
agent: planner
---
Load `superpowers/brainstorming` if available; otherwise run a structured research workflow.
Ask clarifying questions one at a time.
Produce `docs/ai-sdlc/<feature>/intent.md`, then `spec.md`, then `plan.md` in the same folder
(`<feature>` is a short kebab-case name; `plan.md` needs a `## Verification Strategy` section).
Commit each artifact with the prefix `docs(plan):`.
Do not write implementation code.
