#!/usr/bin/env bash
# scripts/hooks/tsc-plugin.sh — the tsc-plugin pre-commit hook (#192).
#
# Type-checks .opencode/plugins under the repo's strict tsconfig.json with no
# npm install: pre-commit's node environment holds typescript, @types/node and
# @opencode-ai/plugin (NODE_PATH), and a generated config extending the repo's
# points the compiler at them. CI's 🔷 TypeScript job runs the repo config itself.

set -euo pipefail

: "${NODE_PATH:?run through pre-commit (language: node), which sets NODE_PATH}"
config="$(mktemp --suffix=.json)"
trap 'rm -f "$config"' EXIT

# The plugin package exposes its types only through "exports", which "paths"
# doesn't follow, so map the import to its root .d.ts.
jq -n --arg root "$PWD" --arg np "$NODE_PATH" '{
  extends: "\($root)/tsconfig.json",
  include: ["\($root)/.opencode/plugins/**/*.ts"],
  compilerOptions: {
    typeRoots: ["\($np)/@types"],
    paths: {"@opencode-ai/plugin": ["\($np)/@opencode-ai/plugin/dist/index.d.ts"]}
  }
}' > "$config"

tsc --noEmit -p "$config"
