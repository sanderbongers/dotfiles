#!/usr/bin/env bash

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
    echo "phpstorm: skipping PhpStorm on $(uname)"
    exit 0
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mode="${1:-install}"
manifest="$repo_dir/packages/phpstorm/plugins.txt"
state_patterns="$repo_dir/packages/phpstorm/state-files.txt"
package_root="$repo_dir/stow/phpstorm/Library/Application Support/JetBrains"
config_root="$HOME/Library/Application Support/JetBrains"
phpstorm="${PHPSTORM_BIN:-/Applications/PhpStorm.app/Contents/MacOS/phpstorm}"

shopt -s nullglob
versions=("$package_root"/PhpStorm*/)
if [[ ${#versions[@]} -ne 1 ]]; then
    echo "phpstorm: expected one PhpStorm* folder in $package_root" >&2
    exit 1
fi
version="$(basename "${versions[0]}")"
package_dir="${versions[0]%/}"
config_dir="$config_root/$version"

# A plugin's ID is only recorded in META-INF/plugin.xml inside its jar.
installed_ids() {
    local entry jar id jars
    for entry in "$config_dir/plugins"/*; do
        if [[ -d $entry ]]; then
            jars=("$entry"/lib/*.jar)
        else
            jars=("$entry")
        fi
        for jar in "${jars[@]}"; do
            [[ $jar == *.jar ]] || continue
            id="$(unzip -p "$jar" META-INF/plugin.xml 2>/dev/null |
                sed -n '/<id>/{s:.*<id>\([^<]*\)</id>.*:\1:p;q;}' || true)"
            if [[ -n $id ]]; then
                echo "$id"
                continue 2
            fi
        done
        echo "phpstorm: no plugin ID found in $entry" >&2
    done | sort -u
}

# Whether an options/ file is listed as machine state.
is_state_file() {
    local pattern
    while IFS= read -r pattern || [[ -n $pattern ]]; do
        pattern="${pattern%%#*}"
        pattern="${pattern%"${pattern##*[![:space:]]}"}"
        # shellcheck disable=SC2254
        [[ -n $pattern ]] && case "$1" in $pattern) return 0 ;; esac
    done <"$state_patterns"
    return 1
}

case "$mode" in
    install)
        installed="$(installed_ids)"
        missing=()
        while IFS= read -r id || [[ -n $id ]]; do
            id="${id%%#*}"
            id="${id%"${id##*[![:space:]]}"}"
            [[ -n $id ]] || continue
            grep -qxF -- "$id" <<<"$installed" || missing+=("$id")
        done <"$manifest"
        if [[ ${#missing[@]} -eq 0 ]]; then
            echo "phpstorm: all plugins are installed"
        elif pgrep -f -- "$phpstorm" >/dev/null; then
            echo "phpstorm: PhpStorm is running, so plugins were not installed." >&2
            echo "phpstorm: quit it and rerun bin/install-packages." >&2
            echo "phpstorm: missing: ${missing[*]}" >&2
        elif [[ ! -x $phpstorm ]]; then
            echo "phpstorm: $phpstorm not found, so plugins were not installed" >&2
            exit 1
        else
            "$phpstorm" installPlugins "${missing[@]}"
        fi
        ;;
    dump)
        # Writing an empty list for an IDE that never ran would erase the manifest.
        if [[ ! -d "$config_dir/plugins" ]]; then
            echo "phpstorm: no plugins folder in $config_dir, leaving $manifest unchanged"
            exit 0
        fi
        installed_ids >"$manifest.tmp"
        mv "$manifest.tmp" "$manifest"
        ;;
    check)
        # Warnings only: the settings are the user's to commit and the folder rename is a one-off.
        problems=0
        if changes="$(git -C "$repo_dir" status --porcelain -- stow/phpstorm packages/phpstorm 2>/dev/null)" &&
            [[ -n $changes ]]; then
            echo "WARN: uncommitted PhpStorm settings changes:" >&2
            echo "  ${changes//$'\n'/$'\n'  }" >&2
            problems=1
        fi
        unclassified=()
        for file in "$config_dir/options"/*; do
            [[ -f $file && ! -L $file ]] || continue
            is_state_file "${file##*/}" || unclassified+=("${file##*/}")
        done
        if [[ ${#unclassified[@]} -gt 0 ]]; then
            echo "WARN: PhpStorm options files that are neither linked nor listed as state: ${unclassified[*]}" >&2
            echo "  Settings: move into stow/phpstorm/.../options and run bin/link." >&2
            echo "  State: add to packages/phpstorm/state-files.txt." >&2
            problems=1
        fi
        for file in "$package_dir"/*.* "$package_dir/options"/*; do
            [[ -f $file ]] || continue
            target="$config_dir/${file#"$package_dir"/}"
            if [[ -L $target && ! -e $target ]] || [[ ! -e $target ]]; then
                echo "WARN: PhpStorm deleted ${target#"$config_dir"/}." >&2
                echo "  It does that when a file's settings are reset to defaults." >&2
                echo "  If that was intended, git rm the file in stow/phpstorm. Otherwise run bin/link." >&2
                problems=1
            elif [[ ! -L $target ]]; then
                echo "WARN: PhpStorm replaced the link ${target#"$config_dir"/} with a real file." >&2
                echo "  Its changes stay out of the repository." >&2
                echo "  Copy the file over the one in stow/phpstorm, trash it here and run bin/link." >&2
                problems=1
            fi
        done
        for dir in "$package_dir"/*/; do
            name="$(basename "$dir")"
            [[ $name == options ]] && continue
            if [[ -d "$config_dir/$name" && ! -L "$config_dir/$name" ]]; then
                echo "WARN: $config_dir/$name is a real folder, so new settings stay out of the repository." >&2
                echo "  Move its contents into stow/phpstorm, trash the folder and run bin/link." >&2
                problems=1
            fi
        done
        for dir in "$config_root"/PhpStorm*/; do
            name="$(basename "$dir")"
            newest="$(printf '%s\n%s\n' "$version" "$name" | sort -V | tail -n 1)"
            if [[ $name != "$version" && $newest == "$name" ]]; then
                echo "WARN: $name is newer than the linked $version." >&2
                echo "  Rename the folder in stow/phpstorm with git mv, trash its migrated copies and run bin/link." >&2
                problems=1
            fi
        done
        [[ $problems -eq 1 ]] || echo "PASS: PhpStorm settings are committed and linked"
        ;;
    *)
        echo "phpstorm: unknown mode '$mode' (expected 'check', 'dump' or 'install')" >&2
        exit 1
        ;;
esac
