# Zed Sync Kit

Minimal GitHub-based sync flow for `Zed` config across your own machines.

This repo is the public side of the setup:

- public bootstrap script for `curl`
- scripts to export and install config
- the working flow in one place

Your actual Zed config should live in a separate **private** repo.

## What Gets Synced

Only durable config:

- `settings.json`
- `keymap.json`
- `tasks.json`
- `themes/`

Skipped on purpose:

- caches
- logs
- sessions
- recent projects
- installed extension binaries

For extensions, use `auto_install_extensions` inside `settings.json`.

## Repo Split

Use two repos:

1. `zed-sync-kit`
   Public repo. Hosts this README and `bootstrap-zed.sh`.
2. `zed-config`
   Private repo. Stores your real Zed config plus the export/install scripts.

That split is the practical way to keep `curl` simple while keeping your config private.

## Files In This Repo

- `bootstrap-zed.sh`
- `export-zed-config.sh`
- `install-zed-config.sh`
- `test-local-flow.sh`

The bootstrap script is the only file that must be public for the one-liner flow.
The export/install scripts can also be copied into your private `zed-config` repo as-is.

## Flow

### 1. Create The Private Config Repo

On any machine where `gh` is logged in:

```bash
gh repo create YOUR_USER/zed-config --private --clone
cd zed-config
cp /path/to/zed-sync-kit/export-zed-config.sh .
cp /path/to/zed-sync-kit/install-zed-config.sh .
mkdir -p zed
git add .
git commit -m "Initialize Zed config repo"
git push
```

If you want, you can also copy `test-local-flow.sh` into that repo for local checks.

### 2. Export From The Primary Machine

On the machine that already has your preferred Zed setup:

```bash
cd /path/to/zed-config
./export-zed-config.sh
git add .
git commit -m "Export Zed config"
git push
```

What it does:

1. Detects your Zed config directory
2. Copies supported config into `./zed/`
3. Leaves Git to handle history and sync

## 3. Install On A New Machine

Before running install:

1. install `gh`
2. run `gh auth login`
3. install `Zed` once

Then run:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/zed-sync-kit/main/bootstrap-zed.sh | bash -s -- YOUR_USER/zed-config
```

What it does:

1. Checks that `gh` and `git` exist
2. Checks `gh auth status`
3. Clones your private `zed-config` repo into a temp directory
4. Runs `install-zed-config.sh`
5. Backs up any existing local Zed config
6. Copies the synced config into Zed's config path
7. Deletes the temp directory

## 4. Verify

Open `Zed` and check:

- theme
- key bindings
- tasks
- any custom theme files

If `auto_install_extensions` is defined in `settings.json`, extensions should install on launch.

## Expected Config Paths

The scripts check these paths in this order:

- `~/.config/zed`
- `~/.zed`

You can override detection if needed:

```bash
ZED_SOURCE_DIR=/custom/path ./export-zed-config.sh
ZED_TARGET_DIR=/custom/path ./install-zed-config.sh
```

## Example `settings.json` Snippet

```json
{
  "theme": "One Dark",
  "base_keymap": "VSCode",
  "auto_install_extensions": {
    "html": true,
    "toml": true,
    "dockerfile": true
  }
}
```

## Test

Local smoke test:

```bash
bash ./test-local-flow.sh
```

It creates two temporary fake home directories, exports config from one, installs into the other, and compares the results.

## Notes

- The bootstrap script is safe enough for self-use if you control the repo and the GitHub account.
- `curl | bash` still means "run remote code", so keep the bootstrap script tiny and readable.
- This repo gives you a stable flow, not account-level sync like VS Code.
