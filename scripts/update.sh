#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$script_dir/.."
platform="$(uname)"

# make update pulls first, so this always runs the newly fetched maintenance code.
case "$platform" in
    Darwin)
        if ! command -v brew >/dev/null || [[ ! -s "$repo_dir/.machine-profile" ]]; then
            echo "Run 'make install' to set up Homebrew and the machine profile first." >&2
            exit 1
        fi
        case "$(cat "$repo_dir/.machine-profile")" in
            personal | work) ;;
            *) echo "Invalid .machine-profile; expected personal or work." >&2; exit 1 ;;
        esac
        "$script_dir/packages/homebrew.sh" install
        ;;
    Linux)
        bash "$script_dir/packages/apt.sh" --no-upgrade
        if ! command -v nvim >/dev/null; then
            bash "$script_dir/packages/neovim.sh"
        fi
        ;;
    *) echo "Unsupported platform: $platform" >&2; exit 1 ;;
esac

"$script_dir/link.sh"
fish -c 'fisher update'

if [[ $platform == Darwin ]]; then
    bat cache --build
else
    batcat cache --build
fi

echo "Dotfiles updated. Review and commit any Fish plugin changes."
