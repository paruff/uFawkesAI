#!/usr/bin/env bash
# images/devsecops/tests/verify-tools.sh — proves a built image variant ships
# exactly the locked toolchain and that each gate actually gates.
#
#   docker run --rm --network none -v "$PWD/images/devsecops/tests:/tests:ro" \
#     <image> /tests/verify-tools.sh core
#
# 1. every lock entry for the variant (and the variants below it) is on PATH
#    and reports its locked version; Python and Node pins match too;
# 2. each scanner/linter accepts a clean input and rejects a planted-bad one
#    (bad inputs are generated here, never committed — the repo's own
#    gitleaks/shellcheck/actionlint gates would flag them);
# 3. the offline pre-commit baseline passes on a clean repo with no network.
#
# Override paths for a non-image dry run: UFAWKES_ETC, UFAWKES_OPT.

set -uo pipefail

VARIANT="${1:-core}"
ETC="${UFAWKES_ETC:-/etc/ufawkes}"
OPT="${UFAWKES_OPT:-/opt/ufawkes}"
LOCK="${ETC}/tools.lock.json"

case "$VARIANT" in
  core) VARIANTS='["core"]' ;;
  gitops) VARIANTS='["core","gitops"]' ;;
  ai) VARIANTS='["core","gitops","ai"]' ;;
  *)
    echo "unknown variant: $VARIANT" >&2
    exit 2
    ;;
esac

pass=0
failures=()
ok() {
  pass=$((pass + 1))
  echo "  ✅ $1"
}
bad() {
  failures+=("$1")
  echo "  ❌ $1"
  if [ -n "${2:-}" ]; then echo "       ${2//$'\n'/$'\n'       }" | head -15; fi
}

# expect_pass <label> <cmd...> / expect_reject <label> <cmd...>
# A rejection only counts if the tool ran: exit 126/127 (not executable /
# not found) is a failure of the image, not a successful gate.
expect_pass() {
  local label="$1" out
  shift
  if out="$("$@" 2>&1)"; then ok "$label"; else bad "$label (exit $?)" "$out"; fi
}
expect_reject() {
  local label="$1" out rc
  shift
  out="$("$@" 2>&1)"
  rc=$?
  if [ "$rc" -eq 0 ]; then
    bad "$label: accepted a planted-bad input" "$out"
  elif [ "$rc" -ge 126 ]; then
    bad "$label: tool did not run (exit $rc)" "$out"
  else ok "$label"; fi
}

echo "== 1. Locked versions (${VARIANT}) =="
# -r, not -f: an unreadable lock made jq fail inside the process
# substitution below, so section 1 ran zero checks and still passed.
[ -r "$LOCK" ] || {
  echo "missing or unreadable $LOCK" >&2
  exit 1
}
while IFS=$'\t' read -r name version cmd; do
  # shellcheck disable=SC2086  # version_cmd is a trusted word list from the lock
  out="$($cmd 2>&1)"
  if grep -qF "$version" <<< "$out"; then ok "$name $version"; else bad "$name: expected $version" "$out"; fi
done < <(jq -r --argjson v "$VARIANTS" \
  '.tools[] | select(.variant as $x | $v | index($x)) | [.name, .version, .version_cmd] | @tsv' "$LOCK")

# check_pins <venv> <requirements.in>: every top-level pin is installed.
check_pins() {
  local freeze pin
  freeze="$(uv pip freeze --python "$1" 2>&1)"
  while IFS= read -r pin; do
    if grep -qixF "$pin" <<< "$freeze"; then ok "python $pin"; else bad "python $pin not installed in $1"; fi
  done < <(grep -E '^[A-Za-z0-9_.-]+==' "$2")
}
check_pins "${OPT}/venv" "${ETC}/requirements.in"

while IFS=$'\t' read -r pkg version; do
  installed="$(jq -r .version "${OPT}/node/node_modules/${pkg}/package.json" 2> /dev/null)"
  if [ "$installed" = "$version" ]; then ok "npm $pkg $version"; else bad "npm $pkg: expected $version, got ${installed:-none}"; fi
done < <(jq -r '.dependencies | to_entries[] | [.key, .value] | @tsv' "${OPT}/node/package.json")

