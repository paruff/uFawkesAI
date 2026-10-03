# Specification — uFawkesAI v2.0.0

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 1

Acceptance criteria IDs are the suite's (`AC-AI-*`, `AC-SITE-01`), defined in
[uFawkes.dev `suite-release/spec.md`](https://github.com/paruff/uFawkes.dev/blob/main/docs/ai-sdlc/suite-release/spec.md).

## The 2.0 contract

Semver covers exactly these. A change to any of them is a major version.

| Surface | 2.0 value |
|---|---|
| Devcontainer image | `ghcr.io/paruff/fawkes-space`, tags `X.Y.Z` and `X.Y`, cosign-signed (keyless, GitHub OIDC), digest in the GitHub Release |
| Image release tag | the template's own `vX.Y.Z` tag publishes the image of the same version |
| Artifact layout | `docs/ai-sdlc/<feature>/{intent,spec,plan}.md`; `plan.md` carries a `## Verification Strategy` heading (enforced by `scripts/check-artifact-chain.sh`) |
| npm package | `ufawkesai` |

Not covered: agent prompt text, default model routing, skill internals, the
base layers the devcontainer is built from (`*-core`, `*-ai`), and `:latest`.

## Requirements

**REQ-001 — Pinnable image (AC-AI-01).** Pushing `v2.0.0` publishes
`fawkes-space:2.0.0` and `:2.0`, signed. `docker manifest inspect` succeeds
unauthenticated; `cosign verify` passes with the steps in
`build-devsecops-images.yml`'s header. The digest appears in the Release.

**REQ-002 — Template works from "Use this template" (AC-AI-02).** A repo
created from the template, opened in `fawkes-space:2.0.0`: all four
harnesses start, the `intent → spec → plan` flow produces files the plan
command accepts, the placeholder audit (#28) finds nothing unfilled, and
`make validate` passes. Evidence: a real run transcript.

**REQ-003 — Contract and upgrade note (AC-AI-03).** This file, linked from
the release notes, including the upgrade note below.

**REQ-004 — Claims match what ships (AC-AI-04).** The README's harness
anatomy, DORA AI capability and playbook-stage maps name only files in the
template tree or tools in the image's tool list. The Observability row
follows REQ-006's outcome.

**REQ-005 — Tests and evals gate merges (AC-AI-07).** Unit tests and agent
evals are required checks on `main`. Evals also run weekly and on any change
to rules, skills or hooks. Each eval task has a rubric scoring task success,
tool use and trajectory against `baseline.json`.

**REQ-006 — Delivery events reach uFawkesObs, or the claim goes (AC-AI-06).**
A real event emitted from a checkout is queryable in uFawkesObs's Loki with
documented LogQL ([`dora-events-portability`](../dora-events-portability/spec.md)
GAP-03, #157). If not verified by the tag, the README and
`docs/UFAWKES_INTEGRATION.md` stop claiming it.

**REQ-007 — DevEx measured (AC-AI-08).** The cold/warm start benchmark
([`image-benchmark`](../image-benchmark/spec.md)) has a baseline recorded on
`v2.0.0-rc.1`, and its results are in the release notes. The CDE spec
(`devsecops-image/`) is grounded in the DevEx research (#150).

**REQ-008 — One hook gate (AC-AI-09).** `.pre-commit-config.yaml` is the only
hook definition. pre-commit and the baseline's tools are pre-installed in the
image; a repo's remote hook environments download once, on first run (owner
decision 2026-10-03: no offline-on-first-open requirement). It runs in
Pre-flight as a required check. No `ci:` block. A monthly workflow opens a
`pre-commit autoupdate` PR.

**REQ-009 — Site current (AC-SITE-01).** ufawkes.dev `/compatibility/` lists
uFawkesAI `v2.0.0`, the image version, and the uFawkesObs row from REQ-006.

## Upgrade from 1.x

1. **npm package:** `copilot-starter-template` → `ufawkesai`. Update
   `package.json` dependencies and any `npx` calls.
2. **gitops image variant removed.** Use `fawkes-space` and install Flux or
   Argo CD tooling in your own layer if you need it.
3. **Image name:** pin `ghcr.io/paruff/fawkes-space:2.0.0` (or a digest) in
   `.devcontainer/devcontainer.json`. Earlier names
   (`ufawkesai-devcontainer`, `ufawkes-devsecops-*`, `fawkes-space-devcontainer`)
   are not published.
4. **Release tags:** the image is now released by the template's `vX.Y.Z`
   tag. `image-v*` tags are retired.
