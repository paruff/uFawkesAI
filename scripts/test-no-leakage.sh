#!/usr/bin/env bash
# Self-test for check-no-leakage.sh: each leak goes red, clean text stays green.
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
d="$(mktemp -d)"; trap 'rm -rf "$d"' EXIT
chk() { # chk <expect-exit> <text>
  printf '%s\n' "$2" > "$d/f.txt"
  rc=0; bash scripts/check-no-leakage.sh "$d/f.txt" > /dev/null 2>&1 || rc=$?
  [ "$rc" -eq "$1" ] || { echo "FAIL: expected exit $1, got $rc for: $2"; exit 1; }
}
chk 1 "host 192.168.1.194 down"
chk 1 "path /Users/someone/projects"
chk 1 "server at 10.0.3.7"
chk 0 "version 10.0.3 and 1.192.168 are fine"
chk 0 "image user /home/dev/work"
echo "✅ check-no-leakage self-test passed"
