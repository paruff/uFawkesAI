---
name: unit-contract-testing
description: "Validate internal API contracts between OBS and PIPE modules. Use when validating function signatures, return types, invariants, preconditions, postconditions, or type-level contracts."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Unit Contract Testing

> **Load trigger:** `"load unit-contract-testing skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Validate internal API contracts between OBS and PIPE modules.

## Responsibilities

- Validate function signatures
- Validate return types
- Validate invariants and preconditions
- Validate postconditions
- Validate type-level contracts

## Inputs

- Type definitions
- Contract tests

## Outputs

- `contract-report.json`

## Contract Categories

| Category | Validation | Tool |
|----------|-----------|------|
| Function signatures | Parameter types | TypeScript compiler |
| Return types | Output types | TypeScript compiler |
| Preconditions | Input validation | Zod / io-ts |
| Postconditions | Output validation | Zod / io-ts |
| Type-level | Type narrowing | tsd |

## Contract Test Example

```typescript
// Function signature contract
function parseVersion(input: string): Version {
  // Contract: input must be string, output must be Version
}

// Zod schema contract
const VersionSchema = z.object({
  major: z.number().int().nonnegative(),
  minor: z.number().int().nonnegative(),
  patch: z.number().int().nonnegative(),
});

// Type test
type _Test = Expect<Equal<ReturnType<typeof parseVersion>, Version>>;
```

## Validation Rules

- [ ] All function signatures correct
- [ ] All return types match
- [ ] All invariants enforced
- [ ] No contract drift
- [ ] Type-level guarantees validated

## Output Format

```json
{
  "skill": "unit-contract-testing",
  "status": "pass | fail",
  "contracts_tested": 40,
  "signature_validations": 30,
  "invariant_validations": 10,
  "type_tests": 5,
  "contract_drift": 0
}
```

## Success Criteria

- No contract drift
- All invariants enforced
- All type-level guarantees validated
