#!/usr/bin/env bash

set -euo pipefail

echo "Installing packages..."
sudo apt-get update
sudo apt-get install -y "$@" \
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

# Trixie's Samba is older than the required 4.23. Once it ships >= 4.23, samba can be moved up.
# Backports needed to install Samba >= 4.23.
echo "Installing Samba from backports..."
sudo apt-get install -y "$@" -t trixie-backports samba
