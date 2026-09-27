#!/usr/bin/env node
// Claude Code PreToolUse hook: block `git commit` when a staged file contains a
// credential-shaped string.
//
// Kept as a file rather than a `node -e` one-liner because the commit-matching
// regex does not survive the extra round of shell unescaping that a one-liner
// needs, and because this way the logic is directly testable.
//
// Input:  Claude Code PreToolUse JSON on stdin, i.e. { tool_input: { command } }
// Output: exit 0  allow
//         exit 2  block the commit
//         other   treated as block by the host
//
// The scan itself is in scripts/hooks/pre-commit-secret-scan.sh, shared with the
// OpenCode plugin so there is exactly one implementation of the check.

"use strict";

const { spawnSync } = require("node:child_process");
const path = require("node:path");

// Real commits only. Must not match:
//   - `git commit-tree <sha>`   (writes an object; makes no commit)
//   - prose or a string literal that merely says "git commit"
//   - `git log --grep "git commit"`
const GIT_COMMIT = /(^|[;&|]\s*)git\s+(-\S+\s+)*commit(\s|$)/;

function readStdin() {
  try {
    return require("node:fs").readFileSync(0, "utf-8") || "";
  } catch {
    return "";
  }
}

function toolCommand() {
  try {
    const payload = JSON.parse(readStdin());
    return payload?.tool_input?.command || "";
  } catch {
    return "";
  }
}

const command = toolCommand();
if (!GIT_COMMIT.test(command)) {
  process.exit(0);
}

const root = process.env.CLAUDE_PROJECT_DIR || process.cwd();
const result = spawnSync("bash", [path.join(root, "scripts/hooks/pre-commit-secret-scan.sh")], {
  stdio: "inherit"
});

// spawnSync error (e.g. bash missing) => null status. Fail closed: an unrunnable
// secret gate must not read as a clean gate.
//
// Exit-code mapping matters more than it looks. Claude Code treats:
//   0  -> proceed
//   2  -> BLOCK, and feed stderr back to the model so it can fix itself
//   *  -> non-blocking error, i.e. the commit would still go through
// The scan script returns 1 for "finding" and 2 for "could not run", so both
// must be re-mapped to 2 here. Passing the script's status through verbatim
// would have looked like it worked while blocking nothing.
const status = result.status;
if (status === 0) process.exit(0);
process.exit(2);
