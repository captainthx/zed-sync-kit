# Zed Sync Kit

English | [ภาษาไทย](./README.th.md)

Minimal GitHub-based sync flow for `Zed` config across your own machines.

Tool split:

- `git` handles local repository work: `add`, `commit`, `push`
- `gh` handles GitHub access: auth, repo create, repo clone for private repos

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

## Script Data Flow

`export-zed-config.sh`

1. Reads local Zed config from `~/.config/zed` or `~/.zed`
2. Copies those files into `zed/` inside the private `zed-config` repo
3. Optional: with `--push`, it also runs local `git add zed`, `git commit`, and `git push`

```text
primary machine Zed config -> private zed-config repo/zed -> GitHub
```

`install-zed-config.sh`

1. Reads `zed/` from the private `zed-config` repo
2. Backs up the current machine's local Zed config
3. Copies the synced files into the machine's Zed config path

```text
GitHub private zed-config repo/zed -> local machine Zed config path
```

`bootstrap-zed.sh`

1. Downloads from the public `zed-sync-kit` repo
2. Uses `gh` auth to clone the private `zed-config` repo, optionally from a test branch, into a temp directory
3. Runs `install-zed-config.sh`
4. Deletes the temp directory

Short version:

- `export` and `install` work on files and a local repo, so they use `git`
- `bootstrap` needs GitHub auth to reach a private repo, so it uses `gh`

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

Why `gh` here:

- this step is about creating a GitHub repo
- `gh repo create` is simpler than creating it manually in the browser

### 2. Export From The Primary Machine

On the machine that already has your preferred Zed setup:

```bash
cd /path/to/zed-config
./export-zed-config.sh
git add .
git commit -m "Export Zed config"
git push
```

Or in one command:

```bash
cd /path/to/zed-config
./export-zed-config.sh --push
```

Optional custom commit message:

```bash
./export-zed-config.sh --push --message "Update Zed config"
```

What it does:

1. Detects your Zed config directory
2. Copies supported config into `./zed/`
3. If you use `--push`, it also uses local `git` to commit and push to the private repo's remote

Why `git` here:

- at this point you are already inside the local `zed-config` repo
- the script is managing files in that repo, not creating or discovering repos on GitHub

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

Why `gh` here:

- a plain `curl` script cannot directly read your private config repo
- `gh` reuses your logged-in GitHub session to access that private repo cleanly

If you want to force a specific config path:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/zed-sync-kit/main/bootstrap-zed.sh | bash -s -- YOUR_USER/zed-config --target /custom/zed/path
```

This is mostly useful for testing. In normal use you can omit the second argument.

If you want to test from a separate branch first:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/zed-sync-kit/main/bootstrap-zed.sh | bash -s -- YOUR_USER/zed-config --ref smoke-test --target /tmp/zed-test
```

That lets you verify a branch before merging config changes into `main`.

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

You can combine the source override with auto-push:

```bash
ZED_SOURCE_DIR=/custom/path ./export-zed-config.sh --push
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
- If you feel confused about `git` vs `gh`, remember: `git` is for the repo on disk, `gh` is for GitHub.
