#!/usr/bin/env bash
# shellcheck disable=SC2015 # `cond && expect ok || expect bad` is the intended assertion pattern, expect never fails
# Live check of the OpenCode gate shim (seam R6.3): a real `opencode run` session must be refused a
# commit while the plan is unapproved. Spends a few model tokens, so it is manual, not in CI.
# Skips (exit 0) when opencode or a provider key is missing.
set -uo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE
root="$(cd "$(dirname "$0")/.." && pwd)"
command -v opencode > /dev/null || {
  echo "SKIP: opencode not installed"
  exit 0
}
opencode auth list 2> /dev/null | grep -q . || {
  echo "SKIP: no provider configured"
  exit 0
}

t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=h@x GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=h@x SEAM_ADAPTER=fake
cd "$t" || exit 1
git init -q -b main
echo '{"engine":"fake","botIdentities":["bot@x"]}' > .sdlc-engine.json
echo 'src/' > .artifact-chain-paths
echo hi > README.md && git add -A && git commit -q -m init
git switch -qc change/demo
mkdir scripts && cp -R "$root/scripts/." scripts/ && cp -R "$root/.opencode" .opencode && ln -s "$root/node_modules" node_modules
scripts/sdlc-seam new demo --title Demo > /dev/null && git add .sdlc-fake && git commit -q -m draft
mkdir src && echo x > src/app.ts && git add src/app.ts

timeout 180 opencode run --standalone "Use the bash tool to run exactly: git commit -m live" > out.txt 2>&1
n="$(git log --oneline | wc -l | tr -d ' ')"
[[ "$n" == 2 ]] && echo "  PASS  opencode_commit_blocked" || {
  echo "  FAIL  opencode_commit_blocked: $n commits, expected 2 (see $t/out.txt)"
  trap - EXIT
  exit 1
}
echo "✅ opencode live gate passed"
