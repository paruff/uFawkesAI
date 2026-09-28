#!/usr/bin/env bash
# pre-commit-agent.sh — Validate agent reports against their output contracts
#
# Run by pre-commit as a local hook (see .pre-commit-config.yaml, repo: local).
# Do NOT symlink this into .git/hooks/pre-commit — that slot belongs to the
# pre-commit framework, and a symlink there is silently never invoked.
#
# Contract keys live in .agents/assertions/minimal-report.yaml under `agents:`.
# They are report kinds, not agent names: under the current taxonomy the owning
# agent is @planner, @builder, @verifier, or @operator.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
ASSERTION_RUNNER="${REPO_ROOT}/.agents/assertions/assertion-runner.sh"
CONTRACT_FILE="${REPO_ROOT}/.agents/assertions/minimal-report.yaml"

if [ ! -f "${ASSERTION_RUNNER}" ] || [ ! -f "${CONTRACT_FILE}" ]; then
  exit 0
fi

# Report filename -> contract key in minimal-report.yaml.
# Every key here MUST exist in the contract file; assertion-runner.sh now fails
# loudly on an unknown key so a typo cannot degrade into a silent pass.
get_contract_key() {
  local report_filename="$1"
  case "$report_filename" in
    build-report.md) echo "build" ;;
    design-report.md) echo "design" ;;
    review-report.md) echo "review" ;;
    spec-report.md) echo "spec" ;;
    test-report.md) echo "test" ;;
    test-execution-report.md) echo "test-execution" ;;
    cross-validation-report.md) echo "cross-validation" ;;
    *) echo "" ;; # Unknown report type
  esac
}

STAGED_REPORTS=$(git diff --cached --name-only --diff-filter=ACM | grep -E '(^|/)[a-z-]+-report\.md$' || true)

if [ -z "${STAGED_REPORTS}" ]; then
  exit 0
fi

TOTAL_FAILS=0
UNCONTRACTED=()

while IFS= read -r report_path; do
  [ -z "${report_path}" ] && continue
  full_path="${REPO_ROOT}/${report_path}"
  [ -f "${full_path}" ] || continue

  base="$(basename "${report_path}")"
  contract="$(get_contract_key "${base}")"

  if [ -z "${contract}" ]; then
    # Say so out loud rather than pretending it was checked.
    UNCONTRACTED+=("${base}")
    continue
  fi

  echo "pre-commit-agent: validating ${base} against the '${contract}' contract..."
  if bash "${ASSERTION_RUNNER}" "${full_path}" "${contract}" > /dev/null 2>&1; then
    echo "  OK"
  else
    echo "  FAILED — ${contract} contract not satisfied"
    bash "${ASSERTION_RUNNER}" "${full_path}" "${contract}" 2>&1 | sed 's/^/    /'
    TOTAL_FAILS=$((TOTAL_FAILS + 1))
  fi
done <<< "${STAGED_REPORTS}"

if [ "${#UNCONTRACTED[@]}" -gt 0 ]; then
  echo "pre-commit-agent: no contract defined, not validated: ${UNCONTRACTED[*]}"
  echo "  Add a contract in ${CONTRACT_FILE#"${REPO_ROOT}/"} if these should be gated."
fi

if [ "${TOTAL_FAILS}" -gt 0 ]; then
  echo ""
  echo "pre-commit-agent: ${TOTAL_FAILS} report(s) failed contract validation."
  echo "Fix the reports before committing, or re-run with --no-verify."
  exit 1
fi
