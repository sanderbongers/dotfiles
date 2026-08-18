status is-interactive; or return

if command -q zoxide
    # Load shell integration, cached until zoxide is updated.
    set -l cache $__fish_cache_dir/zoxide_init.fish
    if not test -f $cache; or test (command -s zoxide) -nt $cache
        set -l tmp $cache.$fish_pid.tmp
        zoxide init fish >$tmp
        and command mv -f $tmp $cache; or command rm -f $tmp
    end
    test -f $cache; and source $cache
end
