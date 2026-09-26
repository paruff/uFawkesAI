# Testing Rules

- Run the project's verification gates before every commit: typecheck, lint, tests, and build.
- Add or update tests for every behavioral change.
- Prefer deterministic unit tests first; add integration/e2e only when required by scope.
- Coverage expectation: new/changed logic must be covered by meaningful assertions.
- Never remove failing tests to make CI pass; fix root causes.
