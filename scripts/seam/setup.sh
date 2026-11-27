#!/usr/bin/env bash
# Refresh the SDLC engine's generated files, then enforce this repo's overrides (spec R4.1).
# Idempotent: a second run changes nothing. The engine's `init` is one-time and not run here;
# .sdlc/config.json is committed. Generated skills and agents are committed too (R4.2) and never hand-edited.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

ENGINE=node_modules/@morsadev/sdlc/dist/sdlc.mjs
[[ -f $ENGINE ]] || {
  echo "engine morsadev not installed: run npm ci" >&2
  exit 2
}
[[ -f .sdlc/config.json ]] || {
  echo ".sdlc/config.json missing: restore it from git" >&2
  exit 2
}

# Our agents win on a name collision: sync keeps an existing file unless forced, and we never force.
agents_copy="$(mktemp)"
trap 'rm -f "$agents_copy"' EXIT
ours_before="$(git hash-object .agents/agents/verifier.md)"

# agents-md only: the claude target would write `sdlc hook` entries into .claude/settings.json (a second gate engine)
cfg="$(jq -S '.agents = ["agents-md"] | .gates_self_approval = false' .sdlc/config.json)"
[[ "$cfg" == "$(jq -S . .sdlc/config.json)" ]] || printf '%s\n' "$cfg" > .sdlc/config.json

cp AGENTS.md "$agents_copy"
node "$ENGINE" sync > /dev/null
# the engine's sentence names agents this repo deletes (see the script)
bash scripts/seam/agents-block-fixup.sh AGENTS.md
# sync writes the block without the blank lines markdownlint adds; keep the committed copy when only those differ
block() { sed -n '/<!-- ai-sdlc:start/,/<!-- ai-sdlc:end -->/p' "$1"; }
if diff -qB <(block "$agents_copy") <(block AGENTS.md) > /dev/null; then cp "$agents_copy" AGENTS.md; fi

# the repo allows four agents (scripts/check-agents.sh); drop the engine's extras, our verifier is untouched
rm -f .agents/agents/researcher.md .agents/agents/simplifier.md .agents/agents/spec-reviewer.md
# core.hooksPath stays unset so the pre-commit framework keeps all its hook types
if [[ "$(git config --get core.hooksPath || true)" == ".sdlc/git-hooks" ]]; then git config --unset core.hooksPath; fi
# CLAUDE.md is a symlink to AGENTS.md
[[ "$(readlink CLAUDE.md || true)" == "AGENTS.md" ]] || { rm -f CLAUDE.md && ln -s AGENTS.md CLAUDE.md; }
# one physical copy of the skills
[[ "$(readlink .claude/skills || true)" == "../.agents/skills" ]] || {
  echo ".claude/skills must symlink to ../.agents/skills" >&2
  exit 1
}
# the engine's harness hooks stay out of the Claude Code settings
if grep -q 'sdlc hook' .claude/settings.json; then
  jq 'del(.hooks[][] | select(.hooks[]?.command | tostring | test("sdlc hook")))' .claude/settings.json > .claude/settings.json.tmp
  mv .claude/settings.json.tmp .claude/settings.json
fi
[[ "$(git hash-object .agents/agents/verifier.md)" == "$ours_before" ]] || {
  echo ".agents/agents/verifier.md was overwritten by sync" >&2
  exit 1
}

echo "sdlc engine $(jq -r .version node_modules/@morsadev/sdlc/package.json): setup ok"
