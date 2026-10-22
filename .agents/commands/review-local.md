---
description: Review the change against REVIEW.md before commit and CI
agent: verifier
---
Review the change before it is committed. This is the same rubric CI's agent
review applies, run earlier so findings cost minutes, not a PR round trip.

1. Read `REVIEW.md` first: its Flag and Skip lists, severity levels and output format.
2. Diff: `git diff --staged`; if nothing is staged, `git diff origin/main...HEAD`.
3. Read the linked `docs/ai-sdlc/<feature>/{intent,spec,plan}.md`. A diff that
   traces to none of them is itself a finding.
4. Report as `REVIEW.md` says: a verdict line (`Clean` or the count by severity),
   then each finding as severity, `file:line`, the defect, the concrete failure.
   Say what you did not check.

Read-only: do not edit files, stage, commit or push. Any HIGH finding blocks the
commit; hand it back to `@builder`.
