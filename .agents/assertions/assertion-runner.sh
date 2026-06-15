#!/usr/bin/env bash
# assertion-runner.sh — Validate an agent report against its output contract
# Usage: bash .agents/assertions/assertion-runner.sh <report.md> <agent-name>
#   <report.md>   Path to the agent's markdown report file
#   <agent-name>  Agent identifier (matches key in minimal-report.yaml)
#
# Returns 0 if all assertions pass, 1 with details on failure.
set -euo pipefail

if [ $# -ne 2 ]; then
  echo "Usage: assertion-runner.sh <report.md> <agent-name>"
  exit 1
fi

REPORT_FILE="$1"
AGENT_NAME="$2"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTRACT_FILE="${SCRIPT_DIR}/minimal-report.yaml"

if [ ! -f "${REPORT_FILE}" ]; then
  echo "FAIL: Report file not found: ${REPORT_FILE}"
  exit 1
fi

if [ ! -f "${CONTRACT_FILE}" ]; then
  echo "FAIL: Contract file not found: ${CONTRACT_FILE}"
  exit 1
fi

echo ""
echo "═══════════════════════════════════════════"
echo "  Assertion Runner — ${AGENT_NAME}"
echo "  Report: ${REPORT_FILE}"
echo "═══════════════════════════════════════════"

# Delegate to Python for all validation (handles whitespace in strings correctly)
python3 - "${REPORT_FILE}" "${AGENT_NAME}" "${CONTRACT_FILE}" <<'PYTHON_SCRIPT'
import json
import re
import sys
import yaml

report_path = sys.argv[1]
agent_name = sys.argv[2]
contract_path = sys.argv[3]

with open(contract_path) as f:
    all_contracts = yaml.safe_load(f)

contract = all_contracts.get("agents", {}).get(agent_name, {})
if not contract:
    print("No contract defined for agent '{}' — nothing to validate.".format(agent_name))
    sys.exit(0)

with open(report_path) as f:
    content = f.read()

pass_count = 0
fail_count = 0

def p(msg):
    global pass_count
    pass_count += 1
    print("  PASS: {}".format(msg))

def f(msg):
    global fail_count
    fail_count += 1
    print("  FAIL: {}".format(msg))

print()
print("--- Required Sections ---")
for section in contract.get("required_sections", []):
    if re.search(re.escape(section), content, re.IGNORECASE):
        p("Section '{}' found".format(section))
    else:
        f("Required section '{}' not found".format(section))

print()
print("--- Required Fields ---")
field_checks = {
    "decision": lambda c: bool(re.search(r"\*\*Decision:\*\*|PASS|FAIL|BLOCKED", c, re.IGNORECASE)),
    "status": lambda c: bool(re.search(r"\*\*Status:\*\*", c, re.IGNORECASE)),
    "risk_level": lambda c: bool(re.search(r"\*\*Risk level:\*\*", c, re.IGNORECASE)),
    "size_decision": lambda c: bool(re.search(r"\*\*Size:\*\*|PASS|EXCEEDS LIMIT", c, re.IGNORECASE)),
    "biggest_gap": lambda c: bool(re.search(r"biggest gap", c, re.IGNORECASE)),
    "total_estimated_lines": lambda c: bool(re.search(r"total estimated lines|estimated lines", c, re.IGNORECASE)),
}
for field, required in contract.get("required_fields", {}).items():
    if not required:
        continue
    check = field_checks.get(field)
    if check:
        if check(content):
            p("Field '{}' found".format(field))
        else:
            f("Required field '{}' not found".format(field))
    else:
        p("Field '{}' (not checked automatically)".format(field))

print()
print("--- Forbidden Patterns ---")
for pattern in contract.get("forbidden_patterns", []):
    try:
        if re.search(pattern, content, re.IGNORECASE):
            f("Forbidden pattern '{}' found in report".format(pattern))
        else:
            p("Forbidden pattern '{}' not found".format(pattern))
    except re.error:
        p("Pattern '{}' (invalid regex, skipped)".format(pattern))

print()
print("--- Required Patterns ---")
for pattern in contract.get("required_patterns", []):
    try:
        if re.search(pattern, content, re.IGNORECASE):
            p("Required pattern '{}' found".format(pattern))
        else:
            f("Required pattern '{}' not found".format(pattern))
    except re.error:
        f("Pattern '{}' (invalid regex)".format(pattern))

print()
print("--- Findings Validation ---")
findings_when = contract.get("findings_required_when", "never")
if findings_when != "never":
    decision_found = None
    if findings_when == "FAIL" and re.search(r"\*\*Decision:\*\*.*FAIL", content):
        decision_found = "FAIL"
    elif findings_when == "REQUEST_CHANGES" and re.search(r"REQUEST CHANGES", content):
        decision_found = "REQUEST_CHANGES"
    elif findings_when == "CRITICAL" and re.search(r"^### CRITICAL|^## CRITICAL", content, re.MULTILINE):
        decision_found = "CRITICAL"

    if decision_found:
        finding_count = len(re.findall(r"^\| (CRITICAL|HIGH|MEDIUM|LOW)", content, re.MULTILINE))
        if finding_count > 0:
            p("{} findings match {} decision".format(finding_count, decision_found))
        else:
            f("Decision is {} but no findings found".format(decision_found))

print()
print("--- Severity Classification ---")
if contract.get("severity_classification", False):
    findings_with_severity = re.findall(r"^\| (CRITICAL|HIGH|MEDIUM|LOW)", content, re.MULTILINE)
    found_sevs = set(findings_with_severity)
    if found_sevs:
        p("Findings use severity levels: {}".format(", ".join(sorted(found_sevs))))
    else:
        f("severity_classification required but no severity levels found in findings")

print()
print("═══════════════════════════════════════════")
print("  Results: {} passed, {} failed".format(pass_count, fail_count))
print("═══════════════════════════════════════════")
print()

sys.exit(0 if fail_count == 0 else 1)
PYTHON_SCRIPT
