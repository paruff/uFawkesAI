#!/usr/bin/env bash
# scripts/test-dora-vocabulary-locale.sh — regression test: check-dora-vocabulary.sh
# must give the same verdict under a byte-oriented (C) locale as under UTF-8.
# Its regexes used a bracket class holding the multibyte em-dash, which
# BSD/macOS sed and grep split per byte when LC_ALL is unset or C.
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

fail=0
for loc in C en_US.UTF-8; do
  if LC_ALL="$loc" bash scripts/check-dora-vocabulary.sh > /dev/null 2>&1; then
    echo "  ok   check-dora-vocabulary under LC_ALL=$loc"
  else
    echo "  FAIL check-dora-vocabulary under LC_ALL=$loc"
    fail=1
  fi
done
[ "$fail" -eq 0 ] && echo "ALL 2 CHECKS PASSED"
exit "$fail"
