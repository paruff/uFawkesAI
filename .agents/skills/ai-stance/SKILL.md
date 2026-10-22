---
name: ai-stance
description: "Write and maintain AI_STANCE.md: what AI use is expected, which tools are permitted, and what is prohibited, permitted with guardrails, or allowed. Use when onboarding a repo, adopting a new AI tool or model, or at the quarterly review. Implements DORA AI Capability 1."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
  cadence: quarterly
---

# Skill: ai-stance

> **Load trigger:** "load ai-stance skill" · **DORA:** AI Capability 1, a clear and communicated AI stance

`AI_STANCE.md` states how AI is used in the repo. `scripts/check-ai-stance.sh` (pre-commit and CI) enforces the
structure: three policy buckets and a `Last reviewed:` date. This skill covers what the script cannot judge.

## When to use

- Onboarding a repo, or adopting a new AI tool or model (update the stance in the same PR).
- The quarterly review, or after a reported violation of a Prohibited item.

## Write it

Ask for: the repo name, any repo-specific prohibited uses, any tools beyond the defaults, and compliance needs
(SOC2, GDPR). Then write `AI_STANCE.md` with these parts:

1. **Header.** `Last reviewed: <today>`, `Next review due: <today + 90 days>`, owner.
2. **Expectation of use.** Whether AI use is expected, encouraged, optional or discouraged, in one sentence of why.
   State that it applies to human contributors and AI agents.
3. **Organizational support.** Permitted tools (each with a named model or version, not "latest LLM"), where the
   skills live, and how to raise a policy concern (an issue labelled `ai-policy`).
4. **Three buckets.**
   - *Prohibited* (at least three items): sending PII, credentials or private infrastructure config to public
     models; committing AI-generated code that fails pre-commit; bypassing branch protection; unreviewed
     AI-generated security policy. Add repo-specific items, such as alerting rules or access policies that page people.
   - *Permitted with guardrails*: a table of use and guardrail, for example "AI code merged to main: human review and a
     test covering the change".
   - *Allowed*: genuinely low-risk uses such as completion, explanations, first drafts, triage.
5. **Agent obligations.** Agents verify this file exists before work, log the session, and halt on a Prohibited action
   until a human authorizes it.

## Audit it

Run `bash scripts/check-ai-stance.sh`, then check by hand:

- Every listed tool is in use, none is end-of-life, and each model id is current.
- Nothing in Allowed should have a guardrail; no "it depends" without saying on what.
- `Last reviewed` is present and `Next review due` is not past; no `[PLACEHOLDER]` text remains.

Report gaps as Critical (block release), Non-critical (fix within 30 days), or Informational, each with the fix.

## Keep it consistent across repos

When one uFawkes repo changes a shared item (a tool, a model, a Prohibited entry), compare the others:
`diff <(sed -n '/^## Permitted Tools/,/^## /p' ../<repo>/AI_STANCE.md) <(sed -n '/^## Permitted Tools/,/^## /p' AI_STANCE.md)`.
Differences are fine when justified by the repo; unexplained ones are drift.
