#!/usr/bin/env bash

set -euo pipefail

: "${script_dir:?script_dir must be exported by parent script}"

if ! grep -qs pam_tid.so /etc/pam.d/sudo_local; then
    echo "Enabling Touch ID for sudo..."
    if [[ ! -f /etc/pam.d/sudo_local ]]; then
        sudo install -m 444 -o root -g wheel /dev/null /etc/pam.d/sudo_local
    fi
    echo "auth    sufficient    pam_tid.so" | sudo tee -a /etc/pam.d/sudo_local
fi

if [[ ! -x $(command -v brew) ]]; then
    echo "Installing Homebrew..."
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ ! -x $(command -v fish) ]]; then
    echo "Installing Fish..."
    brew install fish
fi

if [[ $(basename "$SHELL") != "fish" ]]; then
    echo "Setting Fish as default shell..."
    grep -q "$(which fish)" /etc/shells || which fish | sudo tee -a /etc/shells
    chsh -s "$(which fish)"
    SHELL_CHANGED=true
fi

if [ -d ~/.config/fish ] && [ ! -L ~/.config/fish ]; then
    echo "Removing default Fish configuration..."
    rm -rf ~/.config/fish
fi

echo "Stowing dotfiles..."
[[ -x $(command -v stow) ]] || brew install stow
"${script_dir}/link.sh"

echo "Installing Homebrew packages..."
"${script_dir}/brew/bundle.sh" install

echo "Rebuilding bat cache..."
bat cache --build

echo "Applying adopted macOS defaults (commented checklist; no-op until you opt settings in)..."
"${script_dir}/macos/apply-defaults.sh"

repo_dir="${script_dir}/.."
ssh_url="git@github.com:sanderbongers/dotfiles.git"
if [[ "$(git -C "$repo_dir" remote get-url origin)" != "$ssh_url" ]] &&
    ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "Switching git remote to SSH..."
    git -C "$repo_dir" remote set-url origin "$ssh_url"
fi

if [[ ${SHELL_CHANGED:-false} == true ]]; then
    echo "Changed default shell to Fish, restart terminal to apply changes."
fi
