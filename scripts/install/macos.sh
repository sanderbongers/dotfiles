#!/usr/bin/env bash

set -euo pipefail

: "${script_dir:?script_dir must be exported by parent script}"

fish_dir="$HOME/.config/fish"
if [[ -e "$fish_dir" && ! -L "$fish_dir" ]]; then
    if [[ ! -d "$fish_dir" ]]; then
        echo "$fish_dir is not a directory. Move it aside before running bin/install." >&2
        exit 1
    fi
    trash "$fish_dir"
    echo "Moved the previous Fish configuration to Trash."
fi

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

echo "Stowing dotfiles..."
[[ -x $(command -v stow) ]] || brew install stow
"${script_dir}/link.sh"

echo "Installing Homebrew packages..."
"${script_dir}/packages/homebrew.sh" install

mariadb_conf_dir="$(brew --prefix)/etc/my.cnf.d"
if [[ -d "$mariadb_conf_dir" ]]; then
    echo "Configuring MariaDB..."
    mariadb_conf="$(cd "${script_dir}/../config/mariadb" && pwd)/bind-localhost.cnf"
    if [[ ! "$mariadb_conf" -ef "${mariadb_conf_dir}/bind-localhost.cnf" ]]; then
        ln -sf "$mariadb_conf" "${mariadb_conf_dir}/bind-localhost.cnf"
        echo "Restart MariaDB to apply: brew services restart mariadb"
    fi
fi

echo "Configuring unbound..."
unbound_src="${script_dir}/../config/unbound"
unbound_etc="$(brew --prefix)/etc/unbound"
if [[ -f "${unbound_etc}/unbound.conf" && ! -L "${unbound_etc}/unbound.conf" ]]; then
    echo "Backing up existing unbound.conf to unbound.conf.default..."
    mv "${unbound_etc}/unbound.conf" "${unbound_etc}/unbound.conf.default"
fi
ln -sf "${unbound_src}/unbound.conf" "${unbound_etc}/unbound.conf"
if [[ ! -f "${unbound_etc}/unbound.local.conf" ]]; then
    echo "Copying unbound.local.conf.example to unbound.local.conf..."
    cp "${unbound_src}/unbound.local.conf.example" "${unbound_etc}/unbound.local.conf"
fi
[[ -f "${unbound_etc}/unbound_control.key" ]] || unbound-control-setup
sudo brew services restart unbound

if [[ ! -f /etc/resolver/test ]]; then
    echo "Routing .test domains to local resolver..."
    sudo install -d -m 755 /etc/resolver
    printf 'nameserver 127.0.0.1\n' | sudo tee /etc/resolver/test >/dev/null
fi

echo "Switching Wi-Fi DNS to local unbound..."
sudo networksetup -setdnsservers Wi-Fi 127.0.0.1
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder || true
if ! dscacheutil -q host -a name example.com | grep -q ip_address; then
    echo "Resolution failed after switching DNS. Reverting Wi-Fi to DHCP DNS..."
    sudo networksetup -setdnsservers Wi-Fi empty
    echo "Fill in ${unbound_etc}/unbound.local.conf, then rerun:"
    echo "  sudo networksetup -setdnsservers Wi-Fi 127.0.0.1"
fi

echo "Rebuilding bat cache..."
bat cache --build

echo "Applying macOS defaults..."
"${script_dir}/macos/apply-defaults.sh"

repo_dir="${script_dir}/.."
ssh_url="git@github.com:sanderbongers/dotfiles.git"
if [[ "$(git -C "$repo_dir" remote get-url origin)" != "$ssh_url" ]] &&
    ssh -o BatchMode=yes -o ConnectTimeout=5 -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "Switching git remote to SSH..."
    git -C "$repo_dir" remote set-url origin "$ssh_url"
fi

if [[ ${SHELL_CHANGED:-false} == true ]]; then
    echo "Changed default shell to Fish. Restart terminal to apply."
fi
