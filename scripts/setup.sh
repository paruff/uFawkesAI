#!/usr/bin/env bash
set -euo pipefail

echo "Setting up uFawkesAI agent symlinks..."
ln -sf AGENTS.md CLAUDE.md
ln -sf ../AGENTS.md .github/copilot-instructions.md
ln -sf AGENTS.md .cursorrules

echo "Installing pre-commit hooks..."
# Hook installation (see AI-007)

echo "✅ uFawkesAI setup complete. Open AGENTS.md and replace all [PLACEHOLDER] sections."
