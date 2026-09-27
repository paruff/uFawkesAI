---
name: code-review
description: "Review PR and build output for quality, security, and compliance. Implements DORA AI Capabilities 1, 4, 5, 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: code-review

> **Load trigger:** "load code-review skill" > **DORA:** AI Capabilities 1, 4, 5, 7
> **Token cost:** Low

## Purpose

Review PR and build output for quality, security, and compliance. Implements DORA AI Capabilities 1, 4, 5, 7.

## When to Use

See sub-skills for specific triggers.

## Sub-skills (now integrated)

# Skill: Code Review

> **Load trigger:** `"load review skill"`

> Migrated from the former `review` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

## Review Modes

This skill has two modes: You have two modes:

- **PR Review Mode** — quick review of a PR diff (architecture, tests, security surface, secrets, dependencies)
- **Build Validation Mode** — comprehensive validation of build output (spec, design, acceptance criteria, code quality, security, governance)

Select mode based on available inputs. If only a PR diff is available, run PR Review. If full build output is available, run Build Validation.

You report what you find. You do not speculate. If you cannot determine whether something is correct, say so.

---

## PR REVIEW MODE

Use when only a PR diff or code change is available.

### Checklist

#### 1. PR Size Gate

Count changed lines. If > 400:

```
⚠ PR SIZE: [N] changed lines exceeds the 400-line limit.
CI will block this unless `large-pr-approved` label is applied by a human.
This review proceeds but the label issue must be resolved before merge.
```

#### 2. Architecture Compliance

Read `docs/ARCHITECTURE.md` and AGENTS.md §4. Check:

- No Firebase/DB calls in screen/controller/view layer
- No business logic in UI components
- No circular imports
- No `any` in catch blocks
- New types defined in types index, not inline
- New files in correct layer

Report each violation: `File:Line — Rule violated — Recommended fix`

#### 3. Test Coverage

For each changed source file, is there a corresponding test change?

- Docs-only or config-only change → acceptable
- Refactor with no behavior change → verify
- Feature or bug fix with no new tests → flag, require explanation

#### 4. Security Surface (PR Audit)

##### Secrets (block on any finding)

- Hardcoded API keys, tokens, passwords, connection strings
- `.env` files committed (should be in `.gitignore`)
- Private keys, certs, `.p12` files in source
- OAuth tokens in comments or test fixtures
- GitHub Actions secrets accessed inline rather than via `${{ secrets.NAME }}`

If found: "CRITICAL — remove immediately. Do not merge. Rotate the exposed credential."

##### Dependency Changes

If `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, or equivalent changed:

- List each new dependency and its version pinning (exact vs range)
- Flag any dependency with known CVEs if detectable
- New dependencies require PM sign-off

##### Authentication and Authorization

- New routes have authentication guards
- Authorization checks are server-side, not client-side only
- JWT/session tokens handled correctly
- No auth bypasses left in for test convenience

##### Data Handling

- No PII in log statements
- No PII in OTEL span attributes
- Database queries parameterized
- Data handling complies with data policy

##### Infrastructure and CI

- Secrets accessed only via environment variables
- GitHub Actions pinned to specific commit SHAs
- New IAM permissions are minimum required
- Containers run as non-root

#### 5. AI-Assisted Review Block

Check that the PR description contains a completed AI-Assisted Review Block (AGENTS.md §7). If missing:

```
⚠ MISSING: AI-Assisted Review Block required in every agent PR.
Template is in AGENTS.md §7. The PR author must complete it before merge.
```

#### 6. Author Uncertainty

Read the "What I was NOT sure about" section. These items require direct human attention.

### PR Review Output

```markdown
## Review Agent Assessment — [PR title]

**Mode:** PR Review
**Size:** [N] lines — PASS / EXCEEDS LIMIT
**Architecture:** PASS / [N] violations — see below
**Tests:** PASS / GAPS — see below
**Security surface:** NONE / FLAGGED — see below
**Review Block:** COMPLETE / MISSING / INCOMPLETE

---

### Architecture Violations

[File:Line — Rule violated — Recommended fix]
[Or: "None found"]

### Test Gaps

[Source file — Behavior not covered — Recommended test]
[Or: "Coverage adequate"]

### Security Flags

[What changed — Risk — Recommended action]
[Or: "No security surface changes detected"]

### Dependency Review

[New dep: name@version — status: OK / REVIEW NEEDED / REJECT]
[Or: "No dependency changes"]

### Items Requiring Human Judgment

[From the "not sure about" section + any ambiguities found]

### Overall Recommendation

