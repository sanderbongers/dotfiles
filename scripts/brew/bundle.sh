#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
profile_file="$repo_dir/.machine-profile"
mode="${1:-install}"

# The profile determines which additional Brewfile.<profile> to merge. Prompt for it on install.
case "$mode" in
    check)
        if [[ ! -s "$profile_file" ]]; then
            echo "brew/bundle: machine profile not set, run 'make install'" >&2
            exit 1
        fi
        ;;
    install)
        while [[ ! -s "$profile_file" ]]; do
            read -rp "Is this a personal or work machine? [personal/work] " answer
            case "$answer" in
                personal | work) echo "$answer" >"$profile_file" ;;
                *) echo "brew/bundle: invalid answer '$answer' (choose 'personal' or 'work')" >&2 ;;
            esac
        done
        ;;
    *)
        echo "brew/bundle: unknown mode '$mode' (expected 'check' or 'install')" >&2
        exit 1
        ;;
esac

brewfile="$(cat "$repo_dir/Brewfile" "$repo_dir/Brewfile.$(cat "$profile_file")")"

case "$mode" in
    check)
        echo "$brewfile" | brew bundle check --file=- --no-upgrade --verbose
        ;;
    install)
        echo "$brewfile" | brew bundle check --file=- --no-upgrade ||
            echo "$brewfile" | brew bundle install --file=- --no-upgrade
        ;;
esac
