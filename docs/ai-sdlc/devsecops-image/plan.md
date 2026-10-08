# Plan (v1) — uFawkes DevSecOps Toolchain Image

Status: SHIPPED in v2.0.0; audited 2026-10-08 (see the end). Implements `spec.md` (approved
2026-09-26). CI blocks PRs over 400 lines, so the work ships as five PRs,
each independently reviewable and green.

## Resolved tool versions

Resolved 2026-09-26 from each project's latest GitHub release (npm / dl.k8s.io
where noted). These seed `tools.lock.json`; update automation owns them afterwards (see PR 3 notes).
All listed tools publish `linux/amd64` and `linux/arm64` builds.

"Checksum source" is where the lock's SHA-256 comes from. **Computed** = the
project publishes no checksum file; the hash is computed once from the pinned
release asset when the lock entry is created and then enforced on every build.

### core

| Tool                  | Version  | Install          | Checksum source                 |
| --------------------- | -------- | ---------------- | ------------------------------- |
| node (LTS "Krypton")  | 24.21.0  | nodejs.org tarball | `SHASUMS256.txt`              |
| uv                    | 0.12.19  | GitHub release   | `sha256.sum`                    |
| gh                    | 2.101.0  | GitHub release   | `gh_2.101.0_checksums.txt`      |
| jq                    | 1.8.2    | GitHub release   | `sha256sum.txt`                 |
| yq                    | 4.53.6   | GitHub release   | `checksums`                     |
| pre-commit            | 4.6.2    | uv (hash-locked) | PyPI hashes                     |
| shellcheck            | 0.11.0   | GitHub release   | computed                        |
| shfmt (mvdan/sh)      | 3.14.1   | GitHub release   | computed                        |
| hadolint              | 2.15.1   | GitHub release   | `checksums.sha256`              |
| actionlint            | 1.7.12   | GitHub release   | `actionlint_1.7.12_checksums.txt` |
| yamllint              | 1.38.0   | uv (hash-locked) | PyPI hashes                     |
| markdownlint-cli2     | 0.23.3   | npm (lockfile)   | `package-lock.json` integrity   |
| ruff                  | 0.16.9   | GitHub release   | per-asset `.sha256`             |
| editorconfig-checker  | 4.0.2    | GitHub release   | `checksums.txt`                 |
| gitleaks              | 8.30.1   | GitHub release   | `gitleaks_8.30.1_checksums.txt` |
| detect-secrets        | 1.5.0    | uv (hash-locked) | PyPI hashes                     |
| trivy                 | 0.74.0   | GitHub release   | `trivy_0.74.0_checksums.txt`    |
| grype                 | 0.119.0  | GitHub release   | `grype_0.119.0_checksums.txt`   |
| syft                  | 1.52.0   | GitHub release   | `syft_1.52.0_checksums.txt`     |
| osv-scanner           | 2.6.0    | GitHub release   | `osv-scanner_SHA256SUMS`        |
| semgrep               | 1.178.0  | uv (hash-locked) | PyPI hashes                     |
| zizmor                | 1.30.1   | GitHub release   | computed                        |
| cosign                | 3.1.3    | GitHub release   | `cosign_checksums.txt`          |

### gitops (adds)

| Tool        | Version | Install          | Checksum source                   |
| ----------- | ------- | ---------------- | --------------------------------- |
| kubectl     | 1.37.1  | dl.k8s.io        | per-binary `.sha256`              |
| helm        | 4.3.0   | get.helm.sh      | per-archive `.sha256sum`          |
| kustomize   | 5.8.1   | GitHub release   | `checksums.txt`                   |
| kubeconform | 0.8.0   | GitHub release   | `CHECKSUMS`                       |
| kind        | 0.33.0  | GitHub release   | per-binary `.sha256sum`           |
| flux        | 2.9.5   | GitHub release   | `flux_2.9.5_checksums.txt`        |
| argocd      | 3.5.3   | GitHub release   | `cli_checksums.txt`               |
| opentofu    | 1.12.6  | GitHub release   | `tofu_1.12.6_SHA256SUMS`          |
| tflint      | 0.64.0  | GitHub release   | `checksums.txt`                   |
| checkov     | 3.3.19  | uv (hash-locked) | PyPI hashes                       |
| conftest    | 0.70.1  | GitHub release   | `checksums.txt`                   |
| kyverno CLI | 1.19.1  | GitHub release   | `checksums.txt`                   |
| sops        | 3.13.3  | GitHub release   | `sops-v3.13.3.checksums.txt`      |
| age         | 1.3.2   | GitHub release   | computed                          |

