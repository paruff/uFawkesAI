---
name: security-testing
description: "Detect insecure code patterns, vulnerabilities, and misconfigurations in OBS, PIPE, and Fawkes services. Implements DORA AI Capabilities 1, 4."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: security-testing

> **Load trigger:** "load security-testing skill" > **DORA:** AI Capabilities 1, 4
> **Token cost:** Medium

## Purpose

Detect insecure code patterns, vulnerabilities, and misconfigurations in OBS, PIPE, and Fawkes services. Uses Semgrep, CodeQL, Trivy, and secret detection. Implements DORA AI Capabilities 1, 4.

## When to Use

- Running SAST on code changes
- Scanning container images for vulnerabilities
- Scanning dependencies for CVEs
- Detecting secrets in source code, Git history, container layers

## Sub-skills (now integrated)

### 1. SAST (Semgrep + CodeQL)

### Container Security

# Skill: Container Image Security

> **Load trigger:** `"load container-security skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low

## Purpose

Ensure container images built by PIPE are secure, minimal, and free of vulnerabilities.

## Responsibilities

- Scan container images
- Validate base image security
- Validate OS package vulnerabilities
- Validate image metadata

## Inputs

- Built image

## Outputs

- `container.json`
- `container-vulns.txt`

## Sub-Skills

| Skill                          | Purpose                          |
| ------------------------------ | -------------------------------- |
| `container-security/vuln-scan` | Container vulnerability scanning |
| `container-security/signature` | Image signature verification     |

## Image Requirements

| Requirement | Rule                        |
| ----------- | --------------------------- |
| Base image  | Distroless or minimal       |
| Latest tag  | Not used                    |
| Root user   | Not running as root         |
| Ports       | Only required ports exposed |
| Secrets     | No secrets in image layers  |

**Enforcement: advisory.** Trivy runs in `image-build.yml` and
`image-release.yml` but only appends to the job summary (`|| true`). These
criteria are reported, not enforced.

## Validation Rules

- [ ] No critical vulnerabilities
- [ ] Base image is distroless/minimal
- [ ] Not running as root
- [ ] No secrets in layers
- [ ] Valid signature

## Output Format

```json
{
  "skill": "container-security",
  "status": "pass | fail",
  "image": "my-app:v1.3.0",
  "base_image": "distroless",
  "running_as_root": false,
  "vulnerabilities": {
    "critical": 0,
    "high": 0,
    "medium": 2,
    "low": 5
  },
  "signature_valid": true,
  "issues": []
}
```

## Success Criteria

- No critical vulnerabilities
- Valid signature
- Secure base image

### Dependency Scanning

# Skill: Dependency & Supply Chain Scanning

> **Load trigger:** `"load dependency-scanning skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low

## Purpose

Detect vulnerable dependencies in NPM, Python, Go, and container layers.

## Responsibilities

- Scan NPM dependencies
- Scan Python dependencies
- Scan OS packages in container images
- Validate SBOM contents

## Inputs

- `package.json`
- `requirements.txt`
- `Dockerfile`

## Outputs

- `dependency.json`
- `sbom.json`

## Sub-Skills

| Skill                      | Purpose                      |
| -------------------------- | ---------------------------- |
| `dependency-scanning/npm`  | NPM dependency scanning      |
| `dependency-scanning/sbom` | SBOM generation & validation |

## Scan Targets

| Target                | Tool  | Focus       |
| --------------------- | ----- | ----------- |
| `package-lock.json`   | Trivy | JS/TS CVEs  |
| `requirements.txt`    | Trivy | Python CVEs |
| `go.sum`              | Trivy | Go CVEs     |
| Container OS packages | Trivy | OS CVEs     |

## Severity Thresholds

**Partial enforcement.** `.github/workflows/dependency-review.yml` runs
`actions/dependency-review-action@v5`, which is a real merge gate — but it
gates on *newly introduced* vulnerable or unlicensed dependencies appearing in
the diff, not on a repo-wide CVE count. A pre-existing Critical in an unchanged
dependency will not fail it, so the "no critical CVEs" bar below is a reporting
target that this workflow does not enforce on its own.

| Severity | Response                                       |
| -------- | ---------------------------------------------- |
| Critical | Mark blocking in `review-report.md`; update or justify before merge |
| High     | Mark blocking in `review-report.md`; fix in 7 days |
| Medium   | Warn, fix within 30 days                       |
| Low      | Log, fix in next sprint                        |

**Enforcement: partial.** `dependency-review.yml` gates newly introduced
vulnerable or unlicensed dependencies only; a pre-existing Critical does not
fail it. These criteria are reported, not enforced.

## Validation Rules

- [ ] All dependency files scanned
- [ ] No critical CVEs
- [ ] SBOM generated
- [ ] CVEs triaged

## Output Format

```json
{
  "skill": "dependency-scanning",
  "status": "pass | fail",
  "scans": {
    "npm": { "vulnerabilities": 0, "critical": 0 },
    "python": { "vulnerabilities": 0, "critical": 0 },
    "container_os": { "vulnerabilities": 0, "critical": 0 }
  },
  "sbom_generated": true,
  "total_critical": 0
}
```

## Success Criteria

- No critical CVEs
- SBOM generated successfully

### Sast

