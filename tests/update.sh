#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
fixture="$tmp/repo"
mkdir -p "$fixture/scripts/packages" "$fixture/homebrew" "$tmp/bin" "$tmp/home"
cp "$repo_dir/Makefile" "$fixture/Makefile"
cp "$repo_dir/scripts/update.sh" "$fixture/scripts/"
cp "$repo_dir/scripts/upgrade.sh" "$fixture/scripts/"
cp "$repo_dir/scripts/packages/apt.sh" "$fixture/scripts/packages/"
cp "$repo_dir/scripts/packages/homebrew.sh" "$fixture/scripts/packages/"
printf 'personal\n' >"$fixture/.machine-profile"
printf 'brew "bat"\n' >"$fixture/homebrew/Brewfile"
printf 'brew "fish"\n' >"$fixture/homebrew/Brewfile.personal"

cat >"$tmp/bin/mock" <<'MOCK'
#!/bin/bash
name="${0##*/}"
printf '%s %s\n' "$name" "$*" >>"$TEST_LOG"
case "$name" in
    uname) echo "${TEST_OS:-Darwin}" ;;
    git)
        case "$1" in
            pull) exit "${TEST_PULL_STATUS:-0}" ;;
        esac
        ;;
    brew)
        cat >/dev/null
        if [[ "$2" == check ]]; then exit 1; fi
        exit "${TEST_PACKAGE_STATUS:-0}"
        ;;
    sudo)
        if [[ "$2" == autoremove ]]; then
            grep -qx install-neovim "$TEST_LOG" || exit 1
        fi
        exit "${TEST_PACKAGE_STATUS:-0}"
        ;;
    fish)
        grep -qx link "$TEST_LOG" || exit 1
        exit "${TEST_FISH_STATUS:-0}"
        ;;
esac
MOCK
chmod +x "$tmp/bin/mock"
for command in uname git brew sudo bat batcat nvim fish; do
    ln -s mock "$tmp/bin/$command"
done
cat >"$fixture/scripts/link.sh" <<'LINK'
#!/bin/bash
echo link >>"$TEST_LOG"
LINK
chmod +x "$fixture/scripts/link.sh"
cat >"$fixture/scripts/packages/neovim.sh" <<'NEOVIM'
#!/bin/bash
echo install-neovim >>"$TEST_LOG"
exit "${TEST_NEOVIM_STATUS:-0}"
NEOVIM

export TEST_LOG="$tmp/commands.log"
export HOME="$tmp/home" PATH="$tmp/bin:/usr/bin:/bin"
cd "$fixture"

run_maintenance() {
    : >"$TEST_LOG"
    env "$@" make "${target:-update}" >"$tmp/output" 2>&1
}
expect_failure() {
    if run_maintenance "$@"; then
        echo "Expected ${target:-update} to fail: $*" >&2
        cat "$tmp/output" "$TEST_LOG"
        exit 1
    fi
}
expect_log() { grep -Fq -- "$1" "$TEST_LOG" || { cat "$tmp/output" "$TEST_LOG"; exit 1; }; }
reject_log() { if grep -Fq -- "$1" "$TEST_LOG"; then cat "$TEST_LOG"; exit 1; fi; }

run_maintenance
expect_log 'git pull origin main'
expect_log 'brew bundle install --file=- --no-upgrade'
expect_log 'link'
expect_log 'fish -c fisher update'
expect_log 'bat cache --build'
reject_log 'sudo '
echo 'ok - macOS updates plugins after linking and builds cache'

run_maintenance TEST_OS=Linux
expect_log 'sudo apt-get install -y --no-upgrade bat'
expect_log 'sudo apt-get install -y --no-upgrade -t trixie-backports samba'
expect_log 'batcat cache --build'
expect_log 'fish -c fisher update'
reject_log 'install-neovim'
reject_log 'autoremove'
reject_log 'brew '
rm "$tmp/bin/nvim"
run_maintenance TEST_OS=Linux
expect_log 'install-neovim'
echo 'ok - Linux preserves installed packages and Neovim; installs missing Neovim'

expect_failure TEST_PULL_STATUS=1
reject_log 'brew '
reject_log 'link'
reject_log 'fish '
echo 'ok - pull failures stop maintenance'

expect_failure TEST_PACKAGE_STATUS=1
reject_log 'link'
reject_log 'bat cache'
reject_log 'fish '
expect_failure TEST_FISH_STATUS=1
expect_log 'fish -c fisher update'
reject_log 'bat cache'
echo 'ok - Fish command failures stop maintenance'

target=upgrade
run_maintenance HOMEBREW_BUNDLE_NO_UPGRADE=1
expect_log 'brew bundle install --file=- --upgrade'
expect_log 'bat cache --build'
reject_log 'git '
reject_log 'link'
reject_log 'fish '
reject_log 'sudo '
echo 'ok - macOS explicitly upgrades the Brewfile packages'

run_maintenance TEST_OS=Linux
expect_log 'sudo apt-get update'
expect_log 'sudo apt-get upgrade --with-new-pkgs -y'
expect_log 'install-neovim'
expect_log 'batcat cache --build'
reject_log 'brew '
reject_log 'git '
reject_log 'link'
reject_log 'fish '
reject_log 'dist-upgrade'
expect_log 'sudo apt-get autoremove -y'
echo 'ok - Linux upgrades APT packages and Neovim before dependency cleanup'

expect_failure TEST_PACKAGE_STATUS=1
reject_log 'bat cache'
expect_failure TEST_OS=Linux TEST_PACKAGE_STATUS=1
reject_log 'autoremove'
reject_log 'install-neovim'
reject_log 'batcat cache'
expect_failure TEST_OS=Linux TEST_NEOVIM_STATUS=1
reject_log 'autoremove'
reject_log 'batcat cache'
echo 'ok - upgrade failures stop subsequent work'

rm "$fixture/.machine-profile"
expect_failure
reject_log 'brew '
target=update
expect_failure
reject_log 'brew '
reject_log 'link'
reject_log 'fish '
echo 'ok - package failures or missing setup stop maintenance'
