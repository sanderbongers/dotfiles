#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fish_config="$repo_dir/stow/fish/.config/fish"
fish_bin="$(command -v fish)" || { echo 'Fish is required to check the configuration.' >&2; exit 1; }
case "${1:-}" in
    '' | --syntax-only) ;;
    *) echo 'Usage: scripts/check-fish.sh [--syntax-only]' >&2; exit 2 ;;
esac

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM HUP
mkdir -p "$tmp/home" "$tmp/config" "$tmp/runtime"
chmod 700 "$tmp/runtime"
cp -R "$fish_config" "$tmp/config/fish"
cd "$tmp/home"

run_fish() {
    env -i HOME="$tmp/home" PATH="$PATH" TERM=dumb LANG=C.UTF-8 TMPDIR="$tmp" \
        XDG_CONFIG_HOME="$tmp/config" XDG_RUNTIME_DIR="$tmp/runtime" \
        FISH_UNIT_TESTS_RUNNING=1 "$fish_bin" "$@"
}

# fish -n validates only its first argument, so check one file per invocation.
while IFS= read -r -d '' file; do
    run_fish --no-config -n "$file"
done < <(find "$tmp/config/fish" -type f -name '*.fish' -print0)
[[ ${1:-} != --syntax-only ]] || exit 0

# Run twice: the first pass may populate caches, the second must start clean.
for _ in 1 2; do
    if ! run_fish -i -c exit 2>"$tmp/stderr" || test -s "$tmp/stderr"; then
        cat "$tmp/stderr" >&2
        exit 1
    fi
done
