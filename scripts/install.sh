#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly script_dir

case "$(uname)" in
    Linux*)
        source "${script_dir}/_install_linux.sh"
        ;;
    Darwin*)
        source "${script_dir}/_install_macos.sh"
        ;;
esac
