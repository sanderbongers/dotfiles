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
- `packages/`: Homebrew and apt package declarations
- `scripts/`: setup and maintenance
- `stow/`: dotfiles linked into my home directory
- `tests/`: shell tests

Stow packages with a `.linux-ignore` file are skipped on Linux.

## Homebrew

Use `make dump-packages` to write installed packages to the Brewfiles. New entries get added to the shared
`packages/homebrew/Brewfile`, from where they can optionally be moved to `Brewfile.personal` or `Brewfile.work`.

To minimise update dialogs, disable an app's own updater and make `make upgrade` keep it up to date by adding it to
`HOMEBREW_UPGRADE_GREEDY_CASKS` in `stow/homebrew/.homebrew/brew.env`.

## Debian packages

Edit `packages/apt/packages.txt` for regular packages and `packages/apt/backports.txt` for packages installed from
Backports.

## macOS defaults

Edit `scripts/macos/apply-defaults.sh`, give Full Disk Access to iTerm2 in System Settings > Privacy & Security, then
run `make apply-macos-defaults`.

To find a setting, run `make snapshot-macos` before and after changing it in the UI. Compare the snapshots in
`baseline/`.

### Caps Lock delay

`stow/macos/Library/LaunchAgents/local.caps-lock-delay.plist` removes the Caps Lock activation delay at login.
Keep Raycast's Hyper Key disabled, as it still filters short taps. The `macos` Stow package is skipped on Linux.

Link and activate it once:

```fish
bin/link
launchctl bootstrap gui/(id -u) ~/Library/LaunchAgents/local.caps-lock-delay.plist
```

To change the delay, edit `CapsLockDelayOverride` in the plist (milliseconds), then reload:

```fish
launchctl bootout gui/(id -u)/local.caps-lock-delay
launchctl bootstrap gui/(id -u) ~/Library/LaunchAgents/local.caps-lock-delay.plist
```

Note: remapping Caps Lock (e.g. with Raycast's Hyper Key) overrides this setting.
