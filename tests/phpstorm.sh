#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT HUP INT TERM
fixture="$tmp/repo"
home="$tmp/home"
version=PhpStorm2026.3
package="$fixture/stow/phpstorm/Library/Application Support/JetBrains/$version"
config="$home/Library/Application Support/JetBrains/$version"
mkdir -p "$fixture/scripts/packages" "$fixture/packages/phpstorm" "$package/options" "$package/colors"
mkdir -p "$config/plugins" "$tmp/bin"
cp "$repo_dir/scripts/packages/phpstorm.sh" "$fixture/scripts/packages/"
script="$fixture/scripts/packages/phpstorm.sh"
manifest="$fixture/packages/phpstorm/plugins.txt"
printf '# state\nrecent.xml  # trailing\nair*.xml\n' >"$fixture/packages/phpstorm/state-files.txt"
: >"$package/colors/.gitkeep"
: >"$package/options/project.default.xml"

# unzip reports the jar's file name as the plugin ID, so no real archives are needed.
cat >"$tmp/bin/mock" <<'MOCK'
#!/bin/bash
name="${0##*/}"
printf '%s %s\n' "$name" "$*" >>"$TEST_LOG"
case "$name" in
    uname) echo "${TEST_OS:-Darwin}" ;;
    unzip)
        jar="$2"
        [[ $jar == *'no-id'* ]] && exit 11
        id="${jar##*/}"
        printf '<idea-plugin>\n  <id>%s</id>\n</idea-plugin>\n' "${id%.jar}"
        ;;
    pgrep) exit "${TEST_RUNNING:-1}" ;;
    phpstorm) exit "${TEST_PHPSTORM_STATUS:-0}" ;;
esac
MOCK
chmod +x "$tmp/bin/mock"
for tool in uname unzip pgrep phpstorm; do
    ln -s mock "$tmp/bin/$tool"
done
export TEST_LOG="$tmp/calls" HOME="$home" PATH="$tmp/bin:/usr/bin:/bin" PHPSTORM_BIN="$tmp/bin/phpstorm"
cd "$tmp"

fail() {
    echo "$1" >&2
    cat "$tmp/output" "$TEST_LOG" >&2 || true
    exit 1
}
run() {
    : >"$TEST_LOG"
    "$script" "$@" >"$tmp/output" 2>&1
}

mkdir "$config/plugins/Caddy" "$config/plugins/Caddy/lib" "$config/plugins/Fish Shell" "$config/plugins/Fish Shell/lib"
: >"$config/plugins/Caddy/lib/com.example.caddy.jar"
: >"$config/plugins/Caddy/lib/helper.jar"
: >"$config/plugins/Fish Shell/lib/com.example.fish.jar"
: >"$config/plugins/com.example.single.jar"
mkdir -p "$config/plugins/broken/lib"
: >"$config/plugins/broken/lib/no-id.jar"

run dump
[[ $(cat "$manifest") == $'com.example.caddy\ncom.example.fish\ncom.example.single' ]] ||
    fail 'dump did not write the sorted plugin IDs, or recorded a helper jar and a plugin without ID'
grep -q 'no plugin ID found in .*broken' "$tmp/output" || fail 'dump did not report a plugin without an ID'
echo 'ok - dump writes the sorted IDs of installed plugins and reports plugins without one'

printf '# first line\ncom.example.fish\ncom.example.new\n\ncom.example.other # trailing\n' >"$manifest"
run install
[[ $(grep '^phpstorm ' "$TEST_LOG") == 'phpstorm installPlugins com.example.new com.example.other' ]] ||
    fail 'install did not request exactly the missing plugins'
printf 'com.example.fish\ncom.example.caddy\n' >"$manifest"
run install
grep -q '^phpstorm ' "$TEST_LOG" && fail 'install ran PhpStorm although nothing was missing'
grep -q 'all plugins are installed' "$tmp/output" || fail 'install did not report that nothing was missing'
echo 'ok - install passes only missing plugins to PhpStorm and ignores comments'

printf 'com.example.new\n' >"$manifest"
TEST_RUNNING=0 run install
grep -q '^phpstorm ' "$TEST_LOG" && fail 'install ran PhpStorm while it was running'
grep -q 'PhpStorm is running' "$tmp/output" || fail 'install did not explain the skip while PhpStorm runs'
status=0
TEST_PHPSTORM_STATUS=7 run install || status=$?
[[ $status -eq 7 ]] || fail 'install hid a PhpStorm failure'
echo 'ok - install skips with a message while PhpStorm runs and keeps its failures'

