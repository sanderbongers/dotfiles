#!/usr/bin/env bash

set -euo pipefail

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

if [[ ! -e /etc/apt/sources.list.d/docker.list && ! -e /etc/apt/sources.list.d/docker.sources ]]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc >/dev/null
    sudo chmod 0644 /etc/apt/keyrings/docker.asc
    printf '%s\n' \
        "Types: deb" \
        "URIs: https://download.docker.com/linux/debian" \
        "Suites: trixie" \
        "Components: stable" \
        "Architectures: $(dpkg --print-architecture)" \
        "Signed-By: /etc/apt/keyrings/docker.asc" | sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null
fi

if [[ ! -x $(command -v nodejs) ]]; then
    echo "Installing Node.js..."
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT
    curl -fsSL https://deb.nodesource.com/setup_lts.x -o "$tmp_dir/nodesource_setup.sh"
    sudo bash "$tmp_dir/nodesource_setup.sh"
fi
