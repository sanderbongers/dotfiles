# Dotfiles

My dotfiles for macOS and Debian. Managed with GNU Stow.

## Setup

On a fresh Mac, install the command line tools first:

```sh
xcode-select --install
```

Then, on either platform:

```sh
git clone https://github.com/sanderbongers/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
make install
```

On macOS, choose `personal` or `work` when prompted. The choice is saved in `.machine-profile`.

iTerm2 is configured to use the settings in `config/iterm2/`. Restart iTerm2 if it was running.

## Updates

```sh
make update   # Pull remote changes, install missing packages and update Fish plugins
make upgrade  # Upgrade packages
```

## Layout

- `config/`: app and service configuration managed outside Stow
- `homebrew/`: shared and machine-specific Brewfiles
- `scripts/`: setup and maintenance
- `stow/`: dotfiles linked into my home directory
- `tests/`: shell tests

Stow packages with a `.linux-ignore` file are skipped on Linux.

## Homebrew

Use `make dump-packages` to write installed packages to the Brewfiles. New entries get added to the shared
`homebrew/Brewfile`, from where they can optionally be moved to `Brewfile.personal` or `Brewfile.work`.

To minimise update dialogs, disable an app's own updater and make `make upgrade` keep it up to date by adding it to
`HOMEBREW_UPGRADE_GREEDY_CASKS` in `stow/homebrew/.homebrew/brew.env`.

## macOS defaults

Edit `scripts/macos/apply-defaults.sh`, then run `make apply-macos-defaults`.

To find a setting, run `make snapshot-macos` before and after changing it in the UI. Compare the snapshots in
`baseline/`.

## Commands

Run `make help` for all commands.
