# Dotfiles

Personal dotfiles and bootstrap scripts for macOS and Linux (Debian).

## Fresh setup

### macOS

```bash
xcode-select --install
git clone https://github.com/sanderbongers/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
make install
```

The clone uses HTTPS because a fresh Mac has no SSH keys yet. `make install` prompts once for the machine's profile (work or personal, persisted in `.machine-profile`), enables Touch ID for sudo, installs Homebrew and the packages for that profile, snapshots the default settings into `baseline/`, and links the dotfiles with GNU Stow.

When the 1Password SSH agent can authenticate to GitHub, a later `make install`/`make update` switches the `origin` remote to SSH automatically.

### Linux (Debian)

```bash
git clone https://github.com/sanderbongers/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
make install
```

Sets up apt sources (fish, Caddy, 1Password, backports), installs packages, Neovim, sets locale and fish as the login shell, and links the dotfiles.

Packages marked with a `.linux-ignore` file in their `stow/` directory are skipped.

## Everyday use

```bash
make update
```

Pulls the latest changes and idempotently runs the installer/updater.

## Commands

| Command                     | Description                                                        |
| --------------------------- | ------------------------------------------------------------------ |
| `make install`              | Install dotfiles and packages                                      |
| `make update`               | Pull latest changes, then install                                  |
| `make link`                 | Symlink all dotfiles into the home directory                       |
| `make unlink`               | Remove all dotfile symlinks                                        |
| `make doctor`               | Dry-run the linker and verify Homebrew packages are installed      |
| `make test-links`           | Run the linker test suite in a throwaway home directory            |
| `make install-packages`     | Install Homebrew packages for this machine's profile               |
| `make dump-packages`        | Write installed Homebrew packages into the shared `Brewfile`       |
| `make apply-macos-defaults` | Apply the macOS defaults you have uncommented in the checklist     |
| `make snapshot-macos`       | Snapshot current macOS defaults into `baseline/` for later diffing |

## Homebrew bundle

`Brewfile` contains packages installed on every machine. `Brewfile.work` and `Brewfile.personal` are for
profile-specific additions.

`make dump-packages` writes everything to the shared `Brewfile`, after which new entries can be moved to the
profile-specific files manually before committing.

## macOS settings

1. Set the preference by hand in System Settings (launch the app at least once so its domain exists),
   then run `make snapshot-macos`.
2. Change the setting in the UI.
3. Run `make snapshot-macos` again and diff the two new directories in `baseline/`.
4. Uncomment the matching line in `scripts/macos/apply-defaults.sh` (or add a new `defaults write` derived from the
   diff), then run `make apply-macos-defaults` to apply them.

Note: Some settings do not live in `defaults` at all and will not show up in a snapshot diff.
