# Intent — Review passes and an agent PR-review job (#158)

Status: ACCEPTED (originator: repo owner; suite-release plan, "After this plan")

## Problem

The playbook's review stage has no home in the template. There is no
`REVIEW.md` telling a reviewer what to flag, and no job that reviews a PR
before a human does. Review lives only in the verifier agent's prose.

## Desired Outcome

A template repo ships a one-page `REVIEW.md` and a PR job that runs a review
agent against it and posts findings. The agent comments; a human merges.

## Decisions Already Made

- The review agent never approves, requests changes through the API, or merges
  (hard rule 2: no merging your own PR).
- Reuse the `.claude/reviews/` severity shape (HIGH, MEDIUM, LOW).
- Without the API key the job fails with a message; a skipped review must not
  look like a passing one (same stance as `agent-config-ci.yml`).
