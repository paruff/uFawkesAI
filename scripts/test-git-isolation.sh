#!/usr/bin/env bash
# scripts/test-git-isolation.sh — no test may write to the real git index.
#
# Git exports GIT_INDEX_FILE (and friends) to the hooks it runs. A test that
# builds a throwaway repo with `git init` and `git add` inherits it, so its
# `git add -A` rewrites the OUTER repository's index with the throwaway repo's
# files: every real file then shows as staged for deletion, and the commit that
# triggered the hook would delete the repository. This happened to a real commit
# (scripts/test-check-placeholders.sh); only a stray file failing shellcheck
# stopped it. A test that uses git must unset GIT_INDEX_FILE, GIT_DIR and
# GIT_WORK_TREE first, as scripts/test-artifact-chain.sh does.
#
# This runs every test that calls `git init` or `git add` as git would run it
# from a hook (GIT_INDEX_FILE pointing at an outer repo's index) and fails if
# the outer index changed.
#
# Exit: 0 every test left the outer index alone, 1 one did not.
set -uo pipefail
# This test builds a repo itself, so it needs the same isolation it checks for:
# its own setup must not touch the real index when git runs it from a hook.
unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE GIT_PREFIX GIT_COMMON_DIR
cd "$(dirname "$0")/.." || exit 1
root="$PWD"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fails=0
checked=0

# The "real" repository whose index must survive.
git init -q "$tmp/outer"
(
  cd "$tmp/outer" || exit 1
  echo keep > keep.txt
  git add keep.txt
  git -c user.email=t@example.invalid -c user.name=t commit -qm init
) > /dev/null || {
  echo "test-git-isolation: cannot build the outer repo" >&2
  exit 1
}
before="$(git -C "$tmp/outer" ls-files)"

for t in "$root"/scripts/test-*.sh; do
  [ "$(basename "$t")" = "test-git-isolation.sh" ] && continue
  grep -q -E 'git (-C [^ ]+ )?(init|add)' "$t" || continue
  checked=$((checked + 1))
  (cd "$tmp" && GIT_INDEX_FILE="$tmp/outer/.git/index" bash "$t") > /dev/null 2>&1
  after="$(git -C "$tmp/outer" ls-files)"
  if [ "$after" = "$before" ]; then
    echo "  ok   $(basename "$t") leaves the outer index alone"
  else
    fails=$((fails + 1))
    echo "  FAIL $(basename "$t") rewrote the outer index: unset GIT_INDEX_FILE GIT_DIR GIT_WORK_TREE at its top"
    # Put the outer index back so one leak doesn't mask the next test's result.
    (cd "$tmp/outer" && git reset -q)
  fi
done

if [ "$checked" -eq 0 ]; then
  echo "test-git-isolation: found no test that uses git: the check is not looking at anything" >&2
  exit 1
fi
if [ "$fails" -gt 0 ]; then
  echo "FAILED: $fails of $checked tests write to the real git index" >&2
  exit 1
fi
echo "ALL $checked git-using tests leave the real index alone"
