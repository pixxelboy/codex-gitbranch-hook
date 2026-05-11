#!/usr/bin/env bash
set -euo pipefail

# Codex sends hook payload JSON on stdin. This hook does not need to parse it:
# Codex runs command hooks from the session working directory, which is enough
# for Git to find the active repository.

format_path() {
  local path="$1"
  local home="${HOME:-}"

  if [[ -n "$home" && "$path" == "$home" ]]; then
    printf '~'
  elif [[ -n "$home" && "$path" == "$home"/* ]]; then
    printf '%s/%s' '~' "${path#"$home"/}"
  else
    printf '%s' "$path"
  fi
}

branch_icon() {
  case "${CODEX_GITBRANCH_ICON:-nerd}" in
    nerd|"")
      printf ''
      ;;
    emoji)
      printf '🌿'
      ;;
    text)
      printf 'git:'
      ;;
    none)
      printf ''
      ;;
    *)
      printf ''
      ;;
  esac
}

format_branch() {
  local branch="$1"
  local icon
  icon="$(branch_icon)"

  if [[ -n "$icon" ]]; then
    printf '%s %s' "$icon" "$branch"
  else
    printf '%s' "$branch"
  fi
}

print_report() {
  local repository="$1"
  local branch="$2"

  printf 'Codex Git Branch Hook\n\n'
  printf 'Repository:\n%s\n\n' "$repository"
  printf 'Branch:\n%s\n\n' "$(format_branch "$branch")"
  printf 'Reminder:\nVerify you are working on the expected branch before editing files.\n'
}

current_directory() {
  pwd -P 2>/dev/null || pwd
}

main() {
  local cwd
  cwd="$(current_directory)"

  if ! command -v git >/dev/null 2>&1; then
    print_report "$(format_path "$cwd")" "Git is not installed or not available on PATH."
    return 0
  fi

  local repo_root
  repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"

  if [[ -z "$repo_root" ]]; then
    print_report "$(format_path "$cwd")" "Not a Git repository."
    return 0
  fi

  local branch
  branch="$(git -C "$repo_root" symbolic-ref --quiet --short HEAD 2>/dev/null || true)"

  if [[ -z "$branch" ]]; then
    local commit
    commit="$(git -C "$repo_root" rev-parse --short HEAD 2>/dev/null || true)"

    if [[ -n "$commit" ]]; then
      branch="detached HEAD ($commit)"
    else
      branch="detached HEAD (unknown commit)"
    fi
  fi

  print_report "$(format_path "$repo_root")" "$branch"
}

main "$@"
