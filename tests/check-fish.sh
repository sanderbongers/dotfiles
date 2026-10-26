#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
fixture="$tmp/repo"
config="$fixture/stow/fish/.config/fish"
mkdir -p "$fixture/scripts" "$config/functions/nested" "$tmp/host/config/fish"
cp "$repo_dir/scripts/check-fish.sh" "$fixture/scripts/"
printf 'do not modify\n' >"$tmp/host/sentinel"
cat >"$config/config.fish" <<EOFISH
if set -q DOTFILES_LEAK_TEST
    echo 'Inherited caller environment' >&2
    exit 1
end
if test \$HOME = '$tmp/host'
    echo 'Inherited caller home' >&2
    exit 1
end
for directory in \$XDG_CONFIG_HOME \$XDG_RUNTIME_DIR
    if not test (path dirname \$directory) = (path dirname \$HOME)
        echo 'State directory escaped the temporary fixture' >&2
        exit 1
    end
end
echo \$HOME >> '$tmp/startups'
echo 'fixture only' > \$HOME/fish-startup-marker
EOFISH
run_check() {
    HOME="$tmp/host" XDG_CONFIG_HOME="$tmp/host/config" DOTFILES_LEAK_TEST=yes \
        bash "$fixture/scripts/check-fish.sh" "$@" >"$tmp/output" 2>&1
}
run_check --syntax-only
[[ ! -e "$tmp/startups" ]]
run_check
[[ $(wc -l <"$tmp/startups") -eq 2 ]]
[[ $(sort -u "$tmp/startups" | wc -l) -eq 1 ]]
[[ $(cat "$tmp/host/sentinel") == 'do not modify' ]]
[[ ! -e "$tmp/host/fish-startup-marker" ]]
IFS= read -r fixture_home <"$tmp/startups"
[[ ! -e "$fixture_home" ]]
printf 'if\n' >"$config/functions/nested/broken.fish"
if run_check; then
    echo 'Nested Fish syntax error was not detected.' >&2
    exit 1
fi
rm "$config/functions/nested/broken.fish"
printf 'echo startup-error >&2\n' >>"$config/config.fish"
if run_check; then
    echo 'Fish startup stderr was not detected.' >&2
    exit 1
fi
grep -q 'startup-error' "$tmp/output"
echo 'ok - Fish checks isolate home and state, run twice, clean up and detect syntax and startup errors'
