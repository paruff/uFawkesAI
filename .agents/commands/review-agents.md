---
description: Request focused code review from a subagent with git SHA context
agent: builder
---
Dispatch review subagents with `BASE_SHA` and `HEAD_SHA`.
Reviewer output must include: Strengths, Issues (Critical/Important/Minor), and Assessment.
Focus on correctness, requirements fulfillment, edge cases, security, and test coverage.
Run security, correctness, and coverage reviewers in parallel when possible.
