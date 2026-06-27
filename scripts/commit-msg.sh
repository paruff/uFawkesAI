#!/bin/bash
commit_msg_file="$1"
commit_msg=$(head -1 "$commit_msg_file")

if echo "$commit_msg" | grep -qE "^Merge "; then exit 0; fi
if echo "$commit_msg" | grep -qE "^(fixup|squash)!"; then exit 0; fi

pattern="^(feat|fix|docs|style|refactor|test|chore|ci|perf|build|revert)(\(.+\))?: .{1,72}$"

if ! echo "$commit_msg" | grep -qE "$pattern"; then
  echo "ERROR: Commit message does not follow Conventional Commits format."
  echo "Expected: type(scope): description (max 72 chars)"
  exit 1
fi
