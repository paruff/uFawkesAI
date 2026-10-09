# Plan — AWS AI-DLC as an Opt-In Tool in the CDE Image

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 1

Ships in v2.1.0, after v2.0.0 is tagged. Each step is one PR under the
400-line gate.

## Changes

1. **Spike (D1).** In a local `ai` build, try the binary-only entry first:
   run the R2 commands under `--network none`. If they fail, switch to the
   offline `install.sh --from` shape. Record the result in spec D1. No PR if
   the binary alone works; the finding goes on the build issue.
2. **Pin it (R1, R2, R4).** Add an `ai` entry to
   `images/devsecops/tools.lock.json`, modelled on `hadolint` (`format:
   binary`, `checksum_url` → the release's `checksums.txt`,
   `version_cmd: aidlc --version`), with hashes filled in by
   `scripts/image-lock-refresh.sh`. Only if D1 needs it: the runtime archive
   and an install step in `images/devsecops/Dockerfile`.
3. **Prove it in the image (R2, R3, R5).** `verify-tools.sh` already checks
   every lock entry's version. Add the R2 dry run and the R3 no-files check
   to it only if step 1 shows the version check misses a broken install.
4. **Document the opt-in (R6).** One section in `docs/DEVCONTAINER.md`.
5. **Run it for real (R7).** From the published `v2.1.0-rc` devcontainer, in
   a throwaway repo made from the template: `aidlc config --harness claude`,
   then one small `/aidlc` task. Post the record on the run issue.
6. **File D2.** A `goal` decision issue with the R7 record and a
   recommendation among (a), (b) and (c).

## Verification Strategy

| AC | How it is proven | Command / CI job |
|---|---|---|
| 1 | Version check | `docker run --rm --network none -v "$PWD/images/devsecops/tests:/tests:ro" ghcr.io/paruff/fawkes-space-ai:<tag> /tests/verify-tools.sh ai` |
| 2 | Offline dry run | `docker run --rm --network none <ai-image> sh -c 'cd "$(mktemp -d)" && git init -q && aidlc --version && aidlc config --harness claude --dry-run'` |
| 3 | No default config | `grep -rl -i aidlc .claude .opencode AGENTS.md .gitignore templates/` is empty; the same grep over `/home/<user>` in the image finds only the install |
| 4 | Lock bump | `scripts/image-lock-bump.sh --dry-run` lists `aidlc` at a stable version; `scripts/test-image-lock-bump.sh` passes |
| 5 | Scan and benchmark | `images/devsecops/scan.sh`; the `benchmark` job on the `v2.1.0-rc` tag |
| 6 | Real run | The R7 record on the run issue; the D2 issue exists |

Lint: `actionlint` and `shellcheck` on anything touched;
`pre-commit run --all-files`.

## Risks

- **The binary needs its runtime archive offline:** step 1 finds out before
  any lock change, and D1 already has the fallback.
- **The rc benchmark moves** when a binary is added: a larger image is
  expected, so re-baseline only if the gate fails and the size difference
  matches the binary.