### ai (adds)

| Tool         | Version  | Install        | Checksum source               |
| ------------ | -------- | -------------- | ----------------------------- |
| Claude Code  | 2.1.283  | npm (lockfile) | `package-lock.json` integrity |
| OpenCode     | 1.18.32  | npm (lockfile) | `package-lock.json` integrity |

Version notes:

- **node 24 vs 22:** the image uses the current Active LTS (24). The repo's
  application CI jobs keep `setup-node` 22.23.2 until a separate decision;
  the image's node only runs tooling (markdownlint-cli2, agent CLIs).
- **pre-commit:** CI pins 4.6.0 today, the image pins 4.6.2 — PR 4 aligns CI
  by running in the image.
- **OpenCode:** the devcontainer pins 1.18.30; the image moves to 1.18.32.
  Claude Code stays at the currently pinned 2.1.283.
- **Base image:** `debian:trixie-slim` digest and the `snapshot.debian.org`
  timestamp are captured in PR 1 (Docker is not available in the current
  devcontainer, so they couldn't be resolved while writing this plan).

## Implementation notes (PR 1)

Deviations from the layout above, made while building PR 1:

- The lock is **`tools.lock.json`**, not YAML: the build stage parses it with
  Debian's `jq`, avoiding a bootstrap dependency on the pinned `yq`.
- The **base image digest and apt snapshot** live in the Dockerfile, not in
  the lock (PR 3 moved the digest into `FROM` for Dependabot).
- The installer is **`images/devsecops/install-tools.sh`** (inside the Docker
  build context), not under `scripts/`. `scripts/image-lock-refresh.sh` stays
  under `scripts/`.
- **`pre-commit/baseline.yaml` ships in PR 1**, because the image is verified
  against it. Switching this repo's `.pre-commit-config.yaml` to it stays in PR 4.
- The **offline pre-commit check runs on a generated clean repo**, not on this
  repo. Adopting this repo's own files is PR 4's check.
- **Planted-bad fixtures are generated inside `verify-tools.sh`** at run time,
  not committed. A committed fake secret or broken script would trip this
  repo's own gitleaks, shellcheck and actionlint gates.
- `pre-commit-hooks` 6.0.0 was added to the Python pins, since the baseline's
  hygiene hooks call its console scripts.

## Implementation notes (PR 2)

- **Claude Code is not baked into `ai`.** Its package licence reads "© Anthropic
  PBC. All rights reserved. Use is subject to the Legal Agreements…", with no
  permission to redistribute, so the spec's licence fallback applies: the
  devcontainer installs the pinned version from npm at create time (PR 4).
  The image sets a user-writable `NPM_CONFIG_PREFIX` so that needs no sudo.
  If a legal review allows redistribution, add it back as a lock or npm entry.
- **OpenCode comes from its GitHub release, not npm.** The npm package's
  `postinstall` chooses the AVX2 or baseline binary based on the *build host's*
  CPU (non-deterministic), and npm also installs every musl/baseline variant
  (≈ 727 MB). The lock pins one binary per arch. amd64 uses the baseline build,
  which runs on any x64 CPU. No upstream checksum file exists; the pinned
  binaries were confirmed byte-identical to the npm-published ones.
- **checkov has its own venv** (`/opt/ufawkes/venv-gitops`) so its deps can't
  conflict with semgrep's in the core venv.
- **Trust-on-first-use pins** now: shellcheck, shfmt, zizmor, age, opencode.
- kubectl, kubeconform, kind, flux and argocd get version checks only: every
  offline accept/reject test for them needs a cluster, schema downloads or Docker.

## Implementation notes (PR 3)

- **Publishing is its own workflow**, `image-release.yml`, triggered only by
  `image-vX.Y.Z` tags. `packages: write`, `id-token: write` and
  `attestations: write` exist only there, so PR builds never hold them. It
  refuses a tag whose commit is not on `main`.
- **Gate scope (owner decision)**: `images/devsecops/scan.sh` reports every
  fixable CRITICAL/HIGH across the image (run summary table) but gates only
  Debian and the locked Python/npm deps. The first scan found 0 Debian
  findings and ≈ 200 in 13 upstream Go binaries, mostly the Go stdlib (incl.
  CRITICAL CVE-2025-68121 in gitleaks and kustomize), with every tool already
  at its latest release, so a full gate would block every release on fixes
  only upstream can ship.
- **Scan and SBOM use the image's own tools**: trivy and syft run from the
  freshly built `core` image via the Docker socket, not third-party actions.
  The Trivy gate scans `ai` only, because it contains every package of
  `core` and `gitops`.
- **Arch images** are pushed as `:X.Y.Z-amd64` / `:X.Y.Z-arm64`, each with an
  SPDX SBOM attestation. **Indexes** `:X.Y.Z`, `:X.Y`, `:X` are cosign-signed
  (keyless) with SLSA build provenance. No `:latest` tag: consumers pin
  digests.
- **Dependabot, not Renovate**: the repo already uses Dependabot. The base
  digest moved from an `ARG` into the Dockerfile `FROM` line so Dependabot's
  docker updater can bump it; Node tools are covered too. `tools.lock.json`
  and the Python locks are bumped by `image-lock-bump.yml` (see below).
- **Weekly scheduled run** of `image-build.yml` re-verifies the lock and fails
  on fixable CRITICAL/HIGH CVEs; on PRs the same scan is report-only.

### Releasing (human steps)

1. Merge to `main`; wait for `image-build.yml` to pass on `main`.
2. `git tag image-vX.Y.Z <merged-sha> && git push origin image-vX.Y.Z`.
3. First release only: in GitHub → Packages, set `fawkes-core`, `fawkes-space-ai`, and `fawkes-space` to **public** (spec decision).
4. Copy the index digests from the release run's summary into consumers.

## Implementation notes (lock bump)

- **`image-lock-bump.yml`** (Sundays + manual) runs `scripts/image-lock-bump.sh`
  and opens or updates one PR from `chore/image-lock-bump`. It bumps:
  - every `tools.lock.json` tool to its newest non-prerelease upstream
    version, per the entry's explicit `source` (GitHub repo + tag pattern,
    the Kubernetes stable URL, or the Node LTS line — Node stays on its LTS
    major), with checksums re-pinned by `image-lock-refresh.sh`;
  - the Python pins in `requirements*.in`, with the hash locks recompiled by
    the lock's own checksum-verified uv;
  - the apt snapshot to today, if snapshot.debian.org has published it.
