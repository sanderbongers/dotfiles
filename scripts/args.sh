#!/usr/bin/env bash

check_args() {
    local description="$1" command="${0##*/}"
    shift
    case "${1:-}" in
        -h | --help)
            printf '%s\n' "Usage: bin/$command" "$description"
            exit 0
            ;;
    esac
    if [[ $# -ne 0 ]]; then
        echo "Usage: bin/$command [--help]" >&2
        exit 2
    fi
}
