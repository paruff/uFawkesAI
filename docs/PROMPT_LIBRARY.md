# Prompt Library — [PROJECT NAME]

> DORA 2025 (AI Cap 2): "Prompt engineering is rising as a core developer skill.
> The modern engineer's value is in prompt engineering, solution architecture,
> and validating AI outputs — not just writing code."
>
> This library is versioned. When a prompt produces repeated bad output, update it
> and add a changelog entry. The library is a living document.

---

## Prompt Library Changelog

| Date       | Change                                                                                  | Author  |
| ---------- | --------------------------------------------------------------------------------------- | ------- |
| 2026-05-10 | Added "Using Agent Skills" section                                                      | @paruff |
| 2026-05-10 | Added DORA AI Capabilities, Multi-agent orchestration, Agent Skills invocation sections | @paruff |

---

## How to Use This Library

1. Find the task category
2. Copy the prompt template
3. Replace `{{PLACEHOLDERS}}`
4. Paste into Copilot Chat with the specified context files open
5. If output is wrong: see "Red flags" and re-prompt or escalate

---

## Category: Feature Implementation (TDD)

### New Utility Function

**Context to open:** `src/types/index.ts`, `tests/unit/utils/`, your failing test

```
Implement the function {{FUNCTION_NAME}} to make this failing test pass.

Architecture rules (from .github/copilot-instructions.md):
1. This function goes in src/utils/ — it must be a pure function (no side effects)
2. All types from src/types/index.ts — no inline type definitions
3. Return type must be explicit

The failing test:
{{PASTE_TEST}}

Read src/types/index.ts before writing. Do not import from src/services/ or src/hooks/.
```

**Expected output:** The function implementation that makes the test pass, plus JSDoc.

**Red flags:**

- Function imports from `services/` or `hooks/` → reject, re-prompt with rule 1
- Missing return type → reject, ask for explicit return type
- `any` type in catch block → reject, ask for typed error handling

---

### New Service Method

**Context to open:** `src/types/index.ts`, `src/services/[relevant service].ts`, your failing test

```
Implement the service method {{METHOD_NAME}} to make this failing test pass.

Architecture rules:
1. This goes in src/services/{{SERVICE_FILE}} — it may call the Firebase SDK directly
2. It must scope all Firestore operations to the authenticated userId
3. It must never surface raw SDK error messages — map errors to typed errors
4. All input validation goes here (validate before writing to DB)

Read src/types/index.ts and docs/API_SURFACE.md first.

The failing test:
{{PASTE_TEST}}
```

**Red flags:**

- No userId scoping on Firestore operations → SECURITY issue, escalate to @security-agent
- Raw error message returned → reject, ask for error mapping

---

## Category: Code Review

### Pre-Review PR Scan

**Context:** Open the diff

```
Review this PR for the {{PROJECT_NAME}} project.
Read .github/copilot-instructions.md and docs/ARCHITECTURE.md first.

Report findings in five categories:
1. ARCHITECTURE: Layer boundary violations (screens/services/utils/hooks)
2. SECURITY: Unscoped DB operations, exposed error messages, unvalidated inputs, secrets
3. TYPES: `any` types, missing return types, unsafe assertions
4. TESTS: Untested logic, tests that don't cover failure cases
5. DUPLICATION: Logic that duplicates existing utils or services

For each finding: file name, line number, description, corrected code.
If nothing found in a category: write "✅ None found."

End with: "Ready for human review? YES / NO — [reason if NO]"
```

---

## Category: Debugging

### Firebase Permission Denied

```
Explain why this Firestore operation throws permission-denied.

Stack context: Firebase Firestore, Firebase Auth ({{SDK_VERSION}})
Current auth state: {{describe — e.g. "user is authenticated, userId = X"}}
Firestore rules: {{paste relevant rule}}
Operation failing: {{paste the service function call}}

Check: Is the userId being passed correctly? Is the collection path correct?
Does the rule require request.auth.uid to match a path parameter?
Provide the corrected code.
```

### Unexpected Re-render / useEffect Firing

```
Explain why this useEffect is firing more than expected.

Component: {{paste the component}}
What I expect: fires once on mount
What I observe: {{describe the actual behaviour}}

Check: Are the dependencies in the dependency array stable references or new objects on each render?
Is any dependency a function defined inline in the component body?
Provide the corrected dependency array with explanation.
```

---

## Category: Security Review

### Service Function Security Audit

**Context to open:** The function + `src/types/index.ts` + security rules section of `.github/copilot-instructions.md`

