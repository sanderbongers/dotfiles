status is-interactive; or return

# Add abbreviations so typed GNU tool names expand to their g-prefixed counterparts. Scripts still get the BSD tools.
for gnubin in /opt/homebrew/opt/*/libexec/gnubin /usr/local/opt/*/libexec/gnubin
    for tool in $gnubin/*
        set -l name (path basename $tool)
        string match -qr '^[a-z0-9.-]+$' -- $name; or continue # skip names like [
        builtin -q $name; and continue # Keep fish builtins (test, echo, pwd, realpath, ...)
        # Keep own wrapper functions, but not fish's embedded defaults like grep
        functions -q $name; and string match -q "$__fish_config_dir/*" (functions --details $name); and continue
        command -q g$name; or continue # gnubin also holds non-tool entries like man page dirs
        abbr -a $name g$name
        abbr -a sudo:$name --command sudo --regex (string escape --style=regex $name) g$name
    end
end

if command -q ggrep
    abbr -a grep 'ggrep --color=auto'
    abbr -a sudo:grep --command sudo --regex grep 'ggrep --color=auto'
end
