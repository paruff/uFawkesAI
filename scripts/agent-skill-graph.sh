#!/usr/bin/env bash
# agent-skill-graph.sh — Build and validate the skill dependency graph
# DORA Cap 3 (Context Engineering): generate machine-readable graph from lifecycle registry
# Usage: bash scripts/agent-skill-graph.sh
# Outputs:
#   .agents/skills/platform-engineering/skill-dependency-graph/skill-graph.json
#   .agents/skills/platform-engineering/skill-dependency-graph/graph-validation.json
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REGISTRY="${REPO_ROOT}/.agents/registry/skill-lifecycle.yaml"
OUT_DIR="${REPO_ROOT}/.agents/skills/platform-engineering/skill-dependency-graph"

if [ ! -f "${REGISTRY}" ]; then
  echo "FAIL: Registry not found at ${REGISTRY}"
  echo "Run Phase 3 setup first."
  exit 1
fi

mkdir -p "${OUT_DIR}"

export SNAPSHOT_UTC="$(date -u +"%Y-%m-%d %H:%M:%SZ")"

echo "Building skill dependency graph from lifecycle registry..."
echo ""

python3 - "${REGISTRY}" "${OUT_DIR}" <<'PYTHON_SCRIPT'
import json, os, sys
import yaml

registry_path = sys.argv[1]
out_dir = sys.argv[2]

with open(registry_path) as f:
    registry = yaml.safe_load(f)

skills = registry.get("skills", {})

# Build graph
nodes = []
edges = []
adjacency = {}  # name -> [deps]
reverse_adj = {}  # name -> [dependents]

for name, meta in sorted(skills.items()):
    if meta.get("status") == "deprecated":
        continue
    raw_deps = meta.get("dependencies", [])
    deps = []
    for d in raw_deps:
        if d in skills:
            deps.append(d)
        else:
            print("  ⚠ WARNING: {} depends on '{}' which is not in the registry — skipping".format(name, d))
    adjacency[name] = deps
    reverse_adj.setdefault(name, [])
    for dep in deps:
        edges.append({"from": dep, "to": name})
        reverse_adj.setdefault(dep, []).append(name)

    sub_skills = meta.get("sub_skills", [])
    for sub in sub_skills:
        sub_deps = []
        for d in meta.get("dependencies", []):
            if d in skills:
                sub_deps.append(d)
            else:
                print("  ⚠ WARNING: {} depends on '{}' which is not in the registry — skipping".format(sub, d))
        adjacency[sub] = sub_deps
        reverse_adj.setdefault(sub, [])
        for dep in sub_deps:
            if dep not in [e["from"] for e in edges if e["to"] == sub]:
                edges.append({"from": dep, "to": sub})
                reverse_adj.setdefault(dep, []).append(sub)

    level = "domain"
    if sub_skills:
        level = "domain"
    else:
        level = "sub-skill" if "/" in name else "domain"

    nodes.append({
        "id": name,
        "level": level,
        "status": meta.get("status", "active"),
        "version": meta.get("version", "0.0.0"),
    })

# Add sub-skills to nodes (they're in adjacency but not in the skills dict)
node_ids = {n["id"] for n in nodes}
for adj_name in adjacency:
    if adj_name not in node_ids:
        nodes.append({
            "id": adj_name,
            "level": "sub-skill",
            "status": "active",
            "version": "0.0.0",
        })

# Cycle detection (DFS)
WHITE, GRAY, BLACK = 0, 1, 2
color = {n: WHITE for n in adjacency}
parent = {}
cycles = []
order = []

def dfs(u):
    color[u] = GRAY
    for v in adjacency[u]:
        if v not in adjacency:
            continue
        if color[v] == GRAY:
            # Found a cycle — reconstruct
            cycle = [v, u]
            cur = u
            while cur != v:
                cur = parent.get(cur)
                if cur is None:
                    break
                cycle.append(cur)
            cycles.append(list(reversed(cycle)))
        elif color[v] == WHITE:
            parent[v] = u
            dfs(v)
    color[u] = BLACK
    order.append(u)

for node in sorted(adjacency.keys()):
    if color[node] == WHITE:
        dfs(node)

# Topological sort
# DFS appends after visiting dependencies, so order has deps before dependents
topological_order = list(order)

# Build output
graph_data = {
    "skill": "skill-dependency-graph",
    "generated_at": os.environ.get("SNAPSHOT_UTC", ""),
    "registry": "skill-lifecycle.yaml",
    "total_skills": len(nodes),
    "deprecated_skills": sum(1 for m in skills.values() if m.get("status") == "deprecated"),
    "edges": len(edges),
    "nodes": nodes,
    "edges_list": edges,
    "topological_order": topological_order,
}

validation_data = {
    "skill": "graph-validation",
    "generated_at": os.environ.get("SNAPSHOT_UTC", ""),
    "status": "valid" if not cycles else "invalid",
    "total_nodes": len(nodes),
    "total_edges": len(edges),
    "cycles": [{"path": c} for c in cycles],
    "cycle_count": len(cycles),
    "topological_order": topological_order,
    "level_counts": {
        "domains": sum(1 for n in nodes if n["level"] == "domain"),
        "sub_skills": sum(1 for n in nodes if n["level"] == "sub-skill"),
    },
    "status_counts": {},
}

status_counts = {}
for n in nodes:
    s = n["status"]
    status_counts[s] = status_counts.get(s, 0) + 1
validation_data["status_counts"] = status_counts

if cycles:
    print(f"  ⚠ {len(cycles)} circular dependenc{'y' if len(cycles) == 1 else 'ies'} detected!")
    for c in cycles:
        print(f"     {' → '.join(c)}")
else:
    print(f"  ✅ No circular dependencies detected")

# Write skill-graph.json
graph_path = os.path.join(out_dir, "skill-graph.json")
with open(graph_path, "w") as f:
    json.dump(graph_data, f, indent=2)
print(f"  Wrote {graph_path} ({len(nodes)} nodes, {len(edges)} edges)")

# Write graph-validation.json
validation_path = os.path.join(out_dir, "graph-validation.json")
with open(validation_path, "w") as f:
    json.dump(validation_data, f, indent=2)
print(f"  Wrote {validation_path} (status: {validation_data['status']})")

# Print summary
print()
print("  Topological order:")
for i, name in enumerate(topological_order, 1):
    print(f"    {i}. {name}")
PYTHON_SCRIPT
