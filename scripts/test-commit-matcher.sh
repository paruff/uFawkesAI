#!/usr/bin/env bash
# Self-test for the `git commit` matcher in the Claude and OpenCode secret-scan hooks: the two
# copies must be identical, match every real commit form, and ignore look-alikes.
set -euo pipefail
cd "$(dirname "$0")/.."

node - << 'JS'
const fs = require("fs");
const files = ["scripts/hooks/claude-pretooluse-secret-scan.js", ".opencode/plugins/ai-sdlc-hooks.ts"];
const src = files.map((f) => {
  const m = fs.readFileSync(f, "utf8").match(/^const GIT_COMMIT = (\/.*\/);$/m);
  if (!m) { console.error(`FAIL: no GIT_COMMIT regex in ${f}`); process.exit(1); }
  return m[1];
});
if (src[0] !== src[1]) { console.error(`FAIL: the two GIT_COMMIT regexes differ\n  ${src[0]}\n  ${src[1]}`); process.exit(1); }
const pushSrc = files.map((f) => fs.readFileSync(f, "utf8").match(/^const GIT_PUSH = (\/.*\/);$/m)?.[1]);
if (!pushSrc[0] || pushSrc[0] !== pushSrc[1]) { console.error(`FAIL: GIT_PUSH missing or differs\n  ${pushSrc[0]}\n  ${pushSrc[1]}`); process.exit(1); }
const push = eval(pushSrc[0]); // shortcut: our own repo's literal, not user input
const pushYes = ["git push", "git push origin main", "git -C . push", "cd a && git push -u origin x", "(git push origin x)"];
const pushNo = ["git push-to-checkout", 'echo "git push"', "git log --grep push", "git commit -m push", "git pull"];
let pbad = 0;
for (const c of pushYes) if (!push.test(c)) { pbad++; console.error(`FAIL: push missed   ${JSON.stringify(c)}`); }
for (const c of pushNo) if (push.test(c)) { pbad++; console.error(`FAIL: push false hit ${JSON.stringify(c)}`); }
if (pbad) process.exit(1);
const re = eval(src[0]); // shortcut: our own repo's literal, not user input
const yes = ["git commit", "git commit -m x", "cd a && git commit -m x", "git -C sub commit -m x", "git -c user.name=a commit -m x",
  "git --git-dir=.git commit", "(git commit -m x)", "  git commit -m x", "echo hi; git commit", "git -C a -C b commit"];
const no = ["git commit-tree abc", 'git log --grep "git commit"', 'echo "git commit"', "git log -S commit", "git status",
  "git push origin main", "git config alias.ci commit", "git show commit-msg"];
let bad = 0;
for (const c of yes) if (!re.test(c)) { bad++; console.error(`FAIL: missed   ${JSON.stringify(c)}`); }
for (const c of no) if (re.test(c)) { bad++; console.error(`FAIL: false hit ${JSON.stringify(c)}`); }
if (bad) process.exit(1);
console.log(`✅ commit matcher: ${yes.length + no.length} cases, both hook copies identical`);
JS
