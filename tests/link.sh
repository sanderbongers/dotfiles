#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
link="$repo_dir/scripts/link.sh"
pass=0
fail=0

check() {
    local desc="$1" got="$2" want="$3"
    if [[ "$got" == "$want" ]]; then
        echo "ok - $desc"
        pass=$((pass + 1))
    else
        echo "FAIL - $desc"
        echo "  got:  $got"
        echo "  want: $want"
        fail=$((fail + 1))
    fi
}

make_fixture_link() {
    local dir="$1"
    mkdir -p "$dir/scripts"
    cp "$repo_dir/scripts/link.sh" "$dir/scripts/link.sh"
    cp "$repo_dir/.stowrc" "$dir/.stowrc"
    cp -R "$repo_dir/stow" "$dir/stow"
    echo "$dir/scripts/link.sh"
}

test_fresh_link() {
    local tmp status=0
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN
    HOME="$tmp" "$link" >/dev/null 2>&1
    HOME="$tmp" "$link" --check >/dev/null 2>&1 || status=$?
    check "fresh link converges" "$status" "0"
    check "fresh link creates .tmux.conf" "$([[ -L "$tmp/.tmux.conf" ]] && echo yes)" "yes"
}

# Packages are auto-discovered from stow/*/. A newly added package must get linked automatically.
test_new_package_auto_discovered() {
    local tmp home flink status=0
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN
    flink="$(make_fixture_link "$tmp/repo")"
    home="$tmp/home"
    mkdir -p "$home" "$tmp/repo/stow/tmp-test-pkg"
    echo "test" >"$tmp/repo/stow/tmp-test-pkg/.tmp-test-rc"
    HOME="$home" "$flink" >/dev/null 2>&1 || status=$?
    check "a package is auto-discovered and linked" "$status" "0"
    check "the new package's file is reachable" "$([[ -f "$home/.tmp-test-rc" ]] && echo yes)" "yes"
}

# On Linux, packages with .linux-ignore are skipped, unmarked packages still link, and the marker file is never linked.
test_linux_ignore_filters_package() {
    local tmp status=0 out
    tmp="$(mktemp -d)"
    trap 'rm -rf "$tmp"' RETURN
    out="$(LINK_SH_OS=Linux HOME="$tmp" "$link" 2>&1)" || status=$?
    check "simulated Linux run exits 0" "$status" "0"
    check "iterm (marked .linux-ignore) is not linked" "$([[ -e "$tmp/.config/iterm2" ]] && echo yes)" ""
    check "an unmarked package still links on simulated Linux" "$([[ -L "$tmp/.tmux.conf" ]] && echo yes)" "yes"
    check "the .linux-ignore marker itself is never linked" "$(printf '%s' "$out" | grep -c '\.linux-ignore')" "0"
}

test_fresh_link
test_new_package_auto_discovered
test_linux_ignore_filters_package

echo "$pass passed, $fail failed"
[[ "$fail" -eq 0 ]]
