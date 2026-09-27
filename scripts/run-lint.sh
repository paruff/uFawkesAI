#!/usr/bin/env bash
# scripts/run-lint.sh — run every linter that can run on this repo.
#
# Each linter is attempted independently. A linter whose binary is absent is
# reported as SKIP, never as PASS — a skipped check that reads like a passed
# one is how this repo ended up advertising `npm run lint` while linting
# nothing at all.
#
# Exit 0 = every linter that ran, passed. Exit 1 = any linter failed.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

PASSED=0
SKIPPED=0
FAILED=0

run() { # run <label> <command...>
  local label="$1"; shift
  if "$@" >/tmp/lint.$$.out 2>&1; then
    printf '  PASS  %-22s\n' "$label"
    PASSED=$((PASSED + 1))
  else
    printf '  FAIL  %-22s\n' "$label"
    sed 's/^/        /' /tmp/lint.$$.out | head -40
    FAILED=$((FAILED + 1))
  fi
  rm -f /tmp/lint.$$.out
}

skip() { printf '  SKIP  %-22s %s\n' "$1" "$2"; SKIPPED=$((SKIPPED + 1)); }

echo "== Lint =="

# Shell: the one linter that needs no install and covers real code.
mapfile -t shell_files < <(find . -name '*.sh' -not -path './.git/*' \
  -not -path './opencode/*' -not -path '*/node_modules/*' | sort)
if command -v shellcheck >/dev/null 2>&1; then
  run "shellcheck (${#shell_files[@]} files)" shellcheck "${shell_files[@]}"
else
  skip "shellcheck" "not installed (brew install shellcheck) — pre-commit still gates it"
fi

# YAML
if command -v yamllint >/dev/null 2>&1; then
  run "yamllint" yamllint -c .yamllint .
else
  skip "yamllint" "not installed locally — pre-commit gates it"
fi

# Markdown
if command -v markdownlint >/dev/null 2>&1; then
  run "markdownlint" markdownlint --config .markdownlint.json "**/*.md"
else
  skip "markdownlint" "not installed locally — pre-commit gates it"
fi

# Python (the repo's Python lives under templates/)
mapfile -t py_files < <(find templates -name '*.py' 2>/dev/null | sort)
if command -v ruff >/dev/null 2>&1 && [[ "${#py_files[@]}" -gt 0 ]]; then
  run "ruff (${#py_files[@]} files)" ruff check "${py_files[@]}"
else
  skip "ruff" "not installed (or no Python found) — pre-commit gates it"
fi

echo
echo "lint: ${PASSED} passed, ${SKIPPED} skipped, ${FAILED} failed"
if [[ "$FAILED" -ne 0 ]]; then
  exit 1
fi
# A run where everything was skipped is not a green run.
if [[ "$PASSED" -eq 0 ]]; then
  echo "lint: no linter actually ran — this is not a pass" >&2
  exit 1
fi
