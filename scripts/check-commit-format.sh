#!/bin/bash
# Check commit message format for all commits in the current branch/PR
# This runs at pre-commit stage so it catches format issues before CI

set -euo pipefail

# Get the list of commits to check
if [ -n "${GITHUB_PR_NUMBER:-}" ]; then
  # In CI with PR number
  commits=$(gh api repos/paruff/uFawkesAI/pulls/"$GITHUB_PR_NUMBER"/commits --jq '.[] | .sha[0:7] + " " + (.commit.message | split("\n")[0])' 2> /dev/null || echo "")
elif [ -n "${CI_COMMIT_SHA:-}" ]; then
  # In CI without PR number, check last 10 commits
  commits=$(git log --oneline -10)
else
  # Local development - check commits since main
  commits=$(git log --oneline main..HEAD 2> /dev/null || git log --oneline -10)
fi

pattern="^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?: .{1,72}$"
merge_pattern="^Merge "
fixup_pattern="^(fixup|squash)!"

failures=0

while IFS= read -r line; do
  [ -z "$line" ] && continue
  sha="${line%% *}"
  msg="${line#* }"

  if echo "$msg" | grep -qE "$merge_pattern"; then
    continue
  fi
  if echo "$msg" | grep -qE "$fixup_pattern"; then
    continue
  fi

  if ! echo "$msg" | grep -qE "$pattern"; then
    echo "❌ Commit $sha: \"$msg\""
    failures=$((failures + 1))
  fi
done <<< "$commits"

if [ $failures -gt 0 ]; then
  echo "❌ $failures commit(s) don't follow Conventional Commits format."
  echo "Expected: type(scope): description (max 72 chars)"
  echo "Types: feat, fix, docs, style, refactor, test, chore, ci, perf, build, revert"
  exit 1
else
  commit_count=$(echo "$commits" | grep -c '^' || echo 0)
  [ "$commit_count" -gt 0 ] && echo "✅ All $commit_count commit(s) follow Conventional Commits format"
  exit 0
fi
