#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/bin/codex-gitbranch-hook"

fail() {
  printf 'not ok - %s\n' "$1" >&2
  exit 1
}

pass() {
  printf 'ok - %s\n' "$1"
}

assert_file() {
  [[ -f "$1" ]] || fail "expected file: $1"
}

assert_contains() {
  local file="$1"
  local text="$2"
  grep -Fq "$text" "$file" || fail "expected '$text' in $file"
}

assert_output_contains() {
  local output="$1"
  local text="$2"
  printf '%s' "$output" | grep -Fq "$text" || fail "expected output to contain '$text'"
}

new_home() {
  mktemp -d "${TMPDIR:-/tmp}/codex-gitbranch-hook-home.XXXXXX"
}

run_hook() {
  local home="$1"
  shift
  HOME="$home" PATH="$ROOT/bin:$PATH" "$BIN" "$@"
}

test_global_config_creation() {
  local home config output
  home="$(new_home)"
  output="$(run_hook "$home" install --global)"
  config="$home/.codex/config.toml"

  assert_file "$config"
  assert_contains "$config" "[features]"
  assert_contains "$config" "hooks = true"
  assert_contains "$config" "[[hooks.SessionStart]]"
  assert_contains "$config" "$ROOT/bin/codex-gitbranch-hook"
  assert_contains "$config" "# BEGIN codex-gitbranch-hook managed block"
  assert_output_contains "$output" "Installed global Codex hook."
  pass "global config creation"
}

test_idempotent_global_install() {
  local home config marker_count command_count
  home="$(new_home)"
  run_hook "$home" install --global >/dev/null
  run_hook "$home" install --global >/dev/null
  config="$home/.codex/config.toml"

  marker_count="$(grep -Fc "# BEGIN codex-gitbranch-hook managed block" "$config")"
  command_count="$(grep -Fc "$ROOT/bin/codex-gitbranch-hook" "$config")"

  [[ "$marker_count" = "1" ]] || fail "expected one managed block, got $marker_count"
  [[ "$command_count" = "1" ]] || fail "expected one executable command, got $command_count"
  pass "idempotent global install"
}

test_preserves_unrelated_toml() {
  local home config
  home="$(new_home)"
  mkdir -p "$home/.codex"
  config="$home/.codex/config.toml"
  cat >"$config" <<'EOF'
model = "gpt-5.5"

[profiles.default]
approval_policy = "on-request"
EOF

  run_hook "$home" install --global >/dev/null

  assert_contains "$config" 'model = "gpt-5.5"'
  assert_contains "$config" "[profiles.default]"
  assert_contains "$config" 'approval_policy = "on-request"'
  assert_contains "$config" "hooks = true"
  pass "preserves unrelated TOML"
}

test_preview_non_git() {
  local home dir output
  home="$(new_home)"
  dir="$(mktemp -d "${TMPDIR:-/tmp}/codex-gitbranch-hook-nongit.XXXXXX")"
  output="$(cd "$dir" && run_hook "$home" preview)"

  assert_output_contains "$output" "Not a Git repository."
  pass "preview in non-git folder"
}

test_preview_git() {
  local home dir output
  home="$(new_home)"
  dir="$(mktemp -d "${TMPDIR:-/tmp}/codex-gitbranch-hook-git.XXXXXX")"
  git -C "$dir" init -q
  git -C "$dir" checkout -q -b feature/test
  output="$(cd "$dir" && run_hook "$home" preview)"

  assert_output_contains "$output" "Branch:"
  assert_output_contains "$output" "feature/test"
  pass "preview in git folder"
}

test_doctor_output() {
  local home output
  home="$(new_home)"
  run_hook "$home" install --global >/dev/null
  output="$(run_hook "$home" doctor)"

  assert_output_contains "$output" "Codex Git Branch Hook Doctor"
  assert_output_contains "$output" "Executable on PATH:"
  assert_output_contains "$output" "Hooks feature:"
  assert_output_contains "$output" "SessionStart hook:"
  assert_output_contains "$output" "Git:"
  pass "doctor output"
}

test_global_uninstall() {
  local home config
  home="$(new_home)"
  run_hook "$home" install --global >/dev/null
  run_hook "$home" uninstall --global >/dev/null
  config="$home/.codex/config.toml"

  if grep -Fq "# BEGIN codex-gitbranch-hook managed block" "$config"; then
    fail "managed block should be removed"
  fi

  assert_contains "$config" "hooks = true"
  pass "global uninstall removes managed block only"
}

test_global_config_creation
test_idempotent_global_install
test_preserves_unrelated_toml
test_preview_non_git
test_preview_git
test_doctor_output
test_global_uninstall
