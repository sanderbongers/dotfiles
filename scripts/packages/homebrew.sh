#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
    echo "homebrew: skipping Homebrew on $(uname)"
    exit 0
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
profile_file="$repo_dir/.machine-profile"
mode="${1:-install}"

# The profile determines which additional Brewfile.<profile> to merge. Prompt for it on install.
case "$mode" in
    check | dump | upgrade)
        if [[ ! -s "$profile_file" ]]; then
            echo "homebrew: machine profile not set, run 'make install'" >&2
            exit 1
        fi
        ;;
    install)
        while [[ ! -s "$profile_file" ]]; do
            read -rp "Is this a personal or work machine? [personal/work] " answer
            case "$answer" in
                personal | work) echo "$answer" >"$profile_file" ;;
                *) echo "homebrew: invalid answer '$answer' (choose 'personal' or 'work')" >&2 ;;
            esac
        done
        ;;
    *)
        echo "homebrew: unknown mode '$mode' (expected 'check', 'dump', 'install', or 'upgrade')" >&2
        exit 1
        ;;
esac

brewfile="$(cat "$repo_dir/homebrew/Brewfile" "$repo_dir/homebrew/Brewfile.$(cat "$profile_file")")"

case "$mode" in
    check)
        echo "$brewfile" | brew bundle check --file=- --no-upgrade --verbose
        ;;
    install)
        echo "$brewfile" | brew bundle check --file=- --no-upgrade ||
            echo "$brewfile" | brew bundle install --file=- --no-upgrade
        ;;
    dump)
        dump="$(brew bundle dump --file=- --no-restart)"
        echo "$dump" | awk -v shared="$repo_dir/homebrew/Brewfile" \
            -v profile="$repo_dir/homebrew/Brewfile.$(cat "$profile_file")" '
            BEGIN {
                # Entries already in this profile stay here if the dumped line is unchanged.
                while ((getline line < profile) > 0) {
                    if (line !~ /^#/) in_profile[line] = 1
                }
                close(profile)

                # Rebuild both files, even if one ends up with no entries.
                printf "" > profile
                printf "" > shared
            }
            /^#/ {
                desc = $0 "\n"
                next
            }
            {
                target = ($0 in in_profile) ? profile : shared
                printf "%s%s\n", desc, $0 > target
                desc = ""
            }'
        ;;
    upgrade)
        # Install missing Brewfile packages...
        echo "$brewfile" | brew bundle install --file=- --no-upgrade
        # ... but upgrade using brew upgrade, because brew bundle ignores the HOMEBREW_UPGRADE_GREEDY_CASKS setting.
        brew upgrade
        if command -v code >/dev/null; then
            code --update-extensions
        fi
        ;;
esac
