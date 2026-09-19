#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$(uname)" in
    Darwin)
        "$script_dir/packages/homebrew.sh" upgrade
        bat cache --build
        ;;
    Linux)
        sudo apt-get update
        sudo apt-get upgrade --with-new-pkgs -y
        bash "$script_dir/packages/neovim.sh"
        sudo apt-get autoremove -y
        batcat cache --build
        ;;
    *) echo "Unsupported platform: $(uname)" >&2; exit 1 ;;
esac
