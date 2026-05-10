# Security Review Skill

## When to activate
When reviewing a PR for security issues, auditing a service function, adding authentication
or authorization logic, handling user input, writing to a database, or evaluating any
dependency addition.

## Pre-commit security checklist

Before every commit, verify:

- [ ] No secrets, API keys, or credentials in code or comments
- [ ] No `console.log` statements that could leak sensitive data to production logs
- [ ] All user inputs are validated (type, length, range) before use or storage
- [ ] All database operations are scoped to the authenticated `userId`
- [ ] Error messages returned to clients do not expose internal stack traces or schema details
- [ ] No `any` type in catch blocks — use typed error handling
- [ ] `auth.currentUser` is checked before any data operation

## Secrets detection

Patterns to check manually (or use gitleaks in CI):

```
# High-risk patterns
/[A-Za-z0-9+/]{40,}={0,2}/   # base64-encoded secrets
/(sk|pk|api|token|secret|key)[-_]?[A-Za-z0-9]{16,}/i  # common secret formats
/AKIA[0-9A-Z]{16}/             # AWS access key IDs
/ghp_[0-9a-zA-Z]{36}/          # GitHub personal access tokens
/xox[baprs]-[0-9a-zA-Z-]{10,}/ # Slack tokens
```

Run gitleaks if available:
```bash
gitleaks detect --source . --verbose
```

## Dependency vulnerability check

```bash
# npm projects
npm audit --audit-level=high

# Check a specific package before adding it
npm audit --package-lock-only
```

If vulnerabilities are found at HIGH or CRITICAL severity: do not merge. Open a
follow-up issue with label `security`.

## Container scan (if Dockerfile exists)

```bash
# Using trivy (install: https://aquasecurity.github.io/trivy)
trivy image --severity HIGH,CRITICAL $(docker build -q .)
```

## OWASP Top 10 quick-check prompts for code review

When reviewing code, ask:

1. **Injection** — Is any user input concatenated into queries, commands, or HTML without sanitisation?
2. **Broken Auth** — Is `auth.currentUser` checked before every data operation? Are sessions invalidated on logout?
3. **Sensitive Data Exposure** — Is PII or financial data logged, cached, or returned in error messages?
4. **Security Misconfiguration** — Are default credentials removed? Is debug mode disabled in production?
5. **Vulnerable Dependencies** — Does `npm audit` report HIGH/CRITICAL issues?
6. **Insecure Direct Object References** — Can a user access another user's data by changing an ID?
7. **Broken Access Control** — Are all write operations restricted to the resource owner?
8. **XSS** — Is user-controlled content rendered without escaping in HTML contexts?
9. **Insecure Deserialization** — Is untrusted JSON/data parsed without schema validation?
10. **Insufficient Logging** — Are authentication failures and access-control violations logged?

## Severity levels

| Severity | Action |
|---|---|
| CRITICAL | Block merge. Fix before any other work. Notify PM immediately. |
| HIGH | Block merge. Fix in this PR or open a tracked follow-up issue. |
| MEDIUM | Flag in PR review comment. Fix within two sprints. |
| LOW | Note in PR. Fix opportunistically. |

## Connecting to uFawkesSec

If uFawkesSec is running, submit findings via the security event endpoint:
```
POST http://localhost:4317/v1/security-events
Content-Type: application/json

{ "severity": "HIGH", "rule": "unscoped-db-write", "file": "src/services/foo.ts", "line": 42 }
```
