---
name: test-execution
description: "Execute all relevant tests and quality gates to ensure build output is correct, stable, secure, and ready for review. This is the feature workflow's Phase 3 (and Phase 3.5 for live-system verification) — local, pre-push verification. Use when running tests, validating coverage, or checking runtime behavior. Distinct from the `test` skill, which writes tests; this one runs them."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  migrated_from: agent/test-execution
---

# Skill: Test Execution

> **Load trigger:** `"load test-execution skill"`

> Migrated from the former `test-execution` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

Runs the relevant tests and quality gates so the build output is correct, stable, and ready for review. Produces a clear test report for the `code-review` skill. Does not write tests — if tests are missing, that is a finding.

You do not write tests — you execute them and report results. If tests are missing, flag it as a finding.

## Inputs Required Before Testing

Read these files first:

1. Build output (code, manifests, pipelines)
2. `specification.md` — original requirements
3. `design.md` — architectural decisions
4. `tasks.json` — check which acceptance criteria are tagged `test_type: live-system`
5. Test configuration (e.g., `jest.config.ts`, `pytest.ini`, `go test` flags)
6. Governance rules (coverage thresholds, required test stages)

If any file is missing, note it and proceed with what is available.

## Testing Protocol

### Step 1 — Discover Test Infrastructure

Before running tests, identify:

