# Zed Sync Kit

English | [ภาษาไทย](./README.th.md)

Sync `Zed` config across your own machines with `gh`, `git`, one public script, and a local-only secret override file.

## Requirements

- `gh`
- `git`
- `bash`
- `node` or `bun`
- `Zed` installed on the target machine
- `gh auth login` completed

## Fast Start

Primary machine:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export
```

New machine:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install
```

## How It Works

`export`

- runs on the primary machine
- creates `YOUR_GH_USER/zed-config` as a private repo if it does not exist yet
- reads local Zed config
- moves supported secrets into `settings.local.json`
- pushes that config to the private repo

`install`

- runs on the new machine
- reads config from `YOUR_GH_USER/zed-config`
- merges `settings.local.json` if it exists on that machine
- backs up the current local Zed config
- installs the synced config locally

`init`

- optional
- creates the private `zed-config` repo ahead of time

## What Gets Synced

- `settings.json`
- `keymap.json`
- `tasks.json`
- `themes/`

Not synced:

- caches
- logs
- sessions
- machine-local state
- secrets stored in `settings.local.json`

## Local Secrets

`zed-sync` uses `~/.config/zed/settings.local.json` for local-only overrides.

- this file is not pushed to `zed-config`
- `install` merges it into `settings.json` on that machine
- `export` keeps the repo copy sanitized

v1 secret extraction only covers keys under `context_servers.*.settings` whose names end with:

- `_key`
- `_token`
- `_secret`

Example:

```json
{
  "context_servers": {
    "mcp-server-context7": {
      "settings": {
        "context7_api_key": "your-local-secret"
      }
    }
  }
}
```

## Commands

Create the private repo explicitly:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- init
```

Export config:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export
```

Install config:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install
```

## Common Options

Use a custom repo:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --repo YOUR_USER/zed-config
```

Export from a custom source path:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --source /custom/zed/path
```

Install into a custom target path:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install --target /custom/zed/path
```

Test with a separate branch:

```bash
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- export --ref smoke-test
curl -fsSL https://raw.githubusercontent.com/captainthx/zed-sync-kit/main/zed-sync.sh | bash -s -- install --ref smoke-test --target /tmp/zed-test
```

## Notes

- `install` assumes you already ran `export` at least once.
- `settings.local.json` is for `zed-sync`, not a native extra settings file that Zed reads by itself.
- `git` handles the local repo work. `gh` handles GitHub auth and private repo access.
- This is config sync, not account sync like VS Code.
