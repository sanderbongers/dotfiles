#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fixture="$tmp/repo"
mkdir -p "$fixture/scripts/packages" "$fixture/packages" "$fixture/bin" "$tmp/bin" "$tmp/home"
cp "$repo_dir/bin/doctor" "$fixture/bin/"
cp "$repo_dir/scripts/args.sh" "$repo_dir/scripts/link.sh" "$repo_dir/scripts/check-fish.sh" "$fixture/scripts/"
cp "$repo_dir/scripts/packages/homebrew.sh" "$fixture/scripts/packages/"
cp -R "$repo_dir/packages/apt" "$fixture/packages/"
mkdir -p "$fixture/packages/homebrew" "$fixture/stow/fish/.config/fish" "$tmp/home/.config"
printf 'brew "fish"\n' >"$fixture/packages/homebrew/Brewfile"
: >"$fixture/packages/homebrew/Brewfile.personal"
printf 'personal\n' >"$fixture/.machine-profile"
printf 'set -g fish_greeting\n' >"$fixture/stow/fish/.config/fish/config.fish"
ln -s "$fixture/stow/fish/.config/fish" "$tmp/home/.config/fish"
cat >"$tmp/bin/mock" <<'MOCK'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$HOME/calls"
case "${0##*/}" in
    uname) echo "${TEST_OS:-Darwin}" ;;
    stow) [[ "$1" == -n ]] ;;
    brew)
        cat > /dev/null
        [[ "$1 $2" == 'bundle check' ]] || exit 99
        exit "${TEST_PACKAGES_STATUS:-0}"
        ;;
    dpkg-query)
        if [[ "$*" == *samba* && ${TEST_MISSING:-0} == 1 ]]; then
            echo config-files
        else
            echo installed
        fi
        ;;
    fish) [[ "$1" == --no-config && "$2" == -n ]] || exit 99 ;;
    *) exit 99 ;;
esac
MOCK
chmod +x "$tmp/bin/mock"
for name in uname stow brew dpkg-query fish sudo apt-get chsh defaults; do
    ln -s mock "$tmp/bin/$name"
done
export PATH="$tmp/bin:/usr/bin:/bin" HOME="$tmp/home"
cd "$tmp"
"$fixture/bin/doctor" >"$tmp/output" 2>&1
grep -q 'PASS: Dotfile links' "$tmp/output"
grep -q 'PASS: Homebrew packages' "$tmp/output"
TEST_OS=Linux "$fixture/bin/doctor" >"$tmp/output" 2>&1
grep -q 'PASS: Debian packages' "$tmp/output"
if grep -q 'Homebrew' "$tmp/output"; then
    echo 'Doctor reported Homebrew checks on Linux.' >&2
    exit 1
fi
if TEST_PACKAGES_STATUS=1 "$fixture/bin/doctor" >"$tmp/output" 2>&1; then
    echo 'Doctor missed missing Homebrew packages.' >&2
    exit 1
fi
grep -q 'PASS: Fish syntax' "$tmp/output"
if TEST_OS=Linux TEST_MISSING=1 "$fixture/bin/doctor" >"$tmp/output" 2>&1; then
    echo 'Doctor missed an incompletely installed Debian package.' >&2
    exit 1
fi
grep -q 'samba' "$tmp/output"
grep -q 'PASS: Fish syntax' "$tmp/output"
rm "$HOME/.config/fish"
if "$fixture/bin/doctor" >"$tmp/output" 2>&1; then
    echo 'Doctor missed absent links despite a successful Stow dry run.' >&2
    exit 1
fi
grep -q 'Missing or incorrect link' "$tmp/output"
grep -q 'PASS: Homebrew packages' "$tmp/output"
[[ ! -e "$HOME/.config/fish" ]]
mkdir -p "$HOME/.config/fish"
cp "$fixture/stow/fish/.config/fish/config.fish" "$HOME/.config/fish/"
if "$fixture/bin/doctor" >"$tmp/output" 2>&1; then
    echo 'Doctor accepted a copied file instead of a managed link.' >&2
    exit 1
fi
rm "$HOME/.config/fish/config.fish"
rmdir "$HOME/.config/fish"
ln -s "$fixture/stow/fish/.config/fish" "$HOME/.config/fish"
printf 'invalid\n' >"$fixture/.machine-profile"
cp "$HOME/calls" "$tmp/earlier-calls"
: >"$HOME/calls"
if "$fixture/bin/doctor" >"$tmp/output" 2>&1; then
    echo 'Doctor accepted an invalid profile.' >&2
    exit 1
fi
if grep -q '^brew ' "$HOME/calls"; then
    echo 'Homebrew was queried with an invalid profile.' >&2
    exit 1
fi
grep -q 'PASS: Fish syntax' "$tmp/output"
if grep -Eq '^(sudo|apt-get|chsh|defaults) ' "$HOME/calls" "$tmp/earlier-calls"; then
    echo 'Doctor attempted a system change.' >&2
    exit 1
fi

echo 'ok - doctor reports platform coverage and failures without repairs, and continues independent checks'
