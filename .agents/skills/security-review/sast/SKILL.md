---
name: sast
description: "Analyze source code for security vulnerabilities. Use when reviewing code changes for injection risks, insecure patterns, or unsafe APIs."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Static Application Security Testing (SAST)

> **Load trigger:** `"load sast skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Analyze source code for security vulnerabilities through static analysis.

## Responsibilities

- Run static analysis tools against source code
- Detect insecure coding patterns
- Detect injection risks (SQL, command, LDAP, XSS)
- Detect unsafe API usage
- Detect hardcoded credentials and sensitive data exposure

## Inputs

- Source code files
- Configuration files
- Build definitions

## Validation Rules

### Injection Risks

- [ ] No SQL queries built with string concatenation
- [ ] No command execution with unsanitized input
- [ ] No LDAP/NoSQL injection vectors
- [ ] No template injection risks

### Authentication & Session

- [ ] No hardcoded credentials or API keys
- [ ] Passwords hashed with bcrypt/argon2, not MD5/SHA1
- [ ] Session tokens generated with sufficient entropy
- [ ] No weak random number generators for security contexts

### Data Exposure

- [ ] No sensitive data in error messages
- [ ] No PII in log statements
- [ ] No sensitive data in URLs or query parameters
- [ ] Stack traces not exposed to clients

### Unsafe Patterns

- [ ] No `eval()` or `Function()` with dynamic input
- [ ] No `innerHTML` or `dangerouslySetInnerHTML` with user content
- [ ] No deserialization of untrusted data without validation
- [ ] No use of deprecated or insecure cryptographic algorithms

### Input Validation

- [ ] All external inputs validated and sanitized
- [ ] Output encoding applied for context (HTML, JS, SQL)
- [ ] File upload validation (type, size, content)

## Tools

- Language-specific linters (ESLint security plugins, Bandit, Gosec)
- Semgrep with security rulesets
- CodeQL
- SonarQube security rules

## Output Format

```json
{
  "skill": "sast",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "file": "<file path>",
      "line": "<line number>",
      "issue": "Description of the vulnerability",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- No critical or high-severity code vulnerabilities
- No unsafe API usage patterns
- Input validation applied consistently
