#!/usr/bin/env bash
# cross-validation-runner.sh — Phase 5 cross-agent validation
# Validates pairwise consistency between agent outputs
# Usage: bash .agents/assertions/cross-validation-runner.sh <report.md> <agent-name>
# Outputs: .agents/skills/platform-engineering/skill-dependency-graph/cross-validation-report.json

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
RULES_REGISTRY="${REPO_ROOT}/.agents/registry/cross-validation.yaml"
OUT_DIR="${REPO_ROOT}/.agents/skills/platform-engineering/skill-dependency-graph"

if [ ! -f "${RULES_REGISTRY}" ]; then
  echo "FAIL: Cross-validation rules registry not found at ${RULES_REGISTRY}"
  echo "Run Phase 5 setup first."
  exit 1
fi

mkdir -p "${OUT_DIR}"

echo "Running cross-validation against agent reports..."
echo ""

python3 - "${RULES_REGISTRY}" "${OUT_DIR}" <<'PYTHON_SCRIPT'
import json, os, sys, yaml, re
from pathlib import Path

rules_registry_path = sys.argv[1]
out_dir = sys.argv[2]

with open(rules_registry_path) as f:
    rules = yaml.safe_load(f).get("rules", [])

# Parse command line arguments for report paths
# Expected format: --spec-report path/to/spec-report.md --design-report path/to/design-report.md ...
args = sys.argv[3:]
report_paths = {}
for i in range(0, len(args), 2):
    key = args[i].replace('--', '').replace('-report', '')
    report_paths[key] = args[i + 1]

# Load agent reports
agent_reports = {}
for agent, path in report_paths.items():
    if os.path.exists(path):
        with open(path) as f:
            content = f.read()
            agent_reports[agent] = content
    else:
        print(f"  ⚠ WARNING: Report not found at {path}")
        agent_reports[agent] = ""

# Helper function to extract section content from a markdown report
def extract_section(report, section_title):
    """Extract content from a section in a markdown report."""
    lines = report.split('\n')
    in_section = False
    section_content = []
    section_level = 0
    
    for line in lines:
        # Check if this line starts a section with the given title
        stripped = line.strip()
        if stripped.startswith('#' * (section_level + 1)) and stripped.lstrip('#').strip() == section_title:
            in_section = True
            section_level = len(line) - len(line.lstrip('#'))
            continue
        
        # If we're in a section and encounter a new section at same or higher level, stop
        if in_section and stripped and (line.startswith('#' * (section_level + 1)) or line.startswith('#' * section_level)):
            break
        
        if in_section:
            section_content.append(line)
    
    return '\n'.join(section_content).strip()

# Helper function to extract keywords from section content
def extract_keywords(content, field_name):
    """Extract keywords from section content based on field name."""
    # Remove markdown formatting
    text = re.sub(r'[*_`]', '', content)
    
    # Extract field values based on field name
    if field_name == 'requirement':
        # Look for patterns like "REQ-1:", "REQ-1: Implement", etc.
        pattern = r'(?:^|\n)(?:REQ-|req-)\d+:\s*([^\n]+)'
    elif field_name == 'criterion':
        # Look for patterns like "CRIT-1:", "CRIT-1: When", etc.
        pattern = r'(?:^|\n)(?:CRIT-|crit-)\d+:\s*([^\n]+)'
    elif field_name == 'decision':
        # Look for patterns like "DECISION:", "DECISION: Implement", etc.
        pattern = r'(?:^|\n)DECISION:\s*([^\n]+)'
    elif field_name == 'finding':
        # Look for patterns like "FINDING:", "FINDING: Add", etc.
        pattern = r'(?:^|\n)FINDING:\s*([^\n]+)'
    elif field_name == 'task':
        # Look for patterns like "TASK:", "TASK: Implement", etc.
        pattern = r'(?:^|\n)TASK:\s*([^\n]+)'
    elif field_name == 'resolution':
        # Look for patterns like "RESOLUTION:", "RESOLUTION: Fixed", etc.
        pattern = r'(?:^|\n)RESOLUTION:\s*([^\n]+)'
    elif field_name == 'implementation':
        # Look for patterns like "IMPLEMENTATION:", "IMPLEMENTATION: Added", etc.
        pattern = r'(?:^|\n)IMPLEMENTATION:\s*([^\n]+)'
    elif field_name == 'remediation':
        # Look for patterns like "REMEDIATION:", "REMEDIATION: Fixed", etc.
        pattern = r'(?:^|\n)REMEDIATION:\s*([^\n]+)'
    elif field_name == 'test':
        # Look for patterns like "TEST:", "TEST: test_function", etc.
        pattern = r'(?:^|\n)TEST:\s*([^\n]+)'
    elif field_name == 'result':
        # Look for patterns like "RESULT:", "RESULT: PASSED", etc.
        pattern = r'(?:^|\n)RESULT:\s*([^\n]+)'
    else:
        # Generic pattern for any field
        pattern = r'(?:^|\n)' + field_name + r':\s*([^\n]+)'
    
    matches = re.findall(pattern, text, re.IGNORECASE)
    return [m.strip() for m in matches if m.strip()]