```
Security review for this service function.

Apply these rules:
1. All Firestore reads/writes must be scoped to the authenticated userId
2. No raw SDK error messages returned — map to typed errors
3. All numeric inputs must be validated as finite positive numbers before writes
4. All string inputs must have length constraints checked
5. auth.currentUser must be checked before any data operation
6. No `any` in catch blocks

Function:
{{PASTE_FUNCTION}}

For each issue: severity (CRITICAL / HIGH / MEDIUM), line number, risk description, corrected code.
```

---

## Category: Architecture

### "Where does this code belong?"

```
Should this code go in screens/, components/, hooks/, services/, or utils/?

Project layer rules:
- screens/ → navigation targets; UI composition only; no data calls
- components/ → reusable UI primitives; no navigation; no business logic
- hooks/ → React state; may call services; no Firebase SDK directly
- services/ → all Firestore/Firebase operations
- utils/ → pure functions; stateless; no imports from other layers

The code in question:
{{PASTE_CODE}}

Answer: which layer, which file (existing or new), and why.
```

---

## Category: Documentation

### Generate API Surface Entry

**Context:** Open the function file

```
Generate an API_SURFACE.md entry for this exported function.

Use exactly this format:
### [module].[functionName](params)
**Purpose:** [one sentence]
**Parameters:** [param: type — description for each]
**Returns:** [type — description]
**Side effects:** [what external state changes, or "None (pure function)"]
**Error cases:** [what throws and when]
**Example:**
\`\`\`typescript
[one-line usage example]
\`\`\`

Function:
{{PASTE_FUNCTION}}
```

---

## Category: Using Agent Skills

Reference a skill's file path in your prompt to load it on demand.
See `.github/skills/README.md` for invocation syntax per agent.

### Invoke the DORA Metrics skill

**Context to open:** `scripts/weekly-metrics.sh`, `docs/METRICS.md`

```
Read .github/skills/dora-metrics/SKILL.md.

Run `npm run metrics` to get the current rework rate. Using the metric definitions
in the skill, interpret the result and update the rework rate row in the Monthly
Metrics Log in docs/METRICS.md with today's date and value, plus a trend note.
```

**Expected output:** Updated `docs/METRICS.md` with rework rate and trend.

---

### Invoke the Security Review skill

**Context to open:** The service file or PR diff

```
Read .github/skills/security-review/SKILL.md.

Apply the pre-commit security checklist and OWASP Top 10 quick-check to this
service function. Report each finding with: severity, file, line number, risk
description, and corrected code.

Function:
{{PASTE_FUNCTION}}
```

**Expected output:** Structured findings list with severity levels and corrected code.

**Red flags:**

- Agent reports "no issues" on a function with unscoped DB operations → re-prompt, explicitly ask it to check the "All database operations are scoped to the authenticated `userId`" bullet in the Pre-commit security checklist section of the skill

---

### Invoke the Test Generation skill

**Context to open:** The function file, `src/types/index.ts`

```
Read .github/skills/test-generation/SKILL.md.

Generate unit tests for this function following the TDD pattern and naming
conventions described in that skill. The tests should go in
tests/unit/utils/{{FUNCTION_FILE_NAME}}.test.ts.

Function:
{{PASTE_FUNCTION}}
```

**Expected output:** A complete test file with describe/it blocks following the
`when [condition], should [result]` naming convention, covering happy path,
invalid input, and edge cases.

**Red flags:**

- Tests only assert mock calls → reject, ask for behaviour assertions
- `describe` / `it` names don't follow convention → reject, ask for rename

---

## Category: DORA AI Capabilities

Prompts for measuring and improving DORA metrics using AI assistance.

### Run DORA Archetype Self-Assessment

**Context to open:** `docs/TEAM_ARCHETYPE.md`, `docs/METRICS.md`, `.github/skills/dora-metrics/SKILL.md`

```
Read docs/TEAM_ARCHETYPE.md and .github/skills/dora-metrics/SKILL.md.

Conduct a DORA archetype self-assessment for this team based on the metrics in
docs/METRICS.md and the archetype definitions in docs/TEAM_ARCHETYPE.md.

For each archetype dimension, state:
1. Current observed behaviour (cite evidence from metrics or docs)
2. Which archetype it maps to
3. One concrete improvement action

End with: "Current archetype: [name] — Next step: [single highest-leverage action]"
```

**Expected output:** A structured archetype report with evidence-based findings and a
single prioritised next step.

**Red flags:**

- Assessment cites no evidence → re-prompt asking for specific metric values
- Recommends more than one next step → ask it to pick the highest-leverage action only

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Requires docs/METRICS.md to have at least one completed monthly entry.

---

### Calculate Current Rework Rate from Git History

**Context to open:** `scripts/weekly-metrics.sh`, `docs/METRICS.md`

