# v2.2.0 release record

Tag `v2.2.0` (commit `c7873b3`, the commit `v2.2.0-rc.1` passed on). Published 2026-10-22; every job green: verify (amd64, arm64), publish and sign, live acceptance, cold/warm start benchmark, digest into the release.

| Tag | Digest |
| --- | --- |
| `fawkes-space:2.2.0`, `2.2`, `2`, `latest` | `sha256:f5d07e71c3d471e46d1825bd7dcfabec640dfa31801dbf94c48465bd5d4caf70` |
| `fawkes-space:base-2.2.0`, `base-latest` | the ai base layer (no separate `fawkes-space-ai` package) |

Verified with `cosign verify` (v3) against the workflow identity. `.devcontainer/devcontainer.json` and `live-acceptance.yml` both pin the digest above; change them together on the next release.
