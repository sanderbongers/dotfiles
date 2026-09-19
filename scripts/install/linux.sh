#!/usr/bin/env bash

set -euo pipefail

: "${script_dir:?script_dir must be exported by parent script}"

bash "${script_dir}/install/apt-sources.sh"

bash "${script_dir}/packages/apt.sh"

bash "${script_dir}/packages/neovim.sh"

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
