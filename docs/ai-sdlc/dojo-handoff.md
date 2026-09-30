# Dojo Handoff — from a completed plan to a Dojo lab, and back

The AI-SDLC chain ends in code; the Dojo learning loop turns that code into
a lab in [paruff/uFawkesDojo](https://github.com/paruff/uFawkesDojo), and
turns what learners hit into the next cycle's intent:

```
intent.md → spec.md → plan.md → code ─► Dojo lab ─► dojo-feedback.md ─► `intent` issue ─► new intent.md
    ▲                                                                                        │
    └────────────────────────────────── within one sprint ───────────────────────────────────┘
```

A learner is the first person who didn't build the feature to make it work.
Where they get stuck, a guardrail, prompt, spec, plan or lab missed
something, and that is exactly what the next cycle should fix.

## 1. When a plan is ready to become a lab

All of these hold for `docs/ai-sdlc/<feature>/`:

- [ ] `intent.md`, `spec.md` and `plan.md` are merged to `main` (the
      artifact-chain gate guarantees intent ← spec, and plan for `src/` changes).
- [ ] `plan.md` has a `## Verification Strategy` table covering **every** AC
      in `spec.md`, and each row's command/CI job has passed on `main`.
- [ ] The feature runs somewhere a learner can reach (a repo checkout, a
      Compose stack, a public workflow run). uFawkesDojo's authoring rule
      applies: **no lab step may be described unless it has been run, for
      real, by the person or agent writing it.**

## 2. The mapping

| uFawkesAI artifact                                      | Becomes in the uFawkesDojo lab                                               |
| ------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `intent.md` → Problem / Desired outcome                  | The lab's **Why** paragraph and **Objectives** (what the learner will have)  |
| `plan.md` → **Verification Strategy** rows              | The **lab exercise**: one numbered step per row, in `instructions.md`        |
| `plan.md` → Implementation Sequence                     | The **worked example** in `solution/` (study before doing, per the Dojo guide) |
| `spec.md` → **Acceptance Criteria**                     | The **grading rubric**: one `record_test` per AC in `validate.sh`            |
| AC `test_type` (`unit` / `integration` / `live-system`) | What the rubric check touches: a test command / a composed system / a real deployment |

### Exercise — from the Verification Strategy

Each Verification Strategy row (`AC | How it is proven | test_type | Command / CI job`)
becomes one lab step:

1. **Title** = the row's "How it is proven", written as a task ("Validate the
   deploy-marker against the uFawkesDORA schema"), not a feature tour.
2. **Command** = the row's command, run for real while authoring; paste the
   actual output (or an accurate paraphrase) into the step.
3. **Retrieval prompt** = one open question per step ("What would the event
   look like if the PR had no Agent-Tokens footer?"), per the Dojo guide's
   "open-response retrieval" rule.

Rows whose command is a CI job become "inspect a real run" steps (for
example `gh run download … --name dora-events`), never "imagine the output".

### Rubric — from the Acceptance Criteria

Each AC becomes exactly one check in `validate.sh`, using uFawkesDojo's
existing pattern:

```bash
record_test "AC-01" "PASS|FAIL" "<the AC's assertion, in the learner's words>"
```

- The check's name is the AC id, so `validate.sh` output maps 1:1 onto the spec.
- It asserts the AC's observable outcome, not the learner's keystrokes.
- `live-system` ACs are checked against the running system (HTTP response,
  dashboard/API state, artifact contents), never against a file the learner
  could hand-write.
- `validate.sh` exits 0 only if every AC passes, and never swallows a
  failed check without printing what broke (the Dojo's feedback rule:
  immediate, from something real).

### Where it lands in uFawkesDojo

```
<belt>/module-NN-<slug>/
  README.md                 # module page linking the lab
  lab-NN/
    instructions.md         # header + Why/Objectives + exercise steps
    validate.sh             # rubric: one record_test per AC
    solution/               # worked example from the Implementation Sequence
```

`instructions.md` starts with a provenance header so feedback can find its
way back:

```markdown
**Source:** uFawkesAI `docs/ai-sdlc/<feature>/` @ `<commit>`
(exercise = plan.md › Verification Strategy; rubric = spec.md › Acceptance Criteria)
```

Pick the belt by what the lab needs, following uFawkesDojo's `README.md`.
Before publishing, run `dojo-content/lab-verify` on a clean environment.

## 3. From lab to feedback

After a cohort (or a facilitator dry run) completes the lab, load the
**`dojo-feedback`** skill (`.agents/skills/dojo-feedback/SKILL.md`). It
reads the `validate.sh` results and learner notes and writes
`docs/ai-sdlc/<feature>/dojo-feedback.md` in uFawkesAI:

- **Lab Results**: pass/fail per AC.
- **Gaps**: each typed `guardrail`, `prompt`, `spec`, `plan` or `lab`, with
  evidence.
- **Proposed Intent**: Problem / Desired outcome / Out of scope, ready to
  become the next `intent.md`.

Validate it before opening the PR:
`scripts/dojo-feedback-intent.sh docs/ai-sdlc/<feature>/dojo-feedback.md --out-dir /tmp/dojo`.

## 4. From feedback to the next intent (CI)

`.github/workflows/dojo-feedback-intent.yml`:

1. **On merge to `main`** of any `docs/ai-sdlc/**/dojo-feedback.md`: it
   validates the file and opens an issue labelled **`intent`**. The issue
   carries the gaps and a ready-to-commit draft of
   `docs/ai-sdlc/<proposed_feature>/intent.md`, with a due date one sprint
   out. There is one issue per feedback file, so re-runs never duplicate.
   "No gaps" opens nothing.
2. **The cycle restarts:** someone commits the draft (edited as needed —
   humans decide intent) in a PR that says `Closes #<issue>`, then
   continues at the `spec` stage.
3. **Daily:** any `intent` issue still open after **one sprint** is labelled
   `intent-overdue`, with a comment. The sprint is the `learn` agent's
   weekly cadence: 7 days, set by the repo variable `DOJO_SPRINT_DAYS`.

**The loop's health metric** is the time from the `intent` issue opening to
its closing PR merging: it must be under one sprint. Issues labelled
`intent-overdue` are the loop's failures, and are worth raising at the
sprint-end `learn` retrospective.
