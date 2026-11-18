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
bin/update            # Pull, install and upgrade packages and PhpStorm plugins, relink dotfiles, update Fish plugins
bin/dump-packages     # Save installed Homebrew packages to Brewfiles and PhpStorm plugins to packages/phpstorm
bin/install-packages  # Install missing Homebrew packages and PhpStorm plugins, without upgrading existing ones
bin/doctor            # Check system for potential problems
bin/test              # Run isolated tests in a temporary directory
```

Additionally, `bin/unlink` and `bin/link` can be used to remove and recreate symlinks.

New Homebrew packages go into `packages/homebrew/Brewfile`. Move profile-specific packages to `Brewfile.personal` or
`Brewfile.work`.

For cask updates via `bin/update`, add casks to `HOMEBREW_UPGRADE_GREEDY_CASKS` in `stow/homebrew/.homebrew/brew.env`
and disable their built-in updaters.

Debian packages are in `packages/apt/packages.txt` and `packages/apt/backports.txt`.

## PhpStorm

PhpStorm's settings live in `stow/phpstorm/Library/Application Support/JetBrains/PhpStorm<version>/` and are shared by
both profiles. JetBrains Backup and Sync stays off. Whole folders (`codestyles`, `inspection`, `keymaps`, `colors`,
`templates`, `fileTemplates`) are linked, so new schemes land in the repository. From `options/` only individual
settings files are linked, because the rest is machine state. Add a file there when it holds a setting, then run
`bin/link`.

Plugins are listed in `packages/phpstorm/plugins.txt`. `bin/install-packages` and `bin/update` install missing ones and
skip that step while PhpStorm runs. PhpStorm asks once to accept third-party plugins on its first launch. `bin/doctor`
warns about uncommitted settings and about a newer `PhpStorm*` config folder. After a major upgrade, rename the version
folder in the package with `git mv`, trash the migrated copies in `~/Library/Application Support/JetBrains/` and run
`bin/link`.

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
