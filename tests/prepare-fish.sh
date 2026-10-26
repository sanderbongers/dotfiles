#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cat >"$tmp/mock" <<'MOCK'
#!/bin/bash
name="${0##*/}"
echo "$name" >>"$HOME/calls"
if [[ "$name" != trash ]]; then exit 99; fi
if [[ "$TEST_CASE" == failed-trash ]]; then exit 23; fi
/bin/mkdir -p "$HOME/.Trash"
/bin/mv "$1" "$HOME/.Trash/fish"
MOCK
chmod +x "$tmp/mock"

for scenario in absent directory symlink dangling file failed-trash missing-trash; do
    home_dir="$tmp/$scenario"
    fish_dir="$home_dir/.config/fish"
    mkdir -p "$home_dir/.config" "$home_dir/bin"
    for tool in trash grep sudo; do ln -s "$tmp/mock" "$home_dir/bin/$tool"; done
    case "$scenario" in
        directory | failed-trash | missing-trash)
            mkdir "$fish_dir"
            printf 'set -gx EDITOR vim\n' >"$fish_dir/config.fish"
            ;;
        symlink)
            mkdir "$home_dir/managed-fish"
            ln -s "$home_dir/managed-fish" "$fish_dir"
            ;;
        dangling) ln -s "$home_dir/missing-fish" "$fish_dir" ;;
        file) printf 'keep this file\n' >"$fish_dir" ;;
    esac
    if [[ "$scenario" == missing-trash ]]; then unlink "$home_dir/bin/trash"; fi
    status=0
    env HOME="$home_dir" PATH="$home_dir/bin" TEST_CASE="$scenario" script_dir="$repo_dir/scripts" \
        /bin/bash "$repo_dir/scripts/install/macos.sh" </dev/null >"$tmp/output" 2>&1 || status=$?
    case "$scenario" in
        absent | directory | symlink | dangling)
            [[ "$status" == 99 ]]
            grep -Fxq grep "$home_dir/calls"
            case "$scenario" in
                absent) [[ ! -e "$fish_dir" && ! -e "$home_dir/.Trash" ]] ;;
                directory)
                    [[ ! -e "$fish_dir" ]]
                    grep -Fxq 'set -gx EDITOR vim' "$home_dir/.Trash/fish/config.fish"
                    ;;
                symlink | dangling) [[ -L "$fish_dir" && ! -e "$home_dir/.Trash" ]] ;;
            esac
            ;;
        file | failed-trash | missing-trash)
            case "$scenario" in
                file)
                    [[ "$status" == 1 ]]
                    grep -Fxq 'keep this file' "$fish_dir"
                    ;;
                failed-trash) [[ "$status" == 23 ]] ;;
                missing-trash) [[ "$status" == 127 ]] ;;
            esac
            if [[ "$scenario" != file ]]; then
                grep -Fxq 'set -gx EDITOR vim' "$fish_dir/config.fish"
            fi
            if [[ -e "$home_dir/calls" ]] && grep -Eq '^(grep|sudo)$' "$home_dir/calls"; then
                echo 'Preparation failed but system setup continued.' >&2
                exit 1
            fi
            ;;
    esac
    echo "ok - Fish preparation: $scenario"
done
