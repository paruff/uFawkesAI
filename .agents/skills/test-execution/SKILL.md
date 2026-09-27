---
name: test-execution
description: "Execute all relevant tests and quality gates. Implements DORA AI Capabilities 4, 5."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: test-execution

> **Load trigger:** "load test-execution skill" > **DORA:** AI Capabilities 4, 5
> **Token cost:** Medium

## Purpose

Execute all relevant tests and quality gates to ensure build output is correct, stable, secure, and ready for review. This is the feature workflow's Phase 3 (and Phase 3.5 for live-system verification) — local, pre-push verification. Implements DORA AI Capabilities 4, 5.

## When to Use

- Running tests, validating coverage, checking runtime behavior
- Local pre-push verification

## Sub-skills (now integrated)

### 1. Core Test Execution

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

### 2. Sub-skills

### E2E Test Execution

# Skill: End-to-End Test Execution

> **Load trigger:** `"load e2e-test-execution skill"` > **DORA:** AI Capability 5: Working in small batches
> **Token cost:** Low

## Purpose

Validate full system behavior from the user's perspective.

## Responsibilities

- Execute E2E test suite
- Validate workflows end-to-end
- Validate acceptance criteria
- Detect regressions

## Inputs

- Build output
- E2E test files
- `acceptance-criteria.md` (or from tasks)

## Outputs

- `e2e-test-results.json`
- `e2e-test-report.md`

## Execution Rules

### Pre-Run

- [ ] Application deployed to test environment
- [ ] All dependent services running
- [ ] Test data seeded
- [ ] Browser/UI available (if UI tests)
- [ ] API endpoints accessible

### Execution

- [ ] All E2E workflows executed
- [ ] User journeys validated
- [ ] Acceptance criteria verified
- [ ] Error scenarios validated

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured (with screenshots if UI)
- [ ] Acceptance criteria mapping documented
- [ ] Regression assessment made

## Workflow Validation

### User Journey Mapping

| Journey                                | Test File         | Status |
| -------------------------------------- | ----------------- | ------ |
| User signup → login → dashboard        | `signup.e2e.ts`   | PASS   |
| Create item → edit → delete            | `crud.e2e.ts`     | PASS   |
| Checkout flow → payment → confirmation | `checkout.e2e.ts` | PASS   |

### Acceptance Criteria Verification

- [ ] Each AC maps to at least one E2E test
- [ ] AC test results documented
- [ ] Uncovered ACs flagged as findings

## Tools

| Type | Tool                          | Notes              |
| ---- | ----------------------------- | ------------------ |
| API  | Supertest, httpx, httptest    | HTTP-level E2E     |
| UI   | Playwright, Cypress, Selenium | Browser automation |
| CLI  | Bash scripts, expect          | Command-line E2E   |

## Output Format

```json
{
  "skill": "e2e-test-execution",
  "status": "pass | fail",
  "total": 5,
  "passed": 5,
  "failed": 0,
  "workflows_tested": [
    "User signup → login → dashboard",
    "Create item → edit → delete"
  ],
  "acceptance_criteria_coverage": {
    "total": 12,
    "covered": 10,
    "uncovered": ["AC-11: Multi-language support", "AC-12: Offline mode"]
  },
  "failures": []
}
```

## Success Criteria

- All E2E tests pass
- Acceptance criteria covered
- No regressions detected

### Integration Test Execution

# Skill: Integration Test Execution

> **Load trigger:** `"load integration-test-execution skill"` > **DORA:** AI Capability 5: Working in small batches
> **Token cost:** Low

## Purpose

Validate interactions between components.

## Responsibilities

- Execute integration test suite
- Validate component interactions
- Validate data flow correctness
- Detect integration failures

## Inputs

- Build output
- Integration test files
- Test configuration

## Outputs

- `integration-test-results.json`
- `integration-test-report.md`

## Execution Rules

### Pre-Run

- [ ] Required services/dependencies available (or mocked)
- [ ] Test database/datastore configured
- [ ] Network dependencies accessible or simulated
- [ ] Environment variables set

### Execution

- [ ] All integration tests executed
- [ ] Service interactions validated
- [ ] Data flow validated
- [ ] Timeout and retry behavior validated

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured
- [ ] Integration points documented
- [ ] External dependency issues flagged

## Integration Points

### Common Integration Boundaries

- API ↔ Database
- API ↔ External Service (payment, email, etc.)
- Service ↔ Service (internal RPC/messaging)
- Frontend ↔ Backend (API calls)
- CLI ↔ Filesystem

### Validation Rules

- [ ] Database queries return expected shapes
- [ ] External service responses handled correctly
- [ ] Error responses propagated correctly
- [ ] Timeouts handled gracefully
- [ ] Retries follow exponential backoff

