#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
target_dir="${ZED_TARGET_DIR:-}"

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

  for name in settings.json keymap.json tasks.json themes; do
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

if [ ! -d "${repo_zed_dir}" ]; then
  printf 'Missing repo config directory: %s\n' "${repo_zed_dir}" >&2
  exit 1
fi

mkdir -p "${zed_dir}"
backup_dir

install_optional_file "settings.json"
install_optional_file "keymap.json"
install_optional_file "tasks.json"
install_optional_dir "themes"

printf 'Installed Zed config into %s\n' "${zed_dir}"
