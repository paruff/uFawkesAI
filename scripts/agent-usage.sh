#!/usr/bin/env bash
# scripts/agent-usage.sh — prints an `Agent-Tokens:` commit trailer with the
# token usage an AI agent session actually recorded, so CI can report agent
# cost per PR (scripts/emit-dora-event.sh sums these trailers).
#
# Reads Claude Code session transcripts (~/.claude/projects/<project>/*.jsonl).
# Each API response is logged once per content block, so usage is
# de-duplicated by message id before summing. Report-only.
#
# Usage:
#   scripts/agent-usage.sh [--session <file.jsonl>] [--since <ISO-8601>]
#     default session: the most recently written transcript for this repo
#     --since: count only messages at/after this UTC timestamp, e.g.
#              2026-09-27T10:00:00Z (the branch start); must end in Z
#
# Append the output to a commit message, e.g.:
#   git commit -m "feat: x" -m "$(scripts/agent-usage.sh --since 2026-09-27T10:00:00Z)"

set -euo pipefail
cd "$(dirname "$0")/.."

session=""
since="1970-01-01T00:00:00Z"
while [ $# -gt 0 ]; do
  case "$1" in
    --session) session="$2"; shift 2 ;;
    --since) since="$2"; shift 2 ;;
    *) echo "unknown argument: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$session" ]; then
  project_dir="${HOME}/.claude/projects/$(pwd | sed 's|[/.]|-|g')"
  # Transcript names are UUIDs; ls -t is the portable newest-first (no GNU find -printf).
  # shellcheck disable=SC2012
  session="$(ls -t "$project_dir"/*.jsonl 2>/dev/null | head -1 || true)"
  [ -n "$session" ] || { echo "no Claude Code transcript found in ${project_dir}" >&2; exit 1; }
fi

jq -rs --arg since "$since" '
  [ .[] | select(.message.usage != null and (.timestamp // "") >= $since) ]
  | group_by(.message.id) | map(last)
  | {
      input:       (map(.message.usage.input_tokens // 0) | add // 0),
      output:      (map(.message.usage.output_tokens // 0) | add // 0),
      cache_read:  (map(.message.usage.cache_read_input_tokens // 0) | add // 0),
      cache_write: (map(.message.usage.cache_creation_input_tokens // 0) | add // 0),
      model:       ((map(.message.model // empty) | unique | join("+")) // "")
    }
  | "Agent-Tokens: input=\(.input) output=\(.output) cache_read=\(.cache_read) cache_write=\(.cache_write) model=\(if .model == "" then "unknown" else .model end) source=claude-code"
' "$session"
