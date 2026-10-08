#!/usr/bin/env bash
# scripts/hooks/tsc-plugin.sh — the tsc-plugin pre-commit hook (#192).
#
# Type-checks .opencode/plugins under the repo's strict tsconfig.json with no
# npm install: pre-commit's node environment holds typescript, @types/node and
# @opencode-ai/plugin (NODE_PATH), and a generated config extending the repo's
# points the compiler at them. CI's 🔷 TypeScript job runs the repo config itself.

set -euo pipefail

: "${NODE_PATH:?run through pre-commit (language: node), which sets NODE_PATH}"
# POSIX mktemp: use -t prefix (works on both GNU and BSD)
config="$(mktemp -t tsc-plugin.XXXXXX)"
trap 'rm -f "$config"' EXIT

# The plugin package exposes its types only through "exports", which "paths"
# doesn't follow, so map the import to its root .d.ts.
# Don't extend root tsconfig.json (it excludes .opencode); create standalone config.
jq -n --arg root "$PWD" --arg np "$NODE_PATH" '{
  compilerOptions: {
    target: "ES2022",
    lib: ["ES2022"],
    module: "ESNext",
    moduleResolution: "bundler",
    types: ["node"],
    noEmit: true,
    strict: true,
    noUncheckedIndexedAccess: true,
    noImplicitOverride: true,
    noFallthroughCasesInSwitch: true,
    forceConsistentCasingInFileNames: true,
    skipLibCheck: true,
    allowJs: false,
    typeRoots: ["\($np)/@types"],
    paths: {"@opencode-ai/plugin": ["\($np)/@opencode-ai/plugin/dist/index.d.ts"]}
  },
  include: ["\($root)/.opencode/plugins/**/*.ts"]
}' > "$config"

tsc --noEmit -p "$config"
