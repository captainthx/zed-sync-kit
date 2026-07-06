# Zed Sync Kit

English | [ภาษาไทย](./README.th.md)

Sync `Zed` config across your own machines with `gh`, `git`, and one public script.

## Requirements

- `gh`
- `git`
- `bash`
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
- pushes that config to the private repo

`install`

- runs on the new machine
- reads config from `YOUR_GH_USER/zed-config`
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
- `git` handles the local repo work. `gh` handles GitHub auth and private repo access.
- This is config sync, not account sync like VS Code.
