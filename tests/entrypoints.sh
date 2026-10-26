#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fixture="$tmp/repo with spaces"
mkdir -p "$fixture/bin" "$fixture/scripts/macos" "$fixture/scripts/packages" "$fixture/scripts/install" "$tmp/bin"
cp "$repo_dir"/bin/* "$fixture/bin/"
cp "$repo_dir/scripts/args.sh" "$fixture/scripts/"
export TEST_LOG="$tmp/calls"
for script in link macos/apply-defaults packages/homebrew install/macos install/linux; do
    cat >"$fixture/scripts/$script.sh" <<'STUB'
#!/bin/bash
printf '%s %s\n' "${BASH_SOURCE[0]##*/}" "$*" >> "$TEST_LOG"
exit "${TEST_STATUS:-0}"
STUB
done
cat >"$tmp/bin/uname" <<'UNAME'
#!/bin/bash
echo "${TEST_OS:-Darwin}"
UNAME
cat >"$tmp/bin/defaults" <<'DEFAULTS'
#!/bin/bash
printf 'defaults %s\n' "$*" >>"$TEST_LOG"
exit "${TEST_STATUS:-0}"
DEFAULTS
chmod +x "$tmp/bin/uname" "$tmp/bin/defaults"
export PATH="$tmp/bin:$PATH"
cd "$tmp"
for entry in "$fixture"/bin/*; do
    : >"$TEST_LOG"
    "$entry" --help >"$tmp/help"
    grep -q 'Usage: bin/' "$tmp/help"
    [[ ! -s "$TEST_LOG" ]]
    if "$entry" --unknown >/dev/null 2>&1; then
        echo "Unexpected argument accepted by $entry" >&2
        exit 1
    fi
    [[ ! -s "$TEST_LOG" ]]
    case "${entry##*/}" in
        doctor | test | update | upgrade | snapshot-macos) continue ;;
    esac
    "$entry"
    case "${entry##*/}" in
        unlink) expected='link.sh --unlink' ;;
        link) expected='link.sh ' ;;
        install-packages) expected='homebrew.sh install' ;;
        dump-packages) expected='homebrew.sh dump' ;;
        install) expected='macos.sh ' ;;
        *) expected="${entry##*/}.sh " ;;
    esac
    [[ $(cat "$TEST_LOG") == "$expected" ]]
    result=0
    TEST_STATUS=23 "$entry" || result=$?
    [[ $result -eq 23 ]]
done
: >"$TEST_LOG"
TEST_OS=Linux "$fixture/bin/install"
[[ $(cat "$TEST_LOG") == 'linux.sh ' ]]
: >"$TEST_LOG"
"$fixture/bin/snapshot-macos" >"$tmp/output"
[[ $(cat "$TEST_LOG") == $'defaults read\ndefaults -currentHost read' ]]
result=0
TEST_STATUS=23 "$fixture/bin/snapshot-macos" >"$tmp/output" || result=$?
[[ $result -eq 23 ]]
# The language server sends stdin and supplies the file's directory as a search path.
if command -v shellcheck >/dev/null; then
    for entry in "$repo_dir"/bin/*; do
        shellcheck --external-sources --source-path="$repo_dir/bin" - <"$entry"
    done
fi

echo 'ok - all entry points dispatch correctly, handle help and preserve failures outside the repository'
