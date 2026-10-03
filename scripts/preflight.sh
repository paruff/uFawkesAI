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

# BUG FIX 1: pass/warn used bare `$` instead of `$*` — messages were never printed
pass() { printf "%b\n" "${GREEN}✅ ${NC} $*"; }
warn() { printf "%b\n" "${YELLOW}⚠️  ${NC} $*"; }
fail() {
  printf "%b\n" "${RED}❌ ${NC} $*"
  failures=$((failures + 1))
}

echo ""
echo "Running preflight checks..."
echo ""

# ── 1) Shellcheck all shell scripts ─────────────────────────────────────────

if ! command -v shellcheck > /dev/null 2>&1; then
  fail "shellcheck is required but not installed. Run: brew install shellcheck"
else
  shell_files=()
  while IFS= read -r -d '' f; do
    shell_files+=("$f")
    # BUG FIX 2: `-not` is GNU find only — macOS requires `!`
    # BUG FIX 3: glob was '.sh' not '*.sh' — matched nothing
  done < <(find . -type f -name '*.sh' \
    ! -path './.git/*' \
    ! -path './node_modules/*' \
    ! -path './vendor/*' \
    ! -path './build/*' \
    ! -path './dist/*' \
    -print0)

  if [ "${#shell_files[@]}" -eq 0 ]; then
    warn "No shell scripts found."
  elif shellcheck "${shell_files[@]}"; then
    pass "shellcheck passed for ${#shell_files[@]} script(s)."
  else
    fail "shellcheck reported issues. Run shellcheck manually to see details."
  fi
fi

# ── 2) No unfilled placeholders (scripts/check-placeholders.sh, #28) ────────

if [ ! -f AGENTS.md ]; then
  fail "AGENTS.md is missing."
elif PLACEHOLDER_ENFORCE="${PREFLIGHT_ENFORCE_PLACEHOLDERS:-${PLACEHOLDER_ENFORCE:-0}}" \
  bash scripts/check-placeholders.sh; then
  pass "Placeholder audit passed."
else
  fail "Unfilled [PLACEHOLDER] markers (listed above)."
fi

# ── 3) Required symlinks must exist and resolve ──────────────────────────────

required_symlinks=(
  "CLAUDE.md"
  ".github/copilot-instructions.md"
  ".cursorrules"
  ".cursor/rules/AGENTS.md"
)

for link_path in "${required_symlinks[@]}"; do
  if [ ! -L "${link_path}" ]; then
    fail "${link_path} is missing or is not a symlink. Run: ./scripts/setup.sh"
    continue
  fi
  if [ -e "${link_path}" ]; then
    pass "${link_path} exists and resolves."
  else
    fail "${link_path} is a broken symlink. Run: ./scripts/setup.sh"
  fi
done

# ── Summary ──────────────────────────────────────────────────────────────────

echo ""
if [ "${failures}" -gt 0 ]; then
  printf "%b\n" "${RED}Preflight failed with ${failures} issue(s).${NC}"
  exit 1
fi
printf "%b\n" "${GREEN}Preflight passed.${NC}"
