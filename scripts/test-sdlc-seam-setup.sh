#!/usr/bin/env bash
# shellcheck disable=SC2015 # `cond && expect ok || expect bad` is the intended assertion pattern, expect never fails
# Self-test for scripts/seam/setup.sh in a throwaway copy of the repo (spec R4.1, Review Focus 4).
set -uo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE
here="$(cd "$(dirname "$0")" && pwd)"
root="$(dirname "$here")"
fails=0
expect() { if [[ "$2" == ok ]]; then echo "  PASS  $1"; else
  echo "  FAIL  $1 ($3)"
  fails=$((fails + 1))
fi; }

t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
(cd "$root" && git ls-files -co --exclude-standard -z | xargs -0 tar -cf -) | tar -xf - -C "$t"
ln -s "$root/node_modules" "$t/node_modules"
cd "$t" || exit 1
export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_NOSYSTEM=1 GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@x GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@x
git init -q -b main && git add -A && git commit -q -m base
verifier="$(git hash-object .agents/agents/verifier.md)"

# make the tree dirty the way a raw `sdlc init`/`sync` would, then let setup.sh put it right
git config core.hooksPath .sdlc/git-hooks
rm CLAUDE.md && cp AGENTS.md CLAUDE.md
jq '.hooks.Stop += [{"hooks":[{"type":"command","command":"x/.sdlc/bin/sdlc hook stop --agent claude"}]}]' .claude/settings.json > s.tmp && mv s.tmp .claude/settings.json

bash scripts/seam/setup.sh > /dev/null 2> err.txt && expect setup_runs ok || expect setup_runs bad "$(cat err.txt)"
[[ -L CLAUDE.md && "$(readlink CLAUDE.md)" == AGENTS.md ]] && expect claude_md_symlink ok || expect claude_md_symlink bad "not a symlink"
[[ "$(git hash-object .agents/agents/verifier.md)" == "$verifier" ]] && expect verifier_is_ours ok || expect verifier_is_ours bad "changed"
grep -q 'sdlc hook' .claude/settings.json && expect no_engine_hooks bad "found" || expect no_engine_hooks ok
[[ -z "$(git config core.hooksPath)" ]] && expect hookspath_unset ok || expect hookspath_unset bad "set"
[[ "$(find .agents/agents -name '*.md' | wc -l | tr -d ' ')" == 4 ]] && expect four_agents ok || expect four_agents bad "extra agents"
n="$(find . -path ./node_modules -prune -o -name SKILL.md -path '*sdlc-plan*' -print | wc -l | tr -d ' ')"
[[ "$n" == 1 ]] && expect one_skills_copy ok || expect one_skills_copy bad "n=$n"
[[ "$(jq -r .gates_self_approval .sdlc/config.json)" == false ]] && expect self_approval_off ok || expect self_approval_off bad "on"

git add -A && git commit -q -m setup
bash scripts/seam/setup.sh > /dev/null 2>&1
[[ -z "$(git status --porcelain)" ]] && expect second_run_is_clean ok || expect second_run_is_clean bad "$(git status --porcelain | head -3)"

[[ $fails -eq 0 ]] && echo "✅ sdlc seam setup self-test passed" || {
  echo "$fails failure(s)"
  exit 1
}