- The PR body lists every change, and flags TOFU tools (no upstream checksum
  file) for the reviewer to check release pages.
- **Bot-PR CI:** PRs opened with `GITHUB_TOKEN` don't trigger `pull_request`
  workflows, so the job dispatches `ci-quality.yml` (which produces the
  required "✅ CI Complete" check on the head commit) and `image-build.yml`
  (in dispatch mode, the CVE gate is enforced) on the branch.
- **Repo setting required:** "Allow GitHub Actions to create and approve pull
  requests" must be on for `gh pr create`; otherwise the branch is pushed
  and the run fails at PR creation with a clear error.
- Merging is always human; releases are still cut by tagging.

## Lock file format

```yaml
# images/devsecops/tools.lock.json (shown as YAML for readability)
tools:
  - name: gitleaks
    variant: core
    version: 8.30.1
    url: https://github.com/gitleaks/gitleaks/releases/download/v{version}/gitleaks_{version}_linux_{arch}.tar.gz
    arch: { amd64: x64, arm64: arm64 }        # asset naming per arch
    sha256:
      amd64: <filled in PR 1>
      arm64: <filled in PR 1>
    extract: gitleaks                          # path inside archive
    version_cmd: gitleaks version              # verify-tools.sh check
```

`scripts/image-install-tools.sh <variant>` reads the lock, downloads,
verifies `sha256sum -c`, and installs to `/usr/local/bin`; any mismatch
fails the build. A companion `scripts/image-lock-refresh.sh <tool> <version>`
fetches the release checksum (or computes it) and rewrites the entry — this
is what `scripts/image-lock-bump.sh` runs for each bumped tool.

