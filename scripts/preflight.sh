#!/usr/bin/env bash
# preflight.sh — real preflight gate for template repositories
# Run: npm run preflight

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

failures=0

pass() {
  printf "%b\n" "${GREEN}✅${NC} $*"
}

warn() {
  printf "%b\n" "${YELLOW}⚠️ ${NC} $*"
}

fail() {
  printf "%b\n" "${RED}❌${NC} $*"
  failures=$((failures + 1))
}

echo ""
echo "Running preflight checks..."
echo ""

# 1) Shellcheck all shell scripts in the repository
if ! command -v shellcheck >/dev/null 2>&1; then
  fail "shellcheck is required but not installed. Install shellcheck and re-run npm run preflight."
else
  mapfile -d '' shell_files < <(
    find . -type f -name '*.sh' \
      -not -path './.git/*' \
      -not -path './node_modules/*' \
      -not -path './vendor/*' \
      -not -path './build/*' \
      -not -path './dist/*' \
      -print0
  )
  if [ "${#shell_files[@]}" -eq 0 ]; then
    warn "No shell scripts found."
  elif shellcheck "${shell_files[@]}"; then
    pass "shellcheck passed for ${#shell_files[@]} script(s)."
  else
    fail "shellcheck reported issues."
  fi
fi

# 2) AGENTS.md must have no unfilled placeholders
if [ ! -f AGENTS.md ]; then
  fail "AGENTS.md is missing. This template requires AGENTS.md at the repository root."
else
  placeholder_lines="$(grep -n '\[PLACEHOLDER[^]]*\]' AGENTS.md || true)"
  if [ -n "${placeholder_lines}" ]; then
    echo "${placeholder_lines}"
    fail "AGENTS.md contains unfilled [PLACEHOLDER] markers."
  else
    pass "AGENTS.md contains no [PLACEHOLDER] markers."
  fi
fi

# 3) Required symlinks must exist and resolve
required_symlinks=(
  "CLAUDE.md"
  ".github/copilot-instructions.md"
  ".cursorrules"
  ".cursor/rules/AGENTS.md"
)

for link_path in "${required_symlinks[@]}"; do
  if [ ! -L "${link_path}" ]; then
    fail "${link_path} is missing or is not a symlink."
    continue
  fi

  if [ -e "${link_path}" ]; then
    pass "${link_path} exists and resolves."
  else
    fail "${link_path} is a broken symlink."
  fi
done

echo ""
if [ "${failures}" -gt 0 ]; then
  echo "Preflight failed with ${failures} issue(s)."
  exit 1
fi

echo "Preflight passed."
