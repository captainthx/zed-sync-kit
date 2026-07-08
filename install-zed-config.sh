#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${ZED_TARGET_DIR:-}"

detect_js_runtime() {
  if command -v node >/dev/null 2>&1; then
    printf '%s\n' "node"
    return
  fi

  if command -v bun >/dev/null 2>&1; then
    printf '%s\n' "bun"
    return
  fi

  printf 'Missing required command: node or bun\n' >&2
  exit 1
}

detect_zed_config_dir() {
  if [ -n "${target_dir}" ]; then
    printf '%s\n' "${target_dir}"
    return
  fi

  if [ -d "${HOME}/.config/zed" ]; then
    printf '%s\n' "${HOME}/.config/zed"
    return
  fi

  if [ -d "${HOME}/.zed" ]; then
    printf '%s\n' "${HOME}/.zed"
    return
  fi

  printf '%s\n' "${HOME}/.config/zed"
}

backup_dir() {
  if [ ! -d "${zed_dir}" ]; then
    return
  fi

  local timestamp
  timestamp="$(date +%Y%m%d-%H%M%S)"
  local backup_root="${HOME}/.zed-sync-backups/${timestamp}"

  mkdir -p "${backup_root}"

  for name in settings.json settings.local.json keymap.json tasks.json themes; do
    if [ -e "${zed_dir}/${name}" ]; then
      cp -R "${zed_dir}/${name}" "${backup_root}/${name}"
    fi
  done
}

install_optional_file() {
  local name="$1"
  if [ -f "${repo_zed_dir}/${name}" ]; then
    cp "${repo_zed_dir}/${name}" "${zed_dir}/${name}"
  fi
}

install_optional_dir() {
  local name="$1"
  if [ -d "${repo_zed_dir}/${name}" ]; then
    rm -rf "${zed_dir:?}/${name}"
    cp -R "${repo_zed_dir}/${name}" "${zed_dir}/${name}"
  fi
}

repo_zed_dir="${repo_root}/zed"
zed_dir="$(detect_zed_config_dir)"
settings_helper="${repo_root}/settings-sync.js"
js_runtime="$(detect_js_runtime)"

if [ ! -d "${repo_zed_dir}" ]; then
  printf 'Missing repo config directory: %s\n' "${repo_zed_dir}" >&2
  exit 1
fi

if [ ! -f "${settings_helper}" ]; then
  printf 'Missing settings helper: %s\n' "${settings_helper}" >&2
  exit 1
fi

mkdir -p "${zed_dir}"
backup_dir

if [ -f "${repo_zed_dir}/settings.json" ]; then
  "${js_runtime}" "${settings_helper}" install \
    "${repo_zed_dir}/settings.json" \
    "${zed_dir}/settings.local.json" \
    "${zed_dir}/settings.json"
fi

install_optional_file "keymap.json"
install_optional_file "tasks.json"
install_optional_dir "themes"

printf 'Installed Zed config into %s\n' "${zed_dir}"