```
Run `npm run metrics` to calculate the current rework rate.

Using the output:
1. State the rework rate percentage
2. Classify it: Healthy (0–10%), Watch (10–20%), or Stop-features (>20%)
3. If Watch or Stop-features: run the following command to identify the top 5 files
   with the most churn and include the output in your report:
   git log --diff-filter=M --name-only --pretty=format: --since="14 days ago" \
     | sort | uniq -c | sort -rn | head -5
4. Suggest one prompt-engineering fix if rework > 10%

Update the rework rate row in the Monthly Metrics Log in docs/METRICS.md with
today's date, the rework rate value, and a one-line trend note.
```

**Expected output:** Updated `docs/METRICS.md` row plus a console summary with
classification and (if needed) per-file churn counts from git.

**Red flags:**

- Agent updates METRICS.md without running `npm run metrics` → reject, ask it to run
  the script first
- Rework > 20% but no fix suggested → re-prompt asking it to recommend a specific
  change to AGENTS.md or PROMPT_LIBRARY.md for a human to apply, or to open a GitHub
  issue describing the needed update (agents must not modify AGENTS.md directly)

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Requires a git history of at least 14 days; shallow clones may
return inaccurate results.

---

### Write a J-Curve Monitoring Comment in a PR

**Context:** Open the PR diff

```
This PR is part of an AI-accelerated delivery period. Write a J-Curve monitoring
comment to add to the PR description.

The comment should include:
1. A one-sentence summary of what the PR changes
2. The expected short-term dip risk (e.g. increased review time, rework likelihood)
3. Two measurable signals to watch in the next 14 days (use DORA metrics)
4. A recommended rollback trigger condition

Format it as a collapsible GitHub markdown block:
<details>
<summary>📈 J-Curve Monitoring Note</summary>
[content]
</details>
```

**Expected output:** A ready-to-paste GitHub markdown block suitable for the PR
description.

**Red flags:**

- Monitoring signals are not measurable (e.g. "watch for problems") → re-prompt asking
  for specific metric names and threshold values

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Most useful on PRs > 200 changed lines or with cross-cutting
architectural changes.

---

### Evaluate Whether a PR Violates "Working in Small Batches"

**Context:** Open the PR diff

```
Evaluate this PR against the DORA "working in small batches" principle.

Check:
1. Total changed lines — flag if > 400 (our hard limit per AGENTS.md)
2. Number of distinct concerns addressed — flag if > 1 (each concern = its own PR)
3. Estimated review cognitive load — Low / Medium / High
4. Recommended split: if the PR should be split, list the sub-PRs with scope for each

End with: "Small-batch compliant? YES / NO — [reason]"
```

**Expected output:** A structured evaluation with a clear YES/NO verdict and, if NO,
a concrete split plan with sub-PR scopes.

**Red flags:**

- Agent says YES on a 600-line PR → re-prompt, ask it to count changed lines explicitly
- Split plan has more than 3 sub-PRs → acceptable, but flag for PM review

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Line count check is approximate when binary files are included.

---

## Category: Multi-agent orchestration

Prompts for coordinating parallel agent tasks safely. See AGENTS.md §8 for the
3-concurrent-agent limit and file-overlap rules.

### Decompose a Large Feature into Parallel Sub-agent Tasks

**Context to open:** The feature GitHub issue, `docs/ARCHITECTURE.md`

```
Decompose this feature into parallel sub-agent tasks, subject to these constraints:
- Maximum 3 concurrent sub-agent tasks
- Each sub-agent works on a separate branch
- No two sub-agents may touch the same file
- Each task must be independently testable

Feature issue:
{{PASTE_ISSUE}}

For each sub-task output:
1. Task ID (e.g. TASK-1, TASK-2)
2. Scope: which files it reads and which it writes
3. Branch name (e.g. feat/ai-011-task-1)
4. Acceptance criteria (copy or derive from the issue)
5. Dependencies: which tasks must complete first (if any)

End with a dependency graph showing the order of execution.
```

**Expected output:** A decomposition table (max 3 rows) plus a dependency graph in
ASCII or Mermaid syntax.

**Red flags:**

- Any two tasks write to the same file → reject the decomposition, ask for a re-split
- More than 3 concurrent tasks proposed → reject, ask it to serialize some tasks

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Works best when the feature issue has explicit acceptance criteria.
Ambiguous issues produce poor decompositions.

---

### Lead Agent: Synthesise Sub-agent Outputs into a Single Coherent PR

**Context to open:** All sub-agent branch diffs, the original feature issue

