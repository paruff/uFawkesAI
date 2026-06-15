#!/usr/bin/env bash
# pre-commit-agent.sh — Validate agent reports before committing
# Install: ln -sf ../../.agents/hooks/pre-commit-agent.sh .git/hooks/pre-commit
# This hook checks any agent report files (*-report.md, *-report.json)
# in the staged changes against their output contracts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ASSERTION_RUNNER="${REPO_ROOT}/.agents/assertions/assertion-runner.sh"

# Only run if assertion runner exists
if [ ! -f "${ASSERTION_RUNNER}" ]; then
  exit 0
fi

# Find staged report files
STAGED_REPORTS=$(git diff --cached --name-only --diff-filter=ACM | grep -E '.*-report\.md$|.*-report\.json$' || true)

if [ -z "${STAGED_REPORTS}" ]; then
  # No report files staged — nothing to check
  exit 0
fi

TOTAL_FAILS=0

while IFS= read -r report_path; do
  [ -z "${report_path}" ] && continue

  full_path="${REPO_ROOT}/${report_path}"

  if [ ! -f "${full_path}" ]; then
    continue
  fi

  # Determine agent name from filename prefix
  agent_name=""
  case "$(basename "${report_path}")" in
    security-review-report.md|security-report.md) agent_name="security" ;;
    build-review-report.md) agent_name="build-review" ;;
    build-report.md) agent_name="build" ;;
    test-report.md) agent_name="test-execution" ;;
    review-report.md) agent_name="review" ;;
    design-report.md) agent_name="design" ;;
    spec-report.md) agent_name="spec" ;;
    *) 
      # Try prefix match
      base="$(basename "${report_path}")"
      agent_name="${base%-report*}"
      ;;
  esac

  if [ -z "${agent_name}" ]; then
    echo "pre-commit-agent: Cannot determine agent for ${report_path}, skipping"
    continue
  fi

  echo "pre-commit-agent: Checking ${report_path} against ${agent_name} contract..."

  if bash "${ASSERTION_RUNNER}" "${full_path}" "${agent_name}"; then
    echo "  OK"
  else
    echo "  FAILED"
    TOTAL_FAILS=$((TOTAL_FAILS + 1))
  fi
done <<< "${STAGED_REPORTS}"

if [ "${TOTAL_FAILS}" -gt 0 ]; then
  echo ""
  echo "pre-commit-agent: ${TOTAL_FAILS} report(s) failed contract validation."
  echo "Fix the reports before committing, or skip with --no-verify."
  exit 1
fi
