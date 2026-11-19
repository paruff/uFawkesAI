#!/usr/bin/env bash
# scripts/test-main-ci-guard.sh — proves main-ci-guard.yml calls uFawkesPipe's
# reusable guard (PI-8) in the mode this repo relies on: judge main's HEAD and
# fall back to the `✅ CI Complete` check run. The decision logic and its cases
# (green/failed/missing/still-running result) are tested in uFawkesPipe,
# tests/unit/test_reusable_main_ci_guard.py.
#
# Needs python3 (PyYAML). Exit: 0 every check held, 1 otherwise.

set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

python3 - << 'PY'
import re, sys, yaml

wf = yaml.safe_load(open(".github/workflows/main-ci-guard.yml"))
job = wf["jobs"]["main-ci-guard"]
inputs = job.get("with", {})
perms = wf.get("permissions", {})
checks = [
    ("calls Pipe's reusable-main-ci-guard pinned by 40-hex SHA",
     bool(re.match(r"^paruff/uFawkesPipe/\.github/workflows/reusable-main-ci-guard\.yml@[0-9a-f]{40}$", job.get("uses", "")))),
    ("guards the ci-quality.yml workflow", inputs.get("workflow-id") == "ci-quality.yml"),
    ("judges main's HEAD", inputs.get("judge-head") is True),
    ("falls back to the ✅ CI Complete check run", inputs.get("fallback-check-name") == "✅ CI Complete"),
    ("grants checks: read for the fallback", perms.get("checks") == "read"),
    ("runs on pull_request and merge_group", {"pull_request", "merge_group"} <= set(wf.get(True, wf.get("on", {})))),
]
bad = [name for name, ok in checks if not ok]
for name, ok in checks:
    print(("  ok   " if ok else "  FAIL ") + name)
if bad:
    print(f"FAILED {len(bad)} check(s)")
    sys.exit(1)
print(f"ALL {len(checks)} CHECKS PASSED")
PY
