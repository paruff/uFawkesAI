#!/usr/bin/env bash
# post-commit-graphify.sh — Rebuild graphify graph after each commit
# Install: ln -sf ../../.agents/hooks/post-commit-graphify.sh .git/hooks/post-commit
#
# Rebuilds graph.json from the stored extraction (.graphify_extract.json).
# Fast, no LLM, no re-extraction — just re-clusters on code changes.
# To regenerate report + HTML: graphify cluster-only .
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GRAPHIFY_OUT="${REPO_ROOT}/graphify-out"

# Bail if graphify-out doesn't exist or is missing key files
if [ ! -f "${GRAPHIFY_OUT}/.graphify_python" ] || [ ! -f "${GRAPHIFY_OUT}/.graphify_extract.json" ]; then
  exit 0
fi

PYTHON="$(cat "${GRAPHIFY_OUT}/.graphify_python")"

# Bail if graphify isn't installed
if ! "${PYTHON}" -c "import graphify" 2>/dev/null; then
  exit 0
fi

# Only rebuild if code or docs changed (skip pure config/CI-only commits)
CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)
NEEDS_REBUILD=false

while IFS= read -r file; do
  case "${file}" in
    *.py|*.ts|*.js|*.go|*.sh|*.md|*.txt|*.yaml|*.yml|*.json|*.pdf)
      NEEDS_REBUILD=true
      break
      ;;
  esac
done <<< "${CHANGED}"

if [ "${NEEDS_REBUILD}" = false ]; then
  exit 0
fi

echo "post-commit-graphify: rebuilding graph..."

"${PYTHON}" -c "
import json
from pathlib import Path

out = Path('${GRAPHIFY_OUT}')
extraction = json.loads((out / '.graphify_extract.json').read_text(encoding='utf-8'))

from graphify.build import build_from_json
from graphify.cluster import cluster
from graphify.export import to_json

G = build_from_json(extraction)
if G.number_of_nodes() == 0:
    print('Graph empty — aborting')
    raise SystemExit(1)

communities = cluster(G)
to_json(G, communities, str(out / 'graph.json'))
print(f'Graph: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges')
" 2>&1 && \
git add -f graphify-out/graph.json graphify-out/cost.json graphify-out/manifest.json 2>/dev/null && \
echo "post-commit-graphify: done" || \
echo "post-commit-graphify: rebuild failed (non-fatal)"