## Tools

| Language   | Runner        | Notes                                   |
| ---------- | ------------- | --------------------------------------- |
| TypeScript | Jest / Vitest | `--integration` flag or separate config |
| Python     | pytest        | Markers: `@pytest.mark.integration`     |
| Go         | `go test`     | Build tags: `//go:build integration`    |

## Output Format

```json
{
  "skill": "integration-test-execution",
  "status": "pass | fail",
  "total": 8,
  "passed": 8,
  "failed": 0,
  "integration_points_tested": ["API ↔ Database", "API ↔ External Service"],
  "failures": []
}
```

## Success Criteria

- All integration tests pass
- Component interactions validated
- Data flow correctness confirmed

### Performance Smoke Testing

# Skill: Performance Smoke Testing

> **Load trigger:** `"load performance-smoke-testing skill"` > **DORA:** AI Capability 5: Working in small batches
> **Token cost:** Low

## Purpose

Validate basic performance characteristics to detect regressions.

## Responsibilities

- Run lightweight load tests
- Measure latency, throughput, error rate
- Detect performance regressions
- Produce performance summary

## Inputs

- Build output
- Performance test configuration
- Baseline metrics (if available)

## Outputs

- `performance-smoke.json`
- `performance-summary.md`

## Metrics

### Core Metrics

| Metric        | Description                   | Unit  |
| ------------- | ----------------------------- | ----- |
| Latency (p50) | Median response time          | ms    |
| Latency (p95) | 95th percentile response time | ms    |
| Latency (p99) | 99th percentile response time | ms    |
| Throughput    | Requests per second           | req/s |
| Error rate    | Percentage of failed requests | %     |
| Saturation    | Resource utilization at peak  | %     |

### Regression Thresholds

| Metric        | Regression If...             |
| ------------- | ---------------------------- |
| Latency (p50) | > 20% increase from baseline |
| Latency (p95) | > 30% increase from baseline |
| Throughput    | > 15% decrease from baseline |
| Error rate    | > 1% increase from baseline  |

## Test Configuration

### Light Smoke Test

- Duration: 30 seconds
- Concurrent users: 10
- Requests per user: 50
- Think time: 100ms

### Standard Smoke Test

- Duration: 60 seconds
- Concurrent users: 50
- Requests per user: 100
- Think time: 200ms

## Validation Rules

### Pre-Test

- [ ] Application accessible
- [ ] Baseline metrics available (or first run noted)
- [ ] Test parameters configured

### During Test

- [ ] No errors exceeding threshold
- [ ] No timeouts exceeding threshold
- [ ] Resource utilization within bounds

### Post-Test

- [ ] Results collected and formatted
- [ ] Regression assessment made
- [ ] Comparison with baseline (if available)

## Tools

| Tool              | Language   | Notes                        |
| ----------------- | ---------- | ---------------------------- |
| k6                | JavaScript | Lightweight, cloud-ready     |
| wrk               | C          | High performance             |
| ab (Apache Bench) | CLI        | Simple, available everywhere |
| locust            | Python     | Scriptable, distributed      |
| vegeta            | Go         | Fixed-rate load testing      |

## Output Format

```json
{
  "skill": "performance-smoke-testing",
  "status": "pass | fail",
  "config": {
    "duration_seconds": 30,
    "concurrent_users": 10,
    "total_requests": 500
  },
  "results": {
    "latency_p50_ms": 45,
    "latency_p95_ms": 120,
    "latency_p99_ms": 250,
    "throughput_rps": 85,
    "error_rate_percent": 0.2,
    "total_requests": 500,
    "successful_requests": 499
  },
  "baseline": {
    "latency_p50_ms": 42,
    "latency_p95_ms": 110,
    "throughput_rps": 90
  },
  "regression": {
    "detected": false,
    "details": []
  }
}
```

## Success Criteria

- No major performance regressions detected
- Latency within acceptable bounds
- Error rate below threshold

### Pipeline Test Stage Validation

# Skill: Pipeline Test Stage Validation

