#!/usr/bin/env bash

set -euo pipefail

if [[ "$SHELL" != *fish ]]; then
    curl -fsSL https://download.opensuse.org/repositories/shells:fish/Debian_13/Release.key | gpg --dearmor | sudo tee /etc/apt/keyrings/shells_fish.gpg >/dev/null
    printf '%s\n' \
        "Types: deb" \
        "URIs: http://download.opensuse.org/repositories/shells:/fish/Debian_13/" \
        "Suites: /" \
        "Components:" \
        "Signed-By: /etc/apt/keyrings/shells_fish.gpg" | sudo tee /etc/apt/sources.list.d/shells:fish.sources >/dev/null
fi

if [[ ! -x $(command -v nodejs) ]]; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
fi

echo "Installing packages..."
sudo apt update -y
sudo apt install -y \
    build-essential \
    fish \
    fzf \
    keychain \
    neovim \
    nodejs \
    stow

if [[ "$LANG" != "en_US.UTF-8" ]]; then
    echo "Setting locale..."
    sudo sed -i 's/^# \(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
    sudo locale-gen
    sudo update-locale LANG=en_US.UTF-8
    sudo timedatectl set-timezone Europe/Amsterdam
fi

if [[ "$SHELL" != *fish ]]; then
    echo "Setting Fish as default shell..."
    grep -q "$(which fish)" /etc/shells || which fish | sudo tee -a /etc/shells
    chsh -s "$(which fish)"
    SHELL_CHANGED=true
fi

if [ ! -L ~/.config/fish ]; then
    echo "Removing default Fish configuration..."
    rm -rf ~/.config/fish
fi

echo "Stowing dotfiles..."
make link

if [[ ! -x $(command -v cargo) ]]; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    grep -q cargo ~/.config/fish/config.fish.local || echo "fish_add_path -g ~/.cargo/env.fish" | tee -a ~/.config/fish/config.fish.local
    # shellcheck disable=SC1090
    if [[ "$SHELL" == *fish ]]; then
        . ~/.cargo/env.fish
    else
        . ~/.cargo/env
    fi
fi

echo "Installing Rust packages..."
cargo install bat fd-find ripgrep git-delta zoxide

echo "Rebuilding bat cache..."
bat cache --build

[[ $SHELL_CHANGED ]] && echo "Changed default shell to Fish, restart terminal to apply changes."