# Helper function to calculate text similarity
def calculate_similarity(text1, text2):
    """Calculate similarity between two texts using simple word overlap."""
    if not text1 or not text2:
        return 0.0
    
    # Normalize and split into words
    words1 = set(re.findall(r'\b\w+\b', text1.lower()))
    words2 = set(re.findall(r'\b\w+\b', text2.lower()))
    
    if not words1 or not words2:
        return 0.0
    
    # Calculate Jaccard similarity
    intersection = words1.intersection(words2)
    union = words1.union(words2)
    
    return len(intersection) / len(union)

# Run validation for each rule
validation_results = []
all_passed = True

for rule in rules:
    rule_id = rule.get('rule_id', '')
    source_agent = rule.get('source_agent', '')
    target_agent = rule.get('target_agent', '')
    description = rule.get('description', '')
    required_sections = rule.get('required_sections', [])
    comparison_logic = rule.get('comparison_logic', {})
    
    # Check if both reports exist
    if source_agent not in agent_reports or target_agent not in agent_reports:
        print(f"  ⚠ WARNING: Missing reports for rule {rule_id} (source: {source_agent}, target: {target_agent})")
        validation_results.append({
            "rule_id": rule_id,
            "source_agent": source_agent,
            "target_agent": target_agent,
            "description": description,
            "passed": False,
            "reason": "Missing report files"
        })
        all_passed = False
        continue
    
    source_report = agent_reports[source_agent]
    target_report = agent_reports[target_agent]
    
    # Check if required sections exist
    missing_sections = []
    for section in required_sections:
        source_section = extract_section(source_report, section)
        target_section = extract_section(target_report, section)
        
        if not source_section:
            missing_sections.append(f"{section} (source)")
        if not target_section:
            missing_sections.append(f"{section} (target)")
    
    if missing_sections:
        print(f"  ⚠ WARNING: Rule {rule_id} missing required sections: {', '.join(missing_sections)}")
        validation_results.append({
            "rule_id": rule_id,
            "source_agent": source_agent,
            "target_agent": target_agent,
            "description": description,
            "passed": False,
            "reason": f"Missing required sections: {', '.join(missing_sections)}"
        })
        all_passed = False
        continue
    
    # Extract keywords from source and target
    source_keywords = []
    target_keywords = []
    
    for section in required_sections:
        source_section = extract_section(source_report, section)
        target_section = extract_section(target_report, section)
        
        source_field = comparison_logic.get('source_field', '')
        target_field = comparison_logic.get('target_field', '')
        
        source_keywords.extend(extract_keywords(source_section, source_field))
        target_keywords.extend(extract_keywords(target_section, target_field))
    
    # Check if all source keywords have a match in target
    matched_keywords = []
    unmatched_keywords = []
    
    similarity_threshold = comparison_logic.get('similarity_threshold', 0.7)
    
    for source_kw in source_keywords:
        matched = False
        for target_kw in target_keywords:
            similarity = calculate_similarity(source_kw, target_kw)
            if similarity >= similarity_threshold:
                matched_keywords.append({
                    "source": source_kw,
                    "target": target_kw,
                    "similarity": similarity
                })
                matched = True
                break
        
        if not matched:
            unmatched_keywords.append(source_kw)
    
    if unmatched_keywords:
        print(f"  ⚠ WARNING: Rule {rule_id} failed - {len(unmatched_keywords)} source items not found in target")
        validation_results.append({
            "rule_id": rule_id,
            "source_agent": source_agent,
            "target_agent": target_agent,
            "description": description,
            "passed": False,
            "reason": f"{len(unmatched_keywords)} source items not found in target",
            "unmatched_keywords": unmatched_keywords,
            "matched_keywords": matched_keywords
        })
        all_passed = False
    else:
        print(f"  ✅ Rule {rule_id} passed")
        validation_results.append({
            "rule_id": rule_id,
            "source_agent": source_agent,
            "target_agent": target_agent,
            "description": description,
            "passed": True,
            "matched_keywords": matched_keywords
        })

# Generate cross-validation report
cross_validation_report = {
    "skill": "cross-validation",
    "generated_at": "",
    "validation_rules": len(rules),
    "passed_rules": sum(1 for r in validation_results if r.get("passed", False)),
    "failed_rules": sum(1 for r in validation_results if not r.get("passed", False)),
    "results": validation_results,
    "decision": "PASS" if all_passed else "FAIL"
}

# Write cross-validation report
report_path = os.path.join(out_dir, "cross-validation-report.json")
with open(report_path, "w") as f:
    json.dump(cross_validation_report, f, indent=2)

print(f"  Wrote {report_path} ({cross_validation_report['passed_rules']}/{cross_validation_report['validation_rules']} rules passed)")

if all_passed:
    print(f"  ✅ Cross-validation PASSED - pipeline can proceed to pipe/obs")
else:
    print(f"  ❌ Cross-validation FAILED - pipeline blocked")
    print(f"  Recommendations:")
    for result in validation_results:
        if not result.get("passed", False):
            print(f"    - Fix {result['rule_id']}: {result.get('reason', 'Validation failed')}")

PYTHON_SCRIPT

# Exit with appropriate code
if [ "$all_passed" = "true" ]; then
  exit 0
else
  exit 1
fi