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

Use `make dump-packages` to write installed packages to the shared `homebrew/Brewfile`. Then optionally move out
profile-specific entries to `Brewfile.personal` or `Brewfile.work`.

## iTerm2

In **Settings → General → Settings**, enable **Load settings from a custom folder or URL**. Select the settings in this
repository's `config/iterm2/` folder, then restart iTerm2.

## macOS defaults

Edit `scripts/macos/apply-defaults.sh`, then run `make apply-macos-defaults`.

To find a setting, run `make snapshot-macos` before and after changing it in the UI. Compare the snapshots in
`baseline/`.

## Commands

Run `make help` for all commands.
