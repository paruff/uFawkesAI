# Security Policy

## Supported Versions

| Version             | Supported |
| ------------------- | --------- |
| Latest release (see [Releases](https://github.com/paruff/uFawkesAI/releases/latest)) and `main` | ✅ |
| Older releases      | ❌        |

## Reporting a Vulnerability

Please report suspected vulnerabilities privately:

1. Use **GitHub Security Advisories** (`Security` tab → `Report a vulnerability`) for this repository.
2. Include:
   - A clear description of the issue
   - Steps to reproduce
   - Impact assessment
   - Any suggested remediation
3. **Do not** open public GitHub issues for unpatched vulnerabilities.

## Response SLA

- **Initial acknowledgement:** within **2 business days**
- **Triage decision:** within **5 business days**
- **Status updates:** at least every **7 days** until resolution

Severity targets after triage:

- **Critical/High:** remediation plan or mitigation within **7 days**
- **Medium/Low:** addressed in the next planned maintenance cycle

## Verify the signed image

Every `ghcr.io/paruff/fawkes-space` digest is signed keyless from this repository's CI (GitHub OIDC) and ships an SBOM
and provenance. Verify with cosign v3 or later (v2 reports "no signatures found"):

```bash
cosign verify ghcr.io/paruff/fawkes-space@<digest> \
  --certificate-identity-regexp '^https://github.com/paruff/uFawkesAI/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com
```

## Repository protections

Secret scanning, push protection, Dependabot and the dependency-review workflow are on for this repository.
