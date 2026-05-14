#!/usr/bin/env bash
# scripts/setup.sh — uFawkesAI project setup
#
# Creates symlinks, installs git hooks, and prints a success summary.
# Idempotent: safe to run multiple times.
#
# Usage:
#   ./scripts/setup.sh           — full setup
#   ./scripts/setup.sh --dry-run — preview actions without making changes

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# ── Colours ──────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Flags ─────────────────────────────────────────────────────────────────
DRY_RUN=false
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

# ── Helpers ───────────────────────────────────────────────────────────────
info()   { echo -e "${BLUE}  →${NC} $*"; }
ok()     { echo -e "${GREEN}  ✅${NC} $*"; }
warn()   { echo -e "${YELLOW}  ⚠️ ${NC} $*"; }
dry()    { echo -e "${YELLOW}  [dry-run]${NC} would: $*"; }

make_dir() {
  local dir="$1"
  if $DRY_RUN; then dry "mkdir -p ${dir}"; return; fi
  mkdir -p "${dir}"
}

make_symlink() {
  local target="$1"
  local link="$2"
  if $DRY_RUN; then dry "ln -sf ${target} ${link}"; return; fi
  ln -sf "${target}" "${link}"
  ok "Symlink: ${link} → ${target}"
}

install_hook() {
  local src="$1"
  local hook_name
  hook_name="$(basename "${src}")"
  local dest=".git/hooks/${hook_name}"
  if $DRY_RUN; then dry "install hook ${hook_name}"; return; fi
  cp "${src}" "${dest}"
  chmod +x "${dest}"
  ok "Hook installed: ${hook_name}"
}

# ── Header ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}uFawkesAI Setup${NC}"
echo "════════════════════════════════════════"
if $DRY_RUN; then
  echo -e "${YELLOW}  DRY-RUN MODE — no changes will be made${NC}"
  echo ""
fi

# ── 1. Symlinks ───────────────────────────────────────────────────────────
echo -e "${BOLD}1. Creating symlinks${NC}"

make_dir .github
make_symlink AGENTS.md CLAUDE.md
make_symlink ../AGENTS.md .github/copilot-instructions.md
make_symlink AGENTS.md .cursorrules
make_dir .cursor/rules
make_symlink ../../AGENTS.md .cursor/rules/AGENTS.md
echo ""

# ── 2. Git hooks ──────────────────────────────────────────────────────────
echo -e "${BOLD}2. Installing git hooks${NC}"
HOOKS_SRC=".github/hooks"

if [ -d "${HOOKS_SRC}" ]; then
  for hook in "${HOOKS_SRC}"/*; do
    [ -f "${hook}" ] && install_hook "${hook}"
  done
else
  warn "No .github/hooks/ directory found — skipping git hook installation"
fi
echo ""

# ── 3. Summary ────────────────────────────────────────────────────────────
echo "════════════════════════════════════════"
if $DRY_RUN; then
  echo -e "${YELLOW}${BOLD}Dry-run complete — no changes were made.${NC}"
else
  echo -e "${GREEN}${BOLD}✅  Setup complete!${NC}"
fi
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Open AGENTS.md and replace every [PLACEHOLDER] section with your project details"
echo -e "  2. Run ${BOLD}npm run preflight${NC} to verify the project is healthy"
echo "  3. Assign your first issue to Copilot or Claude Code"
echo ""
echo "  Docs: https://github.com/paruff/uFawkesAI"
echo ""
