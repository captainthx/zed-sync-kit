#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="${ZED_SOURCE_DIR:-}"

detect_zed_config_dir() {
  if [ -n "${source_dir}" ]; then
    printf '%s\n' "${source_dir}"
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

copy_optional_file() {
  local name="$1"
  if [ -f "${zed_dir}/${name}" ]; then
    cp "${zed_dir}/${name}" "${repo_zed_dir}/${name}"
  else
    rm -f "${repo_zed_dir:?}/${name}"
  fi
}

copy_optional_dir() {
  local name="$1"
  if [ -d "${zed_dir}/${name}" ]; then
    rm -rf "${repo_zed_dir:?}/${name}"
    cp -R "${zed_dir}/${name}" "${repo_zed_dir}/${name}"
  else
    rm -rf "${repo_zed_dir:?}/${name}"
  fi
}

zed_dir="$(detect_zed_config_dir)"
repo_zed_dir="${repo_root}/zed"

mkdir -p "${repo_zed_dir}"

copy_optional_file "settings.json"
copy_optional_file "keymap.json"
copy_optional_file "tasks.json"
copy_optional_dir "themes"

printf 'Exported Zed config from %s to %s\n' "${zed_dir}" "${repo_zed_dir}"
