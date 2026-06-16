---
name: test
description: "Write failing tests before implementation (TDD). Use when creating test suites that validate specification requirements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Test (TDD)

> **Load trigger:** `"load test skill"` 
> **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Write failing tests before implementation (TDD).

## Responsibilities

- Write failing tests based on specification
- Create test suites for acceptance criteria
- Define test patterns and fixtures
- Ensure tests are viable and meaningful
- Follow TDD protocol: test → refactor → implement

## TDD Protocol

```
1. test: add failing tests for [feature]   <-- CI fails here intentionally
2. feat: implement [feature] to pass tests
3. refactor: clean up [feature] if needed
```

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `spec` | Consumes specification and acceptance criteria |

## Inputs

- `specification.md` (from spec)
- `acceptance-criteria.md` (from spec)
- Existing test patterns

## Outputs

- Test files
- `test-report.md`

## Test Writing Rules

### Test Quality

- [ ] Tests are deterministic
- [ ] Tests are independent
- [ ] Tests are readable
- [ ] Tests have meaningful names

### Coverage Priority

1. Error paths (highest priority)
2. Branches
3. Integration boundaries
4. Happy path (lowest priority)

### Test Patterns

- [ ] Arrange-Act-Assert pattern
- [ ] Descriptive test names
- [ ] One assertion per test (when possible)
- [ ] No test interdependencies

### Testability

- [ ] Functions are pure where possible
- [ ] Dependencies are injectable
- [ ] I/O is abstracted
- [ ] Complex logic is broken down

## Language-Specific Examples

### TypeScript/Jest Pattern

```typescript
// tests/services/auth.test.ts
import { signIn } from "../src/services/auth";
import { mockFirebaseAuth } from "./mocks/firebase";

describe("signIn", () => {
  it("returns user object on valid credentials", async () => {
    mockFirebaseAuth.mockResolvedValueOnce({
      uid: "user-123",
      email: "test@test.com",
    });
    const result = await signIn("test@test.com", "valid-password");
    expect(result.uid).toBe("user-123");
  });

  it("throws AuthError when credentials are invalid", async () => {
    mockFirebaseAuth.mockRejectedValueOnce(new Error("auth/wrong-password"));
    await expect(signIn("test@test.com", "wrong")).rejects.toThrow(
      "auth/wrong-password",
    );
  });

  it("throws AuthError when email is malformed", async () => {
    await expect(signIn("not-an-email", "password")).rejects.toThrow();
  });
});
```

### Python/pytest Pattern

```python
# tests/test_auth.py
import pytest
from unittest.mock import patch, MagicMock
from src.services.auth import sign_in, AuthError

def test_sign_in_returns_user_on_valid_credentials():
    with patch('src.services.auth.firebase_auth') as mock_auth:
        mock_auth.sign_in_with_password.return_value = {'uid': 'user-123'}
        result = sign_in('test@test.com', 'valid-password')
        assert result['uid'] == 'user-123'

def test_sign_in_raises_on_invalid_credentials():
    with patch('src.services.auth.firebase_auth') as mock_auth:
        mock_auth.sign_in_with_password.side_effect = Exception('INVALID_PASSWORD')
        with pytest.raises(AuthError):
            sign_in('test@test.com', 'wrong')
```

### Go Pattern

```go
// services/auth_test.go
package services

import (
    "testing"
    "errors"
)

func TestSignIn_ValidCredentials_ReturnsUser(t *testing.T) {
    mockAuth := &MockAuthProvider{
        SignInFunc: func(email, password string) (*User, error) {
            return &User{UID: "user-123"}, nil
        },
    }
    svc := NewAuthService(mockAuth)
    user, err := svc.SignIn("test@test.com", "valid-password")
    if err != nil { t.Fatalf("unexpected error: %v", err) }
    if user.UID != "user-123" { t.Errorf("expected user-123, got %s", user.UID) }
}
```

## Mock Boundary Rule

Mock at the I/O boundary only:

- ✅ Mock HTTP client, database driver, filesystem, external SDK
- ❌ Mock internal service functions (tests implementation, not behavior)
- ❌ Mock the thing you are testing

## Output Format

```json
{
  "skill": "test",
  "status": "pass | fail",
  "tests_written": [
    {
      "name": "should reject invalid email",
      "file": "auth.test.ts",
      "type": "error-path",
      "expected": "throws ValidationError"
    }
  ],
  "coverage_targets": {
    "error_paths": 100,
    "branches": 80,
    "integration": 60,
    "happy_path": 40
  }
}
```

## Success Criteria

- All acceptance criteria have corresponding tests
- Tests are failing (as intended in TDD)
- Tests are viable and meaningful
- Test patterns are consistent
