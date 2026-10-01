---
name: lang
description: "Language-specific toolchain conventions for Python and TypeScript. Implements DORA AI Capabilities 3, 4."
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

Language-specific toolchain conventions for Python and TypeScript. CI gate commands, file layout, interface patterns, and configuration standards. Implements DORA AI Capabilities 3, 4.

## When to Use

- Working on a Python or TypeScript/JavaScript project
- Setting up CI gates for language-specific tooling

## Sub-skills (now integrated)

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

Node 22 LTS. Pin in `.nvmrc` and `engines` field in `package.json`.
GitHub Actions: `uses: actions/setup-node@v4` with `node-version: '22'`.

## Usage

```bash
# Python toolchain
load lang/python skill

# TypeScript toolchain
load lang/typescript skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 3, 4 references
- **AI stance audit** validates relevant clarity dimensions