> **Load trigger:** `"load pipeline-test-stage-validation skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low

## Purpose

Ensure the CI/CD pipeline includes required test stages.

## Responsibilities

- Validate presence of unit test stage
- Validate presence of integration test stage
- Validate presence of E2E test stage (if required)
- Validate coverage reporting stage
- Validate test result reporting

## Inputs

- `pipeline-spec.yaml`
- Governance rules

## Outputs

- `pipeline-test-stage-report.json`

## Required Stages

### Must Have

| Stage           | Purpose                | Required |
| --------------- | ---------------------- | -------- |
| Unit tests      | Fast correctness check | Yes      |
| Coverage report | Measure coverage       | Yes      |
| Lint/format     | Code quality           | Yes      |

### Should Have

| Stage             | Purpose               | Required    |
| ----------------- | --------------------- | ----------- |
| Integration tests | Component interaction | Recommended |
| Security scan     | Vulnerability check   | Recommended |

### Nice to Have

| Stage             | Purpose                  | Required      |
| ----------------- | ------------------------ | ------------- |
| E2E tests         | Full workflow validation | If applicable |
| Performance smoke | Basic perf check         | Optional      |

## Validation Rules

### Stage Presence

- [ ] Unit test stage exists
- [ ] Coverage reporting stage exists
- [ ] Integration test stage exists (or justified as N/A)
- [ ] E2E test stage exists (if app has UI or API workflows)

### Stage Configuration

- [ ] Test stages run on PR and push to main
- [ ] Test failures block merge
- [ ] Coverage thresholds enforced in CI
- [ ] Test results reported (not just exit code)

### Pipeline Position

- [ ] Tests run before build/deploy stages
- [ ] Tests run after lint/format stages
- [ ] Security scans run alongside tests

## Tools

- `yq` for YAML parsing
- Policy engine (OPA, Kyverno) for validation
- `gh api` for GitHub Actions workflow inspection

## Output Format

```json
{
  "skill": "pipeline-test-stage-validation",
  "status": "pass | fail",
  "stages": {
    "unit_tests": {
      "present": true,
      "runs_on_pr": true,
      "blocks_merge": true
    },
    "integration_tests": {
      "present": true,
      "runs_on_pr": true,
      "blocks_merge": true
    },
    "e2e_tests": {
      "present": false,
      "justified": false
    },
    "coverage_report": {
      "present": true,
      "threshold_enforced": true
    }
  },
  "findings": [
    {
      "severity": "MEDIUM",
      "stage": "e2e_tests",
      "issue": "E2E test stage missing from pipeline",
      "fix": "Add E2E test stage to pipeline-spec.yaml"
    }
  ]
}
```

## Success Criteria

- Pipeline includes all required test stages
- Test failures block merge
- Coverage thresholds enforced

### Runtime Simulation Validation

# Skill: Runtime Simulation Validation

> **Load trigger:** `"load runtime-simulation-validation skill"` > **DORA:** AI Capability 5: Working in small batches
> **Token cost:** Low

## Purpose

Validate runtime behavior in a simulated environment.

## Responsibilities

- Deploy build output to local/simulated environment
- Validate readiness and liveness probes
- Validate logs and metrics
- Detect runtime errors

## Inputs

- Build output (code, manifests)
- Simulation environment (kind, minikube, Docker Compose, local server)

## Outputs

- `runtime-simulation.json`
- `runtime-errors.txt`

## Validation Rules

### Startup

- [ ] Application starts without errors
- [ ] Startup completes within timeout
- [ ] Liveness probe responds
- [ ] Readiness probe responds

### Runtime

- [ ] No crash loops or restarts
- [ ] No OOM kills
- [ ] No unhandled exceptions in logs
- [ ] Graceful shutdown works

### Logs

- [ ] No ERROR or FATAL messages in logs
- [ ] No stack traces in logs
- [ ] No sensitive data in logs
- [ ] Logging format consistent

### Health Endpoints

- [ ] `/healthz` returns 200
- [ ] `/readyz` returns 200 (or 503 when not ready)
- [ ] `/metrics` returns valid Prometheus format (if applicable)

## Simulation Environments

| Environment        | Tool                  | Use When                       |
| ------------------ | --------------------- | ------------------------------ |
| Kubernetes (local) | kind / minikube       | K8s manifests to validate      |
| Docker             | Docker Compose        | Multi-container apps           |
| Standalone         | Direct execution      | Simple services                |
| Mock server        | WireMock / MockServer | External dependency simulation |

## Tools

- `kubectl` for K8s simulation
- `docker-compose` for multi-container simulation
- `curl` / HTTP client for health check validation
- Log aggregator for log analysis

## Output Format

```json
{
  "skill": "runtime-simulation-validation",
  "status": "pass | fail",
  "startup": {
    "starts_successfully": true,
    "startup_time_ms": 1200,
    "liveness_probe": "healthy",
    "readiness_probe": "ready"
  },
  "runtime": {
    "crash_loops": 0,
    "oom_kills": 0,
    "unhandled_exceptions": 0
  },
  "logs": {
    "error_count": 0,
    "fatal_count": 0,
    "sensitive_data_found": false
  },
  "health_endpoints": {
    "/healthz": 200,
    "/readyz": 200
  },
  "errors": []
}
```

## Success Criteria

- Application starts without errors
- Health probes respond correctly
- No runtime errors detected
- Logs clean and consistent

### Test Coverage Validation

# Skill: Test Coverage Validation

> **Load trigger:** `"load test-coverage-validation skill"` > **DORA:** AI Capability 5: Working in small batches
> **Token cost:** Low

## Purpose

Validate that test coverage meets platform thresholds.

## Responsibilities

- Analyze coverage data from test runs
- Validate coverage against thresholds
- Identify untested or under-tested areas
- Produce coverage report

## Inputs

- Coverage data (from unit/integration test runs)
- Governance rules (threshold requirements)

## Outputs

- `coverage-report.json`
- `coverage-summary.md`

## Thresholds

### Default Thresholds

| Metric             | Minimum | Target |
| ------------------ | ------- | ------ |
| Line coverage      | 80%     | 90%    |
| Branch coverage    | 75%     | 85%    |
| Function coverage  | 85%     | 95%    |
| Statement coverage | 80%     | 90%    |

### Severity Classification

| Gap                           | Severity |
| ----------------------------- | -------- |
| Critical module below 60%     | HIGH     |
| Module below threshold        | MEDIUM   |
| New code below threshold      | HIGH     |
| Existing code below threshold | LOW      |

## Validation Rules

### Coverage Analysis

- [ ] Coverage data parsed and normalized
- [ ] Per-file coverage calculated
- [ ] Per-module coverage calculated
- [ ] Overall coverage calculated

### Threshold Check

- [ ] Line coverage ≥ threshold
- [ ] Branch coverage ≥ threshold
- [ ] Function coverage ≥ threshold
- [ ] No critical module below 60%

### Gap Identification

- [ ] Files with 0% coverage flagged
- [ ] Files below threshold flagged
- [ ] Critical paths with low coverage flagged
- [ ] Untested error paths flagged

## Output Format

```json
{
  "skill": "test-coverage-validation",
  "status": "pass | fail",
  "overall": {
    "line": 87.5,
    "branch": 79.2,
    "function": 92.1,
    "statement": 86.3
  },
  "thresholds": {
    "line": 80,
    "branch": 75,
    "function": 85,
    "statement": 80
  },
  "gaps": [
    {
      "file": "src/services/payment.ts",
      "line_coverage": 45.2,
      "severity": "HIGH",
      "reason": "Critical module below 60%"
    }
  ]
}
```

## Success Criteria

- Coverage meets or exceeds required thresholds
- All gaps identified and classified
- Critical paths have adequate coverage

### Unit Test Execution

# Skill: Unit Test Execution

> **Load trigger:** `"load unit-test-execution skill"` > **DORA:** AI Capability 5: Working in small batches
> **Token cost:** Low

## Purpose

Run unit tests and validate correctness of individual components.

## Responsibilities

- Execute unit test suite
- Collect test results and failure details
- Collect coverage data
- Detect flaky or skipped tests

## Inputs

- Source code
- Unit test files
- Test configuration (`jest.config.ts`, `pytest.ini`, etc.)

## Outputs

- `unit-test-results.json`
- `unit-test-report.md`

## Execution Rules

### Pre-Run

- [ ] Test framework installed and configured
- [ ] Test files discovered and counted
- [ ] Dependencies available (no missing modules)

### Execution

- [ ] All unit tests executed
- [ ] No tests skipped without justification
- [ ] Test output captured (stdout, stderr)
- [ ] Exit code checked (non-zero = failure)

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured (test name, assertion, file:line)
- [ ] Coverage data collected (line, branch, function)
- [ ] Flaky tests flagged (if detectable)

## Tools

| Language   | Runner        | Coverage          |
| ---------- | ------------- | ----------------- |
| TypeScript | Jest / Vitest | `--coverage`      |
| Python     | pytest        | `pytest-cov`      |
| Go         | `go test`     | `-coverprofile`   |
| Rust       | `cargo test`  | `cargo-tarpaulin` |

## Output Format

```json
{
  "skill": "unit-test-execution",
  "status": "pass | fail",
  "total": 44,
  "passed": 42,
  "failed": 0,
  "skipped": 2,
  "coverage": {
    "line": 87.5,
    "branch": 79.2,
    "function": 92.1
  },
  "failures": [],
  "skipped_tests": ["test name 1"]
}
```

## Success Criteria

- All unit tests pass
- Coverage data collected successfully
- No unexplained skips

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

## Usage

```bash
# Run e2e tests
load test-execution/e2e-test-execution skill

# Run integration tests
load test-execution/integration-test-execution skill

# Performance smoke tests
load test-execution/performance-smoke-testing skill

# Pipeline test stage validation
load test-execution/pipeline-test-stage-validation skill

# Runtime simulation
load test-execution/runtime-simulation-validation skill

# Test coverage validation
load test-execution/test-coverage-validation skill

# Unit tests
load test-execution/unit-test-execution skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 4, 5 references
- **AI stance audit** validates relevant clarity dimensions
