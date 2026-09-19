#!/usr/bin/env bash

set -euo pipefail

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