if [ "$VARIANT" = ai ]; then
  while IFS=$'\t' read -r pkg version; do
    installed="$(jq -r .version "${OPT}/node-ai/node_modules/${pkg}/package.json" 2> /dev/null)"
    if [ "$installed" = "$version" ]; then ok "npm $pkg $version"; else bad "npm $pkg: expected $version, got ${installed:-none}"; fi
  done < <(jq -r '.dependencies | to_entries[] | [.key, .value] | @tsv' "${OPT}/node-ai/package.json")
  expect_pass "codex runs" codex --version
  expect_pass "gemini runs" gemini --version
fi

echo "== 2. Gates accept clean input and reject planted-bad input =="
t="$(mktemp -d)"
trap 'rm -rf "$t"' EXIT
mkdir -p "$t/clean" "$t/secret" "$t/wf/.github/workflows"
token="ghp_$(head -c 4096 /dev/urandom | LC_ALL=C tr -dc 'A-Za-z0-9' | head -c 36)"
printf 'github_token = "%s"\n' "$token" > "$t/secret/config.py"
printf 'print("hello")\n' > "$t/clean/app.py"

expect_pass "gitleaks: clean dir" gitleaks dir --no-banner "$t/clean"
expect_reject "gitleaks: planted token" gitleaks dir --no-banner "$t/secret"
# detect-secrets only scans paths under the current directory.
if (cd "$t/secret" && detect-secrets scan config.py) | jq -e '.results | length > 0' > /dev/null; then
  ok "detect-secrets: planted token"
else bad "detect-secrets: missed planted token"; fi

# shellcheck disable=SC2016  # the unexpanded $1 is the planted bug
printf '#!/usr/bin/env bash\nrm -rf $1/*\n' > "$t/bad.sh"
expect_reject "shellcheck: unquoted rm -rf" shellcheck "$t/bad.sh"

printf 'FROM debian:latest\nRUN apt-get install curl\n' > "$t/Dockerfile"
expect_reject "hadolint: unpinned FROM + apt" hadolint "$t/Dockerfile"

cat > "$t/wf/.github/workflows/bad.yml" << 'EOF'
on: issues
jobs:
  echo:
    runs-on: ubuntu-latest
    steps:
      - run: echo "${{ github.event.issue.title }}"
EOF
expect_reject "actionlint: script injection" actionlint "$t/wf/.github/workflows/bad.yml"
expect_reject "zizmor: template injection" zizmor --offline "$t/wf/.github/workflows/bad.yml"

printf 'a: 1\na: 2\n' > "$t/dup.yaml"
expect_reject "yamllint: duplicate key" yamllint "$t/dup.yaml"

printf '#Heading\ntext\n' > "$t/bad.md"
expect_reject "markdownlint-cli2: bad heading" markdownlint-cli2 "$t/bad.md"

printf 'import os\n' > "$t/unused.py"
expect_reject "ruff: unused import" ruff check --no-cache "$t/unused.py"

cat > "$t/rule.yaml" << 'EOF'
rules:
  - id: no-eval
    pattern: eval(...)
    message: eval is forbidden
    languages: [python]
    severity: ERROR
EOF
printf 'eval(input())\n' > "$t/evil.py"
expect_reject "semgrep: local rule" env SEMGREP_ENABLE_VERSION_CHECK=0 \
  semgrep scan --metrics=off --disable-version-check --error --quiet --config "$t/rule.yaml" "$t/evil.py"

# trivy covers SBOMs (syft was dropped as a duplicate).
if trivy fs --quiet --offline-scan --skip-db-update --scanners license --format spdx-json "$t/clean" 2> /dev/null \
  | jq -e '.spdxVersion' > /dev/null; then
  ok "trivy: SPDX SBOM from a directory"
else bad "trivy: no SPDX output"; fi

echo "== 3. Offline pre-commit baseline =="
repo="$t/repo"
mkdir -p "$repo/.github/workflows"
cp "$t/clean/app.py" "$repo/"
printf '#!/usr/bin/env bash\nset -euo pipefail\necho "ok"\n' > "$repo/run.sh"
chmod +x "$repo/run.sh"
printf -- '---\nkey: value\n' > "$repo/config.yaml"
printf '{"key": "value"}\n' > "$repo/data.json"
printf '# Title\n\nSome text.\n' > "$repo/README.md"
cat > "$repo/.github/workflows/ci.yml" << 'EOF'
---
name: ci
on: push
permissions: {}
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - run: echo "ok"
EOF
cp "${OPT}/pre-commit/baseline.yaml" "$repo/.pre-commit-config.yaml"
git -C "$repo" init -q
git -C "$repo" add -A
expect_pass "pre-commit baseline: clean repo" \
  env PRE_COMMIT_HOME="$t/pc-home" bash -c "cd '$repo' && pre-commit run --all-files"
