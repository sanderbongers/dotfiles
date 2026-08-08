status is-interactive; or return

# Prefer GNU tools by expanding them to their g-prefixed binaries.
set -l tools /opt/homebrew/opt/*/libexec/gnubin/* /usr/local/opt/*/libexec/gnubin/*
set -q tools[1]; or return

set -l names
for name in (path basename $tools | string match -r '^[a-z0-9.-]+$') # skip names like [
    builtin -q $name; and continue # Keep fish builtins (test, echo, pwd, realpath, ...)
    # Keep own wrapper functions, but not fish's embedded defaults like grep.
    functions -q $name; and string match -q "$__fish_config_dir/*" (functions --details $name); and continue
    contains -- $name $names; or set -a names $name
end
set -q names[1]; or return

set -l pattern '('(string join '|' (string escape --style=regex $names))')'
abbr -a gnubin --regex $pattern --function __gnubin_expand
abbr -a sudo:gnubin --command sudo --regex $pattern --function __gnubin_expand
abbr -a man:gnubin --command man --command gman --regex $pattern --function __gnubin_expand_bare
