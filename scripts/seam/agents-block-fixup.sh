#!/usr/bin/env bash
# scripts/seam/agents-block-fixup.sh <AGENTS.md>
#
# The engine (@morsadev/sdlc) writes a sentence into the ai-sdlc block that names
# researcher, simplifier and spec-reviewer; the repo allows four agents and
# setup.sh deletes those three files, so the sentence points at nothing. This
# rewrites it in place. Used by setup.sh (after sync) and check-sdlc-block-drift.sh
# (on the synced copy) so both agree. Idempotent; a no-op when the engine's
# sentence is absent (shortcut: exact-text match, fails loudly via the drift
# check if an engine upgrade rewords it).
set -euo pipefail

file="${1:?usage: $0 <AGENTS.md>}"
# shellcheck disable=SC2016 # backticks are literal text of the sentence, not command substitution
old='For clean-context reviews (verifier, spec-reviewer, simplifier, researcher), use `.agents/agents/<name>.md`.'
# shellcheck disable=SC2016 # backticks are literal text of the sentence, not command substitution
new='For a clean-context review, use `.agents/agents/verifier.md`.'

sed -i.fixup "/<!-- ai-sdlc:start/,/<!-- ai-sdlc:end -->/ s|${old}|${new}|" "$file"
rm -f "${file}.fixup"
