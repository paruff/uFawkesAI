---
name: lang
description: "Language-specific toolchain conventions for Go, Python, and TypeScript. Implements DORA AI Capabilities 3, 4."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: lang

> **Load trigger:** "load lang skill" > **DORA:** AI Capabilities 3, 4
> **Token cost:** Low

## Purpose

Language-specific toolchain conventions for Go, Python, and TypeScript. CI gate commands, file layout, interface patterns, and configuration standards. Implements DORA AI Capabilities 3, 4.

## When to Use

- Working on a Go, Python, or TypeScript/JavaScript project
- Setting up CI gates for language-specific tooling

## Sub-skills (now integrated)

### GO

# Skill: Language — Go

> **Load trigger:** `"load lang-go skill"` > **Stack:** Go 1.22+, golangci-lint, go vet, go test, go test -cover, go mod
> **Token cost:** Low

## Toolchain Reference

| Gate            | Tool          | Command                                           | Config file            |
| --------------- | ------------- | ------------------------------------------------- | ---------------------- |
| Lint            | golangci-lint | `golangci-lint run ./...`                         | `.golangci.yml`        |
| Vet             | go vet        | `go vet ./...`                                    | none                   |
| Test            | go test       | `go test ./...`                                   | none                   |
| Coverage        | go test       | `go test -cover -coverprofile=coverage.out ./...` | none                   |
| Coverage report | go tool       | `go tool cover -func=coverage.out`                | none                   |
| Preflight       | shell         | `./scripts/preflight.sh`                          | `scripts/preflight.sh` |

## File Layout Convention

```
cmd/
  [service-name]/
    main.go             ← entry point only; no business logic
internal/
  services/             ← business logic
  handlers/             ← HTTP handlers (net/http or chi/gin)
  models/               ← data types and interfaces
  utils/                ← pure utility functions
pkg/
  [shared-packages]/    ← packages safe to import externally
go.mod
go.sum
```

## CI Gate Commands (ci-quality.yml)

```yaml
- name: Set up Go
  uses: actions/setup-go@v5
  with:
    go-version: "1.22"

- name: Lint
  uses: golangci/golangci-lint-action@v6
  with:
    version: latest

- name: Vet
  run: go vet ./...

- name: Test with coverage
  run: |
    go test -coverprofile=coverage.out ./...
    COVERAGE=$(go tool cover -func=coverage.out | grep total | awk '{print $3}' | tr -d '%')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage ${COVERAGE}% below 80% threshold"
      exit 1
    fi
```

## Go Standards

- Errors are returned, not panicked (except in `main()` or init)
- Interfaces defined at the point of use (consumer), not at definition
- Context propagated as first argument in every function that does I/O
- No global mutable state in packages
- Table-driven tests for functions with multiple input/output cases

## Interface Pattern for Testability

```go
// Define interface in the consuming package
type AuthProvider interface {
    SignIn(ctx context.Context, email, password string) (*User, error)
}

// Implementation satisfies it implicitly
type FirebaseAuthProvider struct { ... }
func (f *FirebaseAuthProvider) SignIn(...) (*User, error) { ... }
```

## .golangci.yml Minimum Config (from paruff/fawkes)

```yaml
linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
run:
  timeout: 5m
```

Note: paruff/fawkes has a `.golangci.yml` — use it as the source of truth for
any project integrating with that repo.

## OTEL SDK (for obs-agent)

```bash
go get go.opentelemetry.io/otel \
       go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp \
       go.opentelemetry.io/otel/sdk/trace
```

Init pattern: call `initTracer()` at start of `main()`, defer `shutdown()`.
Read `OTEL_SERVICE_NAME` and `OTEL_EXPORTER_OTLP_ENDPOINT` from `os.Getenv`.

### PYTHON

# Skill: Language — Python

> **Load trigger:** `"load lang-python skill"` > **Stack:** Python 3.11+, ruff, mypy, pytest, pytest-cov, uv or pip
> **Token cost:** Low

## Toolchain Reference

| Gate      | Tool       | Command                                      | Config file                                |
| --------- | ---------- | -------------------------------------------- | ------------------------------------------ |
| Lint      | ruff       | `ruff check .`                               | `pyproject.toml [tool.ruff]`               |
| Format    | ruff       | `ruff format .`                              | `pyproject.toml [tool.ruff.format]`        |
| Typecheck | mypy       | `mypy src/`                                  | `pyproject.toml [tool.mypy]`               |
| Test      | pytest     | `pytest`                                     | `pyproject.toml [tool.pytest.ini_options]` |
| Coverage  | pytest-cov | `pytest --cov=src --cov-report=term-missing` | `.coveragerc`                              |
| Preflight | shell      | `./scripts/preflight.sh`                     | `scripts/preflight.sh`                     |