- [ ] Test framework and configuration files
- [ ] Test directories and file patterns (including any `tests/live/` or
      `tests_live/` directory — see the `test` agent's file placement convention)
- [ ] Coverage tool and configuration
- [ ] Required test stages (unit, integration, e2e, live-system)

### Step 2 — Execute Tests

Run tests in order:

1. **Unit tests** — fastest, highest granularity
2. **Integration tests** — validate component interactions
3. **E2E tests** — validate full workflows (if applicable)
4. **Coverage analysis** — measure against thresholds
5. **Pipeline validation** — verify test stages in CI config
6. **Runtime simulation** — basic smoke test in simulated env (fast, local,
   NOT a substitute for step 7)
7. **Live System Verification — REQUIRED, not optional, whenever any
   acceptance criterion is tagged `test_type: live-system`.** Load the
   `test-execution/live-system-verification` skill. This stands up a real
   instance of the affected component(s) and runs the live-system-tagged
   tests against it. If no criteria are tagged `live-system`, explicitly note
   "N/A — no live-system criteria in this task" rather than silently omitting
   the section.
8. **Performance smoke** — basic latency/throughput check (optional)

### Step 3 — Collect Results

For each test run, collect:

- Pass/fail counts
- Failure details (test name, error, file)
- Coverage percentages (line, branch, function)
- Runtime errors or warnings
- For live-system verification: raw command/HTTP output for each check — do
  not report a status without the output that produced it (same discipline
  `verification.md` requires)

### Step 4 — Produce Report

Generate the test report with pass/fail decision.

## Required Skills

Load these skills as needed:

| Skill                                           | When to Load                                                                                       |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------- |
| `test-execution/unit-test-execution`            | Running unit tests                                                                                 |
| `test-execution/integration-test-execution`     | Running integration tests                                                                          |
| `test-execution/e2e-test-execution`             | Running end-to-end tests                                                                           |
| `test-execution/test-coverage-validation`       | Validating coverage thresholds                                                                     |
| `test-execution/pipeline-test-stage-validation` | Checking CI test stages                                                                            |
| `test-execution/runtime-simulation-validation`  | Smoke-testing in simulated env                                                                     |
| `test-execution/live-system-verification`       | Running tests against a real live instance (required whenever `live-system`-tagged criteria exist) |
| `test-execution/performance-smoke-testing`      | Basic performance checks                                                                           |

## Language-Specific Tooling

Load the relevant skill for stack-specific test runners:

- TypeScript/JS: `lang-typescript` skill (Jest/Vitest)
- Python: `lang-python` skill (pytest + pytest-cov)
- Go: `lang-go` skill (go test + coverage)

## Output Format

```markdown
## Test Report — [Build/task title]

**Decision:** PASS | FAIL

---

### Test Results

| Suite       | Passed | Failed | Skipped | Total  |
| ----------- | ------ | ------ | ------- | ------ |
| Unit        | 42     | 0      | 2       | 44     |
| Integration | 8      | 0      | 0       | 8      |
| E2E         | 5      | 0      | 0       | 5      |
| Live System | 3      | 0      | 0       | 3      |
| **Total**   | **58** | **0**  | **2**   | **60** |

### Failures

[If any — list test name, file, error message]
[Or: "None"]

### Coverage

| Metric   | Actual | Threshold | Status |
| -------- | ------ | --------- | ------ |
| Line     | 87%    | 80%       | PASS   |
| Branch   | 79%    | 75%       | PASS   |
| Function | 92%    | 85%       | PASS   |

### Pipeline Test Stages

| Stage             | Present | Status  |
| ----------------- | ------- | ------- |
| Unit tests        | Yes     | PASS    |
| Integration tests | Yes     | PASS    |
| E2E tests         | No      | MISSING |

### Runtime Simulation

[Status: PASS/FAIL — details]

### Live System Verification

[Status: PASS | FAIL | N/A — if PASS/FAIL, include the environment stood up,
each check run, and the raw output for each. If N/A, state why (no
live-system-tagged criteria in this task).]

### Performance Smoke

[Status: PASS/FAIL — latency/throughput summary]

### Findings

| Severity | Finding                              | Action                          |
| -------- | ------------------------------------ | ------------------------------- |
| MEDIUM   | E2E test stage missing from pipeline | Add stage to pipeline-spec.yaml |
```

## Output Contract

Your report MUST satisfy this contract. Self-validate before finishing.

- Required sections: Test Report, Test Results, Coverage, Live System Verification
- Required fields: decision (PASS/FAIL)
- Findings required when decision is FAIL
- Forbidden: "no tests exist" — flag as finding but don't use as summary
- Forbidden: a Live System Verification section that reports PASS without raw
  command/HTTP output backing each check
- Schema: `.agents/assertions/agent-output-schema.json`
- Runner: `bash .agents/assertions/assertion-runner.sh <report.md> test-execution`

## Post-Task Logging

After producing your report, write a structured log entry:

1. Append one JSON object to `.agents/logs/YYYY-MM-DD.jsonl` (one line per invocation)
2. Follow the schema in `.agents/schema/skill-invocation-log.json`
3. Include: agent name, session_id (unique identifier), `triggered_by`, `started_at`, `duration_ms`, skills loaded, findings, decision, blockers
4. For each finding, set `actionable`, `manual_review_needed`, and `severity` accurately
5. Set `triggered_by` to `"feature"` (the typical case — this skill is Phase 3 and 3.5 of the feature workflow), `"bugfix"` if invoked to validate a repair, or `"manual"` if invoked directly
6. Record `started_at` (ISO 8601, when this agent began) — `timestamp` in the log entry remains the completion time
7. Compute `duration_ms` as the difference between `started_at` and completion
8. Record whether live-system verification ran, and if so, whether it passed — this is the single most important field for auditing whether the "real system tests" gap is actually closing over time

### Finding Severity

Every finding must carry a `severity` field, one of:

- `blocker` — prevented the task from completing as planned; required a fix before proceeding
- `defect` — a real problem that was found and fixed within this invocation, but did not block completion
- `note` — informational; no fix required

Do not default to `defect` when uncertain.

This log is required. If the file cannot be written, document why.

## Hard Rules

- Never mark tests as passing if they failed.
- Never skip test suites without noting it in the report.
- If no tests exist for a module, flag it as a HIGH finding.
- Coverage below threshold is a FAIL, not a warning.
- Report actual numbers, not estimates.
- **Never mark Live System Verification PASS without pasting the raw output
  that supports it.** A live-system claim without evidence is the exact
  failure mode this phase exists to prevent — treat it with the same rigor
  as `verification.md`'s "no evidence → FAIL" rule.

## Inputs

- Source code (from build)
- Test files (written by the `test` skill)
- Test configuration

## Outputs

- `test-results.json`
- `test-report.md`
- `coverage-report.json`

### 21. Test (from test skill)

# Skill: Test

> **Load trigger:** `"load test skill"`

> Migrated from the former `test` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

You write tests that are honest about what the code actually does. You write failing tests before implementation exists. You never write tests that pass trivially or that test framework behavior rather than application behavior.

Your standard: tests you write today must survive the next AI-generated refactor without being deleted.

## TDD Protocol — Required Commit Order

Per AGENTS.md §6, AI Capability 5 (Working in small batches), and `docs/COMMIT_CONVENTIONS.md`:

```
1. test: add failing tests for [feature]   ← CI fails here intentionally
2. feat: implement [feature] to pass tests
3. refactor: clean up [feature] if needed
```

Never combine a failing test commit with an implementation commit.

## Before Writing Tests

Read first:

1. `src/types/index.ts` (or equivalent) — all data shapes and valid ranges
2. `docs/API_SURFACE.md` — existing public functions (don't re-test what exists)
3. `docs/KNOWN_LIMITATIONS.md` — do not write tests that depend on broken behavior
4. The source file under test — understand the actual implementation contract
5. `tasks.json` — check each acceptance criterion's `test_type` tag
   (`unit` / `integration` / `live-system`) before deciding whether the
   mocking rule below applies

## Test Type: `live-system` — Exception to the Mocking Rule

**If an acceptance criterion in `tasks.json` is tagged `test_type: live-system`,
the "mock at boundaries" rule below does NOT apply to that test.** Write a test
that calls the real dependency — a real running instance of the service,
database, or API — not a mock, stub, or simulated response.

This exists because pattern-correct tests that mock every boundary can pass
while the actual deployed system does not work. A `live-system` test's job is
specifically to catch that gap. See the
`test-execution/live-system-verification` skill for how these get executed
(that agent runs them against a real standing environment — this agent's job
is only to write them).

If a task has no `live-system`-tagged criteria, proceed as normal — the
mocking rule below still applies to `unit` and `integration` tests.

## Coverage Priority Order

1. Uncovered error paths (highest value — crashes and data loss live here)
2. Uncovered branch conditions (if/else, switch cases)
3. Uncovered integration boundaries (service calls, DB calls)
4. Happy path gaps (lowest marginal value if 1–3 are covered)

Do not add coverage by testing trivial getters/setters.

## Test Quality Rules

Each test must:

- Have a descriptive name: `it("returns null when token is expired")` not `it("works")`
- Test one specific behavior
- Use actual data shapes from the types index
- Not use `any` to work around type constraints
- Not mock implementation details — mock at boundaries (API calls, DB, filesystem)
  **unless the test is tagged `live-system` (see above), in which case do not
  mock the boundary at all.**

Do not write:

- Tests that always pass regardless of implementation
- Tests that test mock behavior, not application behavior
- Tests with `expect(true).toBe(true)` or equivalent
- Tests that depend on execution order

## Language Patterns

Load the relevant skill for stack-specific tooling:

- TypeScript/JS: load `lang-typescript` skill (Jest/Vitest patterns)
- Python: load `lang-python` skill (pytest + pytest-cov)
- Go: load `lang-go` skill (go test + coverage)

## File Placement

| Language   | Convention                                    |
| ---------- | --------------------------------------------- |
| TypeScript | `tests/[filename].test.ts` alongside source   |
| Python     | `tests/test_[module].py` at project root      |
| Go         | `[package]_test.go` in same package directory |

`live-system` tests should be placed in a clearly separate directory (e.g.
`tests/live/` or `tests_live/`) so they are trivially distinguishable from
unit/integration tests and can be run as their own suite by `test-execution`.

Never create a new testing convention without noting it in `docs/ARCHITECTURE.md`.

## PR Description for Test PRs

```markdown
## AI-Assisted Review Block

**What does this PR do?**
[Which module is now tested and to what coverage level, and whether any
live-system tests were added]

**What could go wrong?**

- Tests pass locally but fail in CI due to environment differences
- Mock boundaries are incorrect (mocking too deep or too shallow)
- Live-system tests may be flaky if the test environment isn't fully isolated

**What tests cover this change?**
[This IS the test PR — list test files added, what each covers, and which
are tagged live-system]

**Architecture check:**
Tests do not cross layer boundaries except where explicitly tagged
live-system. Mocks applied at service/API boundaries only for non-live-system
tests.

**What I was NOT sure about:**
[Ambiguous behavior in the source that needed a judgment call]
```

## Output Contract

Your report MUST satisfy this contract. Self-validate before finishing.

- Forbidden: "expect(true).toBe(true)", 'it("works")' — tests must be descriptive and meaningful
- Forbidden: tests that test mock behavior instead of application behavior (unless explicitly tagged live-system, where mocking is itself forbidden)
- Must follow the TDD commit order (test → feat → refactor)
- Schema: `.agents/assertions/agent-output-schema.json`
- Runner: `bash .agents/assertions/assertion-runner.sh <report.md> test`

## Post-Task Logging

After producing your report, write a structured log entry:

1. Append one JSON object to `.agents/logs/YYYY-MM-DD.jsonl` (one line per invocation)
2. Follow the schema in `.agents/schema/skill-invocation-log.json`
3. Include: agent name, session_id (unique identifier), `triggered_by`, `started_at`, `duration_ms`, skills loaded, findings, decision, blockers
4. For each finding, set `actionable`, `manual_review_needed`, and `severity` accurately
5. Set `triggered_by` to whichever orchestrator invoked this agent: `"feature"`, `"bugfix"`, `"discovery"`, or `"manual"` if invoked directly by the user
6. Record `started_at` (ISO 8601, when this agent began) — `timestamp` in the log entry remains the completion time
7. Compute `duration_ms` as the difference between `started_at` and completion
8. Record the count of tests written by `test_type` (`unit` / `integration` / `live-system`) — this lets you later audit whether live-system tests are actually being produced, not just theoretically supported

### Finding Severity

Every finding must carry a `severity` field, one of:

- `blocker` — prevented the task from completing as planned; required a fix before proceeding
- `defect` — a real problem that was found and fixed within this invocation, but did not block completion
- `note` — informational; no fix required (e.g. a deprecation notice, a private-API usage observation)

Do not default to `defect` when uncertain — if a finding did not require any code or config change to resolve, it is a `note`, not a `defect`.

This log is required. If the file cannot be written, document why.

## Inputs

- `specification.md` (from spec)
- `acceptance-criteria.md` (from spec)
- Existing test patterns

## Outputs

- Test files
- `test-report.md`