# Skill: Static Application Security Testing (SAST)

> **Load trigger:** `"load sast skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance + Core: Operational visibility
> **Token cost:** Low

## Purpose

Detect insecure code patterns, vulnerabilities, and misconfigurations in OBS, PIPE, and Fawkes services.

## Responsibilities

- Run Semgrep rulesets
- Run CodeQL analysis
- Validate security hotspots
- Validate secure coding patterns

## Inputs

- Source code
- Semgrep config
- CodeQL database

## Outputs

- `sast.sarif`
- `sast-report.json`

## Sub-Skills

| Skill          | Purpose                   |
| -------------- | ------------------------- |
| `sast/semgrep` | Semgrep ruleset execution |
| `sast/codeql`  | CodeQL deep analysis      |

## Severity Levels

**This skill produces evidence only.** No workflow in this repository runs
Semgrep or CodeQL, so a finding here cannot block a merge on its own. Severity
sets the response SLA and whether a finding is marked blocking in the review
report; the deciding authority is a human reading that report.

| Severity | Response                                        |
| -------- | ----------------------------------------------- |
| Critical | Mark blocking in `review-report.md`; fix now     |
| High     | Mark blocking in `review-report.md`; fix in 24h  |
| Medium   | Warn, fix within 1 week                         |
| Low      | Log, fix in next sprint                         |
| Info     | Log only                                        |

To make this an enforced gate rather than advisory, add a SAST job to
`.github/workflows/agent-ci.yml` that exits non-zero on Critical and High, then
update this section. Until that job exists, "blocking" means "requires an
explicit human decision in the review report" — not "the merge is stopped".

**Enforcement: advisory.** No workflow in this repository runs Semgrep or
CodeQL. These criteria are reported, not enforced.

## Validation Rules

- [ ] No critical or high vulnerabilities
- [ ] No unsafe patterns in core logic
- [ ] SARIF output valid
- [ ] All findings triaged

## Tools

- Semgrep
- CodeQL

## Output Format

```json
{
  "skill": "sast",
  "status": "pass | fail",
  "semgrep": { "findings": 0, "critical": 0, "high": 0 },
  "codeql": { "findings": 0, "critical": 0, "high": 0 },
  "total_findings": 0,
  "blocked": false
}
```

## Success Criteria

- No critical or high vulnerabilities
- No unsafe patterns in core logic

### Secret Detection

# Skill: Secret Detection & Artifact Integrity

> **Load trigger:** `"load secret-detection skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
> **Token cost:** Low

## Purpose

Ensure no secrets leak into source code, logs, artifacts, or GitOps repos.

## Responsibilities

- Scan source code for secrets
- Scan Git history
- Scan container layers
- Validate artifact integrity

## Inputs

- Source code
- Git repo
- Container image

## Outputs

| Artifact         | Produced by                                                      | Blocking |
| ---------------- | ---------------------------------------------------------------- | -------- |
| `secrets.json`   | `scripts/check-secret-detection.sh` (source tree, PR-gating)       | Yes      |
| `integrity.json` | `secret-detection/integrity` (artifact/SBOM/signature checks)     | Not yet wired |

`integrity.json` is declared by this skill but has no runner yet. Until one
exists it is listed as `not_run_by_this_validator` in `secrets.json` rather
than reported as a passing zero.

## Sub-Skills

| Skill                        | Purpose                       |
| ---------------------------- | ----------------------------- |
| `secret-detection/gitleaks`  | Gitleaks secret scanning      |
| `secret-detection/integrity` | Artifact integrity validation |

## Secret Types Detected

| Type          | Pattern                     |
| ------------- | --------------------------- |
| API Keys      | `api[_-]?key`, `apikey`     |
| Tokens        | `token`, `bearer`, `jwt`    |
| Passwords     | `password`, `passwd`, `pwd` |
| Private Keys  | `BEGIN.*PRIVATE KEY`        |
| AWS Keys      | `AKIA[0-9A-Z]{16}`          |
| GitHub Tokens | `ghp_[0-9a-zA-Z]{36}`       |
| Slack Tokens  | `xox[baprs]-[0-9a-zA-Z-]+`  |

## Validation Rules

- [ ] No secrets in source code
- [ ] No secrets in Git history
- [ ] No secrets in container layers
- [ ] All artifacts integrity-verified
- [ ] Secrets documented if false positive

## Output Format

```json
{
  "skill": "secret-detection",
  "status": "pass | fail",
  "gitleaks": { "findings": 0, "critical": 0 },
  "container_secrets": 0,
  "artifacts_verified": 5,
  "issues": []
}
```

## Success Criteria

- No secrets found
- All artifacts integrity-verified

## Usage

```bash
# Run SAST
load security-testing/sast skill

# Scan containers
load security-testing/container-security skill

# Scan dependencies
load security-testing/dependency-scanning skill

# Detect secrets
load security-testing/secret-detection skill
```

## Enforcement

- **SAST** runs via .github/workflows/agent-ci.yml (advisory)
- **Container scanning** runs via Trivy in CI (advisory, || true)
- **Dependency scanning** runs via dependency-review action (advisory)
- **Secret detection** runs in pre-commit (enforced)
- **DORA vocabulary** validates AI Capabilities 1, 4 references