## Verification Strategy (pre-bake hook environments)

> **Reverted 2026-10-03.** The bake ran the baseline config, whose hooks are
> `language: system`, so it cached no remote environments; and it created
> `PRE_COMMIT_HOME` as root, so `dev` could not write to it. AC-AI-09 now
> accepts a one-time download into `~/.cache/pre-commit`. Verify: in the
> published devcontainer, as `dev`, `pre-commit run --all-files` succeeds
> (the live acceptance tests in `build-devsecops-images.yml` run exactly that).
> The original section follows for the record.

This PR adds pre-baking of hook environments at image build time (R4 of spec.md).
The change modifies `images/devsecops/Dockerfile` to:

1. Set `PRE_COMMIT_HOME=/opt/ufawkes/pre-commit/cache`
2. Create a temporary git repo during build and run `pre-commit run --all-files`
   against the baseline config to populate the hook environment cache.

### Acceptance Criteria

| AC    | How it is proven                                          | test_type   | Command / CI job                          |
| ----- | -------------------------------------------------------- | ----------- | ----------------------------------------- |
| AC-01 | Image builds successfully on amd64 and arm64             | integration | `image-build.yml` › `verify core`         |
| AC-02 | `pre-commit run --all-files` works offline in built image| integration | `verify-tools.sh core` (network disabled) |
| AC-03 | Hook environments are cached in `PRE_COMMIT_HOME`        | unit        | inspect image layer `/opt/ufawkes/pre-commit/cache` |

### Verification Commands

```bash
# Build and verify core image
docker buildx build --target core -t fawkes-core:test images/devsecops
docker run --rm --network none -v "$PWD/images/devsecops/tests:/tests:ro" \
  fawkes-core:test /tests/verify-tools.sh core
```

## PR sequence

### PR 1 — `feat(image): core variant build and verification`

- `images/devsecops/Dockerfile` (target `core`), `tools.lock.yaml` (core
  entries), `requirements.in` + hash-locked `requirements.lock`,
  `package.json` + `package-lock.json` (markdownlint-cli2 only).
- `scripts/image-install-tools.sh`, `scripts/image-lock-refresh.sh`.
- `images/devsecops/tests/verify-tools.sh` + fixtures (planted fake
  secret, bad Dockerfile, bad workflow, bad shell script).
- `.github/workflows/image-build.yml`: on PRs touching `images/**` —
  buildx `core` for amd64+arm64 (QEMU for arm64), run `verify-tools.sh`,
  **no push**.
- **Verify:** workflow green on both arches; build twice → identical
  `/etc/ufawkes/tools.json`; `docker run --network none … pre-commit run
  --all-files` passes against this repo using the baseline config.

### PR 2 — `feat(image): gitops and ai variants`

- Dockerfile targets `gitops` and `ai`; lock entries; `dev` user +
  sudo + zsh in `ai`; agent CLIs in `ai`'s `package.json`.