APPROVE — no blocking issues found
APPROVE WITH COMMENTS — minor issues, not blocking
REQUEST CHANGES — [N] blocking issues listed above
ESCALATE — architectural decision required before this can merge
```

---

## BUILD VALIDATION MODE

Use when full build output (code, manifests, pipelines, overlays) is available.

### Inputs Required

Read these files first:

1. `specification.md` — original requirements
2. `design.md` — architectural decisions
3. Tasks with acceptance criteria (from `tasks.json` or individual task files)
4. Build output (code, manifests, pipelines)
5. Governance rules (from `AGENTS.md`, policy files)
6. Test results

If any file is missing, note it and proceed with what is available.

### Review Checks

Run these checks in order:

1. **Spec Compliance** — Does build output satisfy all requirements?
2. **Design Compliance** — Does build output match architectural decisions?
3. **Acceptance Criteria** — Are all ACs met?
4. **Code Quality** — Lint, typecheck, formatting
5. **Pipeline Policy** — CI/CD stages correct
6. **K8s Policy** — Manifests compliant
7. **GitOps Overlay** — Overlays valid
8. **Security & RBAC** — Security posture acceptable
9. **Secret Governance** — Secrets handled correctly
10. **Policy-as-Code** — Organizational policies satisfied

### Required Skills

Load these skills as needed:

| Skill                               | When to Load                     |
| ----------------------------------- | -------------------------------- |
| `review/spec-compliance`            | Validating against specification |
| `review/design-compliance`          | Validating against design        |
| `review/review-acceptance-criteria` | Checking acceptance criteria     |
| `review/code-quality`               | Lint, format, structure checks   |
| `review/pipeline-policy`            | CI/CD pipeline validation        |
| `review/k8s-policy`                 | Kubernetes manifest validation   |
| `review/gitops-overlay`             | GitOps overlay validation        |
| `review/security-rbac`              | RBAC and security validation     |
| `review/secret-governance`          | Secret handling validation       |
| `review/policy-validation`          | Policy-as-code validation        |

### Build Validation Output

```markdown
## Build Review Report — [Feature/task title]

**Mode:** Build Validation
**Decision:** PASS | FAIL

---

### Spec Compliance

| Requirement | Status | Notes                  |
| ----------- | ------ | ---------------------- |
| REQ-001     | PASS   | Implemented correctly  |
| REQ-002     | FAIL   | Missing error handling |

### Design Compliance

| Check                  | Status | Notes                              |
| ---------------------- | ------ | ---------------------------------- |
| Architecture alignment | PASS   | —                                  |
| Component boundaries   | PASS   | —                                  |
| Interface contracts    | FAIL   | Response shape differs from design |

### Acceptance Criteria

| AC    | Status | Notes                 |
| ----- | ------ | --------------------- |
| AC-01 | PASS   | —                     |
| AC-02 | FAIL   | Edge case not handled |

### Code Quality

| Check      | Status |
| ---------- | ------ |
| Lint       | PASS   |
| Typecheck  | PASS   |
| Formatting | PASS   |

### Pipeline Policy

| Check           | Status |
| --------------- | ------ |
| Required stages | PASS   |
| Security gates  | PASS   |

### K8s Policy

| Check           | Status |
| --------------- | ------ |
| Resource limits | PASS   |
| SecurityContext | PASS   |

### GitOps Overlay

| Check           | Status |
| --------------- | ------ |
| Kustomize build | PASS   |
| Image tags      | PASS   |

### Security & RBAC

| Check              | Status |
| ------------------ | ------ |
| RBAC roles         | PASS   |
| Container security | PASS   |

### Secret Governance

| Check                | Status |
| -------------------- | ------ |
| No plaintext secrets | PASS   |
| Rotation policies    | PASS   |

### Policy-as-Code

| Check               | Status |
| ------------------- | ------ |
| Manifest compliance | PASS   |
| Pipeline compliance | PASS   |

### Findings

| Severity | Category        | Finding                                | Action                |
| -------- | --------------- | -------------------------------------- | --------------------- |
| CRITICAL | spec-compliance | Missing error handling for API timeout | Implement retry logic |
| MEDIUM   | code-quality    | Unused import in src/utils.ts          | Remove import         |

### Overall Recommendation

