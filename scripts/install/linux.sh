#!/usr/bin/env bash

set -euo pipefail

: "${script_dir:?script_dir must be exported by parent script}"

sudo install -d -m 0755 /etc/apt/keyrings

printf '%s\n' \
    "Types: deb" \
    "URIs: http://deb.debian.org/debian/" \
    "Suites: trixie-backports" \
    "Components: main" \
    "Signed-By: /usr/share/keyrings/debian-archive-keyring.pgp" | sudo tee /etc/apt/sources.list.d/backports.sources >/dev/null

curl -fsSL https://download.opensuse.org/repositories/shells:fish/Debian_13/Release.key | sudo tee /etc/apt/keyrings/fish.asc >/dev/null
printf '%s\n' \
    "Types: deb" \
    "URIs: http://download.opensuse.org/repositories/shells:/fish/Debian_13/" \
    "Suites: /" \
    "Signed-By: /etc/apt/keyrings/fish.asc" | sudo tee /etc/apt/sources.list.d/fish.sources >/dev/null

curl -fsSL 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo tee /etc/apt/keyrings/caddy.asc >/dev/null
printf '%s\n' \
    "Types: deb" \
    "URIs: https://dl.cloudsmith.io/public/caddy/stable/deb/debian/" \
    "Suites: any-version" \
    "Components: main" \
    "Signed-By: /etc/apt/keyrings/caddy.asc" | sudo tee /etc/apt/sources.list.d/caddy.sources >/dev/null

curl -fsSL https://downloads.1password.com/linux/keys/1password.asc | sudo tee /etc/apt/keyrings/1password.asc >/dev/null
printf '%s\n' \
    "Types: deb" \
    "URIs: https://downloads.1password.com/linux/debian/$(dpkg --print-architecture)" \
    "Suites: stable" \
    "Components: main" \
    "Architectures: $(dpkg --print-architecture)" \
    "Signed-By: /etc/apt/keyrings/1password.asc" | sudo tee /etc/apt/sources.list.d/1password.sources >/dev/null

if [[ ! -x $(command -v nodejs) ]]; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
fi

echo "Installing packages..."
sudo apt update -y
sudo apt install -y \
    1password-cli \
    bat \
    bind9-dnsutils \
    bsd-mailx \
    build-essential \
    caddy \
    fd-find \
    fish \
    fzf \
    geoipupdate python3-maxminddb \
    git-delta \
    iotop \
    jq \
    keychain \
    msmtp msmtp-mta \
    ncdu \
    nodejs \
    ripgrep \
    sqlite3 \
    stow \
    sysstat \
    tealdeer \
    tmux \
    unbound \
    zoxide

# Backports needed to install Samba >= 4.23.
# Once trixie stable ships >= 4.23, drop this and move samba into the list above.
echo "Installing Samba from backports..."
sudo apt install -y -t trixie-backports samba

echo "Installing Neovim from tarball..."
NVIM_LATEST=$(curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name' || true)
NVIM_CURRENT=$(nvim --version 2>/dev/null | head -1 | awk '{print $2}' || true)
if [[ -z "$NVIM_LATEST" || "$NVIM_LATEST" == "null" ]]; then
    echo "Could not determine latest Neovim version, skipping."
elif [[ "$NVIM_CURRENT" != "$NVIM_LATEST" ]]; then
    sudo rm -rf /opt/nvim-linux-arm64
    curl -fsSL https://github.com/neovim/neovim/releases/download/stable/nvim-linux-arm64.tar.gz | sudo tar -xz -C /opt
    sudo ln -sfn /opt/nvim-linux-arm64 /opt/nvim
    sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
fi

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
"${script_dir}/link.sh"

echo "Linking bat and fd to their Debian binary names..."
mkdir -p ~/.local/bin
ln -sf "$(command -v batcat)" ~/.local/bin/bat
ln -sf "$(command -v fdfind)" ~/.local/bin/fd

echo "Rebuilding bat cache..."
batcat cache --build

if [[ ${SHELL_CHANGED:-false} == true ]]; then
    echo "Changed default shell to Fish, restart terminal to apply changes."
fi