printf 'com.example.keep\n' >"$manifest"
rm -r "$config/plugins"
run dump
[[ $(cat "$manifest") == com.example.keep ]] || fail 'dump erased the manifest for an IDE without a plugins folder'
mkdir "$config/plugins"
echo 'ok - dump leaves the manifest alone when PhpStorm has no plugins folder'

mkdir -p "$config/options"
ln -s "$package/options/project.default.xml" "$config/options/project.default.xml"
git -C "$fixture" init -q
git -C "$fixture" add -A
git -C "$fixture" -c user.name=t -c user.email=t@example.com commit -q -m initial
mkdir -p "$home/Library/Application Support/JetBrains/Daemon"
run check
grep -q '^PASS: PhpStorm settings' "$tmp/output" || fail 'check warned about a clean, linked setup'
echo 'ok - check passes for committed, linked settings'

: >"$config/options/recent.xml"
: >"$config/options/air-sessions.xml"
run check
grep -q '^PASS' "$tmp/output" || fail 'check flagged linked or state files as unclassified'
: >"$config/options/editor.xml"
: >"$config/options/ide.general.xml"
run check
grep -q 'neither linked nor listed as state: .*editor.xml' "$tmp/output" ||
    fail 'check missed an unclassified options file'
grep -q 'ide.general.xml' "$tmp/output" || fail 'check missed a second unclassified file'
grep -q 'recent.xml\|air-sessions' "$tmp/output" && fail 'check flagged a state file'
rm "$config/options/editor.xml" "$config/options/ide.general.xml"
echo 'ok - check flags options files that are neither linked nor listed as state'

rm "$config/options/project.default.xml"
run check
grep -q 'PhpStorm deleted options/project.default.xml' "$tmp/output" || fail 'check missed a deleted settings file'
grep -q 'git rm' "$tmp/output" || fail 'check did not offer the git rm decision'
ln -s "$tmp/nowhere" "$config/options/project.default.xml"
run check
grep -q 'PhpStorm deleted options/project.default.xml' "$tmp/output" || fail 'check missed a dangling link'
rm "$config/options/project.default.xml"
: >"$config/options/project.default.xml"
run check
grep -q 'replaced the link options/project.default.xml' "$tmp/output" ||
    fail 'check missed a link replaced by a real file'
rm "$config/options/project.default.xml"
ln -s "$package/options/project.default.xml" "$config/options/project.default.xml"
run check
grep -q '^PASS' "$tmp/output" || fail 'check warned although all tracked files are linked'
echo 'ok - check explains deleted, dangling and replaced settings files'

printf '<application/>\n' >"$package/options/project.default.xml"
run check
grep -q 'WARN: uncommitted PhpStorm settings changes' "$tmp/output" || fail 'check missed an uncommitted change'
grep -q 'project.default.xml' "$tmp/output" || fail 'check did not name the changed file'
git -C "$fixture" checkout -q -- .
printf 'com.example.fish\n' >"$manifest"
run check
grep -q 'WARN: uncommitted' "$tmp/output" || fail 'check missed a changed plugin list'
git -C "$fixture" checkout -q -- .
echo 'ok - check warns about uncommitted settings and plugin changes'

mkdir "$config/colors"
run check
grep -q 'colors is a real folder' "$tmp/output" || fail 'check missed an unlinked settings folder'
rmdir "$config/colors"
ln -s "$package/colors" "$config/colors"
run check
grep -q '^PASS' "$tmp/output" || fail 'check warned about a linked settings folder'
echo 'ok - check warns when a whole-folder setting is not a link'

jetbrains="$home/Library/Application Support/JetBrains"
mkdir "$jetbrains/PhpStorm2026.4" "$jetbrains/PhpStorm2025.3"
run check
grep -q 'PhpStorm2026.4 is newer than the linked PhpStorm2026.3' "$tmp/output" ||
    fail 'check missed a newer config folder'
grep -q 'PhpStorm2025.3' "$tmp/output" && fail 'check reported an older config folder'
mkdir "$jetbrains/PhpStorm2026.10"
run check
grep -q 'PhpStorm2026.10 is newer' "$tmp/output" || fail 'check compared versions as text instead of numbers'
echo 'ok - check warns about newer config folders only'

TEST_OS=Linux run check
grep -q 'skipping PhpStorm' "$tmp/output" || fail 'the script did not skip on Linux'
grep -q '^phpstorm ' "$TEST_LOG" && fail 'PhpStorm ran on Linux'
mkdir "$fixture/stow/phpstorm/Library/Application Support/JetBrains/PhpStorm2027.1"
status=0
run check || status=$?
[[ $status -ne 0 ]] || fail 'the script accepted two PhpStorm folders in the package'
echo 'ok - the script skips on Linux and rejects an ambiguous package'
