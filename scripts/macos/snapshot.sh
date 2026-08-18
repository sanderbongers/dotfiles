#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
out_dir="$repo_dir/baseline/$(date +%Y%m%d-%H%M%S)"

echo "Snapshotting current macOS defaults into $out_dir"

mkdir -p "$out_dir"
defaults read >"$out_dir/defaults.txt"
defaults -currentHost read >"$out_dir/defaults-currenthost.txt"
