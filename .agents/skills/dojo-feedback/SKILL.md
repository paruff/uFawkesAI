---
name: dojo-feedback
description: "After a uFawkesDojo lab built from a uFawkesAI feature is completed, turn what learners hit into a dojo-feedback.md artifact: graded results per acceptance criterion, gaps in guardrails/prompts/spec/plan/lab, and a proposed intent that CI turns into an `intent` issue so the AI-SDLC cycle restarts."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dojo Feedback

> **Load trigger:** `"load dojo-feedback skill"` > **DORA:** AI Capability 7: Quality internal platforms + Core: Learning culture
> **Token cost:** Low

## Purpose

Close the Dojo learning loop (`docs/ai-sdlc/dojo-handoff.md`):

```
intent.md → spec.md → plan.md → code → Dojo lab → dojo-feedback.md → new intent.md
```

A lab built from a feature's `plan.md` (exercise) and `spec.md` (rubric) is
the first time someone who did not build the feature has to make it work.
Wherever they got stuck, the guardrails, prompts, spec, plan, or lab missed
something. This skill captures those gaps as evidence and packages them as a
proposed intent, so the next cycle fixes them.

**Scope boundary:** feedback about the *platform* from its users is
`platform-feedback`; authoring/verifying Dojo modules is `dojo-content`.
This skill is only the lab → feedback → intent step.

## When to Run

| Situation                                                  | Run? |
| ---------------------------------------------------------- | ---- |
| A cohort (or one facilitator run) completed a handed-off lab | Yes  |
| `validate.sh` failed for a learner on a rubric check        | Yes  |
| A learner needed help outside the lab instructions          | Yes  |
| Lab completed cleanly, nobody got stuck, no gaps            | Yes — record "no gaps"; do **not** invent any. CI opens no issue without a gap. |

## Inputs (read before writing)

1. The lab in uFawkesDojo: `instructions.md`, `validate.sh`, `solution/`.
2. Every learner's `validate.sh` output (the per-check PASS/FAIL lines).
3. Facilitator/learner notes: where they stalled, what they asked, what they
   looked up outside the lab.
4. The source chain in uFawkesAI: `docs/ai-sdlc/<feature>/intent.md`,
   `spec.md`, `plan.md` (the lab header names the feature and commit).
5. The guardrails and prompts the feature was built under: `AGENTS.md`,
   `.agents/skills/{spec,design,build}/SKILL.md`, hooks
   (`scripts/hooks/protected-paths.json`), CI gates (`.github/workflows/`).

## Gap Types

Classify each gap by where the fix belongs — this decides who acts on it:

| Type        | Meaning                                                              | Typical fix location                       |
| ----------- | -------------------------------------------------------------------- | ------------------------------------------ |
| `guardrail` | A hook, CI gate, or policy let something wrong through (or blocked something right) | `scripts/hooks/`, `.github/workflows/`, `AGENTS.md` (human) |
| `prompt`    | An agent prompt or skill produced an artifact that misled the learner | `.agents/agents/*.md`, `.agents/skills/`   |
| `spec`      | An acceptance criterion was ambiguous, untestable, or missing        | the feature's `spec.md` (via a new intent) |
| `plan`      | The Verification Strategy didn't actually prove the AC               | the feature's `plan.md`                    |
| `lab`       | Only the lab's wording/setup was wrong — the feature was fine        | uFawkesDojo (fix there; no intent needed)  |

A gap is only real with **evidence**: a failing check line, a quoted
learner question, a command that didn't behave as the lab said. No
evidence, no gap.

## Output — `docs/ai-sdlc/<feature>/dojo-feedback.md`

Write it next to the source chain, on a branch, and open a PR. The format
is parsed by `scripts/dojo-feedback-intent.sh` — keep the front matter keys,
headings, and `GAP-NN` bullets exactly as shown.

````markdown
---
lab: white-belt/module-03-delivery-events/lab-01   # path in paruff/uFawkesDojo
lab_ref: <uFawkesDojo commit or PR URL>
source_feature: docs/ai-sdlc/<feature>
source_commit: <uFawkesAI commit the lab was built from>
completed_at: YYYY-MM-DD
learners: <number>
proposed_feature: <kebab-case slug for the new docs/ai-sdlc/<slug>/intent.md>
---

# Dojo Feedback: <feature>

## Lab Results

| AC    | Rubric check (validate.sh) | Passed | Failed | Notes |
| ----- | -------------------------- | ------ | ------ | ----- |
| AC-01 | ...                        | 3      | 0      |       |

## Gaps

### GAP-01: <short title>

- **Type:** guardrail | prompt | spec | plan | lab
- **Evidence:** <failing check line, quoted question, observed behaviour>
- **Affected:** `<path>`
- **Proposed change:** <what should change>
- **Severity:** high | medium | low

## Proposed Intent

### Problem

<Why the next cycle is needed, citing GAP-NN ids.>

### Desired outcome

<What "fixed" looks like, testable.>

### Out of scope

- <Explicitly excluded>
````

If there are no gaps, keep `## Gaps` with the single line `None.` and write
`None — no follow-up cycle needed.` under `### Problem`; CI then opens no
issue.

## What happens next (automated)

1. Merging the PR to `main` runs `.github/workflows/dojo-feedback-intent.yml`,
   which validates the file and opens an issue labelled **`intent`** with the
   gaps and a ready-to-commit draft of
   `docs/ai-sdlc/<proposed_feature>/intent.md`.
2. Someone commits that `intent.md` in a PR whose body says `Closes #<issue>`
   — the cycle restarts at the `spec` stage.
3. The issue is due **one sprint** after it opens (7 days by default; repo
   variable `DOJO_SPRINT_DAYS`). A daily check labels it `intent-overdue` and
   comments if it is still open after that.

## Validation

```bash
scripts/dojo-feedback-intent.sh docs/ai-sdlc/<feature>/dojo-feedback.md --out-dir /tmp/dojo
```

Exit 0 = well-formed (and `/tmp/dojo/{issue-title.txt,issue.md,intent.md}`
show exactly what CI will open). Fix any reported problem before opening the PR.

## Hard Rules

- Never record a gap without evidence from the lab run.
- Never invent gaps to justify a new cycle — "None." is a valid result.
- Never edit `AGENTS.md` to fix a `guardrail` gap; propose it for a human.
- `lab`-type gaps are fixed in uFawkesDojo; they do not need an intent unless
  they reveal a gap of another type too.
