#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
fixture="$tmp/repo"
mkdir -p "$fixture/scripts/packages" "$fixture/packages/homebrew" "$tmp/bin" "$tmp/home"
mkdir -p "$fixture/bin"
cp "$repo_dir/bin/update" "$fixture/bin/"
cp "$repo_dir/scripts/args.sh" "$fixture/scripts/"
mkdir -p "$fixture/packages/apt"
printf 'atop\nbat\n' >"$fixture/packages/apt/packages.txt"
printf 'samba\n' >"$fixture/packages/apt/backports.txt"
cp "$repo_dir/scripts/packages/apt.sh" "$fixture/scripts/packages/"
cp "$repo_dir/scripts/packages/homebrew.sh" "$fixture/scripts/packages/"
printf 'personal\n' >"$fixture/.machine-profile"
printf 'brew "bat"\n' >"$fixture/packages/homebrew/Brewfile"
printf 'brew "fish"\n' >"$fixture/packages/homebrew/Brewfile.personal"

cat >"$tmp/bin/mock" <<'MOCK'
#!/bin/bash
name="${0##*/}"
printf '%s %s\n' "$name" "$*" >>"$TEST_LOG"
case "$name" in
    uname) echo "${TEST_OS:-Darwin}" ;;
    git)
        case "$1" in
            pull)
                if [[ ${TEST_REPLACE_SCRIPT:-0} == 1 ]]; then
                    printf '%s\n' '#!/bin/bash' 'echo updated-script >> "$TEST_LOG"' > bin/update
                fi
                exit "${TEST_PULL_STATUS:-0}"
                ;;
        esac
        ;;
    brew)
        if [[ "$1" == bundle ]]; then cat >/dev/null; fi
        if [[ "$1" == "${TEST_FAIL_BREW_COMMAND:-}" ]]; then exit 1; fi
        exit "${TEST_PACKAGE_STATUS:-0}"
        ;;
    sudo)
        if [[ "$2" == "${TEST_FAIL_APT_COMMAND:-}" ]]; then exit 1; fi
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
for command in uname git brew sudo bat batcat fish mas code; do
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
cd "$tmp"

run_maintenance() {
    : >"$TEST_LOG"
    env "$@" "$fixture/bin/update" >"$tmp/output" 2>&1
}
expect_failure() {
    if run_maintenance "$@"; then
        echo "Expected update to fail: $*" >&2
        cat "$tmp/output" "$TEST_LOG"
        exit 1
    fi
}
expect_log() { grep -Fq -- "$1" "$TEST_LOG" || {
    cat "$tmp/output" "$TEST_LOG"
    exit 1
}; }
reject_log() { if grep -Fq -- "$1" "$TEST_LOG"; then
    cat "$TEST_LOG"
    exit 1
fi; }
expect_once() { [[ $(grep -Fxc -- "$1" "$TEST_LOG") == 1 ]] || {
    cat "$TEST_LOG"
    exit 1
}; }
expect_order() {
    local previous=0 line entry
    for entry in "$@"; do
        line=$(grep -nFx -- "$entry" "$TEST_LOG" | cut -d: -f1)
        if [[ -z "$line" ]] || ((line <= previous)); then
            cat "$TEST_LOG"
            exit 1
        fi
        previous=$line
    done
}

run_maintenance
expect_order 'git pull origin main' 'mas upgrade' 'brew bundle install --file=- --no-upgrade' \
    'brew upgrade --no-ask' 'code --update-extensions' 'link' 'fish -c fisher update' 'bat cache --build'
expect_once 'brew bundle install --file=- --no-upgrade'
expect_once 'bat cache --build'
reject_log 'sudo '
echo 'ok - macOS pulls, installs missing packages, upgrades, links and updates plugins; builds cache once'

run_maintenance TEST_OS=Linux
expect_once 'sudo apt-get install -y --no-upgrade atop bat'
expect_once 'sudo apt-get install -y --no-upgrade -t trixie-backports samba'
expect_order 'git pull origin main' 'sudo apt-get update' 'sudo apt-get upgrade --with-new-pkgs -y' \
    'install-neovim' 'sudo apt-get autoremove -y' 'link' 'fish -c fisher update' 'batcat cache --build'
expect_once 'sudo apt-get update'
expect_once 'batcat cache --build'
reject_log 'brew '
reject_log 'dist-upgrade'
echo 'ok - Linux installs manifest packages, upgrades APT and Neovim, cleans dependencies and updates dotfiles'

expect_failure TEST_PULL_STATUS=1
reject_log 'brew '
reject_log 'link'
reject_log 'fish '
echo 'ok - pull failures stop maintenance'

expect_failure TEST_PACKAGE_STATUS=1
reject_log 'link'
reject_log 'bat cache'
reject_log 'fish '
expect_failure TEST_FAIL_BREW_COMMAND=upgrade
expect_log 'brew bundle install --file=- --no-upgrade'
expect_log 'brew upgrade --no-ask'
reject_log 'code '
reject_log 'link'
reject_log 'fish '
reject_log 'bat cache'
echo 'ok - package installation and upgrade failures stop maintenance'

expect_failure TEST_FISH_STATUS=1
expect_log 'fish -c fisher update'
reject_log 'bat cache'
echo 'ok - Fish command failures stop maintenance'

expect_failure TEST_OS=Linux TEST_PACKAGE_STATUS=1
reject_log 'sudo apt-get upgrade'
reject_log 'install-neovim'
reject_log 'autoremove'
reject_log 'link'
reject_log 'batcat cache'
expect_failure TEST_OS=Linux TEST_FAIL_APT_COMMAND=upgrade
expect_once 'sudo apt-get install -y --no-upgrade atop bat'
expect_log 'sudo apt-get upgrade --with-new-pkgs -y'
reject_log 'autoremove'
reject_log 'install-neovim'
reject_log 'link'
reject_log 'batcat cache'
expect_failure TEST_OS=Linux TEST_NEOVIM_STATUS=1
reject_log 'autoremove'
reject_log 'link'
reject_log 'batcat cache'
echo 'ok - Linux package and Neovim failures stop subsequent work'

rm "$fixture/.machine-profile"
expect_failure
reject_log 'brew '
reject_log 'link'
reject_log 'fish '
echo 'ok - package failures or missing setup stop maintenance'

run_maintenance TEST_REPLACE_SCRIPT=1
expect_log 'updated-script'
reject_log 'link'
echo 'ok - update runs the newly pulled script instead of continuing the old version'
