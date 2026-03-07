# Prompt Library — [PROJECT NAME]

> DORA 2025 (AI Cap 2): "Prompt engineering is rising as a core developer skill.
> The modern engineer's value is in prompt engineering, solution architecture,
> and validating AI outputs — not just writing code."
>
> This library is versioned. When a prompt produces repeated bad output, update it
> and add a changelog entry. The library is a living document.

---

## How to Use This Library

1. Find the task category
2. Copy the prompt template
3. Replace `{{PLACEHOLDERS}}`
4. Paste into Copilot Chat with the specified context files open
5. If output is wrong: see "Red flags" and re-prompt or escalate

---

## Category: Feature Implementation (TDD)

### New Utility Function

**Context to open:** `src/types/index.ts`, `tests/unit/utils/`, your failing test

```
Implement the function {{FUNCTION_NAME}} to make this failing test pass.

Architecture rules (from .github/copilot-instructions.md):
1. This function goes in src/utils/ — it must be a pure function (no side effects)
2. All types from src/types/index.ts — no inline type definitions
3. Return type must be explicit

The failing test:
{{PASTE_TEST}}

Read src/types/index.ts before writing. Do not import from src/services/ or src/hooks/.
```

**Expected output:** The function implementation that makes the test pass, plus JSDoc.

**Red flags:** 
- Function imports from `services/` or `hooks/` → reject, re-prompt with rule 1
- Missing return type → reject, ask for explicit return type
- `any` type in catch block → reject, ask for typed error handling

---

### New Service Method

**Context to open:** `src/types/index.ts`, `src/services/[relevant service].ts`, your failing test

```
Implement the service method {{METHOD_NAME}} to make this failing test pass.

Architecture rules:
1. This goes in src/services/{{SERVICE_FILE}} — it may call the Firebase SDK directly
2. It must scope all Firestore operations to the authenticated userId
3. It must never surface raw SDK error messages — map errors to typed errors
4. All input validation goes here (validate before writing to DB)

Read src/types/index.ts and docs/API_SURFACE.md first.

The failing test:
{{PASTE_TEST}}
```

**Red flags:**
- No userId scoping on Firestore operations → SECURITY issue, escalate to @security-agent
- Raw error message returned → reject, ask for error mapping

---

## Category: Code Review

### Pre-Review PR Scan

**Context:** Open the diff

```
Review this PR for the {{PROJECT_NAME}} project.
Read .github/copilot-instructions.md and docs/ARCHITECTURE.md first.

Report findings in five categories:
1. ARCHITECTURE: Layer boundary violations (screens/services/utils/hooks)
2. SECURITY: Unscoped DB operations, exposed error messages, unvalidated inputs, secrets
3. TYPES: `any` types, missing return types, unsafe assertions
4. TESTS: Untested logic, tests that don't cover failure cases
5. DUPLICATION: Logic that duplicates existing utils or services

For each finding: file name, line number, description, corrected code.
If nothing found in a category: write "✅ None found."

End with: "Ready for human review? YES / NO — [reason if NO]"
```

---

## Category: Debugging

### Firebase Permission Denied

```
Explain why this Firestore operation throws permission-denied.

Stack context: Firebase Firestore, Firebase Auth ({{SDK_VERSION}})
Current auth state: {{describe — e.g. "user is authenticated, userId = X"}}
Firestore rules: {{paste relevant rule}}
Operation failing: {{paste the service function call}}

Check: Is the userId being passed correctly? Is the collection path correct?
Does the rule require request.auth.uid to match a path parameter?
Provide the corrected code.
```

### Unexpected Re-render / useEffect Firing

```
Explain why this useEffect is firing more than expected.

Component: {{paste the component}}
What I expect: fires once on mount
What I observe: {{describe the actual behaviour}}

Check: Are the dependencies in the dependency array stable references or new objects on each render?
Is any dependency a function defined inline in the component body?
Provide the corrected dependency array with explanation.
```

---

## Category: Security Review

### Service Function Security Audit

**Context to open:** The function + `src/types/index.ts` + security rules section of `.github/copilot-instructions.md`

```
Security review for this service function.

Apply these rules:
1. All Firestore reads/writes must be scoped to the authenticated userId
2. No raw SDK error messages returned — map to typed errors
3. All numeric inputs must be validated as finite positive numbers before writes
4. All string inputs must have length constraints checked
5. auth.currentUser must be checked before any data operation
6. No `any` in catch blocks

Function:
{{PASTE_FUNCTION}}

For each issue: severity (CRITICAL / HIGH / MEDIUM), line number, risk description, corrected code.
```

---

## Category: Architecture

### "Where does this code belong?"

```
Should this code go in screens/, components/, hooks/, services/, or utils/?

Project layer rules:
- screens/ → navigation targets; UI composition only; no data calls
- components/ → reusable UI primitives; no navigation; no business logic  
- hooks/ → React state; may call services; no Firebase SDK directly
- services/ → all Firestore/Firebase operations
- utils/ → pure functions; stateless; no imports from other layers

The code in question:
{{PASTE_CODE}}

Answer: which layer, which file (existing or new), and why.
```

---

## Category: Documentation

### Generate API Surface Entry

**Context:** Open the function file

```
Generate an API_SURFACE.md entry for this exported function.

Use exactly this format:
### [module].[functionName](params)
**Purpose:** [one sentence]
**Parameters:** [param: type — description for each]
**Returns:** [type — description]
**Side effects:** [what external state changes, or "None (pure function)"]
**Error cases:** [what throws and when]
**Example:**
\`\`\`typescript
[one-line usage example]
\`\`\`

Function:
{{PASTE_FUNCTION}}
```

---

## Changelog

| Date | Change | Reason |
|---|---|------|
| [PLACEHOLDER] | Initial library created | AIOPS-04 |
