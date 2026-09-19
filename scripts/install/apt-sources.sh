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

if [[ ! -x $(command -v nodejs) ]]; then
    echo "Installing Node.js..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
    sudo bash nodesource_setup.sh
fi