## File Layout Convention

```
src/
  [package_name]/
    __init__.py
    services/           ← business logic
    utils/              ← pure functions
    models/             ← data models (Pydantic or dataclasses)
    api/                ← HTTP handlers / FastAPI routers
tests/
  test_services/        ← mirrors src/services/
  test_utils/           ← mirrors src/utils/
  conftest.py           ← shared fixtures
pyproject.toml          ← all tool config here (not setup.py)
```

## CI Gate Commands (ci-quality.yml)

```yaml
- name: Set up Python
  uses: actions/setup-python@v5
  with:
    python-version: "3.11"

- name: Install dependencies
  run: pip install -e ".[dev]"

- name: Lint
  run: ruff check .

- name: Typecheck
  run: mypy src/

- name: Test with coverage
  run: pytest --cov=src --cov-fail-under=80 --cov-report=xml
```

## Type Standards

- All public function signatures fully annotated
- Use `from __future__ import annotations` for forward references
- Prefer `TypeAlias` over bare assignments for complex types
- Pydantic v2 for data validation at service boundaries
- No `# type: ignore` without an inline comment explaining why

## pyproject.toml Minimum Config

```toml
[tool.ruff]
line-length = 88
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "I", "UP", "B"]

[tool.mypy]
strict = true
python_version = "3.11"

[tool.pytest.ini_options]
testpaths = ["tests"]
addopts = "--strict-markers"

[tool.coverage.run]
source = ["src"]
omit = ["tests/*"]
```

## OTEL SDK (for obs-agent)

```bash
pip install opentelemetry-sdk opentelemetry-exporter-otlp-proto-http
```

Init pattern: call `configure_otel()` at application entry point before importing
service modules. Read `OTEL_SERVICE_NAME` and `OTEL_EXPORTER_OTLP_ENDPOINT` from env.

## fawkes Repo Context

paruff/fawkes uses Python extensively (43.5% of codebase). Primary patterns:

- FastAPI for HTTP services
- Pydantic v2 for models
- pytest with conftest fixtures
- `.flake8` and `.coveragerc` exist in root (legacy — ruff supersedes flake8)

### TYPESCRIPT

# Skill: Language — TypeScript

> **Load trigger:** `"load lang-typescript skill"` > **Stack:** TypeScript, Node.js, ESLint, tsc, Jest/Vitest, npm
> **Token cost:** Low

## Toolchain Reference

| Gate      | Tool              | Command                 | Config file                            |
| --------- | ----------------- | ----------------------- | -------------------------------------- |
| Lint      | ESLint            | `npm run lint`          | `.eslintrc.js` or `eslint.config.js`   |
| Typecheck | tsc               | `npm run typecheck`     | `tsconfig.json`                        |
| Test      | Jest or Vitest    | `npm run test`          | `jest.config.ts` or `vitest.config.ts` |
| Coverage  | Jest `--coverage` | `npm run test:coverage` | `jest.config.ts`                       |
| Preflight | custom            | `npm run preflight`     | `scripts/preflight.sh`                 |

## File Layout Convention

```
src/
  types/index.ts        ← all shared types and interfaces
  services/             ← business logic, no UI dependencies
  utils/                ← pure functions, no side effects
  screens/ or pages/    ← UI layer only
tests/
  services/             ← mirrors src/services/
  utils/                ← mirrors src/utils/
```

## CI Gate Commands (ci-quality.yml)

```yaml
- name: Lint
  run: npm ci && npm run lint

- name: Typecheck
  run: npm run typecheck

- name: Test with coverage
  run: npm run test:coverage
  env:
    CI: true

- name: Coverage threshold
  run: |
    COVERAGE=$(cat coverage/coverage-summary.json | jq '.total.lines.pct')
    if (( $(echo "$COVERAGE < 80" | bc -l) )); then
      echo "Coverage $COVERAGE% is below 80% threshold"
      exit 1
    fi
```

## Type Standards

- No `any` in service or utility functions
- Catch blocks: `catch (error: unknown)` — narrow before use
- All external API responses typed with Zod or explicit interface
- No inline type definitions in function signatures — define in `src/types/index.ts`

## OTEL SDK (for obs-agent)

```bash
npm install @opentelemetry/sdk-node @opentelemetry/exporter-trace-otlp-http
```

Init pattern: `src/instrumentation.ts` — imported before all other imports in entry point.

## Node Version

Node 20 LTS. Pin in `.nvmrc` and `engines` field in `package.json`.
GitHub Actions: `uses: actions/setup-node@v4` with `node-version: '20'`.

## Usage

```bash
# Go toolchain
load lang/go skill

# Python toolchain
load lang/python skill

# TypeScript toolchain
load lang/typescript skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 3, 4 references
- **AI stance audit** validates relevant clarity dimensions
