#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly repo_dir

# LINK_SH_OS lets tests simulate Linux filtering.
os="${LINK_SH_OS:-$(uname)}"
case "$os" in
    Darwin | Linux) ;;
    *)
        echo "link.sh: unsupported OS $os" >&2
        exit 1
        ;;
esac

# Packages are auto-discovered from stow/*/.
# A package marked with a .linux-ignore file (e.g.  php-cs-fixer) is skipped on Linux.
packages=()
for dir in "$repo_dir"/stow/*/; do
    [[ "$os" == Linux && -e "$dir.linux-ignore" ]] && continue
    packages+=("$(basename "$dir")")
done

# Run from the repo root so Stow reads .stowrc.
cd "$repo_dir"

case "${1:-}" in
    --check) stow -n --verbose --restow "${packages[@]}" ;;
    --unlink) stow --verbose --delete "${packages[@]}" ;;
    *) stow --verbose --restow "${packages[@]}" ;;
esac
