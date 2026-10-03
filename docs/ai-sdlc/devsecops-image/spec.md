# Specification (v1) — uFawkes DevSecOps Toolchain Image

Status: APPROVED (owner, 2026-09-26) with the resolutions recorded under
"Resolved decisions". Derived from `intent.md`; `plan.md` follows.

## Requirements

**R1 — One image, three consumers.** The same image digest backs local
pre-commit (inside the devcontainer), the devcontainer itself, and CI jobs.
No verification tool is installed at job or container-create time.

**R2 — Layered variants.** Three images, each `FROM` the previous one's
digest:

| Variant  | Purpose                                              | Consumers                       |
| -------- | ---------------------------------------------------- | ------------------------------- |
| `core`   | pre-commit, linters, secret + vuln + SAST scanners   | CI gates, any repo              |
| `gitops` | `core` + Kubernetes / IaC / policy-as-code tooling   | infra & GitOps repos, CI        |
| `ai`     | `gitops` + agent harnesses (Claude Code, OpenCode)   | devcontainer for AI-native SDLC |

**R3 — Determinism.** Rebuilding from the same commit produces the same
tool set at the same versions:

- Base image pinned by digest (`debian:trixie-slim@sha256:…`).
- apt packages installed from a pinned `snapshot.debian.org` timestamp.
- Every downloaded binary pinned by version **and** verified by SHA-256
  (per architecture) from a single lock file, `images/devsecops/tools.lock.yaml`.
- Python tools installed with `uv` from a hash-locked requirements file into
  an isolated venv; Node tools from a committed `package-lock.json`.
- The image records its own manifest (`/etc/ufawkes/tools.json`: tool,
  version, sha256) so any environment can print exactly what it runs.

**R4 — Offline pre-commit.** Hooks run with no network access:

- The image ships a baseline config (`/opt/ufawkes/pre-commit/baseline.yaml`)
  whose hooks are `language: system` and call the preinstalled binaries —
  no per-repo environment downloads.
- This repo's `.pre-commit-config.yaml` migrates to that baseline (plus its
  local `commit-msg` hook).
- For repos that keep remote-rev hooks, the image pre-warms `PRE_COMMIT_HOME`
  for the baseline's revs as a best-effort cache (not a guarantee).

**R5 — Supply-chain integrity.** Every published image is:

- multi-arch (`linux/amd64`, `linux/arm64`);
- scanned (Trivy) before push. The **gate** fails on CRITICAL/HIGH with a fix
  available in what this repo controls: Debian packages (apt snapshot) and
  the locked Python/npm deps. Upstream prebuilt binaries are **reported, not
  gated**: their findings (mostly Go stdlib compiled into the release) need an
  upstream rebuild, which the lock-bump workflow picks up. Owner decision
  2026-09-27, after PR 3's first scan found ≈ 200 such findings across 13
  tools, all already at their latest releases, and 0 in Debian. Accepted
  exceptions go in a reviewed `.trivyignore` with reason and expiry.
- accompanied by an SPDX SBOM and SLSA build-provenance attestation;
- keyless-signed with cosign via GitHub OIDC (no stored keys — Hard Rule 1).

**R6 — Versioning and updates.**

- Tags: `ghcr.io/paruff/fawkes-<variant>:<semver>` plus
  `:<major>` and `:<major>.<minor>`; **consumers pin the digest**.
- Release trigger: git tag `image-v<semver>` in this repo (distinct from any
  template release tags).