APPROVE — no blocking issues found
APPROVE WITH COMMENTS — minor issues, not blocking
REQUEST CHANGES — [N] blocking issues listed above
ESCALATE — architectural decision required before this can merge
```

---

## Output Contract

Your report MUST satisfy this contract. Self-validate before finishing.

### PR Review Mode

- Required sections: Review Agent Assessment, Architecture Violations, Test Gaps
- Required fields: size_decision (PASS/EXCEEDS LIMIT)
- Findings required when decision is REQUEST CHANGES
- Forbidden: "LGTM", "looks good" — be specific

### Build Validation Mode

- Required sections: Build Review Report, Spec Compliance, Design Compliance, Acceptance Criteria, Code Quality, Findings
- Required fields: decision (PASS/FAIL/BLOCKED)
- Findings required when decision is FAIL
- Findings must include severity classification (CRITICAL/HIGH/MEDIUM/LOW)
- Forbidden: "I think", "probably", "might be" — report actual findings

### Both Modes

- Schema: `.agents/assertions/agent-output-schema.json`
- Runner: `bash .agents/assertions/assertion-runner.sh <report.md> review`

## Post-Task Logging

After producing your report, write a structured log entry:

1. Append one JSON object to `.agents/logs/YYYY-MM-DD.jsonl` (one line per invocation)
2. Follow the schema in `.agents/schema/skill-invocation-log.json`
3. Include: agent name, session_id (unique identifier), skills loaded, findings, decision, blockers
4. For each finding, set `actionable` and `manual_review_needed` accurately

This log is required. If the file cannot be written, document why.

## Hard Rules

- Never approve a PR with unfixed architecture violations.
- Never approve a PR where the Review Block is absent.
- Never approve a PR where the author flagged uncertainty you cannot resolve.
- Never apply the `large-pr-approved` label — that is human-only.
- Never mark a CRITICAL finding as resolved without verification.
- Never approve build output that violates security policies.
- Never skip a review check without documenting why.
- If you cannot verify a finding, mark it as NEEDS MANUAL REVIEW.
- Report actual findings, not assumptions.
- If you cannot complete the review due to missing context, say so immediately rather than leaving it open.

## Sub-Skills

| Skill                               | Purpose                        |
| ----------------------------------- | ------------------------------ |
| `review/spec-compliance`            | Validate against specification |
| `review/design-compliance`          | Validate against architecture  |
| `review/code-quality`               | Assess code quality            |
| `review/review-acceptance-criteria` | Validate acceptance criteria   |
| `review/security-rbac`              | RBAC validation                |
| `review/secret-governance`          | Secret management review       |
| `review/policy-validation`          | Policy-as-code validation      |
| `review/k8s-policy`                 | Kubernetes policy compliance   |
| `review/pipeline-policy`            | Pipeline policy validation     |
| `review/gitops-overlay`             | GitOps overlay validation      |

## Inputs

- PR diff (PR Review mode)
- Build output (Build Validation mode)
- `specification.md`
- `design.md`
- Test results

## Outputs

- `review-report.json`
- `findings.json`
- `recommendations.json`

### 11. Cross-Validation (from cross-validation skill)

# Skill: Cross-Validation

> **Load trigger:** `"load cross-validation skill"`

> Migrated from the former `cross-validation` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

This skill verifies that outputs from the parallel validation block are consistent with each other and with their sources. Your job is to verify that all agent outputs from the parallel validation block are consistent with each other and with their sources.

You run after `test-execution` and `code-review` have completed, and you validate pairwise consistency between their outputs and their sources (`spec`, `design`, `build`, `test`). If any validation fails, you block progression to `delivery`.

## What You Do

1. **Load the cross-validation skill** (`.agents/skills/cross-validation/SKILL.md`) to understand the validation rules
2. **Load the cross-validation rules registry** (`.agents/registry/cross-validation.yaml`) to see which agent pairs need validation
3. **Run the cross-validation runner** (`.agents/assertions/cross-validation-runner.sh`) to:
   - Read the relevant agent reports (spec, design, build, test, test-execution, review)
   - Apply each validation rule from the registry
   - Generate a unified cross-validation report
4. **Validate your report** against the cross-validation contract in `.agents/assertions/minimal-report.yaml`
5. **Write a structured log entry** to `.agents/logs/YYYY-MM-DD.jsonl`

## Validation Rules

The cross-validation process validates these 4 pairwise relationships:

1. **Spec ↔ Build Consistency** — All spec requirements are addressed in build output
2. **Spec ↔ Test Coverage** — All spec acceptance criteria have corresponding tests
3. **Design ↔ Build Compliance** — Build follows architecture decisions from design
4. **Test ↔ Test-Execution Viability** — All tests are viable and passing in test-execution

If any rule fails, you block the pipeline and report the specific inconsistencies.

## Output Contract

Your report MUST satisfy this contract. Self-validate before finishing.

- Must include "Cross-Validation Report" section
- Must include "Validation Results" section with pass/fail for each rule
- Must include "Findings" section listing all inconsistencies
- Must include "Decision" field (PASS or FAIL)
- Must include "Recommendations" section if FAILED
- Schema: `.agents/assertions/agent-output-schema.json`
- Runner: `bash .agents/assertions/cross-validation-runner.sh <report.md> cross-validation`

## Post-Task Logging

After producing your report, write a structured log entry:

1. Append one JSON object to `.agents/logs/YYYY-MM-DD.jsonl` (one line per invocation)
2. Follow the schema in `.agents/schema/skill-invocation-log.json`
3. Include: agent name, session_id (unique identifier), skills loaded, findings, decision, blockers
4. Log the validation results: which rules passed, which failed, and why
5. Log the pipeline impact: whether the pipeline is blocked or can proceed

## Hard Rules

- Never skip cross-validation — it is the final gate before delivery
- Never accept a partial validation — all 4 rules must pass
- Never bypass the cross-validation runner — use it for all validation logic
- Always log the validation outcome for telemetry
- Always block the pipeline if any validation fails

## Usage

See sub-skills for specific triggers.

## Enforcement

- **DORA vocabulary** validates AI Capabilities 1, 4, 5, 7 references
- **AI stance audit** validates relevant clarity dimensions
