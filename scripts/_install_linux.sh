#!/usr/bin/env bash

set -euo pipefail

sudo install -d -m 0755 /etc/apt/keyrings

printf '%s\n' \
    "Types: deb" \
    "URIs: http://deb.debian.org/debian/" \
    "Suites: trixie-backports" \
    "Components: main" \
    "Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp" | sudo tee /etc/apt/sources.list.d/backports.sources >/dev/null

curl -fsSL https://download.opensuse.org/repositories/shells:fish/Debian_13/Release.key | sudo gpg --dearmor --yes -o /etc/apt/keyrings/fish.gpg
printf '%s\n' \
    "Types: deb" \
    "URIs: http://download.opensuse.org/repositories/shells:/fish/Debian_13/" \
    "Suites: /" \
    "Signed-By: /etc/apt/keyrings/fish.gpg" | sudo tee /etc/apt/sources.list.d/fish.sources >/dev/null

curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor --yes -o /etc/apt/keyrings/caddy.gpg
printf '%s\n' \
    "Types: deb" \
    "URIs: https://dl.cloudsmith.io/public/caddy/stable/deb/debian/" \
    "Suites: any-version" \
    "Components: main" \
    "Signed-By: /etc/apt/keyrings/caddy.gpg" | sudo tee /etc/apt/sources.list.d/caddy.sources >/dev/null

if [[ ! -x $(command -v nodejs) ]]; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
fi

echo "Installing packages..."
sudo apt update -y
sudo apt install -y \
    bat \
    bind9-dnsutils \
    build-essential \
    caddy \
    fd-find \
    fish \
    fzf \
    git-delta \
    iotop \
    jq \
    keychain \
    msmtp msmtp-mta \
    neovim \
    nodejs \
    ripgrep \
    sqlite3 \
    stow \
    sysstat \
    tealdeer \
    tmux \
    unbound \
    zoxide

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

echo "Linking bat and fd to their Debian binary names..."
sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd

test -f /usr/share/fish/completions/bat.fish || bat --completion fish | sudo tee /usr/share/fish/completions/bat.fish >/dev/null
test -f /usr/share/fish/completions/ripgrep.fish || rg --generate=complete-fish | sudo tee /usr/share/fish/completions/ripgrep.fish >/dev/null

echo "Rebuilding bat cache..."
bat cache --build

if [[ ${SHELL_CHANGED:-false} == true ]]; then
    echo "Changed default shell to Fish, restart terminal to apply changes."
fi
