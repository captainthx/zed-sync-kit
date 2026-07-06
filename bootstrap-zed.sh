#!/usr/bin/env bash
set -euo pipefail

if [ "${1:-}" = "" ]; then
  printf 'Usage: bash bootstrap-zed.sh OWNER/REPO\n' >&2
  exit 1
fi

repo_slug="$1"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    printf 'Missing required command: %s\n' "$1" >&2
    exit 1
  fi
}

require_cmd gh
require_cmd git

if ! gh auth status >/dev/null 2>&1; then
  printf 'gh is not authenticated. Run: gh auth login\n' >&2
  exit 1
fi

tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

gh repo clone "${repo_slug}" "${tmp_root}/repo" -- --depth=1 >/dev/null
bash "${tmp_root}/repo/install-zed-config.sh"
