#!/usr/bin/env bash
# post-commit-graphify.sh — Rebuild graphify graph after each commit
# Install: ln -sf ../../.agents/hooks/post-commit-graphify.sh .git/hooks/post-commit
#
# Runs `graphify update` (code-only, no LLM) and stages the persistent
# outputs so they're included in the *next* commit. This keeps the graph
# current without slowing down the commit itself.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
GRAPHIFY_OUT="${REPO_ROOT}/graphify-out"

# Bail if graphify-out doesn't exist (graph hasn't been built yet)
if [ ! -d "${GRAPHIFY_OUT}" ]; then
  exit 0
fi

# Bail if .graphify_python is missing (corrupted or incomplete setup)
if [ ! -f "${GRAPHIFY_OUT}/.graphify_python" ]; then
  echo "post-commit-graphify: .graphify_python missing, skipping rebuild"
  exit 0
fi

PYTHON="$(cat "${GRAPHIFY_OUT}/.graphify_python")"

# Bail if graphify isn't installed
if ! "${PYTHON}" -c "import graphify" 2>/dev/null; then
  echo "post-commit-graphify: graphify not installed, skipping"
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

# Run incremental update (no LLM, code-only re-extraction)
if GRAPHIFY_ROOT="${REPO_ROOT}" "${PYTHON}" -c "
import sys, json
from pathlib import Path

root = Path('${REPO_ROOT}')
out = root / 'graphify-out'

# Run detect to find changed files since last manifest
from graphify.detect import detect, load_manifest, save_manifest
from graphify.extract import extract

manifest = load_manifest()
result = detect(root)

# Compare against manifest to find new/changed files
all_files = []
for files in result['files'].values():
    all_files.extend(files)

changed = []
for f in all_files:
    p = Path(f)
    if not p.exists():
        continue
    if f not in manifest or p.stat().st_mtime > manifest.get(f, {}).get('mtime', 0):
        changed.append(f)

if not changed:
    print('No changed files — skipping update')
    sys.exit(0)

print(f'Changed: {len(changed)} files')

# Update manifest timestamps
save_manifest(result.get('all_files') or result['files'])

# Re-run extraction on changed code files only
code_files = [Path(f) for f in changed if f.endswith(('.py', '.ts', '.js', '.go', '.sh', '.yaml', '.yml', '.json'))]
if code_files:
    ast = extract(code_files, cache_root=root)
    Path(out / '.graphify_ast.json').write_text(json.dumps(ast, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f'AST update: {len(ast[\"nodes\"])} nodes, {len(ast[\"edges\"])} edges')

# Rebuild graph with existing extraction + new AST
extract_path = out / '.graphify_extract.json'
if extract_path.exists():
    extraction = json.loads(extract_path.read_text(encoding='utf-8'))
else:
    extraction = {'nodes': [], 'edges': [], 'hyperedges': []}

# Merge new AST into existing extraction
if code_files and (out / '.graphify_ast.json').exists():
    new_ast = json.loads((out / '.graphify_ast.json').read_text(encoding='utf-8'))
    seen = {n['id'] for n in extraction['nodes']}
    for n in new_ast['nodes']:
        if n['id'] not in seen:
            extraction['nodes'].append(n)
            seen.add(n['id'])
    extraction['edges'].extend(new_ast['edges'])

# Rebuild graph JSON only (skip report/html — fragile, slow, needs full detect data)
from graphify.build import build_from_json
from graphify.cluster import cluster
from graphify.export import to_json

G = build_from_json(extraction)
if G.number_of_nodes() == 0:
    print('Graph empty after update — aborting')
    sys.exit(1)

communities = cluster(G)
to_json(G, communities, str(out / 'graph.json'))
print(f'Graph updated: {G.number_of_nodes()} nodes, {G.number_of_edges()} edges')
print('Run: graphify cluster-only . to regenerate report + html')
" 2>&1; then
  # Stage persistent outputs for the next commit
  git add -f \
    graphify-out/graph.json \
    graphify-out/cost.json \
    graphify-out/manifest.json \
    2>/dev/null || true

  echo "post-commit-graphify: done — outputs staged for next commit"
else
  echo "post-commit-graphify: update failed (non-fatal)"
fi
