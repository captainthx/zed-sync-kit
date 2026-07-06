#!/usr/bin/env bash
set -euo pipefail

template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

repo_root="${tmp_root}/repo"
home_one="${tmp_root}/home-one"
home_two="${tmp_root}/home-two"

mkdir -p "${repo_root}" "${home_one}/.config/zed/themes" "${home_two}"
cp "${template_root}/export-zed-config.sh" "${repo_root}/export-zed-config.sh"
cp "${template_root}/install-zed-config.sh" "${repo_root}/install-zed-config.sh"
chmod +x "${repo_root}/export-zed-config.sh" "${repo_root}/install-zed-config.sh"

printf '{ "theme": "One Dark" }\n' > "${home_one}/.config/zed/settings.json"
printf '[{"bindings":{"cmd-j":"editor::JoinLines"}}]\n' > "${home_one}/.config/zed/keymap.json"
printf '[{"label":"hello","command":"echo hi"}]\n' > "${home_one}/.config/zed/tasks.json"
printf '{ "name": "Demo Theme" }\n' > "${home_one}/.config/zed/themes/demo.json"

HOME="${home_one}" "${repo_root}/export-zed-config.sh" >/dev/null
HOME="${home_two}" "${repo_root}/install-zed-config.sh" >/dev/null

cmp "${home_one}/.config/zed/settings.json" "${home_two}/.config/zed/settings.json"
cmp "${home_one}/.config/zed/keymap.json" "${home_two}/.config/zed/keymap.json"
cmp "${home_one}/.config/zed/tasks.json" "${home_two}/.config/zed/tasks.json"
cmp "${home_one}/.config/zed/themes/demo.json" "${home_two}/.config/zed/themes/demo.json"

printf 'ok\n'
