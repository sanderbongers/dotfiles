status is-interactive; or return

# Prefer GNU tools by expanding them to their g-prefixed binaries.
# Caches the generated abbrs until a formula or wrapper changes.
set -l cache $__fish_cache_dir/gnubin.fish
if not test -f $cache
        or test /opt/homebrew/opt -nt $cache
        or test /usr/local/opt -nt $cache
        or test $__fish_config_dir/functions -nt $cache
    set -l tools /opt/homebrew/opt/*/libexec/gnubin/* /usr/local/opt/*/libexec/gnubin/*

    set -l names
    for name in (path basename $tools | string match -r '^[a-z0-9.-]+$') # Skip names like [
        # Keep fish builtins (echo, pwd, realpath, test, ...)
        builtin -q $name; and continue
        # Keep own wrapper functions, but not fish's embedded defaults like grep.
        functions -q $name; and string match -q "$__fish_config_dir/*" (functions --details $name); and continue
        contains -- $name $names; or set -a names $name
    end

    set -l tmp $cache.$fish_pid.tmp
    begin
        if set -q names[1]
            set -l pattern '('(string join '|' (string escape --style=regex $names))')'
            printf '%s\n' \
                "abbr -a gnubin --regex '$pattern' --function __gnubin_expand" \
                "abbr -a sudo:gnubin --command sudo --regex '$pattern' --function __gnubin_expand" \
                "abbr -a man:gnubin --command man --command gman --regex '$pattern' --function __gnubin_expand_bare"
        else
            echo -n
        end
    end >$tmp
    and command mv -f $tmp $cache; or command rm -f $tmp
end
test -f $cache; and source $cache
