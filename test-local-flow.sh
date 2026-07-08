#!/usr/bin/env bash
set -euo pipefail

template_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp_root="$(mktemp -d)"
trap 'rm -rf "${tmp_root}"' EXIT

repo_root="${tmp_root}/repo"
home_plain_source="${tmp_root}/home-plain-source"
home_plain_target="${tmp_root}/home-plain-target"
home_secret_source="${tmp_root}/home-secret-source"
home_secret_target="${tmp_root}/home-secret-target"
home_secret_target_with_local="${tmp_root}/home-secret-target-with-local"

mkdir -p \
  "${repo_root}" \
  "${home_plain_source}/.config/zed/themes" \
  "${home_plain_target}" \
  "${home_secret_source}/.config/zed/themes" \
  "${home_secret_target}" \
  "${home_secret_target_with_local}"

cp "${template_root}/export-zed-config.sh" "${repo_root}/export-zed-config.sh"
cp "${template_root}/install-zed-config.sh" "${repo_root}/install-zed-config.sh"
cp "${template_root}/settings-sync.js" "${repo_root}/settings-sync.js"
chmod +x "${repo_root}/export-zed-config.sh" "${repo_root}/install-zed-config.sh" "${repo_root}/settings-sync.js"

printf '{ "theme": "One Dark" }\n' > "${home_plain_source}/.config/zed/settings.json"
printf '[{"bindings":{"cmd-j":"editor::JoinLines"}}]\n' > "${home_plain_source}/.config/zed/keymap.json"
printf '[{"label":"hello","command":"echo hi"}]\n' > "${home_plain_source}/.config/zed/tasks.json"
printf '{ "name": "Demo Theme" }\n' > "${home_plain_source}/.config/zed/themes/demo.json"

HOME="${home_plain_source}" "${repo_root}/export-zed-config.sh" >/dev/null
HOME="${home_plain_target}" "${repo_root}/install-zed-config.sh" >/dev/null

cmp "${home_plain_source}/.config/zed/settings.json" "${home_plain_target}/.config/zed/settings.json"
cmp "${home_plain_source}/.config/zed/keymap.json" "${home_plain_target}/.config/zed/keymap.json"
cmp "${home_plain_source}/.config/zed/tasks.json" "${home_plain_target}/.config/zed/tasks.json"
cmp "${home_plain_source}/.config/zed/themes/demo.json" "${home_plain_target}/.config/zed/themes/demo.json"

cat > "${home_secret_source}/.config/zed/settings.json" <<'EOF'
// jsonc is allowed on input
{
  "context_servers": {
    "mcp-server-context7": {
      "enabled": true,
      "settings": {
        "context7_api_key": "ctx7-secret",
      },
    },
  },
  "theme": "One Dark",
}
EOF

HOME="${home_secret_source}" "${repo_root}/export-zed-config.sh" >/dev/null

test -f "${home_secret_source}/.config/zed/settings.local.json"
rtk rg -q 'ctx7-secret' "${home_secret_source}/.config/zed/settings.local.json"
! rtk rg -q 'ctx7-secret' "${repo_root}/zed/settings.json"
rtk rg -q 'ctx7-secret' "${home_secret_source}/.config/zed/settings.json"

HOME="${home_secret_target}" "${repo_root}/install-zed-config.sh" >/dev/null
! rtk rg -q 'ctx7-secret' "${home_secret_target}/.config/zed/settings.json"

mkdir -p "${home_secret_target_with_local}/.config/zed"
cp "${home_secret_source}/.config/zed/settings.local.json" "${home_secret_target_with_local}/.config/zed/settings.local.json"
HOME="${home_secret_target_with_local}" "${repo_root}/install-zed-config.sh" >/dev/null
rtk rg -q 'ctx7-secret' "${home_secret_target_with_local}/.config/zed/settings.json"

printf 'ok\n'
