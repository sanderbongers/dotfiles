#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fish_config="$repo_dir/stow/fish/.config/fish"

# fish -n validates only its first argument, so check one file per invocation.
shopt -s globstar nullglob
for f in "$fish_config"/**/*.fish; do
    fish -n "$f"
done

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
mkdir -p "$tmp/config" "$tmp/cache" "$tmp/data"
cp -R "$fish_config" "$tmp/config/fish"

# Run twice: the first pass may populate caches, the second must start clean.
for run in 1 2; do
    stderr="$tmp/stderr.$run"
    # __ssh_key_setup_done short-circuits conf.d/ssh.fish so the test shell doesn't run real SSH setup.
    if ! env __ssh_key_setup_done=1 XDG_CONFIG_HOME="$tmp/config" XDG_CACHE_HOME="$tmp/cache" \
        XDG_DATA_HOME="$tmp/data" fish -i -c exit 2>"$stderr" || test -s "$stderr"; then
        cat "$stderr" >&2
        exit 1
    fi
done
