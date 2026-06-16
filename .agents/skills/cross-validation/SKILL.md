---
name: cross-validation
model: claude-sonnet-4-6
license: MIT
compatibility: "uFawkesAI"
metadata:
  author: paruff
  suite: uFawkesAI
---

# Cross-Validation Skill

The cross-validation skill enables the cross-validation agent to validate consistency between agent outputs and their sources. It provides the rules registry and validation runner that check pairwise consistency across the agent pipeline.

## Skill Purpose

This skill implements cross-validation of the uFawkesAI agent pipeline. It validates that:

1. **Spec ↔ Build Consistency** — All spec requirements are addressed in build output
2. **Spec ↔ Test Coverage** — All spec acceptance criteria have corresponding tests
3. **Design ↔ Build Compliance** — Build follows architecture decisions from design
4. **Test ↔ Test-Execution Viability** — All tests are viable and passing in test-execution

Note: The review agent now consolidates review, build-review, and security capabilities. Review findings are validated as part of the build process.

## How to Load

Load this skill when you need to validate cross-agent consistency:

```
Load `.agents/skills/cross-validation/SKILL.md`
```

## Validation Rules Registry

The skill uses `.agents/registry/cross-validation.yaml` as the rules registry. This file defines:

- Which agent pairs need validation
- What specific consistency checks to perform
- How to extract and compare information from agent reports

## Validation Runner

The skill provides `.agents/assertions/cross-validation-runner.sh` which:

1. Reads the cross-validation rules from the registry
2. Extracts relevant sections from agent reports (spec, design, build, test, test-execution, review)
3. Applies each validation rule
4. Generates a unified cross-validation report
5. Returns PASS if all rules pass, FAIL otherwise

## Usage Examples

### Loading the Skill

```
Load `.agents/skills/cross-validation/SKILL.md`
```

### Running Validation

```
bash .agents/assertions/cross-validation-runner.sh \
  --spec-report path/to/spec-report.md \
  --design-report path/to/design-report.md \
  --build-report path/to/build-report.md \
  --test-report path/to/test-report.md \
  --test-execution-report path/to/test-execution-report.md \
  --review-report path/to/review-report.md
```

### Expected Output

The runner produces a unified cross-validation report with:

- Summary of all validation rules
- Pass/fail status for each rule
- Detailed findings for failed rules
- Overall decision (PASS or FAIL)
- Recommendations for fixing failures

## Integration

The cross-validation skill is loaded by the cross-validation agent, which runs after the parallel block of `test-execution` and `review` and before `delivery`.

## Validation Rules Details

Each rule in the registry defines:

- `source_agent` — The agent whose output is the source of truth
- `target_agent` — The agent whose output needs validation against the source
- `validation_type` — The type of consistency check to perform
- `description` — Human-readable description of the rule
- `required_sections` — Sections that must be present in both reports
- `comparison_logic` — How to compare the sections (keyword matching, pattern matching, etc.)

## Example Rule

```yaml
- rule_id: spec-build-consistency
  source_agent: spec
  target_agent: build
  validation_type: requirement_coverage
  description: "All spec requirements must be addressed in build output"
  required_sections:
    - "Functional Requirements"
    - "Acceptance Criteria"
  comparison_logic:
    extract_keywords: true
    require_all_keywords: true
    source_field: "requirement"
    target_field: "task"
```

## Error Handling

If any validation rule fails:

1. The runner reports the specific inconsistencies
2. The cross-validation agent blocks the pipeline
3. The cross-validation agent generates recommendations for fixing the issues
4. The human operator reviews and decides next steps

## Testing the Skill

To test the cross-validation skill:

1. Create sample agent reports (spec, design, build, test, test-execution, review)
2. Run the cross-validation runner with these reports
3. Verify that the runner correctly identifies consistency issues
4. Verify that the runner correctly identifies consistency passes

## Dependencies

This skill depends on:

- `.agents/registry/cross-validation.yaml` — Rules registry
- `.agents/assertions/cross-validation-runner.sh` — Validation runner
- `.agents/assertions/minimal-report.yaml` — Output contract

## Skill Lifecycle

This skill is in the `active` status and is part of Phase 5 (Cross-Validation) of the uFawkesAI agent pipeline. It is a platform-engineering skill that supports the entire agent ecosystem.