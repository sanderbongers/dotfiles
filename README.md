# .dotfiles

Personal dotfiles and bootstrap scripts for macOS and Linux (Debian).

## Installation

```bash
git clone git@github.com:sanderbongers/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
make install
```

## Update

```bash
make update
```

## Available commands

```text
help             Display help message
install          Install dotfiles and packages
update           Update dotfiles and packages
link             Symlink all dotfiles to home directory
unlink           Remove all dotfile symlinks
bundle-install   Install Homebrew packages from global Brewfile
bundle-dump      Write installed Homebrew packages into global Brewfile
```
