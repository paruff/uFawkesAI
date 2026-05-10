# Test Generation Skill

## When to activate
When writing new tests, improving coverage, generating tests for an existing function,
setting up a new test file, or following TDD for a new feature.

## TDD pattern — non-negotiable commit sequence

**Write the failing test first. Always.**

```
1. Write the failing test
2. git commit -m "test(scope): failing test for [what]"   ← commit while RED
3. Write the implementation
4. git commit -m "feat(scope): implement [what]"           ← commit when GREEN
5. Refactor if needed
6. git commit -m "refactor(scope): clean up [what]"        ← optional
```

If you are asked to write tests for already-implemented code: write the tests,
but add a note in the PR that TDD discipline was not followed.

## Test naming convention

```typescript
describe('what the unit does', () => {
  it('when [condition], should [expected result]', () => {
    // Arrange
    // Act
    // Assert
  });
});
```

**Examples:**
```typescript
describe('calculateReworkRate', () => {
  it('when no PRs exist, should return zero', () => { ... });
  it('when all PRs are fixes, should return 100', () => { ... });
  it('when rework PRs exceed 20%, should flag for process review', () => { ... });
});
```

## Coverage targets (from AGENTS.md Section 6)

- **`src/utils/`** — 80% line coverage minimum
- **`src/services/`** — 80% line coverage minimum

Run coverage check (note: `npm run test:coverage` is a placeholder in this template —
replace it with your actual test runner command once the test infrastructure is set up):
```bash
npm run test:coverage
```

## Prompt templates for test generation

### Generate unit tests for a utility function

```
Generate unit tests for this function following the project's TDD conventions.

Function:
{{PASTE_FUNCTION}}

Requirements:
1. Use describe/it with the naming convention: when [condition], should [result]
2. Cover: happy path, invalid input, edge cases (null, empty, boundary values)
3. Tests go in tests/unit/utils/{{FUNCTION_FILE_NAME}}.test.ts
4. Do not mock unless the function calls external services
5. Use the types from src/types/index.ts — no inline type definitions

Return only the test file content.
```

### Generate unit tests for a service method

```
Generate unit tests for this service method. The method calls Firebase Firestore.

Method:
{{PASTE_METHOD}}

Requirements:
1. Mock the Firebase SDK — do not make real network calls
2. Cover: authenticated user success path, unauthenticated user rejection, Firestore error handling
3. Tests go in tests/unit/services/{{SERVICE_FILE_NAME}}.test.ts
4. Verify that all Firestore operations are scoped to the userId
5. Verify that errors are mapped to typed errors, not raw SDK messages

Return only the test file content.
```

### Generate integration test

```
Generate an integration test for this feature end-to-end.

Feature: {{DESCRIBE_FEATURE}}
Entry point: {{COMPONENT_OR_HOOK}}
External dependencies: {{LIST — Firebase, API calls, etc.}}

Requirements:
1. Use a test double (emulator / mock server) — no real external calls
2. Cover the happy path and at least one failure scenario
3. Tests go in tests/integration/
4. Arrange → Act → Assert structure

Return only the test file content.
```

## Anti-patterns — what NOT to test

- ❌ **Implementation details** — do not assert on private methods, internal state, or internal call counts
- ❌ **Framework code** — do not test that React renders a div or that useState works
- ❌ **Trivial accessors** — do not test a getter that returns a field with no logic
- ❌ **Mock return values** — a test that only asserts a mock was called proves nothing about behaviour
- ❌ **Type assertions** — TypeScript already checks types; do not write tests that only verify a type

## Test file structure

```
tests/
  unit/
    utils/          # Pure function tests — no mocks needed
    services/       # Service method tests — mock the Firebase SDK
    hooks/          # Hook tests — use renderHook from @testing-library/react
  integration/      # End-to-end feature tests with emulators or mock servers
  e2e/              # Full UI tests with Playwright
```
