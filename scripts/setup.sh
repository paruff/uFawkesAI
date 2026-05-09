#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

echo "Setting up uFawkesAI agent symlinks..."
mkdir -p .github
ln -sf AGENTS.md CLAUDE.md
ln -sf ../AGENTS.md .github/copilot-instructions.md
ln -sf AGENTS.md .cursorrules

echo "Pre-commit hook installation is not configured yet (planned in AI-007)."

echo "✅ uFawkesAI setup complete. Open AGENTS.md and replace all [PLACEHOLDER] sections."
