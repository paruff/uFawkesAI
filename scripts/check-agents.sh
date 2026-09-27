#!/usr/bin/env bash
# scripts/check-agents.sh — validate the 4 execution-boundary agents.
#
# Why this exists: `dual-harness-smoke.sh` only ever did `test -f` on command
# files. Agent *discovery* was never checked, so `@planner` could be entirely
# undiscoverable and every check would still pass. That is how all four
# agents sat at `mode: primary` — loadable in the TUI, but not dispatchable
# as subagents, which is what an `@agent` mention requires.
#
# This validates statically and deterministically. Live invocation cannot be
# checked here because opencode loads agent config once at startup and does
# not hot-reload it: a newly added agent only becomes dispatchable after the
# harness is restarted. See docs/HARNESS_DISPATCH.md.
#
# Exit 0 = all four agents valid and dispatchable. Exit 1 otherwise.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

EXPECTED=(planner builder verifier operator)
CANONICAL=".agents/agents"
MOUNT=".opencode/agents"
FAIL=0
ok()   { printf '  OK   %s\n' "$1"; }
bad()  { printf '  FAIL %s\n' "$1"; FAIL=1; }

# Frontmatter keys opencode accepts on an agent file. Anything else is routed
# into `options`, which is how a typo silently becomes a no-op setting.
ALLOWED='^(name|model|variant|description|mode|hidden|color|steps|options|permission|disable|temperature|top_p):'
VALID_MODES='^(primary|subagent|all)$'

echo "== Agent dispatch check =="

for agent in "${EXPECTED[@]}"; do
  file="$CANONICAL/$agent.md"
  link="$MOUNT/$agent.md"

  if [[ ! -f "$file" ]]; then
    bad "$agent: canonical file missing ($file)"
    continue
  fi
  ok "$agent: canonical file present"

  # The harness mount must be a symlink into .agents/ so there is one source.
  if [[ ! -L "$link" ]]; then
    bad "$agent: $link is not a symlink (harness would load a separate copy)"
  elif [[ ! -e "$link" ]]; then
    bad "$agent: $link is DANGLING"
  elif [[ "$(realpath "$link")" != "$(realpath "$file")" ]]; then
    bad "$agent: $link points somewhere other than $file"
  else
    ok "$agent: mounted into $MOUNT"
  fi

  # Frontmatter must be delimited and parseable.
  if ! head -1 "$file" | grep -q '^---$'; then
    bad "$agent: no YAML frontmatter"
    continue
  fi
  fm_end="$(awk 'NR>1 && /^---$/{print NR; exit}' "$file")"
  if [[ -z "$fm_end" ]]; then
    bad "$agent: unterminated frontmatter"
    continue
  fi
  ok "$agent: frontmatter delimited (lines 2-$((fm_end - 1)))"

  fm="$(sed -n "2,$((fm_end - 1))p" "$file")"

  # name must match the filename, or dispatch by @name breaks.
  name="$(sed -nE 's/^name:[[:space:]]*["'"'"']?([^"'"'"']*)["'"'"']?[[:space:]]*$/\1/p' <<<"$fm" | head -1)"
  if [[ "$name" == "$agent" ]]; then
    ok "$agent: name matches filename"
  else
    bad "$agent: name is '${name:-<missing>}' but the file is $agent.md"
  fi

  # description is what the model matches on; without it the agent is filtered out.
  if grep -qE '^description:[[:space:]]*"?[^"]' <<<"$fm"; then
    ok "$agent: has a description"
  else
    bad "$agent: no description — the agent will never be surfaced"
  fi

  # mode must be valid, and must permit subagent dispatch for @mentions.
  mode="$(sed -nE 's/^mode:[[:space:]]*//p' <<<"$fm" | head -1)"
  if [[ -z "$mode" ]]; then
    bad "$agent: no mode declared (defaults vary; declare it explicitly)"
  elif ! grep -qE "$VALID_MODES" <<<"$mode"; then
    bad "$agent: invalid mode '$mode' (want primary|subagent|all)"
  elif [[ "$mode" == "primary" ]]; then
    bad "$agent: mode=primary is TUI-only — not dispatchable via @agent. Use 'all'."
  else
    ok "$agent: mode=$mode (dispatchable)"
  fi

  # Unknown frontmatter keys become `options` and do nothing.
  unknown="$(grep -vE "$ALLOWED" <<<"$fm" | grep -E '^[a-zA-Z_][a-zA-Z0-9_-]*:' | sed -E 's/:.*//' | sort -u)"
  if [[ -z "$unknown" ]]; then
    ok "$agent: no unknown frontmatter keys"
  else
    bad "$agent: unknown frontmatter key(s): $(tr '\n' ' ' <<<"$unknown")"
  fi
done

# No retired stage-agent may reappear in either location.
echo "-- retired-agent guard --"
retired='^(docs-agent|design-agent|spec-agent|test-agent|test-execution-agent|review-agent|security-agent|cross-validation-agent|flow-agent|learn-agent|measure-agent|release-agent|discover-agent)$'
for dir in "$CANONICAL" "$MOUNT"; do
  [[ -d "$dir" ]] || continue
  found="$(find "$dir" -maxdepth 1 -name '*.md' -printf '%f\n' 2>/dev/null | sed 's/\.md$//' | grep -E "$retired" || true)"
  if [[ -z "$found" ]]; then
    ok "$dir: no retired stage/flow agents"
  else
    bad "$dir: retired agent(s) present: $(tr '\n' ' ' <<<"$found")"
  fi
done

echo "=========================="
if [[ "$FAIL" -eq 0 ]]; then
  echo "PASS: all ${#EXPECTED[@]} execution-boundary agents are valid and dispatchable."
  echo "NOTE: live invocation needs an opencode restart — agent config is not hot-reloaded."
  exit 0
fi
echo "FAIL: agent dispatch check found problems (see above)"
exit 1
