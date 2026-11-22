#!/usr/bin/env bash
# shellcheck disable=SC2015 # `cond && expect ok || expect bad` is the intended assertion pattern, expect never fails
# Self-test for the agent commit identity check in check-harness-parity.sh (seam R6a, Review Focus 3).
set -uo pipefail
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE
root="$(cd "$(dirname "$0")/.." && pwd)"
fails=0
expect() { if [[ "$2" == ok ]]; then echo "  PASS  $1"; else
  echo "  FAIL  $1 ($3)"
  fails=$((fails + 1))
fi; }

t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
mkdir -p "$t/scripts" "$t/.claude" "$t/.opencode/plugins"
cp "$root/scripts/check-harness-parity.sh" "$t/scripts/"
fresh() {
  cp "$root/.claude/settings.json" "$t/.claude/"
  cp "$root/.opencode/plugins/ai-sdlc-hooks.ts" "$t/.opencode/plugins/"
  cp "$root/.sdlc-engine.json" "$t/"
}
run() {
  (cd "$t" && bash scripts/check-harness-parity.sh --identity > out.txt 2>&1)
  rc=$?
}

fresh
run
[[ $rc -eq 0 ]] && expect identities_match ok || expect identities_match bad "rc=$rc $(cat "$t/out.txt")"

fresh
sed -i.bak 's/^const BOT_EMAIL = ".*";/const BOT_EMAIL = "other@users.noreply.github.com";/' "$t/.opencode/plugins/ai-sdlc-hooks.ts"
run
[[ $rc -eq 1 ]] && expect emails_differ ok || expect emails_differ bad "rc=$rc"

fresh
jq 'del(.env.GIT_AUTHOR_EMAIL)' "$t/.claude/settings.json" > "$t/s.json" && mv "$t/s.json" "$t/.claude/settings.json"
run
[[ $rc -eq 1 ]] && expect claude_missing ok || expect claude_missing bad "rc=$rc"

fresh
sed -i.bak '/^const BOT_EMAIL/d' "$t/.opencode/plugins/ai-sdlc-hooks.ts"
run
[[ $rc -eq 1 ]] && expect opencode_missing ok || expect opencode_missing bad "rc=$rc"

fresh
jq '.botIdentities = []' "$t/.sdlc-engine.json" > "$t/s.json" && mv "$t/s.json" "$t/.sdlc-engine.json"
run
[[ $rc -eq 1 ]] && expect not_in_bot_list ok || expect not_in_bot_list bad "rc=$rc"

# Review Focus 3: the bot env lives in harness config only, so a plain shell is the human
ident="$(env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL git -C "$root" var GIT_AUTHOR_IDENT)"
bot="$(jq -r '.botIdentities[]' "$root/.sdlc-engine.json")"
[[ "$ident" != *"$bot"* ]] && expect plain_shell_not_bot ok || expect plain_shell_not_bot bad "$ident"

[[ $fails -eq 0 ]] && echo "✅ harness identity self-test passed" || {
  echo "$fails failure(s)"
  exit 1
}
