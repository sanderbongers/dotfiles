# Dotfiles

Personal dotfiles for macOS and (to a lesser extent) Debian. Managed with GNU Stow.

## Installation

```fish
xcode-select --install
git clone https://github.com/sanderbongers/dotfiles.git ~/Developer/dotfiles
cd ~/Developer/dotfiles
bin/install
```

The first run asks for the profile (`personal` or `work`), which is then saved to `.machine-profile`. Restart iTerm2
after installation.

Existing Fish configuration is moved to Trash. Symlinks are left untouched.

## Commands

```fish
bin/update            # Pull remote changes, relink dotfiles, install missing packages and update Fish plugins
bin/upgrade           # Upgrade packages
bin/dump-packages     # Save installed Homebrew packages to Brewfiles
bin/install-packages  # Install missing Homebrew packages, without upgrading existing ones
bin/doctor            # Check system for potential problems
bin/test              # Run isolated tests in a temporary directory
```

Additionally, `bin/unlink` and `bin/link` can be used to remove and recreate symlinks.

New Homebrew packages go into `packages/homebrew/Brewfile`. Move profile-specific packages to `Brewfile.personal` or
`Brewfile.work`.

For cask updates via `bin/upgrade`, add casks to `HOMEBREW_UPGRADE_GREEDY_CASKS` in `stow/homebrew/.homebrew/brew.env`
and disable their built-in updaters.

Debian packages are in `packages/apt/packages.txt` and `packages/apt/backports.txt`.

## macOS preferences

Edit `scripts/macos/apply-defaults.sh`, then run `bin/apply-macos-defaults`. Protected app preferences require Full Disk
Access for iTerm2.

To find potential settings to save: run `bin/snapshot-macos` before and after a UI change and compare snapshots in
`baseline/`.

### Removing the Caps Lock delay

```fish
# Activate
bin/link
if launchctl print gui/(id -u)/local.caps-lock-delay >/dev/null 2>&1
    echo "Caps Lock delay agent is already loaded."
else
    launchctl bootstrap gui/(id -u) ~/Library/LaunchAgents/local.caps-lock-delay.plist
end
```

```fish
# Deactivate
launchctl bootout gui/(id -u)/local.caps-lock-delay
reboot
```

Note: Remapping Caps Lock (e.g. with Raycast's Hyper Key) overrides this setting.