- `docker-bake.hcl` builds all three with shared cache.
- **Gate (human):** confirm Claude Code and OpenCode licences allow
  redistribution in a public image. If not, drop them from `ai` and keep
  the pinned `npm install -g` in `postCreateCommand` (spec fallback).
- **Verify:** `verify-tools.sh gitops|ai` green on both arches; `ai`
  runs as `dev`; `scripts/dual-harness-smoke.sh` passes inside `ai`.

### PR 3 — `ci(image): publish, scan, sign, attest`

- `image-build.yml` gains a publish job on tags `image-v*`: push to
  `ghcr.io/paruff/fawkes-{core,space-ai,space}`, Trivy gate
  (CRITICAL/HIGH with fix → fail; `.trivyignore` reviewed), SBOM
  (syft, SPDX), `actions/attest-build-provenance`, cosign keyless sign.
  Permissions: `packages: write`, `id-token: write`, `attestations: write`
  on that job only.
- Weekly scheduled rebuild + scan on the current lock; a human cuts the
  patch release (see PR 3 notes — no automatic tagging).
- Dependabot for the base digest and Node tools; `tools.lock.json`, the
  Python locks and the apt snapshot are bumped by `image-lock-bump.yml`.
- **Human step:** make the three GHCR packages public after first
  publish; push tag `image-v0.1.0`.
