#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="${ZED_SOURCE_DIR:-}"
push_after_export=0
commit_message="${ZED_SYNC_COMMIT_MESSAGE:-Export Zed config}"

while [ $# -gt 0 ]; do
  case "$1" in
    --push)
      push_after_export=1
      shift
      ;;
    --message)
      if [ $# -lt 2 ]; then
        printf 'Missing value for --message\n' >&2
        exit 1
      fi
      commit_message="$2"
      shift 2
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      printf 'Usage: %s [--push] [--message "commit message"]\n' "$(basename "$0")" >&2
      exit 1
      ;;
  esac
done

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

if [ "${push_after_export}" -eq 1 ]; then
  if ! git -C "${repo_root}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    printf 'Not a git repository: %s\n' "${repo_root}" >&2
    exit 1
  fi

  git -C "${repo_root}" add zed

  if git -C "${repo_root}" diff --cached --quiet; then
    printf 'No config changes to commit\n'
    exit 0
  fi

  git -C "${repo_root}" commit -m "${commit_message}"
  git -C "${repo_root}" push
fi