cp "$t/secret/config.py" "$repo/"
git -C "$repo" add -A
expect_reject "pre-commit baseline: planted token" \
  env PRE_COMMIT_HOME="$t/pc-home" bash -c "cd '$repo' && pre-commit run --all-files"

if [ "$VARIANT" != core ]; then
  echo "== 4. GitOps / IaC / policy gates (offline) =="
  # kubectl, kubeconform, kind and flux need a cluster, schema
  # downloads or Docker for anything beyond the version check above.
  g="$t/gitops"
  mkdir -p "$g/policy"
  cat > "$g/pod.yaml" << 'YAML'
apiVersion: v1
kind: Pod
metadata:
  name: web
spec:
  containers:
    - name: web
      image: nginx:1.27.0
YAML
  sed 's/nginx:1.27.0/nginx:latest/' "$g/pod.yaml" > "$g/pod-latest.yaml"

  cat > "$g/policy/latest.rego" << 'REGO'
package main
import rego.v1
deny contains msg if {
  some c in input.spec.containers
  endswith(c.image, ":latest")
  msg := sprintf("container %s uses :latest", [c.name])
}
REGO
  expect_pass "conftest: pinned image" conftest test --policy "$g/policy" "$g/pod.yaml"
  expect_reject "conftest: :latest image" conftest test --policy "$g/policy" "$g/pod-latest.yaml"

  printf 'resources:\n  - pod.yaml\n' > "$g/kustomization.yaml"
  expect_pass "kustomize: build" kustomize build "$g"

  expect_pass "helm: create + lint" bash -c "cd '$g' && helm create chart >/dev/null && helm lint chart"
  printf 'apiVersion: v2\n' > "$g/chart/Chart.yaml"
  expect_reject "helm: Chart.yaml missing name/version" helm lint "$g/chart"

  age-keygen -o "$g/age.key" 2> /dev/null
  recipient="$(grep -o 'age1[0-9a-z]*' "$g/age.key")"
  printf 'password: planted-plaintext\n' > "$g/secret.yaml"
  if sops --disable-version-check encrypt --age "$recipient" "$g/secret.yaml" > "$g/secret.enc.yaml" \
    && ! grep -q planted-plaintext "$g/secret.enc.yaml" \
    && SOPS_AGE_KEY_FILE="$g/age.key" sops --disable-version-check decrypt "$g/secret.enc.yaml" | grep -q planted-plaintext; then
    ok "sops + age: encrypt hides plaintext, decrypt restores it"
  else bad "sops + age: round trip failed"; fi
fi