- **Verify:** `cosign verify` with the workflow's OIDC identity; `gh
  attestation verify`; SBOM attached.

### PR 4 — `feat(devex): adopt the image in this repo`

- `.devcontainer/devcontainer.json` → `ai` image by digest;
  `postCreateCommand` → `npm ci && ./scripts/setup.sh`.
- `images/devsecops/pre-commit/baseline.yaml` (`language: system` hooks);
  `.pre-commit-config.yaml` switches to it + local `commit-msg`.
- `.github/workflows/reusable-devsecops.yml` (`workflow_call`, `container:`
  core digest input, runs pre-commit + trivy fs + zizmor +
  osv-scanner).
- `ci-quality.yml`: `dual-harness-smoke` runs in the `ai` image; add a
  `devsecops` job calling the reusable workflow.
- `docs/DEVSECOPS_IMAGE.md` (3-step adoption), update
  `docs/DEVCONTAINER.md`, `docs/KNOWN_LIMITATIONS.md`.
- **Verify:** full CI Quality Gate green; pipeline time within +20% of
  the pre-change baseline (record both in the PR).

### PR 5 — re-vendor `reusable-lint.yml` (after upstream)

- **Upstream first** (`paruff/ufawkespipe`): switch its lint jobs to a
  `container-image` input defaulting to the `core` digest, drop per-job
  installs, cut a new tag.
- Then here: re-vendor that tag, update the header comment.
- **Verify:** lint job green with no tool-install steps.

## Acceptance mapping

| Spec criterion                          | Proven in |
| --------------------------------------- | --------- |
| 1. reproducible multi-arch build        | PR 1, 2   |
| 2. verify-tools + fixtures              | PR 1, 2   |
| 3. offline pre-commit                   | PR 1      |
| 4. cosign + attestations                | PR 3      |
| 5. CI in image, ≤ +20% time             | PR 4, 5   |
| 6. second-repo adoption from docs only  | PR 4 (dry run in a scratch repo) |

## Risks

- **QEMU arm64 builds are slow** (semgrep/checkov wheels). Mitigation:
  native `ubuntu-24.04-arm` runners for the arm64 leg.
- **"Computed" checksums** (shellcheck, shfmt, zizmor, opencode) trust the
  asset at lock time (trust-on-first-use). Mitigation: use a project's
  signature/attestation when one exists (e.g. `gh attestation verify`), and
  the reviewer of any lock-bump PR for these tools checks the release page.
  **Since 2026-10-08** `image-lock-refresh.sh` checks a GitHub release asset
  with no checksum file against the SHA-256 digest GitHub records for it
  (fails on a mismatch), so only superpowers (a source archive) is still TOFU.
  Verify: `bash scripts/test-image-lock-refresh.sh`.
- **Upstream PR 5** depends on `ufawkespipe` review; PRs 1–4 don't block
  on it.
- **Flaky tool downloads.** `install-tools.sh` fetches every locked binary
  with `curl --retry 5 --retry-all-errors`: plain `--retry` does not retry a
  connection reset (curl exit 35/56), and one reset failed `main`'s CI on
  2026-10-03 (run 37124317809). The sha256 check still guards every retry.
  Verify: the image builds in `build-devsecops-images.yml` and the
  Multi-Harness Smoke Test.

## Dropped: the polyglot variant (2026-10-03)

Owner decision: no Java in the image. The `polyglot` target (OpenJDK 21 JRE +
jdtls), its `fawkes-space-ai:<v>-polyglot` and `fawkes-space:<v>-polyglot`
tags, the jdtls lock entry, the `ufawkes-lsp-java` Claude plugin listing and
OpenCode's jdtls pin are removed. A Java repo adds a JDK to its own
devcontainer and sets `OPENCODE_DISABLE_LSP_DOWNLOAD=false`; OpenCode's
built-in LSP then fetches jdtls. Nothing was ever published under the
polyglot tags.

Verify: `verify-tools.sh ai` reports java/jdtls absent and the OpenCode LSP
config pinned (TS) with downloads off; `actionlint` on
`build-devsecops-images.yml`; `git grep -i polyglot` finds only this history.

## Fix: curl in the runtime image (2026-10-03)

`curl` was installed only in the `fetch` build stage, so the published image
had none. `scripts/emit-dora-event.sh` exports delivery events with curl, and
in-image runs of `test-emit-dora-event.sh` hung on an OTLP listener with no
timeout (found running the acceptance suite in `fawkes-space:2.0.0-rc.1`).
`core` now installs curl, and the listener times out after 20 s so a missing
POST fails the checks instead of hanging.

Verify: `verify-tools.sh` reports `curl`; in the image as `dev`,
`scripts/run-unit-tests.sh` completes; on the host,
`bash scripts/test-emit-dora-event.sh` passes.

## One-page AGENTS.md (2026-10-03, R10 cognitive load)

`AGENTS.md` loads on every request; AC-AI-08 asks for a static rule file of
one page or less. 170 → 50 lines, with every removed line moved verbatim to
`docs/AGENT_REFERENCE.md`. `scripts/check-secret-detection.sh`'s hint now
points at `AGENTS.md §5` (the pragma line) instead of a stale line number.

Verify: `wc -l AGENTS.md` ≤ 60; `bash scripts/check-harness-parity.sh` (the
symlinks still mirror it); `bash scripts/test-check-secret-detection.sh`; the
required evals on the PR show no regression in agent behaviour.

## Implementation notes (#193 — GitOps hook tools in core)

fawkes's tool-backed hooks (`kustomize-validate`, `helm-lint`,
`kubeval`/kubeconform, `mkdocs-validate`) fail when their tool is missing, so
`core` now carries them and `verify-tools.sh` proves each one:

- **`tools.lock.json`:** `kubeconform` 0.8.0, `kustomize` 5.8.2 and `helm`
  3.22.0 as `core` entries, release checksums pinned per arch.
- **helm stays on major 3** while consumers' CI runs helm 3: a `github`
  source may carry an optional `"major"`, and `image-lock-bump.sh` skips
  tags outside it (the stub in `test-image-lock-bump.sh` proves
  `3.1.0 → 3.2.0`, not `4.0.0`).
- **Python pins** match fawkes's `requirements.txt`: `mkdocs==1.6.1`,
  `mkdocs-material==9.7.7`, `pymdown-extensions==12.1`.
- **kubeconform** gets a version check only (like kubectl/kind): validating
  needs schema downloads, which the offline verify can't do.

### Verification Strategy — #193 tools

| AC | How it is proven | test_type | Where |
| --- | --- | --- | --- |
| kustomize builds a kustomization; rejects a missing resource | `expect_pass` / `expect_reject` in `verify-tools.sh core` | integration | `image-build.yml`, both arches, `--network none` |
| helm lints a fresh chart; rejects a `Chart.yaml` without apiVersion/version | same | integration | same |
| mkdocs builds a material site `--strict`; rejects a nav to a missing page | same | integration | same |
| kubeconform present at the locked version | version check, section 1 | unit | `verify-tools.sh core` |
| lock-bump keeps helm on 3 | stubbed `gh` releases API | unit | `bash scripts/test-image-lock-bump.sh` |
| fresh `fawkes-space` runs fawkes's `pre-commit run --all-files` with no missing-tool failures (#193 Done-when) | live acceptance run in fawkes | integration | `build-devsecops-images.yml` live acceptance |

Verify: `bash scripts/check-artifact-chain.sh origin/main` locally, then the
`DevSecOps Images` workflow green on both arches and `✅ CI Complete` on the PR.

## Audit (2026-10-08)

The plan against what shipped, and what changes:

| # | Finding | Resolution |
| --- | --- | --- |
| A1 | The 2026-10-03 revert dropped pre-baked hooks, so every new container ran `pre-commit install-hooks` for ≈ 5 min and downloaded 1.3 GB. Both reasons for the revert (baseline config only, root-owned cache) are fixable. | `.devcontainer/Dockerfile` bakes this repo's hook environments as `dev` into `~/.cache/pre-commit`; `install-hooks` now takes ≈ 1 s offline. CI builds that layer on PRs and checks it with `--network none`. |
| A2 | ≈ 670 MB of that was Go toolchains for building gitleaks and actionlint from source, though both binaries ship in `core`. | Covered by A1's bake. Switching these hooks to `language: system` would shrink the image further, once uFawkesPipe's Pre-flight has the binaries. |
| A3 | The `gitops` variant (14 tools above) was never built: `docker-bake.hcl` has only `core` and `ai`, and nothing records the decision. | The tools fawkes's hooks need (#193) go into `core`; the rest of the gitops table stays unbuilt until a repo needs it. |
| A4 | grype, syft, semgrep and cosign appear above but are in neither the lock nor the image (SBOMs come from buildx `sbom: true`, cosign from `cosign-installer`). | Tables kept for the record; `tools.lock.json` is the source of truth. |
| A5 | helm 4.3.0 above; fawkes's CI uses helm 3.21.3. | Owner decision 2026-10-08: helm 3 (#193). |
| A6 | The start benchmark (R10) times `docker run`, not time-to-ready: the pull, extension installs and hook downloads were unmeasured. | CI reports hook readiness time per arch; a full `devcontainer up` timing remains open. |
| A7 | Stale notes: OpenCode 1.18.30 / Claude Code 2.1.283 pins, `docs/DEVCONTAINER.md` described `javascript-node:22`, `.devcontainer/devcontainer-lock.json` pinned unused features. | Claude Code 2.1.293; `DEVCONTAINER.md` rewritten; the lock file removed. |

## npm security overrides (2026-10-08)

Dependabot's security updates failed for transitive deps it can't bump, so
`overrides` in the two `package.json` files pin the patched versions until
upstream ships them: smol-toml 1.9.0 and katex 0.18.2 (`node/`), simple-git
4.0.1 and @simple-git/argv-parser 2.0.1 (`node-ai/`, via qmd's
node-llama-cpp, which uses it only to build llama.cpp from source). Drop an
override once its parent depends on a patched version. braces has no patched
release.

Verify: `npm ci` of both lockfiles; markdownlint-cli2 lints a file with math,
rejects a bad file and loads a `--config` TOML; `qmd --version`; node-llama-cpp
imports; `verify-tools.sh ai` in the image build.
