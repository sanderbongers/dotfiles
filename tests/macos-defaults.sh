#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fixture="$tmp/repo"
mkdir -p "$fixture/scripts/macos" "$fixture/config/iterm2" "$tmp/bin" "$tmp/home" "$tmp/apps"

# Resolve fixture apps without relying on installed applications.
# shellcheck disable=SC2016
sed 's|for dir in /System/Applications /Applications; do|for dir in "$TEST_APPS"; do|' \
    "$repo_dir/scripts/macos/apply-defaults.sh" >"$fixture/scripts/macos/apply-defaults.sh"
mkdir "$tmp/apps/ChatGPT.app" "$tmp/apps/Visual Studio Code.app" "$tmp/apps/Claude.app" "$tmp/apps/PhpStorm.app"
cat >"$tmp/bin/mock" <<'MOCK'
#!/bin/bash
name="${0##*/}"
printf '%s %s\n' "$name" "$*" >>"$TEST_LOG"
case "$name:$1:${2:-}" in
    defaults:write:*/com.apple.mail) [[ "$TEST_FAIL" != mail ]] || exit 23 ;;
    defaults:write:com.apple.finder) [[ "$TEST_FAIL" != system ]] || exit 23 ;;
    dockutil:--add:*.app) [[ "$TEST_FAIL" != dock ]] || exit 23 ;;
    dockutil:--add:'') [[ "$*" == *'--type small-spacer'* ]] || exit 24 ;;
esac
exit 0
MOCK
chmod +x "$tmp/bin/mock"
for tool in defaults sudo pmset dockutil killall chflags; do
    ln -s mock "$tmp/bin/$tool"
done
export TEST_LOG="$tmp/calls" TEST_APPS="$tmp/apps"

reject_text() {
    if grep -Fq -- "$1" "$2"; then
        echo "Unexpected output: $1" >&2
        exit 1
    fi
}

run_defaults() {
    local status=0
    printf '%s\n' "$1" >"$fixture/.machine-profile"
    : >"$TEST_LOG"
    env HOME="$tmp/home" PATH="$tmp/bin:/usr/bin:/bin" TEST_FAIL="$2" \
        /bin/bash "$fixture/scripts/macos/apply-defaults.sh" >"$tmp/output" 2>&1 || status=$?
    [[ "$status" == "$3" ]]
    if ((status == 0)); then
        grep -Fxq 'killall Finder' "$TEST_LOG"
    else
        reject_text 'killall Finder' "$TEST_LOG"
    fi
}

run_defaults personal '' 0
grep -Fxq "dockutil --add $TEST_APPS/ChatGPT.app --section apps --no-restart" "$TEST_LOG"
grep -Fxq "dockutil --add $TEST_APPS/Visual Studio Code.app --section apps --no-restart" "$TEST_LOG"
grep -Fq 'Firefox.app' "$tmp/output"
reject_text 'Could not write' "$tmp/output"
mail_domain="$tmp/home/Library/Containers/com.apple.mail/Data/Library/Preferences/com.apple.mail"
grep -Fxq "defaults write $mail_domain AddLinkPreviews -bool false" "$TEST_LOG"

run_defaults work '' 0
grep -Fxq "dockutil --add $TEST_APPS/Claude.app --section apps --no-restart" "$TEST_LOG"
grep -Fxq "dockutil --add $TEST_APPS/PhpStorm.app --section apps --no-restart" "$TEST_LOG"
reject_text 'Could not write' "$tmp/output"

run_defaults personal mail 0
grep -Fq 'com.apple.mail/AddLinkPreviews' "$tmp/output"

run_defaults personal system 23
run_defaults personal dock 23

run_defaults invalid '' 1
grep -Fq 'Invalid .machine-profile' "$tmp/output"
reject_text 'dockutil --remove' "$TEST_LOG"

echo 'ok - macOS defaults: personal, work, mail, system, dock and invalid profile'