```
You are the lead agent synthesising the outputs of {{N}} parallel sub-agent tasks
into a single coherent PR.

Sub-agent branches: {{LIST_BRANCH_NAMES}}
Original feature issue: {{PASTE_ISSUE_URL}}

Steps:
1. Read each sub-agent branch diff
2. Identify any conflicts or inconsistencies between outputs
3. Resolve conflicts using the architecture rules in .github/copilot-instructions.md
4. Produce a unified diff that combines all sub-agent work
5. Write a PR description using the AI-Assisted Review Block template from AGENTS.md

Report any unresolved conflicts in the "What I was NOT sure about" section of the
PR description.
```

**Expected output:** A complete PR description (AI-Assisted Review Block filled out)
plus a summary of any conflicts found and how they were resolved.

**Red flags:**

- Lead agent skips conflict checking → re-prompt asking it to diff each pair of
  sub-agent branches explicitly
- Unresolved conflicts not flagged in PR description → reject, ask it to add them to
  the "What I was NOT sure about" section

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Requires all sub-agent branches to be pushed before synthesis.
Works best when sub-tasks have non-overlapping file scopes.

---

### Verify No Agent is Working on Overlapping Files

**Context:** List of active agent branches (from `git branch -r`)

```
Given these active agent branches, verify that no two agents are working on the
same file.

Active branches:
{{PASTE_BRANCH_LIST}}

For each pair of branches:
1. List the files each branch modifies (use git diff --name-only {{branch}} main)
2. Identify any file that appears in more than one branch
3. For each overlap: which agents are affected, which file, recommended resolution

End with: "File overlap detected? YES / NO"
If YES: list each overlapping file and recommended resolution (merge into one task,
or re-scope one agent's work).
```

**Expected output:** A per-branch file list and an overlap report with YES/NO verdict.

**Red flags:**

- Agent reports NO overlap without listing any files → re-prompt asking for the
  explicit file list per branch

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Relies on git being available in the agent's environment.
Detects file-level overlaps only — does not detect import-level or semantic conflicts.

---

## Category: Agent Skills invocation

Short, canonical prompts to invoke each built-in skill. Use these when you want a
quick skill invocation without the full detail of the "Using Agent Skills" prompts above.
See `.github/skills/README.md` for the full skill reference.

### Invoke the DORA Metrics skill to add rework rate tracking

```
Use the dora-metrics skill to add rework rate tracking for {{SERVICE_OR_FILE}}.

Read .github/skills/dora-metrics/SKILL.md, then update docs/METRICS.md to add a
tracking note for {{SERVICE_OR_FILE}} — noting it as a file to watch for churn in
the next `npm run metrics` report. No code changes are needed; rework rate is
derived automatically from git history.
```

**Expected output:** An updated `docs/METRICS.md` tracking note for the specified
file, explaining why it is being monitored.

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Rework rate is derived from git history, not runtime
instrumentation. This prompt adds a documentation tracking note, not code hooks.

---

### Invoke the Security Review skill before PR approval

```
Use the security-review skill to review this PR before I approve it.

Read .github/skills/security-review/SKILL.md, apply the pre-commit security
checklist and OWASP Top 10 quick-check to every changed file in this PR, and
report findings with: severity (CRITICAL/HIGH/MEDIUM/LOW), file, line, risk
description, and corrected code.

End with: "Safe to approve? YES / NO — [reason if NO]"
```

**Expected output:** A structured findings table and a clear YES/NO approval
recommendation.

**Red flags:**

- Agent says YES without listing any findings → re-prompt asking for an explicit
  checklist run even if all items pass

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Does not replace a human security review for auth flows or
cryptographic changes. Always escalate CRITICAL findings to a human.

---

### Invoke the Test Generation skill to write tests for a function

```
Use the test-generation skill to write tests for {{FUNCTION_NAME}}.

Read .github/skills/test-generation/SKILL.md, then generate a complete test file
for {{FUNCTION_NAME}} in {{FUNCTION_FILE_PATH}}, following the TDD patterns and
naming conventions in that skill.

Place the test file in:
- tests/unit/utils/{{FUNCTION_FILE_NAME}}.test.ts  — for utility functions
- tests/unit/services/{{FUNCTION_FILE_NAME}}.test.ts  — for service methods

The test file must cover: happy path, invalid input, and at least two edge cases.
```

**Expected output:** A complete, runnable test file that fails before the
implementation is written and passes after.

**Red flags:**

- Tests only assert mock calls, not behaviour → reject, ask for behaviour assertions
- `describe`/`it` names don't follow `when [condition], should [result]` → ask for rename
- No edge cases → re-prompt asking for at least two edge-case scenarios

**Version:** 1.0
**Tested with:** Claude Code, GitHub Copilot
**Test date:** 2026-05-10
**Known limitations:** Generated tests assume Jest + ts-jest. Adjust import paths if
using a different test runner.

---
