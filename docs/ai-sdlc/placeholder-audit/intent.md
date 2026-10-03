# Intent — Placeholder audit

Status: ACCEPTED (originator: repo owner, issue #28; v2.0.0 AC-AI-02)

## Problem

The template ships ~30 `[PLACEHOLDER …]` markers that a new project must fill
in. Only `AGENTS.md` was checked, and only when opted in, so a project could
run its agents on unfilled policy, runbook and archetype docs.

## Desired Outcome

A repo created from the template fails preflight until every marker is
filled; the template repo itself only warns.

## Decisions Already Made

- Template mode is a repo-root `.template` marker that `scripts/setup.sh`
  deletes (issue #28).
- Reuse the existing preflight and verify checks; no new workflow (Pre-flight
  already runs `scripts/preflight.sh` in CI).
