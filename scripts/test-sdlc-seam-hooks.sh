#!/usr/bin/env bash
# shellcheck disable=SC2015 # `cond && expect ok || expect bad` is the intended assertion pattern, expect never fails
# Self-test for scripts/hooks/seam-gate.sh, the git pre-commit and pre-push gate (seam R6.1).
set -uo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE CI # CI=true makes the gate defer; only the one case below sets it
root="$(cd "$(dirname "$0")/.." && pwd)"
hook="$root/scripts/hooks/seam-gate.sh"
fails=0
expect() { if [[ "$2" == ok ]]; then echo "  PASS  $1"; else
  echo "  FAIL  $1 ($3)"
  fails=$((fails + 1))
fi; }

export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=h@x GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=h@x
export SEAM_ADAPTER=fake
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
cd "$t" || exit 1
git init -q -b main
echo '{"engine":"fake","botIdentities":["bot@x"]}' > .sdlc-engine.json
echo 'src/' > .artifact-chain-paths
echo hi > README.md
git add -A && git commit -q -m init
git switch -qc change/demo
"$root/scripts/sdlc-seam" new demo --title Demo > /dev/null && git add -A && git commit -q -m draft

run() {
  out="$(bash "$hook" "$@" 2>&1)"
  rc=$?
}

mkdir src && echo x > src/app.ts && git add src
run commit
[[ $rc -ne 0 && "$out" == *demo/plan* ]] && expect commit_blocked_names_plan ok || expect commit_blocked_names_plan bad "rc=$rc out=$out"

git reset -q src && rm -rf src && echo more >> README.md && git add README.md
run commit
[[ $rc -eq 0 ]] && expect docs_only_commit_passes ok || expect docs_only_commit_passes bad "rc=$rc out=$out"
git commit -q -m docs

mkdir src && echo x > src/app.ts && git add -A && git commit -q -m feat
run push
[[ $rc -ne 0 && "$out" == *demo/plan* ]] && expect push_blocked ok || expect push_blocked bad "rc=$rc out=$out"

out="$(CI=true bash "$hook" push 2>&1)"
rc=$?
[[ $rc -eq 0 ]] && expect ci_env_defers_to_sdlc_seam_ci ok || expect ci_env_defers_to_sdlc_seam_ci bad "rc=$rc out=$out"

git switch -q main && git switch -qc scratch/none
run push
[[ $rc -eq 0 ]] && expect push_no_code_vs_main ok || expect push_no_code_vs_main bad "rc=$rc out=$out"

git switch -q change/demo
pending="$(git rev-parse HEAD)"
for g in intent spec plan; do
  GIT_AUTHOR_EMAIL=boss@x GIT_COMMITTER_EMAIL=boss@x "$root/scripts/sdlc-seam" approve demo "$g" 2> /dev/null
done
run push
[[ $rc -eq 0 ]] && expect push_passes_when_approved ok || expect push_passes_when_approved bad "rc=$rc out=$out"

# Harness shims (R6.2, R6.3): same verdicts, from the same script. Run inside a copy of the tooling.
git reset -q --hard "$pending" # back to the unapproved plan
mkdir -p scripts && cp -R "$root/scripts/." scripts/
cp -R "$root/.opencode" .opencode
ln -s "$root/node_modules" node_modules
echo y > src/b.ts && git add src/b.ts
run_claude_hook() {
  out="$(printf '{"tool_input":{"command":"%s"}}' "$1" | CLAUDE_PROJECT_DIR="$t" node scripts/hooks/claude-pretooluse-secret-scan.js 2>&1)"
  rc=$?
}
run_claude_hook "git commit -m x"
[[ $rc -eq 2 && "$out" == *"sdlc-seam gate"* ]] && expect claude_blocks_commit ok || expect claude_blocks_commit bad "rc=$rc out=$out"
run_claude_hook "git -C . push"
[[ $rc -eq 2 && "$out" == *"sdlc-seam gate"* ]] && expect claude_blocks_push ok || expect claude_blocks_push bad "rc=$rc out=$out"
run_claude_hook "git commit-tree abc"
[[ $rc -eq 0 ]] && expect claude_ignores_commit_tree ok || expect claude_ignores_commit_tree bad "rc=$rc out=$out"
run_oc_hook() {
  out="$(node --input-type=module -e '
    const { AiSdlcHooks } = await import(process.cwd() + "/.opencode/plugins/ai-sdlc-hooks.ts");
    const h = await AiSdlcHooks({});
    try { await h["tool.execute.before"]({ tool: "bash" }, { args: { command: process.argv[1] } }); console.log("allowed"); }
    catch (e) { console.log("blocked: " + e.message); }' "$1" 2>&1)"
}
run_oc_hook "git commit -m x"
[[ "$out" == *"blocked"*"sdlc-seam gate"* ]] && expect opencode_blocks_commit ok || expect opencode_blocks_commit bad "out=$out"
run_oc_hook "git -C . push"
[[ "$out" == *"blocked"*"sdlc-seam gate"* ]] && expect opencode_blocks_push ok || expect opencode_blocks_push bad "out=$out"
run_oc_hook "git commit-tree abc"
[[ "$out" == *allowed* ]] && expect opencode_ignores_commit_tree ok || expect opencode_ignores_commit_tree bad "out=$out"

[[ $fails -eq 0 ]] && echo "✅ sdlc seam hooks self-test passed" || {
  echo "$fails failure(s)"
  exit 1
}
