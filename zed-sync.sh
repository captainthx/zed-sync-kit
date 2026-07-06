#!/usr/bin/env bash
set -euo pipefail

kit_repo_slug="${ZED_SYNC_KIT_REPO:-captainthx/zed-sync-kit}"
kit_ref="${ZED_SYNC_KIT_REF:-main}"

usage() {
  cat <<'EOF' >&2
Usage:
  bash zed-sync.sh init [--repo OWNER/REPO]
  bash zed-sync.sh export [--repo OWNER/REPO] [--ref BRANCH] [--source PATH] [--message TEXT]
  bash zed-sync.sh install [--repo OWNER/REPO] [--ref BRANCH] [--target PATH]

Defaults:
  --repo   current-gh-user/zed-config
  --ref    main
EOF
}

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

ensure_auth() {
  if ! gh auth status >/dev/null 2>&1; then
    printf 'gh is not authenticated. Run: gh auth login\n' >&2
    exit 1
  fi
}

current_user() {
  gh api user --jq .login
}

download_raw() {
  local name="$1"
  local dest="$2"
  curl -fsSL "https://raw.githubusercontent.com/${kit_repo_slug}/${kit_ref}/${name}" -o "${dest}"
}

write_private_repo_scaffold() {
  local repo_dir="$1"

  mkdir -p "${repo_dir}/zed"

  cat > "${repo_dir}/README.md" <<'EOF'
# zed-config

Private repo for Zed config shared across your own machines.

This repo is meant to be used by the public `zed-sync-kit` scripts.
EOF

  cat > "${repo_dir}/.gitignore" <<'EOF'
zed/.DS_Store
EOF
}

clone_or_create_repo() {
  local repo_slug="$1"
  local repo_dir="$2"

  if gh repo view "${repo_slug}" >/dev/null 2>&1; then
    gh repo clone "${repo_slug}" "${repo_dir}" -- --depth=1 >/dev/null
    return
  fi

  gh repo create "${repo_slug}" --private >/dev/null
  mkdir -p "${repo_dir}"
  git -C "${repo_dir}" init >/dev/null
  git -C "${repo_dir}" branch -m main
  git -C "${repo_dir}" remote add origin "https://github.com/${repo_slug}.git"
  write_private_repo_scaffold "${repo_dir}"
  git -C "${repo_dir}" add .
  git -C "${repo_dir}" commit -m "Initialize zed-config repo" >/dev/null
  git -C "${repo_dir}" push -u origin main >/dev/null
}

checkout_ref() {
  local repo_dir="$1"
  local repo_ref="$2"

  if [ "${repo_ref}" = "main" ]; then
    git -C "${repo_dir}" checkout main >/dev/null 2>&1 || true
    return
  fi

  if git -C "${repo_dir}" ls-remote --exit-code --heads origin "${repo_ref}" >/dev/null 2>&1; then
    git -C "${repo_dir}" fetch origin "${repo_ref}:refs/remotes/origin/${repo_ref}" >/dev/null 2>&1
    git -C "${repo_dir}" checkout -B "${repo_ref}" "origin/${repo_ref}" >/dev/null
  else
    git -C "${repo_dir}" checkout -b "${repo_ref}" >/dev/null
  fi
}

command_name="${1:-}"

if [ -z "${command_name}" ]; then
  usage
  exit 1
fi

shift

repo_slug=""
repo_ref="main"
source_dir=""
target_dir=""
commit_message="Export Zed config"

while [ $# -gt 0 ]; do
  case "$1" in
    --repo)
      repo_slug="${2:-}"
      shift 2
      ;;
    --ref)
      repo_ref="${2:-}"
      shift 2
      ;;
    --source)
      source_dir="${2:-}"
      shift 2
      ;;
    --target)
      target_dir="${2:-}"
      shift 2
      ;;
    --message)
      commit_message="${2:-}"
      shift 2
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      usage
      exit 1
      ;;
  esac
done

require_cmd gh
require_cmd git
require_cmd curl
require_cmd bash
ensure_auth

if [ -z "${repo_slug}" ]; then
  repo_slug="$(current_user)/zed-config"
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT
repo_dir="${tmp_root}/repo"

case "${command_name}" in
  init)
    clone_or_create_repo "${repo_slug}" "${repo_dir}"
    printf 'Ready: %s\n' "${repo_slug}"
    ;;
  export)
    clone_or_create_repo "${repo_slug}" "${repo_dir}"
    checkout_ref "${repo_dir}" "${repo_ref}"
    download_raw "export-zed-config.sh" "${repo_dir}/export-zed-config.sh"
    chmod +x "${repo_dir}/export-zed-config.sh"
    if [ -n "${source_dir}" ]; then
      ZED_SOURCE_DIR="${source_dir}" bash "${repo_dir}/export-zed-config.sh" --push --message "${commit_message}"
    else
      bash "${repo_dir}/export-zed-config.sh" --push --message "${commit_message}"
    fi
    ;;
  install)
    clone_or_create_repo "${repo_slug}" "${repo_dir}"
    checkout_ref "${repo_dir}" "${repo_ref}"
    download_raw "install-zed-config.sh" "${repo_dir}/install-zed-config.sh"
    chmod +x "${repo_dir}/install-zed-config.sh"
    if [ -n "${target_dir}" ]; then
      ZED_TARGET_DIR="${target_dir}" bash "${repo_dir}/install-zed-config.sh"
    else
      bash "${repo_dir}/install-zed-config.sh"
    fi
    ;;
  *)
    printf 'Unknown command: %s\n' "${command_name}" >&2
    usage
    exit 1
    ;;
esac