- Dependabot (the repo's existing updater) opens PRs for the base image
  digest (Dockerfile `FROM`) and the Node tools. `tools.lock.json` and the
  Python locks are beyond Dependabot; `image-lock-bump.yml` (weekly,
  `scripts/image-lock-bump.sh`) bumps them, plus the apt snapshot, in one bot
  PR. Each update PR rebuilds and runs R7.
- Scheduled weekly rebuild + Trivy scan of the current lock: it fails when a
  fixable CRITICAL/HIGH CVE appears, and a human bumps the apt snapshot and
  cuts a patch release. Releases are never tagged automatically.

**R7 — Verified before publish.** A test script
(`images/devsecops/tests/verify-tools.sh`) runs inside each built variant
and asserts: every tool in the lock is on `PATH`, reports the locked
version, and a smoke invocation succeeds (e.g. `gitleaks detect` on a
fixture with a planted fake secret must fail; `hadolint` on a bad Dockerfile
must fail). Runs as a CI job on every image PR.

**R8 — Reusable across repos.** Images are published as **public** GHCR
packages, so any repo or fork can pull them without a token.

- A reusable workflow `.github/workflows/reusable-devsecops.yml`
  (`workflow_call`) runs the standard gates inside the pinned image; other
  repos call it by `paruff/uFawkesAI/.github/workflows/reusable-devsecops.yml@<tag>`.
- A devcontainer snippet and `docs/DEVSECOPS_IMAGE.md` show adoption in
  three steps (devcontainer `image:`, copy baseline pre-commit config, call
  the reusable workflow).
- No repo-specific paths, secrets, or credentials baked into the image.

**R9 — Users per variant.** `core` and `gitops` run as root, because
GitHub Actions `container:` jobs expect root (`actions/checkout` writes to
the workspace as root). `ai` adds user `dev` (UID/GID 1000) with
passwordless sudo and sets it as the default user, for devcontainer use.

## Tool set (versions resolved in `plan.md` / lock file, not here)

**core**

| Area                 | Tools                                                                  |
| -------------------- | ---------------------------------------------------------------------- |
| Shell/runtime basics | bash, git, curl, ca-certificates, jq, yq, make, gh, node (LTS), python + uv |
| Hook framework       | pre-commit                                                             |
| Hygiene / lint       | shellcheck, shfmt, hadolint, actionlint, yamllint, markdownlint-cli2, ruff, editorconfig-checker |
| Secrets              | gitleaks, detect-secrets                                               |
| Vulns / SCA / SBOM   | trivy, grype, syft, osv-scanner                                        |
| SAST / CI security   | semgrep (OSS), zizmor (GitHub Actions audit)                           |
| Signing              | cosign                                                                 |
| Commits              | the repo's own `commit-msg` hook (no extra tool)                       |

**gitops** (adds)

| Area           | Tools                                              |
| -------------- | -------------------------------------------------- |
| Kubernetes     | kubectl, helm, kustomize, kubeconform, kind        |
| GitOps         | flux, argocd                                       |
| IaC            | opentofu, tflint, checkov                          |
| Policy-as-code | conftest (OPA), kyverno CLI                        |
| Secrets in Git | sops, age                                          |

**ai** (adds)

| Area                  | Tools                                                           |
| --------------------- | --------------------------------------------------------------- |
| Agent harnesses       | Claude Code, OpenCode (versions moved from `postCreateCommand`) |
| MCP runtime deps      | `uv`/`uvx` (unblocks `serena`, see `docs/ai-sdlc/spec.md` R3)   |
| Devcontainer comfort  | zsh, sudo, less, vim-tiny                                       |

Playwright browsers are **not** baked in (≈400 MB+ per arch); the
`playwright` MCP server installs its browser on first use, as today.

## Design

### Repository layout

```
images/devsecops/
  Dockerfile              # multi-stage; targets: core, gitops, ai
  tools.lock.yaml         # name, version, url template, sha256 per arch
  requirements.lock       # Python tools, --require-hashes
  package.json + package-lock.json   # Node tools (markdownlint-cli2, agents)
  pre-commit/baseline.yaml
  tests/verify-tools.sh
  tests/fixtures/…        # planted-bad inputs for smoke checks
scripts/image-install-tools.sh   # reads tools.lock.yaml, verifies sha256
.github/workflows/image-build.yml        # PR: build + test; tag: publish
.github/workflows/reusable-devsecops.yml # consumer gate workflow
docs/DEVSECOPS_IMAGE.md
```

One Dockerfile with named targets keeps the layer chain explicit and lets
`docker buildx bake` build all three with shared cache.

### Build flow

```
tools.lock.yaml ─┐
requirements.lock┼─► buildx (amd64+arm64) ─► verify-tools.sh ─► trivy gate
package-lock.json┘                                                  │
                           tag image-v* ────────────────────────────┤
                                                                     ▼
                       push ghcr ─► SBOM + provenance ─► cosign sign
```

### How consumers use it

- **Devcontainer:** `"image": "ghcr.io/paruff/fawkes-space:<v>@sha256:…"`;
  `postCreateCommand` shrinks to `npm ci && ./scripts/setup.sh`.
- **CI:** `jobs.<id>.container.image` set to the `core` (or `gitops`) digest;
  or call `reusable-devsecops.yml`. The existing `actions/setup-*` and
  `pip install` steps in lint jobs are removed.
- **dual-harness-smoke:** runs inside the `ai` image instead of building the
  devcontainer from scratch (faster, and tests the shipped artifact).

### Changes to existing files (build phase, not now)

`.devcontainer/devcontainer.json`, `.pre-commit-config.yaml`,
`.github/workflows/ci-quality.yml`, `docs/DEVCONTAINER.md`,
`docs/KNOWN_LIMITATIONS.md`. `reusable-lint.yml` is re-vendored from
`paruff/ufawkespipe` after the upstream change, not edited here.

## Acceptance criteria

1. `docker buildx bake` from a clean clone builds all three variants for
   both architectures; two builds of the same commit report identical
   `/etc/ufawkes/tools.json`.
2. `verify-tools.sh` passes in every variant; each planted-bad fixture is
   rejected by its tool.
3. With networking disabled (`docker run --network none`), `pre-commit run
   --all-files` on this repo passes inside `core`.
4. `cosign verify` succeeds against the published digest with the GitHub
   OIDC identity of `image-build.yml`; SBOM and provenance attestations are
   retrievable.
5. CI Quality Gate runs its lint/security jobs in the `core` image with no
   tool-install steps, and total pipeline time does not regress by > 20%.
6. A second repo can adopt the image following only `docs/DEVSECOPS_IMAGE.md`.

## Resolved decisions (owner, 2026-09-26)

- **Visibility:** public GHCR packages.
- **Users:** `core`/`gitops` run as root for CI; `ai` defaults to `dev`.
- **`reusable-lint.yml`:** change it upstream in `paruff/ufawkespipe` first
  (switch its jobs to the `core` image), then re-vendor the new tag here.
  Until that lands, this repo's lint job keeps its current install steps.
- **Tool set:** as listed above; semgrep and checkov stay in their
  current variants.

## Remaining concerns

- **arm64 coverage:** every tool in the lock must publish arm64 builds; any
  that don't are built from source or dropped (to be checked per tool in
  `plan.md`).
- **Image size:** estimated `core` ≈ 600–900 MB; **measured 1.61 GB**
  uncompressed (≈ 500 MB compressed pull) in PR 1's CI. Largest parts:
  semgrep 266 MB, trivy/grype/syft/osv-scanner 387 MB together, cosign
  135 MB, node 121 MB. Node's C headers (67 MB) were dropped as unused;
  further cuts mean dropping or moving tools the owner chose to keep.
  Measured in PR 2's CI: `gitops` 2.71–2.76 GB (+≈ 1.2 GB: checkov 224 MB plus
  13 CLIs, several of them large static binaries) and `ai` 2.92–2.97 GB
  (+≈ 0.2 GB). Variants share layers, so pulling `ai` fetches the stack once.
- **Licenses:** OpenTofu chosen over Terraform (BSL). semgrep OSS rules only.
  OpenCode is MIT and ships in `ai`. Claude Code's licence reserves all rights
  and grants no redistribution, so it is **not** baked into the public image; the
  devcontainer installs the pinned version at create time (see plan.md, PR 2
  notes). Revisit only after a legal review.
- **Baseline vs. per-repo pre-commit config:** adopters with custom hooks
  lose R4's offline guarantee for those hooks. Accepted trade-off.
