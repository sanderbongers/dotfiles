#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly script_dir

case "$(uname)" in
    Linux*)
        source "${script_dir}/install/linux.sh"
        ;;
    Darwin*)
        source "${script_dir}/install/macos.sh"
        ;;
esac
