#!/usr/bin/env bash

echo "Updating system..."
sudo apt update -y

echo "Installing packages..."
sudo apt install -y \
    build-essential \
    fish \
    fzf \
    keychain \
    locales \
    nvim \
    stow

if ! command -v cargo &>/dev/null; then
    echo "Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    grep -q cargo ~/.config/fish/config.fish.local || echo "fish_add_path -g ~/.cargo/env.fish" | tee -a ~/.config/fish/config.fish.local
    # shellcheck disable=SC1090
    . ~/.cargo/env.fish
fi

echo "Installing Rust packages..."
cargo install bat fd-find ripgrep git-delta zoxide

echo "Installing Node.js..."
curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt install -y nodejs

if [[ "$LANG" != "en_US.UTF-8" ]]; then
    echo "Setting locale..."
    sudo sed -i 's/^# \(en_US\.UTF-8 UTF-8\)/\1/' /etc/locale.gen
    sudo locale-gen
    sudo update-locale LANG=en_US.UTF-8
fi

if [[ $(basename "$SHELL") != "fish" ]]; then
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
make stow

echo "Rebuilding bat cache..."
bat cache --build

[[ $SHELL_CHANGED ]] && echo "Changed default shell to Fish, restart terminal to apply changes."
