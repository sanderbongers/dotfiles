#!/usr/bin/env bash
set -euo pipefail

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null || pwd
}

pick_linter() {
  local root
  root="$(repo_root)"

  for linter in \
    "$root/node_modules/.bin/markdownlint-cli2" \
    "$root/node_modules/.bin/markdownlint"
  do
    [[ -x "$linter" ]] && printf '%s\n' "$linter" && return
  done

  command -v markdownlint-cli2 2>/dev/null ||
    command -v markdownlint 2>/dev/null ||
    return 1
}

collect_files() {
  local root
  root="$(repo_root)"

  (
    cd "$root"
    {
      git diff --name-only --diff-filter=ACMRTUXB HEAD -- '*.md' 2>/dev/null || true
      git diff --cached --name-only --diff-filter=ACMRTUXB -- '*.md' 2>/dev/null || true
      git ls-files --others --exclude-standard -- '*.md' 2>/dev/null || true
    } | awk 'NF' | sort -u
  )
}

main() {
  local linter
  local -a files=()

  if (($# > 0)); then
    files=("$@")
  else
    mapfile -t files < <(collect_files)
  fi

  if ((${#files[@]} == 0)); then
    echo "No Markdown files to lint."
    return 0
  fi

  linter="$(pick_linter)" || {
    echo "No supported markdownlint binary was found." >&2
    echo "Install markdownlint-cli2 or markdownlint." >&2
    return 1
  }

  "$linter" "${files[@]}"
}

main "$@"
