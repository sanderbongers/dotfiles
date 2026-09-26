#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

install_packages() {
    local manifest="$1"
    shift
    sed '/^[[:space:]]*#/d' "$manifest" | xargs -r sudo apt-get install -y "$@"
}

echo "Installing packages..."
sudo apt-get update
install_packages "$repo_dir/packages/apt/packages.txt" "$@"

echo "Installing packages from backports..."
install_packages "$repo_dir/packages/apt/backports.txt" "$@" -t trixie-backports