if [ "$VARIANT" = ai ]; then
  echo "== 5. Devcontainer user =="
  if [ "$(id -un)" = dev ] && [ "$(id -u)" = 1000 ]; then ok "runs as dev (1000)"; else bad "expected user dev/1000, got $(id -un)/$(id -u)"; fi
  expect_pass "passwordless sudo" sudo -n true
  expect_pass "zsh present" zsh -c 'exit 0'
  expect_pass "uvx present (MCP servers)" uvx --version
  if [ -n "${NPM_CONFIG_PREFIX:-}" ] && mkdir -p "$NPM_CONFIG_PREFIX" && [ -w "$NPM_CONFIG_PREFIX" ]; then
    ok "user-writable npm prefix for pinned Claude Code install"
  else bad "NPM_CONFIG_PREFIX missing or not writable"; fi

  echo "== 6. Skills, agents and OpenCode config baked in for both harnesses =="
  oc="$HOME/.config/opencode"
  # OpenCode registers Superpowers via skills.paths (plugin node_modules), not links.
  for skill in using-superpowers brainstorming writing-plans test-driven-development \
    systematic-debugging verification-before-completion; do
    for d in "$HOME/.claude/skills" "$oc/node_modules/superpowers/skills"; do
      if [ -f "${d}/${skill}/SKILL.md" ]; then ok "${d#"$HOME"/}: ${skill}"; else bad "${d}/${skill}/SKILL.md missing"; fi
    done
  done
  for skill in gitops-knowledge gitops-repo-audit; do
    for d in "$HOME/.claude/skills" "$oc/skills"; do
      if [ -f "${d}/${skill}/SKILL.md" ]; then ok "${d#"$HOME"/}: ${skill}"; else bad "${d}/${skill}/SKILL.md missing"; fi
    done
  done
  if [ -e "$oc/skills/using-superpowers" ]; then bad "superpowers registered twice for OpenCode (skills/ link + skills.paths)"; else ok "opencode: superpowers registered once"; fi
  for a in planner builder verifier operator; do
    for d in "$HOME/.claude/agents" "$oc/agents"; do
      if [ -f "${d}/${a}.md" ]; then ok "${d#"$HOME"/}: ${a}"; else bad "${d}/${a}.md missing"; fi
    done
  done
  if grep -q '"fast"' "$oc/opencode.jsonc" && ! grep -q '__HOME__' "$oc/opencode.jsonc" \
    && grep -q '"enabled": false' "$oc/fallback.json" && [ ! -e "$oc/tiers.json" ]; then
    ok "opencode config: tier agents, __HOME__ rendered, fallback off, no router"
  else bad "opencode config not the deterministic baked version"; fi

  echo "== 7. Language servers (TS/JS, Python, Go, Java, C/C++, Bash, YAML) =="
  # Each must start and answer, not merely exist on PATH.
  check_lsp() {
    local label="$1" out
    shift
    if out="$("$@" 2>&1)" && [ -n "$out" ]; then ok "lsp ${label}: $(head -1 <<< "$out" | cut -c1-60)"; else bad "lsp ${label}: '$*' failed" "$out"; fi
  }
  check_lsp typescript typescript-language-server --version
  check_lsp tsserver ls -L /usr/local/bin/tsserver
  check_lsp python pyright --version
  check_lsp go gopls version
  check_lsp go-toolchain go version
  check_lsp java java -version
  check_lsp jdtls cat /opt/jdtls/VERSION
  check_lsp c clangd --version
  check_lsp bash bash-language-server --version
  check_lsp yaml ls -L /usr/local/bin/yaml-language-server
  if [ "${OPENCODE_DISABLE_LSP_DOWNLOAD:-}" = true ] && grep -q '"jdtls": {' "$oc/opencode.jsonc"; then
    ok "opencode: lsp on (TS + Java pinned to baked servers), runtime downloads off"
  else bad "opencode: expected pinned lsp servers and OPENCODE_DISABLE_LSP_DOWNLOAD=true"; fi

  echo "== 8. qmd: search works end to end, skill + MCP wired =="
  qd="$(mktemp -d)"
  mkdir -p "$qd/docs" "$qd/.qmd"
  printf '# Rework rate\n\nDeployment rework rate counts unplanned deploys.\n' > "$qd/docs/a.md"
  printf 'collections:\n  t:\n    path: docs\n    pattern: "**/*.md"\n' > "$qd/.qmd/index.yml"
  if out="$(cd "$qd" && git init -q && qmd update 2>&1 && qmd search rework -n 1 2>&1)" && grep -q 'a.md' <<< "$out"; then
    ok "qmd update + search (native sqlite binding loads)"
  else bad "qmd search failed" "$out"; fi
  rm -rf "$qd"
  for d in "$HOME/.claude/skills" "$oc/skills"; do
    if [ -f "$d/qmd/SKILL.md" ]; then ok "${d#"$HOME"/}: qmd skill"; else bad "$d/qmd/SKILL.md missing"; fi
  done
  if grep -q '"qmd"' "$oc/opencode.jsonc"; then ok "opencode: qmd MCP server configured"; else bad "opencode: qmd MCP server missing"; fi
fi

echo
if [ "${#failures[@]}" -gt 0 ]; then
  echo "FAILED ${#failures[@]} check(s), passed ${pass}:"
  printf '  - %s\n' "${failures[@]}"
  exit 1
fi
echo "ALL ${pass} CHECKS PASSED (${VARIANT})"
